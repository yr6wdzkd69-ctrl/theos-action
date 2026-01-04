#import <UIKit/UIKit.h>

// --- Initialization Check ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    keyWindow = ((UIWindowScene *)scene).windows.firstObject;
                    break;
                }
            }
        } else {
            keyWindow = [UIApplication sharedApplication].keyWindow;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Angus System" 
                                                                       message:@"Mod Initialized Successfully" 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

// --- Radar Features ---
%hook GameMapConfig
- (bool)enemyAlwaysVisible {
    return true;
}
%end

%hook EntityModel
- (bool)isVisible {
    return true; 
}
%end

%hook EnemyPlayer
- (bool)isDetected {
    return true;
}
%end
