/*
 * tcm_selftest.c -- end-to-end check of the RISC_V_TCM software flow
 *
 * Exercises everything tcm.ld and start.S set up: read-only data in the
 * ITCM (word, halfword, and byte loads through the ITCM data lane),
 * initialized .data and zeroed .bss in the DTCM, the stack (recursion),
 * and libgcc multiply, divide, and remainder.  main returns a hash of
 * the results; run_tcm_selftest.sh compares it with the same code built
 * for the host.
 */
#include <stdint.h>

static const uint32_t table[8] = {
    0x9E3779B9u, 0x7F4A7C15u, 0x85EBCA6Bu, 0xC2B2AE35u,
    0x27D4EB2Fu, 0x165667B1u, 0xD3A2646Cu, 0xFD7046C5u
};
static const char msg[] = "RISC_V_TCM half-cycle BRAM";
static const int16_t halves[4] = { -12345, 32767, -32768, 255 };
static const int8_t bytes[4] = { -3, 5, -128, 127 };

uint32_t seed = 0x1234567u;      /* .data */
uint32_t scratch[16];            /* .bss  */

static uint32_t mix(uint32_t h, uint32_t v)
{
    h ^= v + 0x9E3779B9u + (h << 6) + (h >> 2);
    return h * 2654435761u;
}

static uint32_t fib(uint32_t n)
{
    return n < 2 ? n : fib(n - 1) + fib(n - 2);
}

int main(void)
{
    uint32_t h = seed;
    uint32_t i;

    for (i = 0; i < 16; i++) {
        h = mix(h, scratch[i]);          /* .bss must start at zero */
        scratch[i] = table[i & 7] * (i + 1);
    }
    for (i = 0; i < 16; i++) {
        h = mix(h, scratch[i]);
    }
    for (i = 0; msg[i] != '\0'; i++) {
        h = mix(h, (uint32_t)(uint8_t)msg[i]);
    }
    for (i = 0; i < 4; i++) {
        h = mix(h, (uint32_t)(int32_t)halves[i]);
        h = mix(h, (uint32_t)(int32_t)bytes[i]);
    }
    h = mix(h, h / 7u);
    h = mix(h, h % 13u);
    h = mix(h, (uint32_t)((int32_t)h / -5));
    h = mix(h, fib(15));
    return (int)h;
}
