#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- كود المحقق (Scanner) ---
// لا يوجد هوك هنا. فقط بحث عن العناوين.

__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableString *debugInfo = [NSMutableString string];
        [debugInfo appendString:@"Searching for Unity...\n"];
        
        bool found = false;
        uint32_t count = _dyld_image_count();
        
        // فحص أول 100 ملف محمل في اللعبة
        for (uint32_t i = 0; i < count; i++) {
            const char *cName = _dyld_get_image_name(i);
            if (cName) {
                NSString *name = [NSString stringWithUTF8String:cName];
                
                // نبحث عن أي شيء يشبه Unity أو اللعبة
                if ([name containsString:@"Unity"] || [name containsString:@"CallOfDuty"] || [name containsString:@"Framework"]) {
                    uint64_t slide = _dyld_get_image_vmaddr_slide(i);
                    [debugInfo appendFormat:@"[%d] %@ -> 0x%llx\n", i, [name lastPathComponent], slide];
                    found = true;
                }
            }
        }
        
        if (!found) {
            [debugInfo appendString:@"❌ Unity Framework NOT found in list!"];
        }

        // عرض النتائج في رسالة
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"G-Box Debugger" 
                                                                       message:debugInfo 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Copy & Send" style:UIAlertActionStyleDefault handler:nil]];
        
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
            [w.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}
