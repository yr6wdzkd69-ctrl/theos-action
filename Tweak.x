#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UIDevice
- (NSUUID *)identifierForVendor {
    // Generates a completely new identity for the game
    return [[NSUUID alloc] initWithUUIDString:@"F472A1B2-C3D4-E5F6-A7B8-C9D0E1F2A3B4"];
}
@end

%ctor {
    @autoreleasepool {
        // Cleaning environment to prevent crash
        unsetenv("DYLD_INSERT_LIBRARIES");
    }
}
