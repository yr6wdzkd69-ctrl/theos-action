#import <Foundation/Foundation.h>

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"A1B2C3D4-E5F6-47A8-9B0C-1D2E3F4G5H6I"];
}
%end

%ctor {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
    }
}
