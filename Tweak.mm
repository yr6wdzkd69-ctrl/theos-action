#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>

// --- إعدادات G-Box الخاصة ---
// بما أننا نحقن في G-Box، العنوان الأساسي هو دائماً (Image 0)
// الأوفستات:
#define OFF_INIT          0x952694
#define OFF_IS_AIMING     0x10

// --- متغيرات ---
uint64_t base_address = 0;
void *current_player = NULL;
void (*old_Init)(void *instance, void *world, void *player);

// --- الهوك (Init) ---
void new_Init(void *instance, void *world, void *player) {
    // 1. تشغيل الأصلي فوراً (عشان ما تعلق اللعبة)
    if (old_Init) {
        old_Init(instance, world, player);
    }
    
    // 2. صيد اللاعب
    if (instance != NULL) {
        current_player = instance;
    }
}

// --- المؤقت (الجاسوس) ---
void gbox_spy_loop() {
    if (current_player != NULL) {
        // قراءة الذاكرة
        bool isScoped = *(bool*)((uint64_t)current_player + OFF_IS_AIMING);
        
        if (isScoped) {
            NSLog(@"[G-Box Hack] Scope ACTIVE 🎯");
        }
    }
}

// --- التشغيل ---
__attribute__((constructor)) static void initialize() {
    // تأخير 7 ثواني (ضروري في G-Box لأن تحميله أبطأ)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. سحب عنوان اللعبة مباشرة
        base_address = _dyld_get_image_vmaddr_slide(0);
        
        // 2. حساب مكان الحقن
        uint64_t target = base_address + OFF_INIT;
        
        // 3. الحقن
        MSHookFunction((void *)target, (void *)new_Init, (void **)&old_Init);
        
        // 4. تشغيل اللوب
        [NSTimer scheduledTimerWithTimeInterval:0.1 
                                         target:[NSBlockOperation blockOperationWithBlock:^{ gbox_spy_loop(); }] 
                                       selector:@selector(main) 
                                       userInfo:nil 
                                        repeats:YES];
        
        // رسالة تأكيد
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"G-Box Mode" 
                                                                            message:@"✅ Hooked Image [0] Successfully." 
                                                                     preferredStyle:UIAlertControllerStyleAlert];
             [alert addAction:[UIAlertAction actionWithTitle:@"Play" style:UIAlertActionStyleDefault handler:nil]];
             [w.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}
