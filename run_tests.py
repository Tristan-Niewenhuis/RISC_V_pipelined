#!/usr/bin/env python3

import csv
import os
import re
import struct
import subprocess
import sys
from pathlib import Path


# ============================================================
# USER CONFIGURATION
# ============================================================

VIVADO = r"C:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat"

HW_AXI = "hw_axi_1"
BITSTREAM = None
HW_DEVICE = None

# AXI address map (byte-addressed; each 32-bit word advances by 4 bytes)
IRAM_AXI_BASE = 0x00000000
DRAM_AXI_BASE = 0x80000000

CONTROL_RESET_ADDR = 0xC0000014
STATUS_ADDR        = 0xC0000010
CYCLE_LO_ADDR      = 0xC0000000
CYCLE_HI_ADDR      = 0xC0000004
INSTRET_LO_ADDR    = 0xC0000008
INSTRET_HI_ADDR    = 0xC000000C

CPU_RESET_ASSERTED = 0
CPU_RESET_RELEASED = 1
DONE_MASK = 0x00000001

# Delay after each individual AXI transaction, in milliseconds.
AXI_TRANSACTION_DELAY_MS = 0

DONE_POLL_INTERVAL = 0.25
DONE_TIMEOUT_SECONDS = 60.0

TESTS = [
    {
        "name": "aha-mont64",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\aha-mont64\aha-mont64_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\aha-mont64\aha-mont64_ram.hex",
    },
    {
        "name": "crc32",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\crc32\crc32_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\crc32\crc32_ram.hex",
    },
    {
        "name": "depthconv",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\depthconv\depthconv_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\depthconv\depthconv_ram.hex",
    },
    {
        "name": "edn",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\edn\edn_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\edn\edn_ram.hex",
    },
    {
        "name": "fake_test",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\fake_test\fake_test_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\fake_test\fake_test_ram.hex",
    },
    {
        "name": "huffbench",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\huffbench\huffbench_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\huffbench\huffbench_ram.hex",
    },
    {
        "name": "matmult-int",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\matmult-int\matmult-int_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\matmult-int\matmult-int_ram.hex",
    },
    {
        "name": "md5sum",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\md5sum\md5sum_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\md5sum\md5sum_ram.hex",
    },
    {
        "name": "nettle-aes",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\nettle-aes\nettle-aes_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\nettle-aes\nettle-aes_ram.hex",
    },
    {
        "name": "nettle-sha256",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\nettle-sha256\nettle-sha256_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\nettle-sha256\nettle-sha256_ram.hex",
    },
    {
        "name": "nsichneu",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\nsichneu\nsichneu_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\nsichneu\nsichneu_ram.hex",
    },
    {
        "name": "picojpeg",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\picojpeg\picojpeg_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\picojpeg\picojpeg_ram.hex",
    },
    {
        "name": "qrduino",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\qrduino\qrduino_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\qrduino\qrduino_ram.hex",
    },
    {
        "name": "sglib-combined",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\sglib-combined\sglib-combined_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\sglib-combined\sglib-combined_ram.hex",
    },
    {
        "name": "slre",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\slre\slre_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\slre\slre_ram.hex",
    },
    {
        "name": "statemate",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\statemate\statemate_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\statemate\statemate_ram.hex",
    },
    {
        "name": "tarfind",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\tarfind\tarfind_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\tarfind\tarfind_ram.hex",
    },
    {
        "name": "ud",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\ud\ud_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\ud\ud_ram.hex",
    },
    {
        "name": "wikisort",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\wikisort\wikisort_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\wikisort\wikisort_ram.hex",
    },
    {
        "name": "xgboost",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\xgboost\xgboost_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\xgboost\xgboost_ram.hex",
    },
]

RESULTS_FILE = "embench_results.csv"


# ============================================================
# UTILITY FUNCTIONS
# ============================================================

def tcl_hex(value):
    """Format an integer as an 8-digit Tcl/Vivado hex address."""
    return f"{value:08X}"


