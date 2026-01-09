#import <UIKit/UIKit.h>
#import <substrate.h>

// --- متغيرات ---
UIWindow *overlayWindow = nil;
UIView *crosshairView = nil;

// --- إعداد الطبقة البصرية ---
void setup_crosshair() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1. إنشاء نافذة شفافة فوق اللعبة
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.windowLevel = UIWindowLevelStatusBar + 100; // فوق كل شيء
        overlayWindow.userInteractionEnabled = NO; // عشان تقدر تلمس اللعبة من خلالها
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.hidden = NO;
        
        // 2. إنشاء نقطة التصويب (Crosshair)
        CGFloat size = 6.0; // حجم النقطة
        crosshairView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
        crosshairView.backgroundColor = [UIColor redColor]; // لون أحمر
        crosshairView.layer.cornerRadius = size / 2; // شكل دائري
        crosshairView.center = overlayWindow.center; // في منتصف الشاشة تماماً
        
        // إضافة حدود سوداء للنقطة (عشان تبان في الثلج)
        crosshairView.layer.borderColor = [UIColor blackColor].CGColor;
        crosshairView.layer.borderWidth = 1.0;
        
        // 3. إضافة النقطة للشاشة
        [overlayWindow addSubview:crosshairView];
        
        // رسالة ترحيب
        NSLog(@"[MYTH] Crosshair Overlay Enabled!");
    });
}

// --- الاستماع لتشغيل اللعبة ---
// سننتظر حتى تظهر اللعبة ثم نرسم فوقها
void (*old_viewDidAppear)(id self, SEL _cmd, BOOL animated);

void new_viewDidAppear(id self, SEL _cmd, BOOL animated) {
    if (old_viewDidAppear) old_viewDidAppear(self, _cmd, animated);
    
    static bool isSetup = false;
    if (!isSetup) {
        isSetup = true;
        // تشغيل الكروس هير بعد 3 ثواني
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            setup_crosshair();
            
            // رسالة تأكيد للمستخدم
             UIWindow *w = [[UIApplication sharedApplication] keyWindow];
             if (w && w.rootViewController) {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MYTH ESP 🎯" 
                                                                                message:@"Crosshair Overlay Active.\nNo offsets used = No Crash." 
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                 [alert addAction:[UIAlertAction actionWithTitle:@"Nice" style:UIAlertActionStyleDefault handler:nil]];
                 [w.rootViewController presentViewController:alert animated:YES completion:nil];
             }
        });
    }
}

__attribute__((constructor)) static void initialize() {
    // هوك على أي شاشة تفتح عشان نشغل الطبقة
    MSHookMessageEx(objc_getClass("UIViewController"), @selector(viewDidAppear:), (IMP)&new_viewDidAppear, (IMP *)&old_viewDidAppear);
}
