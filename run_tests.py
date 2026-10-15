#!/usr/bin/env python3

import csv
import os
import re
import struct
import subprocess
import sys
import time
from pathlib import Path


# ============================================================
# USER CONFIGURATION
# ============================================================

# Vivado executable.
# If "vivado" is already in PATH, leave this as "vivado".
VIVADO = "C:\\AMDDesignTools\\2026.1\\Vivado\\bin\\vivado.bat"

# ------------------------------------------------------------
# FPGA / JTAG configuration
# ------------------------------------------------------------

# Name of the JTAG-to-AXI Master instance in Vivado.
# Usually hw_axi_1, but check Hardware Manager if different.
HW_AXI = "hw_axi_1"

# Optional bitstream.
#
# Set to None if the FPGA is already programmed and you do NOT
# want this script to program it.
#
# Example:
# BITSTREAM = r"C:\RISC_V_research\build\RISC_V.bit"
BITSTREAM = None

# FPGA device name.
#
# Normally the first device is enough:
#   [lindex [get_hw_devices] 0]
#
# Leave as None unless you specifically need a device name.
HW_DEVICE = None


# ------------------------------------------------------------
# AXI address map
# ------------------------------------------------------------

# CHANGE THESE to match your Vivado address map.

# AXI address where IRAM is visible through JTAG-to-AXI.
IRAM_AXI_BASE = 0x00000000

# AXI address where DRAM is visible through JTAG-to-AXI.
DRAM_AXI_BASE = 0x80000000

# Test controller addresses.
#
# Based on the addresses you gave:
#
#   C0000000 = cycle low
#   C0000004 = cycle high
#   C0000008 = instret low
#   C000000C = instret high
#   C0000010 = STATUS
#   C0000014 = CPU RESET
#
CONTROL_RESET_ADDR = 0xC0000014
STATUS_ADDR        = 0xC0000010
CYCLE_LO_ADDR      = 0xC0000000
CYCLE_HI_ADDR      = 0xC0000004
INSTRET_LO_ADDR    = 0xC0000008
INSTRET_HI_ADDR    = 0xC000000C


# ------------------------------------------------------------
# CPU control values
# ------------------------------------------------------------

CPU_RESET_ASSERTED = 0
CPU_RESET_RELEASED = 1

# DONE is bit 0 of STATUS.
DONE_MASK = 0x00000001


# ------------------------------------------------------------
# Test execution configuration
# ------------------------------------------------------------

# Maximum AXI burst length.
#
# JTAG-to-AXI supports burst transactions. We split large memory
# images into chunks so we do not make one enormous transaction.
AXI_BURST_WORDS = 256

# How often to poll DONE.
DONE_POLL_INTERVAL = 0.25

# Maximum time to wait for a benchmark.
# Increase this for long-running benchmarks.
DONE_TIMEOUT_SECONDS = 60.0


# ============================================================
# TEST LIST
# ============================================================

# Add tests here.
#
# Each test needs:
#
#   name      - name that will appear in the results CSV
#   iram_file - word-per-line .hex image or raw little-endian .bin for instruction memory
#   dram_file - word-per-line .hex image or raw little-endian .bin for data memory
#
# You can add other fields later if you need them.
#
# Example:
#
# TESTS = [
#     {
#         "name": "crc32",
#         "iram_file": r"C:\embench\crc32_iram.bin",
#         "dram_file": r"C:\embench\crc32_dram.bin",
#     },
#     {
#         "name": "cubic",
#         "iram_file": r"C:\embench\cubic_iram.bin",
#         "dram_file": r"C:\embench\cubic_dram.bin",
#     },
# ]

TESTS = [
    {
        "name": "empty_test",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\fake_test\fake_test_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\fake_test\fake_test_ram.hex",
    },

    {
        "name": "crc32",
        "iram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\crc32\crc32_rom.hex",
        "dram_file": r"C:\RISC_V_research\RISC_V_pipelined_private\embench-iot-files\build\src\crc32\crc32_ram.hex",
    },

    # Add more tests here.
]


