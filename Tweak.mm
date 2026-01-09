#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- Configuration ---
#define OFF_PLAYER_UPDATE  0x1ADB974
#define OFF_IS_ADS         0x200EC04

// --- Globals ---
uint64_t unity_base = 0;
void (*old_PlayerUpdate)(void *instance);
bool (*Game_IsADSAiming)(void* player);

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

// --- Hooks ---
void new_PlayerUpdate(void *instance) {
    if (old_PlayerUpdate) {
        old_PlayerUpdate(instance);
    }

    if (instance == NULL || Game_IsADSAiming == NULL) {
        return;
    }

    bool isScoped = Game_IsADSAiming(instance);
    
    if (isScoped) {
        // Aimbot logic will be placed here
    }
}

// --- Constructor ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        if (unity_base != 0) {
            uint64_t addr_Update = unity_base + OFF_PLAYER_UPDATE;
            uint64_t addr_IsADS  = unity_base + OFF_IS_ADS;
            
            Game_IsADSAiming = (bool (*)(void*))(addr_IsADS);

            MSHookFunction((void *)addr_Update, (void *)new_PlayerUpdate, (void **)&old_PlayerUpdate);
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ScopeBot" 
                                                                           message:@"Active & Safe" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}
