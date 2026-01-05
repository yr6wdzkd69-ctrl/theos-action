#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"CODMMod"] || 
        [path containsString:@"Frameworks/PixVideo"] || 
        [path containsString:@"Sideloadly"] ||
        [path containsString:@"Cydia"] ||
        [path containsString:@"Abtu"]) {
        return NO;
    }
    return %orig;
}
%end

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"B822F1D4-A1BC-4D11-82B3-E642A9F55C92"];
}
%end

%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSMutableDictionary *dict = [%orig mutableCopy];
    NSArray *keysToRemove = @[@"SignerIdentity", @"AppleInternal", @"ProvisioningProfile", @"HasEntitlements"];
    for (NSString *key in keysToRemove) {
        if ([dict objectForKey:key]) {
            [dict removeObjectForKey:key];
        }
    }
    return dict;
}
%end

%hook NSUserDefaults
- (id)objectForKey:(NSString *)defaultName {
    if ([defaultName isEqualToString:@"InAppPurchases"] || [defaultName isEqualToString:@"DeviceBanned"]) {
        return nil;
    }
    return %orig;
}
%end

%ctor {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
        unsetenv("_DYLD_INSERT_LIBRARIES");
        unsetenv("DYLD_LIBRARY_PATH");
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"[EliteShield] System Protected & Device Spoofed.");
        });
    }
}
