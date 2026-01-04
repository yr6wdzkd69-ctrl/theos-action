#import <Foundation/Foundation.h>

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
