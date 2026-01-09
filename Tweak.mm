#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- YOUR EXTRACTED OFFSETS ---
#define OFF_UPDATE      0x7871168
#define OFF_IS_AIMING   0x96D4E8

// --- Globals ---
uint64_t unity_base = 0;
void (*old_Update)(void *instance);
bool (*Game_IsAiming)(void* instance);

// --- Helper ---
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

// --- The Hook ---
void new_Update(void *instance) {
    // 1. Run Original Game Code
    if (old_Update) {
        old_Update(instance);
    }

    // 2. Safety Check
    if (instance == NULL || Game_IsAiming == NULL) {
        return;
    }

    // 3. Check Scope State
    bool isScoped = Game_IsAiming(instance);

    if (isScoped) {
        // [SCOPE DETECTED]
        // This confirms the logic works! 
        // Aimbot math goes here later.
    }
}

// --- Entry Point ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        if (unity_base != 0) {
            // Calculate Addresses
            uint64_t addr_Update   = unity_base + OFF_UPDATE; 
            uint64_t addr_IsAiming = unity_base + OFF_IS_AIMING;
            
            // Link Functions
            Game_IsAiming = (bool (*)(void*))(addr_IsAiming);

            // Apply Hook
            MSHookFunction((void *)addr_Update, (void *)new_Update, (void **)&old_Update);
            
            // Success Message
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ScopeBot" 
                                                                           message:@"Injected Successfully!\nOffsets Applied ✅" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Let's Play" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}
