onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib RISC_V_tb_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {RISC_V_tb.udo}

run 1000ns

quit -force
