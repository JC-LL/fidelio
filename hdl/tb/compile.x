echo "=> cleaning..."
rm -rf *.o *.cf *.ghw fidelio_ip_tb
echo "---------- utilities ----------------------------"
echo "=> compiling txt_util.vhd"
ghdl -a --std=08 --work=utils_lib ./txt_util.vhd
echo "---------- NISC microarchitecture ----------------"
echo "=> compiling fidelio_bram_xilinx.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_bram_xilinx.vhd
echo "=> compiling fidelio_type_package.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_config_package.vhd
echo "=> compiling fidelio_type_package_body.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_config_package_body.vhd
echo "=> compiling fidelio_alu.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_alu.vhd
echo "=> compiling fidelio_datapath.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_datapath.vhd
echo "=> compiling fidelio_fsm.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_fsm.vhd
echo "=> compiling fidelio_pfsm.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_pfsm.vhd
echo "=> compiling fidelio_fsmd.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_fsmd.vhd
echo "=> compiling fidelio_nisc.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_nisc.vhd
echo "---------- NISC IP encapsulation stuff -----------"
echo "=> compiling fidelio_ip_pkg.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_ip_pkg.vhd
echo "=> compiling fidelio_ip_reg.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_ip_reg.vhd
echo "=> compiling fidelio_ip.vhd"
ghdl -a --std=08 --work=fidelio_lib ../src/fidelio_ip.vhd
echo "=> compiling fidelio_ip_tb.vhd"
ghdl -a --std=08 --work=fidelio_lib ./fidelio_ip_tb.vhd
echo "=> elaborate fidelio_ip_tb"
ghdl -e --std=08 --work=fidelio_lib fidelio_ip_tb

if [ -f "fidelio_ip_tb" ];then
echo "---------- NISC IP simulation --------------------"
echo "=> simulate  fidelio_ip_tb"
ghdl -r fidelio_ip_tb --wave=fidelio_ip_tb.ghw
gtkwave fidelio_ip_tb.ghw fidelio_ip_tb.sav
fi ;
