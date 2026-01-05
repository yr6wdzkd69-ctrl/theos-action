#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NSUUID * newIdentifier(id self, SEL _cmd) {
    return [[NSUUID alloc] initWithUUIDString:@"FAC421B2-C3D4-E5F6-A7B8-C9D0E1F2A3B4"];
}

static void __attribute__((constructor)) initialize(void) {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
        
        Class cls = objc_getClass("UIDevice");
        if (cls) {
            Method m = class_getInstanceMethod(cls, @selector(identifierForVendor));
            if (m) {
                method_setImplementation(m, (IMP)newIdentifier);
            }
        }
    }
}
