#import <UIKit/UIKit.h>
#import <substrate.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <string.h>

uint64_t find_pattern(uint64_t startAddress, uint64_t length, const char* pattern, const char* mask) {
    const char* ptr = (const char*)startAddress;
    const char* end = ptr + length;
    size_t patternLength = strlen(mask);

    while (ptr < end - patternLength) {
        bool found = true;
        for (size_t i = 0; i < patternLength; i++) {
            if (mask[i] != '?' && pattern[i] != ptr[i]) {
                found = false;
                break;
            }
        }
        if (found) {
            return (uint64_t)ptr;
        }
        ptr++;
    }
    return 0;
}

void showOffsetAlert(uint64_t offset) {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = [NSString stringWithFormat:@"Offset Found: 0x%llX", offset];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Offset Dumper" 
                                                                       message:message 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        
        UIWindow *window = [[UIApplication sharedApplication] windows].firstObject;
        UIViewController *topController = window.rootViewController;
        
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        [topController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        uint64_t slide = _dyld_get_image_vmaddr_slide(0);
        
        // IMPORTANT: Replace bytes below with the real Pattern
        const char* pattern = "\xF0\x03\x1F\x2A\xE1\x03\x00\x94"; 
        const char* mask    = "xxxxxxxx";
        
        uint64_t foundAddr = find_pattern(slide + 0x100000000, 0x10000000, pattern, mask);

        if (foundAddr != 0) {
            uint64_t offset = foundAddr - slide;
            showOffsetAlert(offset);
        }
    });
}
