#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"B14992C4-3D22-4E51-9011-F23456789ABC"];
}
%end
