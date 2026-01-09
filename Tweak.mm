#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>
#import <string.h>

// --- الأرقام المستخرجة من الديمب الخاص بك ---
#define OFF_INIT        0x952694   // دالة التشغيل (كبيرة وآمنة)
#define OFF_IS_AIMING   0x96D4E8   // دالة الفحص (سنقوم باستدعائها فقط)

// --- متغيرات عالمية ---
uint64_t unity_base = 0;
void *myPlayerInstance = NULL; // هنا سنحفظ اللاعب

// --- تعريف الدوال ---
// الدالة الأصلية لـ Init
void (*old_Init)(void *instance, void *world, void *player);

// دالة السكوب (لن نقوم بعمل هوك عليها، فقط سنناديها)
bool (*Game_get_IsAiming)(void *instance);

// --- البحث عن ملف Unity ---
intptr_t get_unity_slide() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        // نبحث عن UnityFramework، وإذا لم نجدها نجرب الملف الرئيسي
        if (name && (strstr(name, "UnityFramework") || strstr(name, "CallOfDuty"))) {
            return _dyld_get_image_vmaddr_slide(i);
        }
    }
    return _dyld_get_image_vmaddr_slide(0); // الخطة البديلة
}

// --- الهوك الآمن (Init) ---
void new_Init(void *instance, void *world, void *player) {
    // 1. نشغل كود اللعبة الأصلي أولاً (عشان ما تخرب اللعبة)
    if (old_Init) {
        old_Init(instance, world, player);
    }

    // 2. نسرق عنوان اللاعب ونحفظه عندنا
    if (instance != NULL) {
        myPlayerInstance = instance;
        NSLog(@"[ScopeBot] Player Instance Captured: %p", instance);
    }
}

// --- المؤقت الخارجي (Timer) ---
// هذا الكود يشتغل في الخلفية ولا يسبب كراش
void check_scope_loop() {
    if (myPlayerInstance != NULL && Game_get_IsAiming != NULL) {
        // ننادي دالة السكوب بأمان
        bool isScoped = Game_get_IsAiming(myPlayerInstance);
        
        if (isScoped) {
            // هنا يشتغل الهاك!
            // حالياً فقط سنطبع رسالة للتأكد
             NSLog(@"[ScopeBot] SCOPE IS ON! 🎯");
        }
    }
}

// --- بداية التشغيل ---
__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        unity_base = get_unity_slide();
        
        if (unity_base != 0) {
            // حساب العناوين
            uint64_t addr_Init     = unity_base + OFF_INIT;
            uint64_t addr_IsAiming = unity_base + OFF_IS_AIMING;
            
            // تجهيز دالة السكوب (بدون هوك)
            Game_get_IsAiming = (bool (*)(void*))(addr_IsAiming);

            // عمل هوك على Init فقط
            MSHookFunction((void *)addr_Init, (void *)new_Init, (void **)&old_Init);
            
            // تشغيل المؤقت (يفحص 10 مرات في الثانية)
            [NSTimer scheduledTimerWithTimeInterval:0.1 
                                             target:[NSBlockOperation blockOperationWithBlock:^{ check_scope_loop(); }] 
                                           selector:@selector(main) 
                                           userInfo:nil 
                                            repeats:YES];
            
            // رسالة النجاح
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"ScopeBot V3" 
                                                                           message:@"Hooked 'Init' Successfully.\nGo into a match to activate." 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Play" style:UIAlertActionStyleDefault handler:nil]];
            
            UIWindow *w = [[UIApplication sharedApplication] keyWindow];
            if (w && w.rootViewController) {
                [w.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}
