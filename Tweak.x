#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>

uintptr_t get_base_address() {
    return _dyld_get_image_header(0);
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"System Core" 
                                    message:@"Injection Successful\nOffset Mode Active" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (root) {
            [root presentViewController:alert animated:YES completion:nil];
        }
    });
}

void apply_offsets() {
    uintptr_t base = get_base_address();
    
    // Replace 0x1234567 with your actual Radar Offset
    uintptr_t radar_ptr = base + 0x1234567; 
    *(bool *)radar_ptr = true;

    // Replace 0x7654321 with your actual Aimbot Offset
    uintptr_t aimbot_ptr = base + 0x7654321; 
    *(bool *)aimbot_ptr = true;
}

%hook UnityPlayer
- (void)update {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apply_offsets();
    });
}
%end
