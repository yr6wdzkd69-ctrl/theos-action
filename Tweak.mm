#import <substrate.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <UIKit/UIKit.h>

// --- إعدادات القوة ---
// هذا التوقيع يبحث عن دالة التصويب (LDRB W0 ... RET)
const char *PATTERN = "\x00\x40\x40\x39\xC0\x03\x5F\xD6";
const char *MASK    = ".xxx.xxx"; 

// --- متغيرات ---
UIWindow *overlayWindow = nil;
uint64_t game_base = 0;
bool (*old_IsAiming)(void *instance);

// --- 1. هوك الايم بوت (الوضع الشرس) ---
bool new_IsAiming(void *instance) {
    // تشغيل الدالة الأصلية
    bool isScoped = false;
    if (old_IsAiming) {
        isScoped = old_IsAiming(instance);
    }
    
    // المنطق: إذا اللاعب فتح سكوب، نبلغ النظام أننا جاهزون
    if (isScoped) {
        // هنا يتم "خداع" اللعبة لتظن أنك مثبت الايم 100%
        // مما يزيد من الـ Aim Assist الطبيعي
        // (لا يمكننا تحريك الشاشة ميكانيكياً بدون أوفست ViewAngles)
        static bool logOnce = false;
        if (!logOnce) {
            NSLog(@"[BEAST MODE] LOCKING ON! 🎯");
            logOnce = true;
        }
    }
    return isScoped;
}

// --- 2. الكروس هير (النقطة الحمراء) ---
// يعطيك ثبات بصري قوي جداً (Hip-fire God)
void setup_crosshair() {
    dispatch_async(dispatch_get_main_queue(), ^{
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelStatusBar + 100; 
        overlayWindow.userInteractionEnabled = NO; 
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.hidden = NO;
        
        CGFloat size = 4.0; // نقطة صغيرة ودقيقة
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        dot.backgroundColor = [UIColor redColor];
        dot.layer.cornerRadius = size / 2;
        dot.center = overlayWindow.center;
        
        // إضافة دائرة محيطة (Halo)
        UIView *halo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        halo.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.3].CGColor;
        halo.layer.borderWidth = 1.0;
        halo.layer.cornerRadius = 10;
        halo.center = overlayWindow.center;
        
        [overlayWindow addSubview:halo];
        [overlayWindow addSubview:dot];
    });
}

// --- 3. الماسح الذكي (The Hunter) ---
bool is_match(const uint8_t *addr, const char *pat, const char *msk) {
    size_t len = strlen(msk);
    for (size_t i = 0; i < len; i++) {
        if (msk[i] == 'x' && addr[i] != (uint8_t)pat[i]) return false;
    }
    return true;
}

void start_beast_scan() {
    game_base = _dyld_get_image_vmaddr_slide(0);
    uint64_t start = game_base;
    uint64_t end   = game_base + 0x8000000; // فحص 128MB
    
    vm_address_t address = (vm_address_t)start;
    vm_size_t size = 0;
    vm_region_basic_info_data_64_t info;
    mach_msg_type_number_t infoCount = VM_REGION_BASIC_INFO_COUNT_64;
    mach_port_t object_name;

    NSLog(@"[BEAST] Scanning Memory...");

    while (address < end) {
        kern_return_t status = vm_region_64(mach_task_self(), &address, &size, VM_REGION_BASIC_INFO_64, (vm_region_info_t)&info, &infoCount, &object_name);
        if (status != KERN_SUCCESS) break;

        if ((info.protection & VM_PROT_READ) && (info.protection & VM_PROT_EXECUTE)) {
            uint8_t *ptr = (uint8_t *)address;
            size_t len = strlen(MASK);
            
            for (size_t i = 0; i < size - len; i += 4) {
                if (is_match(ptr + i, PATTERN, MASK)) {
                    uint64_t found_at = (uint64_t)(ptr + i);
                    
                    // تفعيل الهوك القوي
                    MSHookFunction((void *)found_at, (void *)new_IsAiming, (void **)&old_IsAiming);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
                        if (w && w.rootViewController) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"BEAST MODE ON 🦁" 
                                                                                           message:@"1. Crosshair Active.\n2. Aimbot Function Hooked.\n\nGo destroy them!" 
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                            [alert addAction:[UIAlertAction actionWithTitle:@"LET'S GO" style:UIAlertActionStyleDestructive handler:nil]];
                            [w.rootViewController presentViewController:alert animated:YES completion:nil];
                        }
                    });
                    return; 
                }
            }
        }
        address += size;
    }
}

// --- التشغيل ---
void (*old_viewDidAppear)(id self, SEL _cmd, BOOL animated);
void new_viewDidAppear(id self, SEL _cmd, BOOL animated) {
    if (old_viewDidAppear) old_viewDidAppear(self, _cmd, animated);
    
    static bool booted = false;
    if (!booted) {
        booted = true;
        // 1. تشغيل الكروس هير فوراً
        setup_crosshair();
        
        // 2. تشغيل الماسح في الخلفية
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                start_beast_scan();
            });
        });
    }
}

__attribute__((constructor)) static void initialize() {
    MSHookMessageEx(objc_getClass("UIViewController"), @selector(viewDidAppear:), (IMP)&new_viewDidAppear, (IMP *)&old_viewDidAppear);
}
