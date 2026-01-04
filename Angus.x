#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>

%hook NSBundle
- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"SignerIdentity"]) return nil;
    return %orig;
}
%end

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"CODMMod"]) return NO;
    if ([path containsString:@"SecurityBypass"]) return NO;
    if ([path containsString:@"Library/MobileSubstrate"]) return NO;
    return %orig;
}
%end
