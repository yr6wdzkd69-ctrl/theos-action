#import <substrate.h>
#import <mach-o/dyld.h>

// Aimbot Offset for 1.0.53 (64-bit)
#define Off_Aimbot 0x108D4C2F8

void (*old_Aim)(void *instance);
void new_Aim(void *instance) {
    if (instance != NULL) {
        // High power logic goes here
    }
    old_Aim(instance);
}

%ctor {
    // Get game base address
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);

    // Injection Hook
    MSHookFunction((void *)(base + Off_Aimbot), (void *)&new_Aim, (void **)&old_Aim);
}
