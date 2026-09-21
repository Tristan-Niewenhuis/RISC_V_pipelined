/* Copyright (C) 2017 Embecosm Limited and University of Bristol

   Contributor Graham Markall <graham.markall@embecosm.com>

   This file is part of Embench and was formerly part of the Bristol/Embecosm
   Embedded Benchmark Suite.

   SPDX-License-Identifier: GPL-3.0-or-later */

#include <stdint.h>
#include <support.h>

volatile uint32_t start_cycles_hi;
volatile uint32_t start_cycles_lo;
volatile uint32_t stop_cycles_hi;
volatile uint32_t stop_cycles_lo;

void
initialise_board ()
{
  __asm__ volatile ("li a0, 0" : : : "memory");
}

void __attribute__ ((noinline))
start_trigger ()
{
  __asm__ volatile("rdcycle %0" : "=r"(start_cycles_lo));
  __asm__ volatile("rdcycleh %0" : "=r"(start_cycles_hi));
}

void __attribute__ ((noinline))
stop_trigger ()
{
  __asm__ volatile("rdcycle %0" : "=r"(stop_cycles_lo));
  __asm__ volatile("rdcycleh %0" : "=r"(stop_cycles_hi));
  //do the subtraction
  uint64_t dif = (((uint64_t)stop_cycles_hi << 32) | (uint64_t)stop_cycles_lo) - (((uint64_t)start_cycles_hi << 32) | (uint64_t)start_cycles_lo);
  uint32_t dif_lo = (uint32_t)dif;
  uint32_t dif_hi = (uint32_t)(dif >> 32);
  //but the result in a0 and a1, and then a keyword in a2 to probe trigger on debugger
  __asm__ volatile("mv a0, %0" : : "r"(dif_lo) : "a0");
  __asm__ volatile("mv a1, %0" : : "r"(dif_hi) : "a1");
  __asm__ volatile("li a2, 0x12345678" : : : "a2");
}
