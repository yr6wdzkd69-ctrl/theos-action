#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%ctor {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
        unsetenv("_DYLD_INSERT_LIBRARIES");
    }
}

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"C933E1F8-D47D-506B-94FC-1D358A4F7F6G"];
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