def tcl_data_word(value):
    """Format a 32-bit word for Vivado."""
    return f"{value & 0xFFFFFFFF:08X}"


def load_memory_words(filename):
    """
    Load a memory image as 32-bit words.
    .hex/.mem/.txt: one hexadecimal word per line.
    Other extensions: raw bytes grouped into little-endian words.
    """
    filename = Path(filename)

    if not filename.exists():
        raise FileNotFoundError(f"Memory image does not exist: {filename}")

    if filename.suffix.lower() in {".hex", ".mem", ".txt"}:
        words = []
        for line_number, raw_line in enumerate(
            filename.read_text(encoding="utf-8-sig").splitlines(), start=1
        ):
            line = raw_line.strip()
            if not line or line.startswith("#") or line.startswith("//"):
                continue

            line = re.split(r"\s+#|\s+//", line, maxsplit=1)[0].strip()
            if not line:
                continue
            if line.lower().startswith("0x"):
                line = line[2:]

            if not re.fullmatch(r"[0-9a-fA-F]{1,8}", line):
                raise ValueError(
                    f"Invalid hex word in {filename}, line {line_number}: "
                    f"{raw_line!r}. Expected one 32-bit hex word per line."
                )
            words.append(int(line, 16))
        return words

    data = filename.read_bytes()
    if not data:
        return []

    if len(data) % 4 != 0:
        padding = 4 - (len(data) % 4)
        print(
            f"Warning: {filename} is not a multiple of 4 bytes. "
            f"Adding {padding} zero bytes."
        )
        data += b"\x00" * padding

    return [
        struct.unpack_from("<I", data, offset)[0]
        for offset in range(0, len(data), 4)
    ]


def validate_test(test):
    for field in ("name", "iram_file", "dram_file"):
        if field not in test:
            raise ValueError(f"Test is missing required field '{field}': {test}")


# ============================================================
# TCL GENERATION
# ============================================================

def tcl_single_word_transaction(name, axi_address, word):
    """
    Generate one single-word JTAG-to-AXI write transaction.
    A transaction is run, delayed, then deleted before the next word.
    """
    return f"""
# Write one word at 0x{tcl_hex(axi_address)}
delete_hw_axi_txn -quiet [get_hw_axi_txns {name}]
create_hw_axi_txn {name} $hw_axi \\
    -type WRITE \\
    -address {tcl_hex(axi_address)} \\
    -len 1 \\
    -data {{{tcl_data_word(word)}}}
run_axi_delayed {name}
delete_hw_axi_txn -quiet [get_hw_axi_txns {name}]
"""


def generate_memory_load_tcl(prefix, base_address, words):
    """
    Generate a separate single-word AXI write for every memory word.
    AXI addresses are byte addresses, so word i is at base + 4*i.
    """
    chunks = []
    for index, word in enumerate(words):
        address = base_address + 4 * index
        transaction_name = f"{prefix}_{index}"
        chunks.append(
            tcl_single_word_transaction(transaction_name, address, word)
        )
    return "\n".join(chunks)


# ============================================================
# TCL SCRIPT GENERATION
# ============================================================

