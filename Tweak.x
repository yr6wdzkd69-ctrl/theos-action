#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"F472A1B2-C3D4-E5F6-A7B8-C9D0E1F2A3B4"];
}
%end

%ctor {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
    }
}
