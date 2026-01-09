#import <substrate.h>
#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>

// --- التوقيع المحسن (Signature) ---
// نبحث عن دالة IsAiming بدقة أكبر
// النمط: LDRB W0, [X0, #0x10] -> RET
const uint8_t SCAN_PATTERN[] = { 0x00, 0x40, 0x40, 0x39, 0xC0, 0x03, 0x5F, 0xD6 };
const char *MASK = "xxxxxxxx"; // x = يجب التطابق

// --- متغيرات ---
uint64_t game_base = 0;
bool (*old_get_IsAiming)(void *instance);

// --- الهوك ---
bool new_get_IsAiming(void *instance) {
    if (old_get_IsAiming) {
        bool isAiming = old_get_IsAiming(instance);
        if (isAiming) {
            NSLog(@"[MYTH] Scope Detected! 🎯");
        }
        return isAiming;
    }
    return false;
}

// --- دالة البحث الآمن (Safe Scanner) ---
uint64_t find_pattern_safely(uint64_t startAddr, uint64_t size) {
    uint8_t *pStart = (uint8_t *)startAddr;
    uint8_t *pEnd = pStart + size - sizeof(SCAN_PATTERN);

    for (uint8_t *pCurrent = pStart; pCurrent < pEnd; pCurrent += 4) {
        // مطابقة سريعة
        if (pCurrent[0] == SCAN_PATTERN[0] && 
            pCurrent[1] == SCAN_PATTERN[1] && 
            pCurrent[2] == SCAN_PATTERN[2] && 
            pCurrent[3] == SCAN_PATTERN[3]) {
            
            // تحقق كامل
            if (memcmp(pCurrent, SCAN_PATTERN, sizeof(SCAN_PATTERN)) == 0) {
                return (uint64_t)pCurrent;
            }
        }
    }
    return 0;
}

// --- التشغيل ---
__attribute__((constructor)) static void initialize() {
    // ننتظر 12 ثانية (لضمان استقرار الذاكرة)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. تحديد حدود النص التنفيذي (TEXT Segment)
        // هذا يمنع الكراش لأننا لن نقرأ ذاكرة عشوائية
        const struct mach_header_64 *header = (const struct mach_header_64 *)_dyld_get_image_header(0);
        unsigned long size = 0;
        uint8_t *ptr = getsectiondata(header, "__TEXT", "__text", &size);
        
        if (ptr == NULL) {
            NSLog(@"[MYTH] Failed to find TEXT section.");
            return;
        }

        uint64_t start_scan = (uint64_t)ptr;
        game_base = _dyld_get_image_vmaddr_slide(0);
        
        // 2. البدء في البحث الآمن
        uint64_t found_addr = find_pattern_safely(start_scan, size);
        
        if (found_addr != 0) {
            // وجدناه!
            NSLog(@"[MYTH] Pattern Found at: 0x%llx", found_addr);
            
            // التأكد أن العنوان منطقي (داخل حدود اللعبة)
            MSHookFunction((void *)found_addr, (void *)new_get_IsAiming, (void **)&old_get_IsAiming);
            
            // رسالة نجاح
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SCAN SUCCESS 🎯" 
                                                                               message:@"Function Found & Hooked!\nNo Crash." 
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Play" style:UIAlertActionStyleDefault handler:nil]];
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        } else {
            // لم نجد شيئاً (لكن لن تكرش اللعبة)
            NSLog(@"[MYTH] Pattern not found.");
             UIWindow *w = [[UIApplication sharedApplication] keyWindow];
             if (w && w.rootViewController) {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Found ⚠️" 
                                                                                message:@"Scan finished safely, but pattern not found.\nNeed new hex." 
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                 [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                 [w.rootViewController presentViewController:alert animated:YES completion:nil];
             }
        }
    });
}
