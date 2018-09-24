
#  Design related definitions
#
set ENTITY_NAME fcunit
set ARCH_NAME   ppl
set NBITS       16
set INPUTSIZE   24
set CLK_NAME	clk
set CLK_PERIOD  2 ;#ns


#  Source files must be listed in the order that meets VHDL
#  dependency rules
#
set HDL_FILES [list \
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
set DESIGN_ELAB   "${ENTITY_NAME}_nbits${NBITS}_in${INPUTSIZE}"
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
                         -parameters "NBITS = ${NBITS}, INPUTSIZE = ${INPUTSIZE}"
#"INPUT_SIZE = ${INPUT_SIZE}"

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