# ------------------------------------------------------------
# Output
# ------------------------------------------------------------

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

    Supported formats:
      - .hex / .mem / .txt: one 32-bit hexadecimal word per line,
        e.g. 00020117. Each line is the numeric word value; words are
        written to consecutive AXI addresses in increasing order.
      - Other extensions (including .bin): raw bytes grouped into
        little-endian 32-bit words.

    Text files may contain blank lines, whole-line comments starting
    with # or //, and trailing comments after a word.
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

    # Raw binary: four bytes per word, little-endian.
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
    required = ["name", "iram_file", "dram_file"]

    for field in required:
        if field not in test:
            raise ValueError(
                f"Test is missing required field '{field}': {test}"
            )


# ============================================================
# TCL GENERATION
# ============================================================

def tcl_write_transaction(name, axi_address, words):
    """
    Generate Tcl for one JTAG-to-AXI burst write.

    Vivado expects the data list in the order corresponding to
    increasing addresses.
    """

    if not words:
        return ""

    data_string = "_".join(tcl_data_word(w) for w in words)

    return f"""
# ------------------------------------------------------------
# Write {len(words)} words at {tcl_hex(axi_address)}
# ------------------------------------------------------------

delete_hw_axi_txn -quiet [get_hw_axi_txns {name}]

create_hw_axi_txn {name} [get_hw_axis {HW_AXI}] \\
    -type WRITE \\
    -address {tcl_hex(axi_address)} \\
    -len {len(words)} \\
    -data {{{data_string}}}

run_hw_axi [get_hw_axi_txns {name}]
"""


def generate_memory_load_tcl(prefix, base_address, words):
    """
    Generate multiple AXI burst writes for a memory image.
    """

    chunks = []

    for chunk_number, start in enumerate(
        range(0, len(words), AXI_BURST_WORDS)
    ):
        chunk = words[start:start + AXI_BURST_WORDS]

        address = base_address + start

        transaction_name = (
            f"{prefix}_{chunk_number}"
        )

        chunks.append(
            tcl_write_transaction(
                transaction_name,
                address,
                chunk,
            )
        )

    return "\n".join(chunks)


# ============================================================
# TCL SCRIPT GENERATION
# ============================================================

