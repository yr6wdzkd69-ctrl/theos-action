#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%ctor {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
        unsetenv("_DYLD_INSERT_LIBRARIES");

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            UIViewController *rootVC = window.rootViewController;
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Shield Active" 
                                        message:@"Anti-Sideload Detection Enabled\nFingerprint Cleaned" 
                                        preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            if (rootVC) {
                [rootVC presentViewController:alert animated:YES completion:nil];
            }
        });
    }
}

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@".dylib"] || 
        [path containsString:@"Frameworks/"] || 
        [path containsString:@"_patched"]) {
        return NO; 
    }
    return %orig;
}
%end

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"A1B2C3D4-E5F6-4A5B-8C9D-0E1F2A3B4C5D"];
}
%end

%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSMutableDictionary *dict = [%orig mutableCopy];
    [dict removeObjectForKey:@"SignerIdentity"];
    [dict removeObjectForKey:@"AppleInternalDeveloperType"];
    return dict;
}
%end
