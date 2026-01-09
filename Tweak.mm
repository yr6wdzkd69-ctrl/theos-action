#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>

// --- الإعدادات ---
#define OLD_OFFSET      0x952694   // الأوفست القديم
#define SEARCH_RANGE    0x50000    // نطاق البحث (حوالي 300 كيلوبايت)

// --- بصمة بداية الدالة (ARM64 Prologue) ---
// STP X29, X30, [SP, #-0x10]!
// Hex: FD 7B BB A9
const uint8_t FUNC_START[] = { 0xFD, 0x7B, 0xBB, 0xA9 };

// --- متغيرات ---
uint64_t game_base = 0;
void *player_instance = NULL;
void (*old_Init)(void *instance, void *world, void *player);

// --- الهوك ---
void new_Init(void *instance, void *world, void *player) {
    if (old_Init) old_Init(instance, world, player);
    
    if (instance != NULL) {
        player_instance = instance;
        NSLog(@"[MYTH] Player Captured via Neighbor Scan!");
    }
}

// --- ماسح الجيران ---
void scan_neighborhood() {
    game_base = _dyld_get_image_vmaddr_slide(0);
    
    // نقطة البداية (العنوان القديم)
    uint64_t start_point = game_base + OLD_OFFSET;
    
    // حدود البحث (نرجع للخلف ونقدم للأمام)
    uint64_t search_start = start_point - (SEARCH_RANGE / 2);
    uint64_t search_end   = start_point + (SEARCH_RANGE / 2);
    
    NSLog(@"[MYTH] Scanning around 0x%llx...", start_point);

    uint64_t found_addr = 0;
    uint8_t *ptr = (uint8_t *)search_start;

    // الحلقة
    for (uint64_t i = 0; i < SEARCH_RANGE; i += 4) {
        // هل وجدنا بداية دالة؟
        if (memcmp(ptr + i, FUNC_START, sizeof(FUNC_START)) == 0) {
            
            uint64_t candidate = (uint64_t)(ptr + i);
            
            // فلتر بسيط: نستبعد العنوان القديم نفسه لأنه يكرش
            if (candidate == start_point) continue;

            found_addr = candidate;
            break; // وجدنا أقرب جار!
        }
    }

    // النتائج
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
            if (found_addr != 0) {
                // وجدنا عنوان جديد!
                uint64_t new_offset = found_addr - game_base;
                
                // نحاول الحقن
                MSHookFunction((void *)found_addr, (void *)new_Init, (void **)&old_Init);
                
                NSString *msg = [NSString stringWithFormat:@"NEW OFFSET FOUND!\nOld: 0x%X\nNew: 0x%llx\nDiff: %lld bytes", OLD_OFFSET, new_offset, new_offset - OLD_OFFSET];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🎯 BINGO" 
                                                                               message:msg 
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Play" style:UIAlertActionStyleDefault handler:nil]];
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
                
            } else {
                // لم نجد شيئاً
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Failed" 
                                                                               message:@"No function found nearby.\nThe code moved too far." 
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"Close" style:UIAlertActionStyleDefault handler:nil]];
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}

__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            scan_neighborhood();
        });
    });
}