def generate_tcl_script(tests):
    """
    Generate a complete Vivado Tcl script.

    The Tcl script:
      1. Opens hardware manager
      2. Connects to hw_server
      3. Opens the JTAG target
      4. Optionally programs the FPGA
      5. Finds hw_axi_1
      6. Runs every benchmark
      7. Writes results to a temporary results file
    """

    lines = []

    lines.append("# ============================================================")
    lines.append("# Automatically generated by run_embench.py")
    lines.append("# ============================================================")
    lines.append("")

    lines.append("open_hw_manager")
    lines.append("connect_hw_server")
    lines.append("open_hw_target")

    if HW_DEVICE is None:
        lines.append("set hw_device [lindex [get_hw_devices] 0]")
    else:
        lines.append(
            f"set hw_device [get_hw_devices {HW_DEVICE}]"
        )

    # Refresh device.
    lines.append("refresh_hw_device $hw_device")

    if BITSTREAM is not None:
        bitstream_tcl = BITSTREAM.replace("\\", "/")

        lines.append("")
        lines.append("# Program FPGA")
        lines.append(
            f"set_property PROGRAM.FILE {{{bitstream_tcl}}} $hw_device"
        )
        lines.append(
            "program_hw_devices $hw_device"
        )
        lines.append(
            "refresh_hw_device $hw_device"
        )

    lines.append("")
    lines.append("# Locate JTAG-to-AXI Master")
    lines.append(
        f"set hw_axi [get_hw_axis {HW_AXI}]"
    )

    lines.append("")
    lines.append("# Reset JTAG-to-AXI Master")
    lines.append(
        f"reset_hw_axi $hw_axi"
    )

    # Open result file from Tcl.
    #
    # Python will create a temporary filename and replace this
    # placeholder before writing the actual Tcl file.
    lines.append("")
    lines.append(
        'set result_file "__RESULT_FILE__"'
    )
    lines.append(
        'set result_fp [open $result_file "w"]'
    )

    lines.append(
        'puts $result_fp "name,cycle_low,cycle_high,cycles,instret_low,instret_high,instret,elapsed_seconds"'
    )

    # ============================================================
    # Each test
    # ============================================================

    for test_number, test in enumerate(tests):

        validate_test(test)

        name = test["name"]

        iram_words = load_memory_words(test["iram_file"])
        dram_words = load_memory_words(test["dram_file"])

        print(
            f"Preparing {name}: "
            f"{len(iram_words)} IRAM words, "
            f"{len(dram_words)} DRAM words"
        )

        lines.append("")
        lines.append(
            "# ============================================================"
        )
        lines.append(
            f"# TEST {test_number}: {name}"
        )
        lines.append(
            "# ============================================================"
        )

        # --------------------------------------------------------
        # CPU RESET
        # --------------------------------------------------------

        lines.append("")
        lines.append("# Assert CPU reset")
        lines.append(
            f"create_hw_axi_txn reset_cpu_{test_number} "
            f"$hw_axi -type WRITE "
            f"-address {tcl_hex(CONTROL_RESET_ADDR)} "
            f"-data {tcl_hex(CPU_RESET_ASSERTED)}"
        )
        lines.append(
            f"run_hw_axi [get_hw_axi_txns reset_cpu_{test_number}]"
        )

        # --------------------------------------------------------
        # LOAD IRAM
        # --------------------------------------------------------

        lines.append("")
        lines.append("# Load IRAM")

        iram_tcl = generate_memory_load_tcl(
            f"iram_{test_number}",
            IRAM_AXI_BASE,
            iram_words,
        )

        lines.append(iram_tcl)

        # --------------------------------------------------------
        # LOAD DRAM
        # --------------------------------------------------------

        lines.append("")
        lines.append("# Load DRAM")

        dram_tcl = generate_memory_load_tcl(
            f"dram_{test_number}",
            DRAM_AXI_BASE,
            dram_words,
        )

        lines.append(dram_tcl)

        # --------------------------------------------------------
        # CLEAR / INITIALIZE STATUS
        # --------------------------------------------------------

        # The exact behavior here depends on your test_controller.
        #
        # If writing STATUS is not supported, remove this section.
        #
        # We do NOT assume anything about a status-clear register
        # because you only specified STATUS bit 0 as DONE.
        #
        # If your controller automatically clears DONE when CPU
        # reset is asserted, this section is unnecessary.

        # --------------------------------------------------------
        # RELEASE CPU RESET
        # --------------------------------------------------------

        lines.append("")
        lines.append("# Release CPU reset")

        lines.append(
            f"create_hw_axi_txn release_cpu_{test_number} "
            f"$hw_axi -type WRITE "
            f"-address {tcl_hex(CONTROL_RESET_ADDR)} "
            f"-data {tcl_hex(CPU_RESET_RELEASED)}"
        )

        lines.append(
            f"run_hw_axi [get_hw_axi_txns release_cpu_{test_number}]"
        )

        # --------------------------------------------------------
        # POLL DONE
        # --------------------------------------------------------

        lines.append("")
        lines.append("# Poll STATUS until DONE = 1")

        lines.append(
            f"set done_{test_number} 0"
        )

        lines.append(
            f"set poll_start_{test_number} [clock seconds]"
        )

        # Create this transaction once. Recreate-on-each-poll causes
        # Labtools error 27-1991 because the transaction name already exists.
        lines.append(
            f"create_hw_axi_txn status_{test_number} "
            f"$hw_axi -type READ "
            f"-address {tcl_hex(STATUS_ADDR)}"
        )

        lines.append(
            f"while {{!$done_{test_number}}} {{"
        )

        lines.append(
            f"    run_hw_axi [get_hw_axi_txns status_{test_number}]"
        )

        lines.append(
            f"    set status_data_{test_number} "
            f"[get_property DATA [get_hw_axi_txns status_{test_number}]]"
        )

        lines.append(
            f"    scan $status_data_{test_number} %x status_value_{test_number}"
        )

        lines.append(
            f"    if {{($status_value_{test_number} & {DONE_MASK}) != 0}} {{"
        )

        lines.append(
            f"        set done_{test_number} 1"
        )

        lines.append(
            "    }"
        )

        lines.append(
            f"    if {{[expr {{[clock seconds] - $poll_start_{test_number}}}] >= {int(DONE_TIMEOUT_SECONDS)}}} {{"
        )

        lines.append(
            f'        puts "ERROR: Timeout waiting for DONE on {name}"'
        )

        lines.append(
            f'        puts $result_fp "{name},TIMEOUT"'
        )

        lines.append(
            "        flush $result_fp"
        )

        lines.append(
            "        close $result_fp"
        )

        lines.append(
            "        close_hw_target"
        )

        lines.append(
            "        disconnect_hw_server"
        )

        lines.append(
            "        close_hw_manager"
        )

        lines.append(
            "        exit 1"
        )

        lines.append(
            "    }"
        )

        lines.append(
            f"    after {int(DONE_POLL_INTERVAL * 1000)}"
        )

        lines.append("}")

        # --------------------------------------------------------
        # READ CYCLE
        # --------------------------------------------------------

        lines.append("")
        lines.append("# Read cycle low")

        lines.append(
            f"create_hw_axi_txn cycle_lo_{test_number} "
            f"$hw_axi -type READ "
            f"-address {tcl_hex(CYCLE_LO_ADDR)}"
        )

        lines.append(
            f"run_hw_axi [get_hw_axi_txns cycle_lo_{test_number}]"
        )

        lines.append(
            f"set cycle_lo_data_{test_number} "
            f"[get_property DATA [get_hw_axi_txns cycle_lo_{test_number}]]"
        )

        lines.append(
            f"scan $cycle_lo_data_{test_number} %x cycle_lo_{test_number}"
        )

        lines.append("")
        lines.append("# Read cycle high")

        lines.append(
            f"create_hw_axi_txn cycle_hi_{test_number} "
            f"$hw_axi -type READ "
            f"-address {tcl_hex(CYCLE_HI_ADDR)}"
        )

        lines.append(
            f"run_hw_axi [get_hw_axi_txns cycle_hi_{test_number}]"
        )

        lines.append(
            f"set cycle_hi_data_{test_number} "
            f"[get_property DATA [get_hw_axi_txns cycle_hi_{test_number}]]"
        )

        lines.append(
            f"scan $cycle_hi_data_{test_number} %x cycle_hi_{test_number}"
        )

        # --------------------------------------------------------
        # READ INSTRET
        # --------------------------------------------------------

        lines.append("")
        lines.append("# Read retired instructions low")

        lines.append(
            f"create_hw_axi_txn instret_lo_{test_number} "
            f"$hw_axi -type READ "
            f"-address {tcl_hex(INSTRET_LO_ADDR)}"
        )

        lines.append(
            f"run_hw_axi [get_hw_axi_txns instret_lo_{test_number}]"
        )

        lines.append(
            f"set instret_lo_data_{test_number} "
            f"[get_property DATA [get_hw_axi_txns instret_lo_{test_number}]]"
        )

        lines.append(
            f"scan $instret_lo_data_{test_number} %x instret_lo_{test_number}"
        )

        lines.append("")
        lines.append("# Read retired instructions high")

        lines.append(
            f"create_hw_axi_txn instret_hi_{test_number} "
            f"$hw_axi -type READ "
            f"-address {tcl_hex(INSTRET_HI_ADDR)}"
        )

        lines.append(
            f"run_hw_axi [get_hw_axi_txns instret_hi_{test_number}]"
        )

        lines.append(
            f"set instret_hi_data_{test_number} "
            f"[get_property DATA [get_hw_axi_txns instret_hi_{test_number}]]"
        )

        lines.append(
            f"scan $instret_hi_data_{test_number} %x instret_hi_{test_number}"
        )

        # --------------------------------------------------------
        # COMBINE 64-BIT VALUES
        # --------------------------------------------------------

        lines.append("")
        lines.append("# Combine 32-bit halves into 64-bit values")

        lines.append(
            f"set cycles_{test_number} "
            f"[expr {{($cycle_hi_{test_number} << 32) | $cycle_lo_{test_number}}}]"
        )

        lines.append(
            f"set instret_{test_number} "
            f"[expr {{($instret_hi_{test_number} << 32) | $instret_lo_{test_number}}}]"
        )

        # --------------------------------------------------------
        # OUTPUT RESULT
        # --------------------------------------------------------

        lines.append("")
        lines.append(
            f'puts "TEST: {name}"'
        )

        lines.append(
            f'puts "  cycles  = $cycles_{test_number}"'
        )

        lines.append(
            f'puts "  instret = $instret_{test_number}"'
        )

        lines.append(
            f'puts $result_fp "{name},$cycle_lo_{test_number},$cycle_hi_{test_number},$cycles_{test_number},$instret_lo_{test_number},$instret_hi_{test_number},$instret_{test_number},0"'
        )

        lines.append(
            "flush $result_fp"
        )

        # --------------------------------------------------------
        # RESET CPU BEFORE NEXT TEST
        # --------------------------------------------------------

        lines.append("")
        lines.append("# Put CPU back into reset before next test")

        lines.append(
            f"create_hw_axi_txn final_reset_{test_number} "
            f"$hw_axi -type WRITE "
            f"-address {tcl_hex(CONTROL_RESET_ADDR)} "
            f"-data {tcl_hex(CPU_RESET_ASSERTED)}"
        )

        lines.append(
            f"run_hw_axi [get_hw_axi_txns final_reset_{test_number}]"
        )

    # ============================================================
    # FINISH
    # ============================================================

    lines.append("")
    lines.append("close $result_fp")
    lines.append("close_hw_target")
    lines.append("disconnect_hw_server")
    lines.append("close_hw_manager")
    lines.append("exit")

    return "\n".join(lines)


