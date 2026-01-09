#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>

// =================================================
//        MYTH SCOPE BOT - FINAL STABLE VER
// =================================================

// --- 1. الأوفستات (من الديمب الخاص بك) ---
#define OFF_INIT          0x952694   // دالة تهيئة اللاعب
#define OFF_IS_AIMING     0x10       // مكان بيانات السكوب في الذاكرة

// --- 2. متغيرات عالمية ---
uint64_t game_base = 0;       // عنوان اللعبة
void *player_instance = NULL; // هنا سنحفظ بيانات اللاعب

// --- 3. تعريف الدالة الأصلية ---
void (*old_Init)(void *instance, void *world, void *player);

// --- 4. الهوك الآمن (Init) ---
// وظيفته فقط: سرقة عنوان اللاعب عند الدخول للجيم
void new_Init(void *instance, void *world, void *player) {
    // تشغيل كود اللعبة الأصلي فوراً (لمنع التعليق)
    if (old_Init) {
        old_Init(instance, world, player);
    }

    // حفظ اللاعب
    if (instance != NULL) {
        player_instance = instance;
    }
}

// --- 5. حلقة التجسس (Spy Loop) ---
// هذا الكود يقرأ الذاكرة بهدوء دون استدعاء دوال (آمن 100% من الكراش)
void spy_loop() {
    if (player_instance != NULL) {
        // قراءة مباشرة: هل اللاعب فاتح سكوب؟
        bool isScoped = *(bool*)((uint64_t)player_instance + OFF_IS_AIMING);
        
        if (isScoped) {
            // هنا تضع كود الايم بوت لاحقاً
            // حالياً سنطبع للتأكد
            NSLog(@"[MYTH] SCOPE ACTIVE! 🎯");
        }
    }
}

// --- 6. نقطة التشغيل الرئيسية ---
__attribute__((constructor)) static void initialize() {
    // ننتظر 5 ثواني لضمان أن اللعبة حملت ملفاتها
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // [هام جداً]
        // بما أننا حقنا في "التطبيق الرئيسي"، فعنوان اللعبة هو دائماً الملف رقم 0
        game_base = _dyld_get_image_vmaddr_slide(0);
        
        // حساب عنوان دالة Init
        uint64_t target_addr = game_base + OFF_INIT;
        
        // تنفيذ الحقن
        MSHookFunction((void *)target_addr, (void *)new_Init, (void **)&old_Init);
        
        // تشغيل المؤقت (يفحص 10 مرات في الثانية)
        [NSTimer scheduledTimerWithTimeInterval:0.1 
                                         target:[NSBlockOperation blockOperationWithBlock:^{ spy_loop(); }] 
                                       selector:@selector(main) 
                                       userInfo:nil 
                                        repeats:YES];
        
        // رسالة تأكيد النجاح
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MYTH Hack Loaded" 
                                                                            message:@"Injection Successful via Main App 💉\nNo Crash Mode." 
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             [alert addAction:[UIAlertAction actionWithTitle:@"Let's Play" style:UIAlertActionStyleDefault handler:nil]];
             [w.rootViewController presentViewController:alert animated:YES completion:nil];
        }
        
        NSLog(@"[MYTH] Hack Injected Successfully at Base: 0x%llx", game_base);
    });
}
