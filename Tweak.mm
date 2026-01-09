#import <substrate.h>
#import <UIKit/UIKit.h>

// --- اختبار النظام (بدون أوفستات اللعبة) ---
// هذا الكود يسوي هوك على شاشة الايفون العادية
// اذا كرش هنا، يعني الحماية تمنع تشغيل اي هاك

// تعريف المؤشر الأصلي
void (*old_viewDidAppear)(id self, SEL _cmd, BOOL animated);

// الدالة الجديدة
void new_viewDidAppear(id self, SEL _cmd, BOOL animated) {
    
    // تشغيل الدالة الأصلية
    if (old_viewDidAppear) {
        old_viewDidAppear(self, _cmd, animated);
    }

    // عرض رسالة مرة واحدة فقط
    static bool showedAlert = false;
    if (!showedAlert) {
        showedAlert = true;
        NSLog(@"[ScopeBot] System Hook SUCCESS! No Crash.");
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"System Test" 
                                                                       message:@"✅ The Dylib is RUNNING!\nThe Game offsets were the problem." 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
            [w.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    }
}

// البناء
__attribute__((constructor)) static void initialize() {
    // هوك على كلاس UIViewController (موجود في كل الايفونات)
    // لا نستخدم UnityFramework هنا
    MSHookMessageEx(objc_getClass("UIViewController"), @selector(viewDidAppear:), (IMP)&new_viewDidAppear, (IMP *)&old_viewDidAppear);
}
