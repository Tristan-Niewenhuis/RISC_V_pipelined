#include <stdint.h>

#define LED ((uint32_t *)0x40000000)
#define SWITCHES ((uint32_t *)0x40010000)

volatile uint32_t start_cycles_hi;
volatile uint32_t start_cycles_lo;
volatile uint32_t stop_cycles_hi;
volatile uint32_t stop_cycles_lo;

void delay(uint32_t count)
{
  uint32_t i;
  for (i = 0; i < count; i++)
    ;
}

int main()
{
  uint32_t ledbits = 1;
  uint32_t switches;

  while (1)
  {
    __asm__ volatile("rdcycle %0" : "=r"(start_cycles_lo));
    __asm__ volatile("rdcycleh %0" : "=r"(start_cycles_hi));

    switches = *SWITCHES;
    while (ledbits != 0x8000)
    {
      *LED = ledbits;
      ledbits <<= 1;
      delay(switches);
    }
    while (ledbits != 1)
    {
      *LED = ledbits;
      ledbits >>= 1;
      delay(switches);
    }

    __asm__ volatile("rdcycle %0" : "=r"(stop_cycles_lo));
    __asm__ volatile("rdcycleh %0" : "=r"(stop_cycles_hi));
    // do the subtraction
    uint64_t dif = (((uint64_t)stop_cycles_hi << 32) | (uint64_t)stop_cycles_lo) - (((uint64_t)start_cycles_hi << 32) | (uint64_t)start_cycles_lo);
    uint32_t dif_lo = (uint32_t)dif;
    uint32_t dif_hi = (uint32_t)(dif >> 32);
    // but the result in a0 and a1, and then a keyword in a2 to probe trigger on debugger
    __asm__ volatile("mv a0, %0" : : "r"(dif_lo) : "a0");
    __asm__ volatile("mv a1, %0" : : "r"(dif_hi) : "a1");
    __asm__ volatile("li a2, 0x12345678" : : : "a2");
  }

  return 0;
}
