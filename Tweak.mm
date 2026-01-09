#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- زيادة وزن الملف (عشان نتأكد أن التحديث وصل) ---
// هذه السطور فقط لزيادة الحجم وتغيير الـ Checksum
const char *dummy_data = "SCOPE_BOT_V5_TESTing_SIZE_CHANGE_AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

// --- Offsets ---
#define OFF_INIT   0x952694   // دالة التهيئة (Init)
#define OFFSET_IS_AIMING_FIELD  0x10  // مكان السكوب في الذاكرة

// --- Globals ---
uint64_t unity_base = 0;
void *myPlayer = NULL; 

// --- Original Function ---
void (*old_Init)(void *instance, void *world, void *player);

// --- Utils ---
intptr_t get_unity_slide() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && (strstr(name, "UnityFramework") || strstr(name, "CallOfDuty"))) {
            return _dyld_get_image_vmaddr_slide(i);
        }
    }
    return _dyld_get_image_vmaddr_slide(0);
}

// --- Hook Init ---
void new_Init(void *instance, void *world, void *player) {
    if (instance != NULL) {
        myPlayer = instance;
    }
    if (old_Init) {
        old_Init(instance, world, player);
    }
}

// --- Spy Loop ---
void spy_on_scope() {
    if (myPlayer != NULL) {
        // قراءة الذاكرة بأمان
        bool isScoped = *(bool*)((uint64_t)myPlayer + OFFSET_IS_AIMING_FIELD);
        
        if (isScoped) {
            NSLog(@"[ScopeBot] SCOPE ACTIVE! 🎯");
        }
    }
}

// --- Main ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        // طباعة النص الطويل للتأكد
        NSLog(@"[ScopeBot] Dummy Data Loaded: %s", dummy_data);

        if (unity_base != 0) {
            uint64_t addr_Init = unity_base + OFF_INIT;
            
            MSHookFunction((void *)addr_Init, (void *)new_Init, (void **)&old_Init);
            
            [NSTimer scheduledTimerWithTimeInterval:0.1 
                                             target:[NSBlockOperation blockOperationWithBlock:^{ spy_on_scope(); }] 
                                           selector:@selector(main) 
                                           userInfo:nil 
                                            repeats:YES];
        }
    });
}
