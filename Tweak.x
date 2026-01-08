#import <substrate.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>

%ctor {
    uint64_t slide = _dyld_get_image_vmaddr_slide(0);

    uint64_t offset = 0x1059A2C0;

    uint64_t targetAddress = slide + offset;

    unsigned char patch[] = {0x00, 0x00, 0x80, 0xD2, 0xC0, 0x03, 0x5F, 0xD6};

    MSHookMemory((void *)targetAddress, patch, sizeof(patch));
}
