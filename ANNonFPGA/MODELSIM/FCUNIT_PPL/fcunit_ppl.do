onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /fcunit_ppl_tb/clk_tb
add wave -noupdate /fcunit_ppl_tb/rst_tb
add wave -noupdate /fcunit_ppl_tb/x_tb
add wave -noupdate /fcunit_ppl_tb/w_tb
add wave -noupdate /fcunit_ppl_tb/b_tb
add wave -noupdate /fcunit_ppl_tb/y_tb
add wave -noupdate /fcunit_ppl_tb/stop
add wave -noupdate /fcunit_ppl_tb/x_prev_tb
add wave -noupdate /fcunit_ppl_tb/w_prev_tb
add wave -noupdate /fcunit_ppl_tb/b_prev_tb
add wave -noupdate /fcunit_ppl_tb/check
add wave -noupdate -radix decimal /fcunit_ppl_tb/y_exp
add wave -noupdate /fcunit_ppl_tb/DUV/clk
add wave -noupdate /fcunit_ppl_tb/DUV/rst
add wave -noupdate /fcunit_ppl_tb/DUV/x
add wave -noupdate /fcunit_ppl_tb/DUV/w
add wave -noupdate /fcunit_ppl_tb/DUV/b
add wave -noupdate -radix decimal /fcunit_ppl_tb/DUV/y
add wave -noupdate /fcunit_ppl_tb/DUV/x_reg
add wave -noupdate /fcunit_ppl_tb/DUV/x_next
add wave -noupdate /fcunit_ppl_tb/DUV/w_reg
add wave -noupdate /fcunit_ppl_tb/DUV/w_next
add wave -noupdate /fcunit_ppl_tb/DUV/b_reg
add wave -noupdate /fcunit_ppl_tb/DUV/b_next
add wave -noupdate /fcunit_ppl_tb/DUV/y_reg
add wave -noupdate /fcunit_ppl_tb/DUV/y_next
add wave -noupdate /fcunit_ppl_tb/DUV/add_reg
add wave -noupdate /fcunit_ppl_tb/DUV/add_next
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {75 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 219
configure wave -valuecolwidth 129
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {920 ns}
