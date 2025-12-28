#include <stdio.h>
#include <stdint.h>
#include <time.h>

uint32_t montgomery_reduction(uint32_t a) {
    uint32_t m = (a * 3327) & 0xFFFF;
    uint32_t t = (a + m * 3329) >> 16;
    if (t >= 3329) return t - 3329;
    return t;
}

int main() {
    uint32_t val = 0x42;
    uint32_t iters = 5000000;
    
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    for (uint32_t i = 0; i < iters; i++) {
        val = (montgomery_reduction(val) + 1);
    }

    clock_gettime(CLOCK_MONOTONIC, &end);
    double time_ms = (end.tv_sec - start.tv_sec) * 1000.0 + (end.tv_nsec - start.tv_nsec) / 1000000.0;

    printf("🎯 WYNIK M1 (C): 0x%x\n", val & 0xFF);
    printf("⏱️ CZAS M1 (C): %.4f ms\n", time_ms);
    return 0;
}