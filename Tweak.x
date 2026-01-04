#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// --- Alert on Start to verify Injection ---
%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CoreApp" 
                                    message:@"Hack Loaded Successfully!" 
                                    preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

// --- Radar Features ---
%hook GameMapConfig
- (bool)enemyAlwaysVisible { return true; }
- (bool)isEnemyVisibleOnMap { return true; }
%end

%hook EntityModel
- (bool)isVisible { return true; }
%end

// --- Aimbot Features ---
%hook PlayerWeaponControl
- (bool)isAimbotEnabled { return true; }
- (float)getAimbotFov { return 15.0f; }
- (float)getAimbotSmooth { return 0.5f; }
%end

