#import <Foundation/Foundation.h>

%hook NSBundle
- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"SignerIdentity"]) return nil;
    return %orig;
}
%end

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"Library/MobileSubstrate"]) return NO;
    if ([path containsString:@"Cydia"]) return NO;
    return %orig;
}
%end
