#import <Foundation/Foundation.h>

%hook NSUserDefaults
- (BOOL)boolForKey:(NSString *)defaultName {
    if ([defaultName isEqualToString:@"FirebaseCrashlyticsCollectionEnabled"]) return NO;
    return %orig;
}
%end

%hook UIDevice
- (BOOL)isJailbroken {
    return NO;
}
%end

%hook NSFileManager
- (BOOL)isReadableFileAtPath:(NSString *)path {
    if ([path containsString:@"DynamicLibraries"]) return NO;
    return %orig;
}
%end
