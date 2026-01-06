#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <objc/runtime.h>

void wipeKeychain() {
    NSArray *secItemClasses = @[(__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecClassInternetPassword,
                                (__bridge id)kSecClassCertificate,
                                (__bridge id)kSecClassKey,
                                (__bridge id)kSecClassIdentity];
    for (id secItemClass in secItemClasses) {
        NSDictionary *spec = @{(__bridge id)kSecClass: secItemClass};
        SecItemDelete((__bridge CFDictionaryRef)spec);
    }
}

NSUUID * newIdentifier(id self, SEL _cmd) {
    return [[NSUUID alloc] initWithUUIDString:@"7A24F1B2-C3D4-E5F6-A7B8-C9D0E1F2A999"];
}

static void __attribute__((constructor)) initialize(void) {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
        
        wipeKeychain();
        
        Class cls = objc_getClass("UIDevice");
        if (cls) {
            Method m = class_getInstanceMethod(cls, @selector(identifierForVendor));
            if (m) {
                method_setImplementation(m, (IMP)newIdentifier);
            }
        }
    }
}
