#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <AdSupport/AdSupport.h>
#import <objc/runtime.h>

void showSuccessAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Store Shield"
                                                                       message:@"Device Cleaned & Spoofed!\nID is Random."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        if (rootVC) {
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
    });
}

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

NSUUID * randomUUID(id self, SEL _cmd) {
    return [NSUUID UUID];
}

static void __attribute__((constructor)) initialize(void) {
    @autoreleasepool {
        unsetenv("DYLD_INSERT_LIBRARIES");
        
        wipeKeychain();
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
        
        Class devCls = objc_getClass("UIDevice");
        if (devCls) {
            Method m = class_getInstanceMethod(devCls, @selector(identifierForVendor));
            if (m) method_setImplementation(m, (IMP)randomUUID);
        }
        
        Class adCls = objc_getClass("ASIdentifierManager");
        if (adCls) {
            Method m = class_getInstanceMethod(adCls, @selector(advertisingIdentifier));
            if (m) method_setImplementation(m, (IMP)randomUUID);
        }
        
        showSuccessAlert();
    }
}

