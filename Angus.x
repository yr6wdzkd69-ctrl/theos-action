#import <Foundation/Foundation.h>

// Safe construction to avoid disk write crashes
%ctor {
    @autoreleasepool {
        // Silent loading
    }
}

// Minimal bypass without interfering with system files
%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"Cydia"] || [path containsString:@"Sileo"]) return NO;
    return %orig;
}
%end
