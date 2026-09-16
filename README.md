# Pipelining an RV32I RISC-V Core (Work in progress)
### A Study of Hazard Resolution, Performance, and FPGA Timing Tradeoffs

**Author:** Tristan Niewenhuis  
**Project Type:** Independent Study / Computer Architecture Research  
**Platform:** Digilent Nexys A7 (Xilinx Artix-7 xc7a100tcsg324-1)  
**Date:** Fall 2026

---

## Overview

This project explores the design and implementation of a classic five-stage pipelined RV32I RISC-V processor on FPGA hardware.

The primary goal is not simply to pipeline a processor, but to experimentally investigate a tradeoff in computer architecture:

> Does reducing pipeline stalls through forwarding always improve real-world performance?

This repository documents the architectural modifications, RTL implementation, benchmarking infrastructure, and experimental evaluation used to answer that question.

---

## Research Question

This work evaluates three hazard-handling implementations on the same RV32I processor:

### 1. Stall-Only Pipeline
Data hazards are detected and resolved entirely through pipeline stalls.

### 2. Partial Forwarding
Values are forwarded from the EX/MEM stage while other hazards still require stalls.

### 3. Full Forwarding
Forwarding paths exist from both EX/MEM and MEM/WB stages.

---

## Why This Matters

Many processor design projects stop after implementing forwarding and report improved CPI.

This project goes further by measuring:

- CPI (Cycles Per Instruction)
- Fmax (Maximum Clock Frequency)
- LUT utilization
- Flip-Flop utilization

The final performance metric is:

Performance = IPC × Fmax

--

## Processor Architecture
The processor is based on the RV32I instruction set and is converted from a non-pipelined implementation into a classic five-stage pipeline.

## Repo Structure TODO
All sources in the RISC_V.srcs/
RISC_V.vhdl is the top module of the processor, and the block design is used to connect it to native bram and clocking.

RISC_V_AXI.vhdl is the version of that uses AXI interfaces to fetch and load/store which means it is compatible with external RAM, however there is a large stall penalty waiting for load/store and pre-fetch misses.

Planning on doing forwarding comparisons for both native bram, and axi bus implementations.

## Results TODO
Come back in November 2026

## Future Work
- Bimodal and Gshare predictors

## Contact
Tristan Niewenhuis

Tristanniewenhuis@gmail.com

605-251-9304

https://www.linkedin.com/in/tristanniewenhuis/

https://github.com/Tristan-Niewenhuis