# ============================================================
# MAIN
# ============================================================

def main():

    if not TESTS:
        print("ERROR: TESTS list is empty.")
        sys.exit(1)

    # Verify all tests and memory images before starting Vivado.
    for test in TESTS:
        validate_test(test)

        if not os.path.isfile(test["iram_file"]):
            print(
                f"ERROR: IRAM file does not exist:\n"
                f"  {test['iram_file']}"
            )
            sys.exit(1)

        if not os.path.isfile(test["dram_file"]):
            print(
                f"ERROR: DRAM file does not exist:\n"
                f"  {test['dram_file']}"
            )
            sys.exit(1)

    # Results file is written in the current directory.
    results_path = Path(RESULTS_FILE).resolve()

    # Generate Tcl script.
    tcl_path = Path.cwd() / "run_embench.tcl"

    tcl_script = generate_tcl_script(TESTS)

    # Replace result-file placeholder.
    #
    # Tcl uses forward slashes on Windows reliably.
    result_tcl_path = str(results_path).replace("\\", "/")

    tcl_script = tcl_script.replace(
        "__RESULT_FILE__",
        result_tcl_path,
    )

    tcl_path.write_text(
        tcl_script,
        encoding="utf-8",
    )

    print()
    print("============================================================")
    print("Starting Vivado")
    print("============================================================")
    print()
    print(f"Vivado : {VIVADO}")
    print(f"Tcl    : {tcl_path}")
    print(f"Output : {results_path}")
    print()

    # --------------------------------------------------------
    # Start Vivado in Tcl batch mode.
    # --------------------------------------------------------

    command = [
        VIVADO,
        "-mode",
        "batch",
        "-source",
        str(tcl_path),
    ]

    try:
        process = subprocess.run(
            command,
            check=False,
        )

    except FileNotFoundError:
        print(
            f"ERROR: Could not find Vivado executable '{VIVADO}'."
        )
        print(
            "Set VIVADO above to the full path to vivado.bat "
            "if necessary."
        )
        sys.exit(1)

    print()
    print("============================================================")
    print("Vivado finished")
    print("============================================================")
    print()

    if process.returncode != 0:
        print(
            f"Vivado exited with error code {process.returncode}"
        )
        sys.exit(process.returncode)

    if results_path.exists():
        print(f"Results written to:")
        print(f"  {results_path}")
    else:
        print("WARNING: Results file was not created.")


if __name__ == "__main__":
    main()