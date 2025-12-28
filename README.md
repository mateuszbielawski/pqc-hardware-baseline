# ReaxSec.IoT — Hardware PQC Baseline Experiment

This repository contains a baseline experiment exploring the offloading of Post-Quantum Cryptography (PQC) primitives from an MCU to a simple, deterministic hardware block.

The project demonstrates the isolation of **Montgomery reduction** (a core building block for Kyber/ML-KEM) on a low-cost FPGA to achieve execution determinism, a key factor for CRA and NIS2 compliance.

## Project Structure
- `/rtl`: Verilog source files for the Montgomery unit and UART communication.
- `/constraints`: Physical pin assignments for the Tang Nano 20k.
- `/benchmarks`: Python scripts for hardware testing and software reference.

## Baseline Results (5,000,000 Operations)
| Platform | Environment | Execution Time | Consistency |
| :--- | :--- | :--- | :--- |
| **FPGA (Gowin)** | 27MHz (Hardware) | **~200 ms** | **100% Deterministic** |
| **Apple M1** | C (Software) | 30ms - 40ms | High Jitter (~33% variance) |

*Note: The FPGA measurement includes full round-trip I/O via USB-Serial.*



## Why This Approach?
In constrained IoT systems, cryptographic drivers often share CPU cycles with the application, leading to interrupts and timing jitter. Under the **Cyber Resilience Act (CRA)** and **NIS2**, predictable behaviour is essential. 

Moving crypto to the hardware boundary provides:
1. **Separation of Concerns:** Firmware churn doesn't affect crypto performance.
2. **Predictability:** Zero jitter from OS scheduling or interrupts.
3. **Auditability:** A smaller, verifiable hardware codebase for security-critical logic.

## Getting Started
1. **Hardware:** Synthesize the RTL using Gowin EDA and flash the `top_benchmark.v` to a Tang Nano 20k.
2. **Verification:** Run `python3 benchmarks/benchmark_fpga.py` to trigger the hardware test.
3. **Comparison:** Run `python3 benchmarks/benchmark_software.py` to see the software reference performance and jitter. Run `gcc bench.c` and `./bench` to see the C implementation

## License
MIT
