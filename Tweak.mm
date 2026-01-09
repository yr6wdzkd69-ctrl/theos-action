#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- إعدادات الهاك ---
// الأوفستات التي استخرجناها سابقاً
#define OFF_INIT   0x952694   
#define OFFSET_IS_AIMING_FIELD  0x10

// --- متغيرات ---
uint64_t final_base_address = 0;
void *myPlayer = NULL;
void (*old_Init)(void *instance, void *world, void *player);

// --- دالة البحث الذكي (Smart Finder) ---
// هذه الدالة تبحث عن "الهدف" مهما كان اسمه
uint64_t get_smart_base_address() {
    uint32_t count = _dyld_image_count();
    uint64_t candidate_addr = 0;
    
    for (uint32_t i = 0; i < count; i++) {
        const char *cName = _dyld_get_image_name(i);
        if (!cName) continue;
        
        NSString *name = [NSString stringWithUTF8String:cName];
        
        // الأولوية 1: UnityFramework (الأكثر دقة)
        if ([name containsString:@"UnityFramework"]) {
            return _dyld_get_image_vmaddr_slide(i);
        }
        
        // الأولوية 2: اسم اللعبة الرئيسي
        if ([name containsString:@"CallOfDuty"] && !candidate_addr) {
            candidate_addr = _dyld_get_image_vmaddr_slide(i);
        }
    }
    
    // إذا لم نجد Unity، نستخدم عنوان اللعبة
    if (candidate_addr != 0) return candidate_addr;
    
    // الحل الأخير: الملف رقم 0 (الرئيسي دائماً)
    return _dyld_get_image_vmaddr_slide(0);
}

// --- الهوك (Init) ---
void new_Init(void *instance, void *world, void *player) {
    if (instance != NULL) {
        myPlayer = instance;
    }
    if (old_Init) {
        old_Init(instance, world, player);
    }
}

// --- المؤقت (Loop) ---
void main_loop() {
    if (myPlayer != NULL) {
        // قراءة الذاكرة (Memory Read)
        // لن تسبب كراش إلا إذا كان المؤشر خطأ
        bool isScoped = *(bool*)((uint64_t)myPlayer + OFFSET_IS_AIMING_FIELD);
        
        if (isScoped) {
            // كود تجريبي: هزاز خفيف عند السكوب للتأكد
             // UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
             // [gen impactOccurred];
             NSLog(@"[ScopeBot] AIM ACTIVE 🎯");
        }
    }
}

// --- التشغيل ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. البحث عن العنوان
        final_base_address = get_smart_base_address();
        uint64_t target_init_addr = final_base_address + OFF_INIT;

        // 2. رسالة التشخيص (قبل الهوك)
        // هذه الرسالة ستخبرنا هل العنوان صحيح أم صفر
        NSString *msg = [NSString stringWithFormat:@"Base: 0x%llx\nTarget Init: 0x%llx\n\nClick OK to Inject.", final_base_address, target_init_addr];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Smart Injector" 
                                                                       message:msg 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"INJECT NOW" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            // 3. الحقن يتم فقط بعد ضغط الزر (لتجنب كراش البداية)
            MSHookFunction((void *)target_init_addr, (void *)new_Init, (void **)&old_Init);
            
            // تشغيل اللوب
            [NSTimer scheduledTimerWithTimeInterval:0.1 
                                             target:[NSBlockOperation blockOperationWithBlock:^{ main_loop(); }] 
                                           selector:@selector(main) 
                                           userInfo:nil 
                                            repeats:YES];
        }]];
        
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
            [w.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}
