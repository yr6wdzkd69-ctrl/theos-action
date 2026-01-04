#import <Foundation/Foundation.h>

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"Library/MobileSubstrate"]) return NO;
    if ([path containsString:@"Cydia"]) return NO;
    if ([path containsString:@"Sileo"]) return NO;
    return %orig;
}
%end
