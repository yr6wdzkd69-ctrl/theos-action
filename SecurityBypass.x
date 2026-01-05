#import <Foundation/Foundation.h>

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"Sideloadly"] || 
        [path containsString:@"Cydia"] || 
        [path containsString:@"ESign"] || 
        [path containsString:@"Shadow"]) {
        return NO;
    }
    return %orig;
}
%end
