#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- OFFSETS FROM YOUR DUMP (A2DPlayerSkillInput) ---
#define OFF_CHECK_INPUT  0x9528D8   // The Loop
#define OFF_IS_AIMING    0x96D4E8   // The Trigger

// --- Globals ---
uint64_t unity_base = 0;

// --- Function Pointers ---
void (*old_CheckSkillInput)(void *instance);
bool (*Game_get_IsAiming)(void *instance);

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

// --- The Safe Hook ---
void new_CheckSkillInput(void *instance) {
    // 1. Run Original Game Logic First
    if (old_CheckSkillInput) {
        old_CheckSkillInput(instance);
    }

    // 2. Safety Check (Prevent Crash)
    if (instance == NULL) {
        return;
    }

    // 3. Check Scope (Using the correct class function)
    if (Game_get_IsAiming != NULL) {
        bool isAiming = Game_get_IsAiming(instance);
        
        if (isAiming) {
            // [SCOPE DETECTED]
            // Since we are here without crash, the code works!
            // Future: Add Aimbot Logic Here.
        }
    }
}

// --- Constructor ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        if (unity_base != 0) {
            // Calculate Real Addresses
            uint64_t addr_CheckInput = unity_base + OFF_CHECK_INPUT;
            uint64_t addr_IsAiming   = unity_base + OFF_IS_AIMING;
            
            // Link Helper Function
            Game_get_IsAiming = (bool (*)(void*))(addr_IsAiming);

            // Apply The Hook
            MSHookFunction((void *)addr_CheckInput, (void *)new_CheckSkillInput, (void **)&old_CheckSkillInput);
            
            // Success Message
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ScopeBot" 
                                                                           message:@"Injected into A2DPlayerSkillInput ✅\nNo Crash Expected!" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Let's Go" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}
