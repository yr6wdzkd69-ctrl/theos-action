#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Forced Injection Logic
__attribute__((constructor))
static void force_load() {
    // This runs immediately when the dylib is loaded in memory
}

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

