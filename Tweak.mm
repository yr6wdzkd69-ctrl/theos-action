#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>

__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 1. قراءة معلومات التطبيق الداخلية
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        
        // 2. قراءة عنوان الذاكرة للتأكد
        uint64_t base = _dyld_get_image_vmaddr_slide(0);
        
        // 3. تجهيز التقرير
        NSString *info = [NSString stringWithFormat:@"ID: %@\nVer: %@ (Build: %@)\nBase Addr: 0x%llx", bundleID, version, build, base];
        
        // 4. عرض الرسالة
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Game Identity 🆔" 
                                                                       message:info 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Copy & Send" style:UIAlertActionStyleDefault handler:nil]];
        
        UIWindow *w = [[UIApplication sharedApplication] keyWindow];
        if (w && w.rootViewController) {
            [w.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}
