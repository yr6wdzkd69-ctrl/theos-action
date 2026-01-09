#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- Configuration ---
// These are the offsets causing the crash. We will test without using them first.
#define OFF_PLAYER_UPDATE  0x1ADB974 
#define OFF_IS_ADS         0x200EC04

// --- Globals ---
uint64_t unity_base = 0;

// --- Utils ---
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

// --- Constructor ---
__attribute__((constructor)) static void initialize() {
    
    // Wait 10 seconds to ensure game is loaded
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        if (unity_base != 0) {
            
            // --- CRASH FIX ---
            // I have disabled MSHookFunction.
            // If the game opens now without crash, it means your Offsets were wrong.
            
            // MSHookFunction(...);  <-- DISABLED
            // MSHookFunction(...);  <-- DISABLED
            
            NSString *msg = [NSString stringWithFormat:@"Unity Found at: 0x%llx\nHooks are DISABLED to prevent crash.\nYou need correct offsets.", unity_base];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ScopeBot Diagnostic" 
                                                                           message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Understood" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        } else {
             NSLog(@"[ScopeBot] UnityFramework not found.");
        }
    });
}
