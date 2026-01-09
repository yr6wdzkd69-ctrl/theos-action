#import <substrate.h>
#import <mach-o/dyld.h>
#import <UIKit/UIKit.h>

// --- زيادة الوزن الإجبارية (Fat Mode) ---
// مصفوفة حجمها 50,000 رقم (حوالي 200KB)
// volatile تعني: "ممنوع الحذف أيها المترجم!"
volatile int heavy_weight[50000];

// --- Offsets ---
#define OFF_INIT   0x952694
#define OFFSET_IS_AIMING_FIELD  0x10

uint64_t unity_base = 0;
void *myPlayer = NULL;
void (*old_Init)(void *instance, void *world, void *player);

intptr_t get_unity_slide() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && (strstr(name, "UnityFramework") || strstr(name, "CallOfDuty"))) {
            return _dyld_get_image_vmaddr_slide(i);
        }
    }
    return _dyld_get_image_vmaddr_slide(0);
}

void new_Init(void *instance, void *world, void *player) {
    if (instance != NULL) myPlayer = instance;
    if (old_Init) old_Init(instance, world, player);
}

void spy_on_scope() {
    if (myPlayer != NULL) {
        bool isScoped = *(bool*)((uint64_t)myPlayer + OFFSET_IS_AIMING_FIELD);
        if (isScoped) {
            NSLog(@"[ScopeBot] SCOPE ON");
        }
    }
}

// دالة لملء المصفوفة (عشان المترجم يقتنع أنها مهمة)
void fill_heavy_data() {
    for (int i = 0; i < 50000; i++) {
        heavy_weight[i] = i * 2; // عملية حسابية وهمية
    }
}

__attribute__((constructor)) static void initialize() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // تشغيل دالة الثقل
        fill_heavy_data();
        // طباعة رقم عشوائي من المصفوفة للتأكد
        NSLog(@"[ScopeBot] Weight Added. Value at 1000: %d", heavy_weight[1000]);

        unity_base = get_unity_slide();
        if (unity_base != 0) {
            uint64_t addr_Init = unity_base + OFF_INIT;
            MSHookFunction((void *)addr_Init, (void *)new_Init, (void **)&old_Init);
            
            [NSTimer scheduledTimerWithTimeInterval:0.1 
                                             target:[NSBlockOperation blockOperationWithBlock:^{ spy_on_scope(); }] 
                                           selector:@selector(main) 
                                           userInfo:nil 
                                            repeats:YES];
        }
    });
}
