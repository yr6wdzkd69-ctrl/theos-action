#import <substrate.h>
#import <mach-o/dyld.h>

// Offset Configuration
static uint64_t TARGET_OFFSET = 0x100080D2; 

%ctor {
    // Calculate ASLR slide
    uint64_t slide = _dyld_get_image_vmaddr_slide(0);
    uint64_t targetAddress = slide + TARGET_OFFSET;

    // Patch Bytes: MOV X0, 0 (False) + RET (Return)
    // Hex: 00 00 80 D2 C0 03 5F D6
    unsigned char patchBytes[] = {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6};

    // Apply Patch
    MSHookMemory((void *)targetAddress, patchBytes, sizeof(patchBytes));
}
