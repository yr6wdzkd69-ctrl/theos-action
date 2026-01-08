#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

void showSuccessAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"System Activated" 
                                                                       message:@"Zonekick ✅" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        UIWindow *window = [[UIApplication sharedApplication] windows].firstObject;
        UIViewController *rootVC = window.rootViewController;
        
        if (rootVC) {
            while (rootVC.presentedViewController) {
                rootVC = rootVC.presentedViewController;
            }
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
    });
}

%ctor {
    showSuccessAlert();

    uint64_t slide = _dyld_get_image_vmaddr_slide(0);
    
    uint64_t offset = 0x1059A2C0;
    
    uint64_t targetAddress = slide + offset;
    
    unsigned char patch[] = {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6};
    
    MSHookMemory((void *)targetAddress, patch, sizeof(patch));
}
