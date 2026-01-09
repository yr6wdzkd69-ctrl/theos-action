#import <substrate.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- متغيرات ---
uint64_t game_base = 0;

// --- ماسح النصوص (The String Hunter) ---
// هذا الكود يبحث عن كلمة "IsAiming" داخل ملفات اللعبة
// المنطقة هذه (TEXT, cstring) قابلة للقراءة 100% ولا تسبب كراش
void scan_for_strings() {
    game_base = _dyld_get_image_vmaddr_slide(0);
    
    // الحصول على رأس الملف
    const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(0);
    
    // البحث عن قسم النصوص (__cstring)
    unsigned long size = 0;
    uint8_t *ptr = getsectiondata(header, "__TEXT", "__cstring", &size);
    
    if (ptr == NULL) {
        // محاولة ثانية مع قسم const
        ptr = getsectiondata(header, "__TEXT", "__const", &size);
    }

    if (ptr == NULL) {
        NSLog(@"[MYTH] Could not find String section.");
        return;
    }

    NSLog(@"[MYTH] Scanning String Section (Size: %lu)...", size);

    // الكلمة التي نبحث عنها
    const char *target = "get_IsAiming";
    size_t target_len = strlen(target);

    uint64_t found_at = 0;

    // بداية البحث
    for (size_t i = 0; i < size - target_len; i++) {
        if (memcmp(ptr + i, target, target_len) == 0) {
            found_at = (uint64_t)(ptr + i);
            break; // وجدناها!
        }
    }

    // عرض النتيجة
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
            if (found_at != 0) {
                // نجاح!
                NSString *msg = [NSString stringWithFormat:@"STRING FOUND!\nText At: 0x%llx\nOffset: 0x%llx\n\nTake a screenshot!", found_at, found_at - game_base];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"✅ WE FOUND IT" 
                                                                               message:msg 
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Send Pic" style:UIAlertActionStyleDefault handler:nil]];
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            } else {
                // فشل
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Found" 
                                                                               message:@"The text 'get_IsAiming' is hidden or encrypted." 
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}

__attribute__((constructor)) static void initialize() {
    // ننتظر 10 ثواني
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // تشغيل البحث في الخلفية
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            scan_for_strings();
        });
    });
}
