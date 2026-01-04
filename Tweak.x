#import <Foundation/Foundation.h>

// --- Only Radar / ESP Features ---

%hook NSBundle
- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"SignerIdentity"]) return nil;
    return %orig;
}
%end

// MiniMap Radar (Always see enemies on map)
%hook GameMapConfig
- (bool)enemyAlwaysVisible {
    return true;
}
%end

// Visual Radar Essentials
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
