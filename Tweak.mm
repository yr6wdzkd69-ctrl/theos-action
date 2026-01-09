#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- Configurable Offsets (UPDATE THESE FROM YOUR DUMP) ---
#define OFF_ZONEKICK      0x1059A2C0
#define OFF_IS_ADS        0x200EC04
#define OFF_UPDATE        0x1380BA8

// --- Global Variables ---
uint64_t unity_base = 0;
void (*old_Update)(void *instance);
void (*old_ZoneKick)(void *instance, void *arg1);
bool (*Game_IsADSAiming)(void* player);

// --- Helper: Find UnityFramework Base Address ---
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

// --- Hook 1: Safe Anti-Kick ---
void new_ZoneKick(void *instance, void *arg1) {
    // Return immediately to bypass the kick command
    return;
}

// --- Hook 2: Scope-Only Logic ---
void new_Update(void *instance) {
    // Safety Check: Ensure pointer is valid before calling
    if (Game_IsADSAiming != NULL) {
        bool isScoped = Game_IsADSAiming(instance);
        if (isScoped) {
            // Aimbot Logic would go here
        }
    }
    
    // Call Original Game Loop
    if (old_Update) {
        old_Update(instance);
    }
}

// --- Main Constructor ---
%ctor {
    // Delay execution by 10 seconds to prevent startup crash
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        if (unity_base != 0) {
            // Calculate Real Addresses
            uint64_t addr_ZoneKick = unity_base + OFF_ZONEKICK;
            uint64_t addr_Update   = unity_base + OFF_UPDATE; 
            uint64_t addr_IsADS    = unity_base + OFF_IS_ADS;
            
            // Assign Function Pointers
            Game_IsADSAiming = (bool (*)(void*))(addr_IsADS);

            // Apply Hooks Safely
            MSHookFunction((void *)addr_ZoneKick, (void *)new_ZoneKick, (void **)&old_ZoneKick);
            MSHookFunction((void *)addr_Update,   (void *)new_Update,   (void **)&old_Update);
            
            // Success Alert
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ScopeBot Loaded" 
                                                                           message:@"Injected Successfully without Crash!" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] windows].firstObject;
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        } else {
            NSLog(@"[ScopeBot] Error: UnityFramework not found.");
        }
    });
}
