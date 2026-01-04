#import <Foundation/Foundation.h>

// --- Radar Features ---
%hook GameMapConfig
- (bool)enemyAlwaysVisible {
    return true;
}
- (bool)isEnemyVisibleOnMap {
    return true;
}
%end

%hook EntityModel
- (bool)isVisible {
    return true; 
}
%end

// --- Aimbot Features ---
%hook PlayerWeaponControl
- (bool)isAimbotEnabled {
    return true;
}
- (float)getAimbotFov {
    return 15.0f; 
}
- (float)getAimbotSmooth {
    return 0.5f;
}
%end

%hook PlayerFiredWeapon
- (float)getSpreadConfig {
    return 0.0f; 
}
- (float)getRecoilConfig {
    return 0.0f;
}
%end
