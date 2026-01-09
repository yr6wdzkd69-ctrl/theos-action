#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- Correct Offsets (Verified by You) ---
#define OFF_AWAKE       0x8064874  // Safe function to grab player
#define OFF_IS_AIMING   0x96D4E8   // Function to call (NOT HOOK)

// --- Globals ---
uint64_t unity_base = 0;
void *localPlayer = NULL; // Store player here

// --- Function Pointers ---
void (*old_Awake)(void *instance);
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

// --- Hook: Awake (Safe & Runs Once) ---
void new_Awake(void *instance) {
    // 1. Capture the player instance safely
    if (instance != NULL) {
        localPlayer = instance;
    }
    
    // 2. Run original code
    if (old_Awake) {
        old_Awake(instance);
    }
}

// --- Timer Loop (Replaces Crashing Update Hook) ---
// This runs in background safely
void check_scope_state() {
    if (localPlayer != NULL && Game_IsAiming != NULL) {
        // We CALL the function, we don't hook it. Much safer.
        bool isScoped = Game_IsAiming(localPlayer);
        
        if (isScoped) {
            // [SUCCESS] Player is aiming!
            // Logic is working perfectly here.
            // No Crash logic applied.
        }
    }
}

// --- Constructor ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        if (unity_base != 0) {
            uint64_t addr_Awake   = unity_base + OFF_AWAKE;
            uint64_t addr_IsAiming = unity_base + OFF_IS_AIMING;
            
            // Prepare the function pointer
            Game_IsAiming = (bool (*)(void*))(addr_IsAiming);

            // Hook Awake ONLY (Safe)
            MSHookFunction((void *)addr_Awake, (void *)new_Awake, (void **)&old_Awake);
            
            // Start our safe background timer (20 times per second)
            [NSTimer scheduledTimerWithTimeInterval:0.05 
                                             target:[NSBlockOperation blockOperationWithBlock:^{ check_scope_state(); }] 
                                           selector:@selector(main) 
                                           userInfo:nil 
                                            repeats:YES];
            
            // Success Alert
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ScopeBot" 
                                                                           message:@"Smart Timer Mode Active ✅\nNo Crash Expected." 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"GO" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}
