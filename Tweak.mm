#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- الأوفستات ---
#define OFF_INIT   0x952694   

// --- متغيرات ---
uint64_t unity_base = 0;
void (*old_Init)(void *instance, void *world, void *player);

// --- البحث الحذر (بدون تخمين) ---
uint64_t find_unity_strictly() {
    uint32_t count = _dyld_image_count();
    
    for (uint32_t i = 0; i < count; i++) {
        const char *cName = _dyld_get_image_name(i);
        if (!cName) continue;
        
        NSString *name = [NSString stringWithUTF8String:cName];
        
        // نبحث عن Unity فقط
        if ([name containsString:@"UnityFramework"]) {
            return _dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0; // إذا لم نجده، نرجع صفر (فشل)
}

// --- الهوك ---
void new_Init(void *instance, void *world, void *player) {
    if (old_Init) old_Init(instance, world, player);
    
    // فقط للتأكد أن الهاك اشتغل
    static bool msgShown = false;
    if (!msgShown) {
        msgShown = true;
        NSLog(@"[ScopeBot] WE ARE IN! Player found at %p", instance);
    }
}

// --- التشغيل ---
__attribute__((constructor)) static void initialize() {
    // ننتظر 5 ثواني فقط
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. البحث الصارم
        unity_base = find_unity_strictly();
        
        if (unity_base == 0) {
            // [حالة الأمان]
            // لم نجد الملف -> نوقف الهاك ونعرض رسالة بدل الكراش
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Safety Stop 🛑" 
                                                                           message:@"Could not find 'UnityFramework'.\nHack aborted to prevent crash." 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
            return;
        }

        // 2. إذا وجدنا الملف، نحقن
        uint64_t addr_Init = unity_base + OFF_INIT;
        MSHookFunction((void *)addr_Init, (void *)new_Init, (void **)&old_Init);
        
        // رسالة نجاح
        UIAlertController *success = [UIAlertController alertControllerWithTitle:@"Success ✅" 
                                                                       message:@"Unity Found & Hooked!\nGo play." 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [success addAction:[UIAlertAction actionWithTitle:@"GO" style:UIAlertActionStyleDefault handler:nil]];
        
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
            [w.rootViewController presentViewController:success animated:YES completion:nil];
        }
    });
}
