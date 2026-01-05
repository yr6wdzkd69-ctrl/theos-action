#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"];
}
%end

%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSMutableDictionary *dict = [%orig mutableCopy];
    if (dict) {
        [dict removeObjectForKey:@"SignerIdentity"];
    }
    return dict;
}
%end

%ctor {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
    }
}
