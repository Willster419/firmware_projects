onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pipeline_tb/clk
add wave -noupdate /pipeline_tb/rst
add wave -noupdate /pipeline_tb/input_data
add wave -noupdate /pipeline_tb/input_valid
add wave -noupdate /pipeline_tb/my_pipeline/pipeline_in
add wave -noupdate /pipeline_tb/my_pipeline/pipeline
add wave -noupdate /pipeline_tb/my_pipeline/pipeline_out
add wave -noupdate /pipeline_tb/output_data
add wave -noupdate /pipeline_tb/output_valid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4500 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {0 ns} {8280 ns}