def generate_tcl_script(tests):
    lines = [
        "# ============================================================",
        "# Automatically generated by run_embench.py",
        "# Single-word AXI writes with a short delay after each transaction",
        "# ============================================================",
        "",
        "open_hw_manager",
        "connect_hw_server",
        "open_hw_target",
    ]

    if HW_DEVICE is None:
        lines.append("set hw_device [lindex [get_hw_devices] 0]")
    else:
        lines.append(f"set hw_device [get_hw_devices {HW_DEVICE}]")

    lines.append("refresh_hw_device $hw_device")

    if BITSTREAM is not None:
        bitstream_tcl = BITSTREAM.replace("\\", "/")
        lines.extend([
            "",
            "# Program FPGA",
            f"set_property PROGRAM.FILE {{{bitstream_tcl}}} $hw_device",
            "program_hw_devices $hw_device",
            "refresh_hw_device $hw_device",
        ])

    lines.extend([
        "",
        "# Locate JTAG-to-AXI Master",
        f"set hw_axi [get_hw_axis {HW_AXI}]",
        "",
        "# Reset JTAG-to-AXI Master",
        "reset_hw_axi $hw_axi",
        "",
        "# Delay helper: run one transaction, then wait briefly",
        "proc run_axi_delayed {txn_name} {",
        "    run_hw_axi [get_hw_axi_txns $txn_name]",
        f"    after {AXI_TRANSACTION_DELAY_MS}",
        "}",
        "",
        'set result_file "__RESULT_FILE__"',
        'set result_fp [open $result_file "w"]',
        'puts $result_fp "name,cycle_low,cycle_high,cycles,instret_low,instret_high,instret,elapsed_seconds"',
    ])

    for test_number, test in enumerate(tests):
        validate_test(test)
        name = test["name"]
        iram_words = load_memory_words(test["iram_file"])
        dram_words = load_memory_words(test["dram_file"])

        print(
            f"Preparing {name}: {len(iram_words)} IRAM words, "
            f"{len(dram_words)} DRAM words"
        )

        lines.extend([
            "",
            "# ============================================================",
            f"# TEST {test_number}: {name}",
            "# ============================================================",
            "",
            "# Assert CPU reset",
            f"create_hw_axi_txn reset_cpu_{test_number} $hw_axi -type WRITE "
            f"-address {tcl_hex(CONTROL_RESET_ADDR)} "
            f"-data {tcl_hex(CPU_RESET_ASSERTED)}",
            f"run_axi_delayed reset_cpu_{test_number}",
            "",
            "# Load IRAM (one AXI transaction per 32-bit word)",
            generate_memory_load_tcl(
                f"iram_{test_number}", IRAM_AXI_BASE, iram_words
            ),
            "",
            "# Load DRAM (one AXI transaction per 32-bit word)",
            generate_memory_load_tcl(
                f"dram_{test_number}", DRAM_AXI_BASE, dram_words
            ),
            "",
            "# Release CPU reset",
            f"create_hw_axi_txn release_cpu_{test_number} $hw_axi -type WRITE "
            f"-address {tcl_hex(CONTROL_RESET_ADDR)} "
            f"-data {tcl_hex(CPU_RESET_RELEASED)}",
            f"run_axi_delayed release_cpu_{test_number}",
            "",
            "# Poll STATUS until DONE = 1",
            f"set done_{test_number} 0",
            f"set poll_start_{test_number} [clock seconds]",
            f"create_hw_axi_txn status_{test_number} $hw_axi -type READ "
            f"-address {tcl_hex(STATUS_ADDR)}",
            f"while {{!$done_{test_number}}} {{",
            f"    run_hw_axi [get_hw_axi_txns status_{test_number}]",
            f"    set status_data_{test_number} "
            f"[get_property DATA [get_hw_axi_txns status_{test_number}]]",
            f"    scan $status_data_{test_number} %x status_value_{test_number}",
            f"    if {{($status_value_{test_number} & {DONE_MASK}) != 0}} {{",
            f"        set done_{test_number} 1",
            "    }",
            f"    if {{[expr {{[clock seconds] - $poll_start_{test_number}}}] >= {int(DONE_TIMEOUT_SECONDS)}}} {{",
            f'        puts "ERROR: Timeout waiting for DONE on {name}"',
            f'        puts $result_fp "{name},TIMEOUT"',
            "        flush $result_fp",
            "        close $result_fp",
            "        close_hw_target",
            "        disconnect_hw_server",
            "        close_hw_manager",
            "        exit 1",
            "    }",
            f"    after {int(DONE_POLL_INTERVAL * 1000)}",
            "}",
            "",
        ])

        counter_specs = [
            ("cycle_lo", CYCLE_LO_ADDR),
            ("cycle_hi", CYCLE_HI_ADDR),
            ("instret_lo", INSTRET_LO_ADDR),
            ("instret_hi", INSTRET_HI_ADDR),
        ]

        for counter_name, address in counter_specs:
            lines.extend([
                f"# Read {counter_name}",
                f"create_hw_axi_txn {counter_name}_{test_number} $hw_axi "
                f"-type READ -address {tcl_hex(address)}",
                f"run_hw_axi [get_hw_axi_txns {counter_name}_{test_number}]",
                f"set {counter_name}_data_{test_number} "
                f"[get_property DATA [get_hw_axi_txns {counter_name}_{test_number}]]",
                f"scan ${counter_name}_data_{test_number} %x {counter_name}_{test_number}",
                "",
            ])

        lines.extend([
            "# Combine 32-bit halves into 64-bit values",
            f"set cycles_{test_number} "
            f"[expr {{($cycle_hi_{test_number} << 32) | $cycle_lo_{test_number}}}]",
            f"set instret_{test_number} "
            f"[expr {{($instret_hi_{test_number} << 32) | $instret_lo_{test_number}}}]",
            "",
            f'puts "TEST: {name}"',
            f'puts "  cycles  = $cycles_{test_number}"',
            f'puts "  instret = $instret_{test_number}"',
            f'puts $result_fp "{name},$cycle_lo_{test_number},$cycle_hi_{test_number},$cycles_{test_number},$instret_lo_{test_number},$instret_hi_{test_number},$instret_{test_number},0"',
            "flush $result_fp",
            "",
            "# Put CPU back into reset before next test",
            f"create_hw_axi_txn final_reset_{test_number} $hw_axi -type WRITE "
            f"-address {tcl_hex(CONTROL_RESET_ADDR)} "
            f"-data {tcl_hex(CPU_RESET_ASSERTED)}",
            f"run_axi_delayed final_reset_{test_number}",
        ])

    lines.extend([
        "",
        "close $result_fp",
        "close_hw_target",
        "disconnect_hw_server",
        "close_hw_manager",
        "exit",
        "",
    ])

    return "\n".join(lines)


