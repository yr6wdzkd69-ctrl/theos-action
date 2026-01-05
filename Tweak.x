#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%ctor {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Shield Status" 
                                        message:@"Fingerprint Cleaned\nProtection Active" 
                                        preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            if (rootVC) {
                [rootVC presentViewController:alert animated:YES completion:nil];
            }
        });
    }
}

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"B822E1F8-C36C-495A-93FC-0C247A3E6E5F"];
}
%end

%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSMutableDictionary *dict = [%orig mutableCopy];
    [dict removeObjectForKey:@"SignerIdentity"];
    return dict;
}
%end

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@".dylib"] || [path containsString:@"Frameworks"]) {
        return NO;
    }
    return %orig;
}
%end
