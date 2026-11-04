# Pipelining an RV32I RISC-V Softcore 
## (Currently sumbitting primary draft of research paper)
### A Study of Hazard Resolution, Performance, and FPGA Timing Tradeoffs

**Author:** Tristan Niewenhuis  
**Project Type:** Independent Study / Computer Architecture Research
**Advisor:** Dr. Larry Pyeatt, South Dakota Mines  
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

## Repo Structure
RISC_V.srcs/ is rtl source files. In there, the sources_1/new contains the vhdl code for the core and all supporting vhdl. sources_1/bd contains all the code for the block design that is used as the top level design to tie everything together. 

In sources_1/new, RISC_V_TCM.vhdl is the main top module of the processor.

The RISCV_package is used to set constants and select desired FORWARDING TYPE: NONE, PARTIAL (only from EX_MEM), and FULL (both from EX_MEM and MEM_WB)

RISC_V_AXI.vhdl is the version of that uses AXI interfaces to fetch and load/store which means it is compatible with external RAM, however there is a large stall penalty waiting for load/store and pre-fetch misses. This is a work in progress.

embecnh-iot-files/ are the complied tests used to test the core.

sim_test/test_2/ was used as a rough verifcation/debug test to catch any bugs in the pipeling process.

build_results/ contains the contents of the RISC_V.runs/impl_1 for each build type. The main builds are in the no_neg_edge sub-folders


## Core Architecture
It implements RV32I withthe Zicsr and Zicntr extensions on a harvard architecture. IF decodes the instruction and generates its immediate. With this early decode, ID hasa full cycle to read the write-first register file, detect RAW hazards, and compute the forwarding selects forthe next cycle, which are registered into the ID/EX register. EX holds the forwarding multiplexers, the ALU, the branch unit and target adder, the CSRs,and the load and store address and byte-strobe logic. The data BRAM is driven at the end of EX. EX also forms the link address of JAL and JALR, which the EX/MEM and MEM/WB data registers then carry like any other result. MEM aligns load data, and WB writes the register file. A taken branch resolvesin EX and flushes IF/ID and ID/EX, a penalty of two cycles. The next PC drives the address of the instruction BRAM directly, with the branch decisionas the last select. It uses static not-taken predictionfor every branch and jump. Instructions and datalive in separate 64 KB tightly coupled memories inblock RAM, clocked on the rising edge. The eight most significant words of the data memory are used asmemory-mapped I/O to communicate with the testcontroller. 

Prtial forwarding uses only the path from EX/MEM, and full forwarding uses the path from both EX/MEM and MEM/WB. A result used two instructions later costs one cycle unless MEM/WB forwards it, because the write-first register file supplies it a cycle later. A taken branch or jump costs two cycles in every variant. A branch or JAL whose target is the next instruction costs nothing, and a JALR always flushes. A constant of an enumerated type, FORWARDING AMOUNT in RISCV package, selects the variant. Generate statements in the datapath are used to choose the corresponding multiplexers in front of the the ALU and the branch unit, along with selecting the matching RAW-hazard logic. The decoder, register file, ALU, branch unit, memories, and pipeline registers are the same in every variant, so the variants differ only in their forwarding multiplexers and stall conditions.

Compared with no forwarding, full forwarding adds a three-input multiplexer in front of the ALU and branch unit selecting from the ID/EX, EX/MEM, or MEM/WB registers. Output is selected based on the forwarding detection logic that was previously computed in the IF/ID stage. The RAW hazard detection is also reduced from stalling the IF/ID register on any producer in the ID/EX or EX/MEM registers to only stalling for a load producer in the ID/EX register. Partial forwarding has only a two-input multiplexer from the ID/EX or EX/MEM registers. Par tial forwarding only stalls the IF/ID register under two conditions: a load producer in the ID/EX register or a producer in the EX/MEM register that was not caused by a RAW hazard in the previous clock.

### No Forwarding
TODO: Need to make these diagrams still
![Core Architecture](docs/images/None_Core_Architecture.png)
### Partial Forwarding (just from mem stage)
![Core Architecture](docs/images/Partial_Core_Architecture.png)
### Full Forwarding
![Core Architecture](docs/images/Full_Core_Architecture.png)

## Testing Framework
![Testing Framwork](docs/images/Testing_Framework.png)

## Partial Forwarding 3 insturction special case
Partial forwarding must account for the combination of three instructions in which the third instruction consumes results from the first two instructions(Ex. “sub x1, x2, x” then “add x4, x5, x6” then “orx7, x1, x4”). In the scenario shown in the image below, the ‘sub’ in EX/MEM will cause a RAW hazard for the ‘or’ in IF/ID. In the next cycle, this will cause a bubble between the ‘or’ and ‘add’ making it no longer forwardable with only partial forwarding. This also causes another RAW hazard which should be ignored, in favor of stalling the ‘add’ in the EX/MEM stageand ”popping” the bubble in ID/EX. This puts the ‘add’ back in position to be forwarded into the ‘or’ while only incurring a one-cycle penalty for this scenario.

![example](docs/images/Partial_Forward_Stall.png)

## Results

Paper Draft in progress and being sumbitted. Will be updated once accepted.


## Future Work
- Bimodal and Gshare predictors
- Partial Forwarding from only the MEM/WB stage?
- Possible exploration of more/less stages and the forwarding paths that could be explored from that

## Contact
Tristan Niewenhuis

Tristanniewenhuis@gmail.com

605-251-9304

https://www.linkedin.com/in/tristanniewenhuis/

https://github.com/Tristan-Niewenhuis



