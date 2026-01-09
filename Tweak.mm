#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>

// --- تعريف التوقيع (The Signature) ---
// نبحث عن: LDRB W0, [X0, #0x10] followed by RET
// Hex: 00 40 40 39 C0 03 5F D6
const uint8_t SCAN_PATTERN[] = { 0x00, 0x40, 0x40, 0x39, 0xC0, 0x03, 0x5F, 0xD6 };

// --- متغيرات ---
uint64_t game_base = 0;
uint64_t game_size = 0;

// تعريف دالة الهوك
bool (*old_get_IsAiming)(void *instance);

// الهوك الجديد
bool new_get_IsAiming(void *instance) {
    // 1. نشغل الأصلية لنعرف الحقيقة
    bool isAiming = old_get_IsAiming(instance);
    
    // 2. إذا كان فاتح سكوب، نبلغك
    if (isAiming) {
        NSLog(@"[Auto-Bot] SCOPE ON! 🎯");
    }
    
    return isAiming;
}

// --- دالة البحث (Scanner) ---
uint64_t find_pattern(uint64_t start, uint64_t length, const uint8_t *pattern, size_t pattern_len) {
    uint8_t *pStart = (uint8_t *)start;
    for (uint64_t i = 0; i < length - pattern_len; i += 4) { // نبحث كل 4 بايت للسرعة
        if (memcmp(pStart + i, pattern, pattern_len) == 0) {
            return start + i;
        }
    }
    return 0;
}

// --- التشغيل ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. تحديد مكان و حجم اللعبة
        game_base = _dyld_get_image_vmaddr_slide(0);
        
        // تقدير حجم اللعبة (عادة 100-200 ميجا)، سنبحث في أول 150 ميجا
        // البحث الكامل قد يطول، سنبحث في القسم التنفيذي __TEXT
        const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(0);
        game_size = 0x8000000; // بحث في نطاق 128MB تقريباً
        
        NSLog(@"[Auto-Bot] Scanning memory for IsAiming signature...");

        // 2. البدء في البحث
        uint64_t found_addr = find_pattern(game_base, game_size, SCAN_PATTERN, sizeof(SCAN_PATTERN));
        
        if (found_addr != 0) {
            // وجدناها!
            MSHookFunction((void *)found_addr, (void *)new_get_IsAiming, (void **)&old_get_IsAiming);
            
            // رسالة نجاح
             UIWindow *w = [[UIApplication sharedApplication] keyWindow];
             if (w && w.rootViewController) {
                 NSString *msg = [NSString stringWithFormat:@"Target Found at: 0x%llx\n(Offset: 0x%llx)\nHooked Successfully! 💉", found_addr, found_addr - game_base];
                 
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AUTO SCANNER ✅" 
                                                                                message:msg 
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                 [alert addAction:[UIAlertAction actionWithTitle:@"GO" style:UIAlertActionStyleDefault handler:nil]];
                 [w.rootViewController presentViewController:alert animated:YES completion:nil];
             }
        } else {
            // فشل البحث
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
             if (w && w.rootViewController) {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Scan Failed ❌" 
                                                                                message:@"Could not find the function signature.\nThe bytes might have changed." 
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                 [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                 [w.rootViewController presentViewController:alert animated:YES completion:nil];
             }
        }
    });
}
