# =====FPGA device : Artix7 in Nexys4DDR
set partname "xc7a100tcsg324-1"
set xdc_constraints "./Nexys4DDR_Master.xdc"
 
# =====Define output directory
set outputDir ./SYNTH_OUTPUTS
file mkdir $outputDir
 
# =====Setup design sources and constraints
read_vhdl [ glob ../assets/*.vhd]
read_vhdl [ glob ../src/*.vhd]
read_xdc $xdc_constraints
 
synth_design -top fidelio_soc -part $partname
write_checkpoint -force $outputDir/post_synth.dcp
report_timing_summary -file $outputDir/post_synth_timing_summary.rpt
report_utilization -file $outputDir/post_synth_util.rpt
opt_design
# reportCriticalPaths $outputDir/post_opt_critpath_report.csv
place_design
# report_clock_utilization -file $outputDir/clock_util.rpt
#
write_checkpoint -force $outputDir/post_place.dcp
report_utilization -file $outputDir/post_place_util.rpt
report_timing_summary -file $outputDir/post_place_timing_summary.rpt
 
# ====== run the router, write the post-route design checkpoint, report the routing
# status, report timing, power, and DRC, and finally save the Verilog netlist.
#
route_design
write_checkpoint -force $outputDir/post_route.dcp
report_route_status -file $outputDir/post_route_status.rpt
report_timing_summary -file $outputDir/post_route_timing_summary.rpt
report_power -file $outputDir/post_route_power.rpt
report_drc -file $outputDir/post_imp_drc.rpt
# write_verilog -force $outputDir/cpu_impl_netlist.v -mode timesim -sdf_anno true
 
# ====== generate a bitstream
write_bitstream -force $outputDir/top.bit
exit
