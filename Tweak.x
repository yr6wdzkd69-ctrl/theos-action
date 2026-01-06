#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <AdSupport/AdSupport.h>
#import <objc/runtime.h>

// 1. Generate Random UUID
static NSUUID *fakeUUID = nil;
NSUUID * getFakeUUID() {
    if (!fakeUUID) {
        fakeUUID = [NSUUID UUID];
    }
    return fakeUUID;
}

// 2. Alert System
void showSuccessAlert() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *foundWindow = nil;
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        foundWindow = window;
                        break;
                    }
                }
            }
            if (foundWindow) break;
        }
        if (foundWindow) {
            NSString *msg = [NSString stringWithFormat:@"Everything Cleaned.\nNew ID: ...%@", [[getFakeUUID() UUIDString] substringFromIndex:24]];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Device Reset Complete"
                                                                           message:msg
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"GO" style:UIAlertActionStyleDefault handler:nil]];
            UIViewController *rootVC = foundWindow.rootViewController;
            if (rootVC) {
                [rootVC presentViewController:alert animated:YES completion:nil];
            }
        }
    });
}

// 3. Wipe Keychain (Deep Clean)
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

// 4. Wipe Cookies & Cache (New Addition)
void wipeCookiesAndCache() {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

// 5. Method Swizzling for UUID
NSUUID * randomUUID(id self, SEL _cmd) {
    return getFakeUUID();
}

// 6. Main Execution (Constructor)
static void __attribute__((constructor)) initialize(void) {
    @autoreleasepool {
        // A. Hide Injection Trace
        unsetenv("DYLD_INSERT_LIBRARIES");
        
        // B. Wipe Clipboard
        [UIPasteboard generalPasteboard].string = @"";
        
        // C. Wipe Data
        wipeKeychain();
        wipeCookiesAndCache();
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
        
        // D. Hook Device ID
        Class devCls = objc_getClass("UIDevice");
        if (devCls) {
            Method m = class_getInstanceMethod(devCls, @selector(identifierForVendor));
            if (m) method_setImplementation(m, (IMP)randomUUID);
        }
        
        // E. Hook Advertising ID
        Class adCls = objc_getClass("ASIdentifierManager");
        if (adCls) {
            Method m = class_getInstanceMethod(adCls, @selector(advertisingIdentifier));
            if (m) method_setImplementation(m, (IMP)randomUUID);
        }
        
        // F. Show Alert
        showSuccessAlert();
    }
}
