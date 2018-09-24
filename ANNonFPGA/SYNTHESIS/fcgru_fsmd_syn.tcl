#===============================================================================
#  File        :  fcl_fsmd_syn.tcl
#  Description :  Simple synthesis script for ALU model.
#  Notes       :  The script can be executed in DC shell by running
#                     source [-echo] [-verbose] path-to-tcl-script
#                 -echo echoes each command as it is executed
#                 -verbose displays the result of each command executed
#                 (error messages are displayed regardless)
#                 The script can also be run from a Linux shell as follows:
#                     dc_shell -f path-to-tcl-script
#  Author      :  Alain Vachoux, EPFL STI IEL LSM, alain.vachoux@epfl.ch
#  Tools       :  Synopsys DC 2014.09
#===============================================================================

#-----  Start of user-defined part  -----
#  This part can be edited for a new design, new constraints,
#  or new synthesis settings

#  Design related definitions
#
set ENTITY_NAME fcgru
set ARCH_NAME   fsmd
set NBITS       16
set INPUT_SIZE  8
set OUTPUT_SIZE 1
set NB_SAMPLES  10
set INT_BITS    3
set CLK_NAME	clk
set CLK_PERIOD  5 ;#ns


#  Source files must be listed in the order that meets VHDL
#  dependency rules
#
set HDL_FILES [list \
   HDL/ANNonFPGA/RTL/dotp_fsmd_rtl.vhd \
   HDL/ANNonFPGA/RTL/elemwise_prod_fsmd.vhd \
   HDL/ANNonFPGA/RTL/gru_fsmd.vhd \
   HDL/ANNonFPGA/RTL/${ENTITY_NAME}_${ARCH_NAME}.vhd ]

#  Synthesis settings
#
set report_significant_digits 3
set DB_FORMAT ddc
set ELAB_POSTFIX "_elab"
set MAPPED_POSTFIX "_mapped"
set COMPILE_MAP_EFFORT medium
set COMPILE_AREA_EFFORT medium

#-----  End of user-defined part  -----

#  Define the names to be used by the script
#
set DESIGN_ENTITY "${ENTITY_NAME}_${ARCH_NAME}"
set DESIGN_ELAB   "${ENTITY_NAME}_nbits${NBITS}_in${INPUT_SIZE}_out${OUTPUT_SIZE}_samples${NB_SAMPLES}"
set DESIGN_MAPPED "${DESIGN_ELAB}_clk${CLK_PERIOD}"

#  Start from fresh state
#
remove_design

#  Analyze the VHDL sources
#
puts "-i- Analyze VHDL sources"
analyze -format vhdl $HDL_FILES

#  Elaborate the design
#
puts "-i- Elaborate design"
elaborate ${ENTITY_NAME} -architecture ${ARCH_NAME} \
                         -parameters "NBITS = ${NBITS}, INPUT_SIZE = ${INPUT_SIZE}, OUTPUT_SIZE = ${OUTPUT_SIZE}, NB_SAMPLES = ${NB_SAMPLES}"

#  Save the elaborated design
#
puts "-i- Save elaborated design"
write -hierarchy -format ddc -output DB/${DESIGN_ELAB}${ELAB_POSTFIX}.ddc

#  Define constraints
#
puts "-i- Define constraints"
puts "-i-   set_max_area 0"
puts "-i-   create_clock $CLK_NAME -period $CLK_PERIOD"
puts "-i-   set_fix_multiple_port_nets -all"
set_max_area 0
create_clock $CLK_NAME -period $CLK_PERIOD
set_fix_multiple_port_nets -all

#  Map and optimize the design
#
puts "-i- Map and optimize design"
compile -map_effort ${COMPILE_MAP_EFFORT} \
        -area_effort ${COMPILE_AREA_EFFORT}

#  Save the mapped design
#
puts "-i- Save mapped design"
write -hierarchy -format ddc -output DB/${DESIGN_MAPPED}${MAPPED_POSTFIX}.ddc

#  Generate reports
#
puts "-i- Generate reports"
set_app_var report_default_significant_digits 3
set RPT_DIR RPT/${DESIGN_MAPPED}
#  Create the RPT subdirectory if needed
if { [file isdirectory "${RPT_DIR}"] == 0 } {
   sh mkdir ${RPT_DIR} }
report_constraint -nosplit -all_violators > ${RPT_DIR}/allviol.rpt
report_area -hierarchy -designware > ${RPT_DIR}/area.rpt
report_timing > ${RPT_DIR}/timing.rpt
report_reference -nosplit > ${RPT_DIR}/references.rpt

#  Generate the Verilog netlist
#
puts "-i- Generate Verilog netlist"
change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output HDL/GATE/${DESIGN_MAPPED}${MAPPED_POSTFIX}.v

#  Generate the SDF timing file for Verilog
#
puts "-i- Generate SDF file for Verilog netlist"
write_sdf -version 2.1 TIM/${DESIGN_MAPPED}${MAPPED_POSTFIX}_vlog.sdf

puts "-i- Finished"
