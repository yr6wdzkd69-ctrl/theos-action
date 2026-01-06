#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <AdSupport/AdSupport.h>
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

void wipeUserDefaults() {
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

NSUUID * newIDFV(id self, SEL _cmd) {
    return [[NSUUID alloc] initWithUUIDString:@"11223344-5566-7788-9900-AABBCCDDEEFF"];
}

NSUUID * newIDFA(id self, SEL _cmd) {
    return [[NSUUID alloc] initWithUUIDString:@"FFEEDDCC-BBAA-0099-8877-665544332211"];
}

static void __attribute__((constructor)) initialize(void) {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
        
        wipeKeychain();
        wipeUserDefaults();
        
        Class devCls = objc_getClass("UIDevice");
        if (devCls) {
            Method m = class_getInstanceMethod(devCls, @selector(identifierForVendor));
            if (m) method_setImplementation(m, (IMP)newIDFV);
        }
        
        Class adCls = objc_getClass("ASIdentifierManager");
        if (adCls) {
            Method m = class_getInstanceMethod(adCls, @selector(advertisingIdentifier));
            if (m) method_setImplementation(m, (IMP)newIDFA);
        }
    }
}

