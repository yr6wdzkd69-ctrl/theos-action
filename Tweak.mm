#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- Offsets ---
#define OFF_INIT   0x952694   // دالة تهيئة اللاعب (كبيرة وآمنة)
#define OFFSET_IS_AIMING_FIELD  0x10  // مكان تخزين السكوب في الذاكرة (من الديمب)

// --- Globals ---
uint64_t unity_base = 0;
void *myPlayer = NULL; // هنا نحفظ عنوان اللاعب

// --- Original Function Pointer ---
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

// --- The Hook (Init ONLY) ---
// نستخدم هذه الدالة فقط لمسك اللاعب مرة واحدة عند البداية
void new_Init(void *instance, void *world, void *player) {
    
    // 1. حفظ اللاعب
    if (instance != NULL) {
        myPlayer = instance;
        NSLog(@"[ScopeBot] Player Captured: %p", instance);
    }

    // 2. تشغيل كود اللعبة الأصلي
    if (old_Init) {
        old_Init(instance, world, player);
    }
}

// --- The Spy Loop (Timer) ---
// هذا الكود يقرأ الذاكرة كل جزء من الثانية بدون تدخل في وظائف اللعبة
void spy_on_scope() {
    if (myPlayer != NULL) {
        // قراءة مباشرة من الذاكرة (Direct Memory Read)
        // هذا السطر مستحيل يسبب كراش دالة لأنه قراءة فقط
        bool isScoped = *(bool*)((uint64_t)myPlayer + OFFSET_IS_AIMING_FIELD);
        
        if (isScoped) {
            // اللاعب فاتح سكوب الآن!
            NSLog(@"[ScopeBot] SCOPE IS ON 🎯");
            
            // هنا لاحقاً نضع كود الايم بوت
        }
    }
}

// --- Constructor ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        if (unity_base != 0) {
            uint64_t addr_Init = unity_base + OFF_INIT;
            
            // Hook Init Only
            MSHookFunction((void *)addr_Init, (void *)new_Init, (void **)&old_Init);
            
            // تشغيل الجاسوس (المؤقت)
            [NSTimer scheduledTimerWithTimeInterval:0.05 
                                             target:[NSBlockOperation blockOperationWithBlock:^{ spy_on_scope(); }] 
                                           selector:@selector(main) 
                                           userInfo:nil 
                                            repeats:YES];
            
            // رسالة النجاح
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ScopeBot V4" 
                                                                           message:@"Memory Reader Mode Active 🛡️\nNo Function Hooks on Aiming." 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"GO" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}
