#import <Foundation/Foundation.h>

%hook GameMapConfig
- (bool)isEnemyVisibleOnMap {
    return true;
}
%end
