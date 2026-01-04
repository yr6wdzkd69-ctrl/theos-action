#import <UIKit/UIKit.h>

__attribute__((constructor))
static void init_mod() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        NSArray *scenes = [[UIApplication sharedApplication].connectedScenes allObjects];
        for (id scene in scenes) {
            if ([scene respondsToSelector:@selector(activationState)] && 
                [scene activationState] == 0) { // UISceneActivationStateForegroundActive
                window = [[scene windows] firstObject];
                break;
            }
        }
        
        if (!window) window = [UIApplication sharedApplication].keyWindow;

        if (window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"System" 
                                                                           message:@"Mod Active" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

%hook GameMapConfig
- (bool)enemyAlwaysVisible { return true; }
%end

%hook EntityModel
- (bool)isVisible { return true; }
%end
