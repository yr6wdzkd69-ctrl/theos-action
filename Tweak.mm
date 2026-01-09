#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- نستخدم فقط رقم السكوب (المشتبه به البريء) ---
#define OFF_IS_AIMING   0x96D4E8

// --- Globals ---
uint64_t unity_base = 0;
bool (*old_IsAiming)(void* instance);

// --- البحث عن اللعبة ---
intptr_t get_unity_slide() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "UnityFramework")) {
            return _dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// --- الهوك الجديد (فقط على السكوب) ---
bool new_IsAiming(void *instance) {
    // 1. تشغيل الدالة الأصلية لنعرف الحقيقة
    bool isScoped = old_IsAiming(instance);
    
    // 2. إذا اللاعب فتح سكوب، نرسل رسالة "صامتة" للكونسول
    // لن نقوم بأي أكشن، فقط نختبر هل يحدث كراش أم لا
    if (isScoped) {
        // Safe Code: Just passing through
    }

    return isScoped;
}

// --- البناء ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        if (unity_base != 0) {
            uint64_t addr_IsAiming = unity_base + OFF_IS_AIMING;
            
            // --- الإجراء الحاسم ---
            // سنقوم بعمل هوك على IsAiming فقط.
            // لقد حذفنا Update لأنه سبب الكراش.
            
            MSHookFunction((void *)addr_IsAiming, (void *)new_IsAiming, (void **)&old_IsAiming);
            
            // رسالة النجاح
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Scope Test" 
                                                                           message:@"Game Started? Try Aiming Now.\nIf no crash -> We Won!" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Test" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}
