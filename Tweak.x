#import <Foundation/Foundation.h>

// --- Weapon Hack (No Recoil/Spread) ---
%hook className
- (bool)isFalse {
    return true; 
}
%end

// --- ESP Radar (Wallhack Essentials) ---
%hook EntityModel
- (bool)isVisible {
    return true; 
}
%end

%hook EnemyPlayer
- (bool)isDetected {
    return true;
}
- (float)distanceToPlayer {
    return %orig;
}
%end

// --- MiniMap Radar ---
%hook GameMapConfig
- (bool)enemyAlwaysVisible {
    return true;
}
%end
