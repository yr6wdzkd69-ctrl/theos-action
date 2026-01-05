#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"C933A2B5-D2CD-5E22-93C4-F753B0G67H10"];
}
%end

%hook NSBundle
- (NSString *)bundleIdentifier {
    return @"com.activision.callofdutymobile";
}
%end

%hook WeaponConfig
- (float)recoilModifier { return 0.0f; } 
- (float)spreadModifier { return 0.0f; }
- (float)aimAssistStrength { return 2.0f; }
%end

%ctor {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
        unsetenv("_DYLD_INSERT_LIBRARIES");
        NSLog(@"[Store-Pro] System Active.");
    }
}
