/* Copyright (C) 2017 Embecosm Limited and University of Bristol
   SPDX-License-Identifier: GPL-3.0-or-later */

#include <stdint.h>
#include <support.h>

#define CYCLE_LO_ADDR (*(volatile uint32_t *)0x0000FFE0)
#define CYCLE_HI_ADDR (*(volatile uint32_t *)0x0000FFE4)
#define INSTRET_LO_ADDR (*(volatile uint32_t *)0x0000FFE8)
#define INSTRET_HI_ADDR (*(volatile uint32_t *)0x0000FFEC)
#define DONE_ADDR (*(volatile uint32_t *)0x0000FFF0)

volatile uint32_t start_cycles_hi;
volatile uint32_t start_cycles_lo;
volatile uint32_t stop_cycles_hi;
volatile uint32_t stop_cycles_lo;

volatile uint32_t start_instret_hi;
volatile uint32_t start_instret_lo;
volatile uint32_t stop_instret_hi;
volatile uint32_t stop_instret_lo;

void initialise_board()
{
  __asm__ volatile("li a0, 0" : : : "memory");
}

void __attribute__((noinline))
start_trigger()
{
  /* Record starting cycle count. */
  __asm__ volatile("rdcycle %0" : "=r"(start_cycles_lo));
  __asm__ volatile("rdcycleh %0" : "=r"(start_cycles_hi));

  /* Record starting retired-instruction count. */
  __asm__ volatile("rdinstret %0" : "=r"(start_instret_lo));
  __asm__ volatile("rdinstreth %0" : "=r"(start_instret_hi));
}

void __attribute__((noinline))
stop_trigger()
{
  uint64_t start_cycles;
  uint64_t stop_cycles;
  uint64_t cycle_diff;

  uint64_t start_instret;
  uint64_t stop_instret;
  uint64_t instret_diff;

  uint32_t cycle_lo;
  uint32_t cycle_hi;
  uint32_t instret_lo;
  uint32_t instret_hi;

  /* Record ending cycle count. */
  __asm__ volatile("rdcycle %0" : "=r"(stop_cycles_lo));
  __asm__ volatile("rdcycleh %0" : "=r"(stop_cycles_hi));

  /* Record ending retired-instruction count. */
  __asm__ volatile("rdinstret %0" : "=r"(stop_instret_lo));
  __asm__ volatile("rdinstreth %0" : "=r"(stop_instret_hi));

  /* Calculate elapsed cycles and retired instructions. */
  start_cycles = ((uint64_t)start_cycles_hi << 32) |
                 (uint64_t)start_cycles_lo;
  stop_cycles = ((uint64_t)stop_cycles_hi << 32) |
                (uint64_t)stop_cycles_lo;
  cycle_diff = stop_cycles - start_cycles;

  start_instret = ((uint64_t)start_instret_hi << 32) |
                  (uint64_t)start_instret_lo;
  stop_instret = ((uint64_t)stop_instret_hi << 32) |
                 (uint64_t)stop_instret_lo;
  instret_diff = stop_instret - start_instret;

  cycle_lo = (uint32_t)cycle_diff;
  cycle_hi = (uint32_t)(cycle_diff >> 32);
  instret_lo = (uint32_t)instret_diff;
  instret_hi = (uint32_t)(instret_diff >> 32);

  /* Write results to memory-mapped registers. */
  CYCLE_LO_ADDR = cycle_lo;
  CYCLE_HI_ADDR = cycle_hi;
  INSTRET_LO_ADDR = instret_lo;
  INSTRET_HI_ADDR = instret_hi;

  /* Signal that measurement is complete. */
  DONE_ADDR = 1;

  /* Keep the processor here after reporting results. */
  while (1)
  {
    __asm__ volatile("nop");
  }
}
