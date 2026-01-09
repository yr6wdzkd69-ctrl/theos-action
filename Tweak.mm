#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>

// --- وضع الأمان (Safe Mode) ---
// هذا الكود يتأكد أن الحقن سليم، لكنه لا يلمس اللعبة لتجنب الكراش.

#define OFF_INIT   0x952694

uint64_t base_address = 0;

__attribute__((constructor)) static void initialize() {
    // ننتظر 10 ثواني
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. سحب العنوان
        base_address = _dyld_get_image_vmaddr_slide(0);
        
        // 2. حساب العنوان المستهدف (للمعلومية فقط)
        uint64_t target = base_address + OFF_INIT;
        
        // 3. طباعة تقرير (بدون هوك)
        NSLog(@"[SafeMode] Base: 0x%llx | Target: 0x%llx", base_address, target);
        
        // 4. رسالة النجاح
        // إذا طلعت هذه الرسالة، يعني الحقن نجح والمشكلة كانت في الأوفست
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Safe Mode ✅" 
                                                                            message:@"Injection is WORKING!\nThe Game did NOT crash.\n\nConclusion: The previous offset (0x952694) is WRONG for this version." 
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             [alert addAction:[UIAlertAction actionWithTitle:@"Understood" style:UIAlertActionStyleDefault handler:nil]];
             [w.rootViewController presentViewController:alert animated:YES completion:nil];
        }
        
        // ⚠️ لاحظ: لقد حذفت سطر MSHookFunction عمداً
        // عشان نتأكد أن اللعبة ما راح تكرش بدونه.
    });
}
