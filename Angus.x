#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>

// Function to hide the dylib from the system list
void hide_bundle(const char *path) {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (strstr(name, path)) {
            // Masking logic here to prevent scanners from seeing the file
            return;
        }
    }
}

%ctor {
    @autoreleasepool {
        hide_bundle("CODMMod.dylib");
    }
}

// Block file system checks
%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"CODMMod"] || [path containsString:@"Frameworks/CODMMod"]) return NO;
    return %orig;
}
%end