def main():
    if not TESTS:
        print("ERROR: TESTS list is empty.")
        sys.exit(1)

    for test in TESTS:
        validate_test(test)
        for memory_type in ("iram_file", "dram_file"):
            if not os.path.isfile(test[memory_type]):
                print(
                    f"ERROR: {memory_type} does not exist:\n"
                    f"  {test[memory_type]}"
                )
                sys.exit(1)

    results_path = Path(RESULTS_FILE).resolve()
    tcl_path = Path.cwd() / "run_embench.tcl"

    tcl_script = generate_tcl_script(TESTS)
    result_tcl_path = str(results_path).replace("\\", "/")
    tcl_script = tcl_script.replace("__RESULT_FILE__", result_tcl_path)
    tcl_path.write_text(tcl_script, encoding="utf-8")

    print()
    print("============================================================")
    print("Starting Vivado")
    print("============================================================")
    print(f"Vivado : {VIVADO}")
    print(f"Tcl    : {tcl_path}")
    print(f"Output : {results_path}")
    print()

    command = [VIVADO, "-mode", "batch", "-source", str(tcl_path)]

    try:
        process = subprocess.run(command, check=False)
    except FileNotFoundError:
        print(f"ERROR: Could not find Vivado executable '{VIVADO}'.")
        print("Set VIVADO to the full path to vivado.bat if necessary.")
        sys.exit(1)

    print()
    print("============================================================")
    print("Vivado finished")
    print("============================================================")

    if process.returncode != 0:
        print(f"Vivado exited with error code {process.returncode}")
        sys.exit(process.returncode)

    if results_path.exists():
        print(f"Results written to:\n  {results_path}")
    else:
        print("WARNING: Results file was not created.")


if __name__ == "__main__":
    main()
