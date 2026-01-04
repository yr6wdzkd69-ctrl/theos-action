#import <Foundation/Foundation.h>

// Safe Hook for MiniMap only
%hook GameMapConfig
- (bool)enemyAlwaysVisible {
    return true;
}
%end
