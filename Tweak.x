#import <Foundation/Foundation.h>

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"F911E1F8-A12B-334C-82FC-0C247A3E6E5F"];
}
%end

%ctor {
    unsetenv("DYLD_INSERT_LIBRARIES");
}

