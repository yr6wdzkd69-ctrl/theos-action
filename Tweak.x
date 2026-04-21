#include <substrate.h>
#include <mach/mach.h>
#include <mach-o/dyld.h>
#include <stdint.h>

// تعليمة العودة لـ ARM64
const uint32_t ARM64_RET = 0xD65F03C0; 

void apply_vanishing_patch(uintptr_t target_addr) {
    if (!target_addr) return;
    uint32_t* target = (uint32_t*)target_addr;

    // فك الحماية
    vm_protect(mach_task_self(), target_addr, 4, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);

    // حقن RET
    *target = ARM64_RET;

    // تنظيف الكاش (ضروري جداً لمعالج A13 في ايفون 11)
    __asm__ volatile ("dc cvau, %0; ic ivau, %0; dsb ish; isb" : : "r"(target) : "memory");

    // إعادة الحماية
    vm_protect(mach_task_self(), target_addr, 4, FALSE, VM_PROT_READ);
}

static void __attribute__((constructor)) init() {
    // ابحث عن دالة البلاغات (تأكد من الرمز الصحيح للعبتك)
    uintptr_t func_ptr = (uintptr_t)MSFindSymbol(NULL, "__ZN15SecurityManager16DispatchReportEi");
    if (func_ptr) {
        apply_vanishing_patch(func_ptr);
    }
}
