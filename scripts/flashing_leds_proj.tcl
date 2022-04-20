# TCL script for zc706_flashing_leds project
# 
# This project will allow the user to access the ZC706's board LEDs
# change the state of the 4 on-board LEDs by running a via the 
# processing system in the Xilinx SDK. The c++ program used to turn 
# on/off the LEDs in found in the SDK folder in this Github repository.
# 
# This hardware design can also be used to build a PetaLinux environment
# (an embedded Linux system on the FPGA board). Instructions on how to
# build and run PetaLinux are found in https://github.com/gracepua/PetaLinux-Guide.
# 
# Author: Grace Palenapa
# Revision: 04.20.2022
# Job Status: Co-op Student w/ IS4S
#
# ZC706 development board : part number (xc7z045ffg900-2)
# 
# Requirements: - Vivado 2019.1
#               - Petalinux 2019.1 (optional)
#               - license for the ZC706 development board
#               - ZC706 board part or board preset files installed in 
#                 <INSTALLATION-ROOT-REPO>/<VERSION>/data/boards/board_parts
#                 or board_files respectively
#
# Notes for me: - zc706_led_bd.tcl --> for block design
#               - flashing_LED_wrapper --> top module name
#               - zc706_leds.xdc -- constraints file name
#               - 
# 
# TCL scripts based on https://github.com/RTSYork/zc706_10g_example scripts


# set the reference directory for source file relative paths 
# (by default, the value is the script directory path)
set origin_dir "."

# create project 
create_project zc706_flashing_leds ./zc706_flashing_leds

# set the directory paths for the new project
set project_dir [get_property directory [current_project]]

# set project properties 
set_obj [get_projects zc706_flashing_leds]
set_property "board part" "xilinx.com:zc706:part0:1.2" $obj
set_property "default_lib" "xil_defaultlib" $obj
set_property "simulator_language" "Mixed" $obj

# create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}

# set 'sources_1' fileset file properties for local files
# None

# set 'sources_1' fileset properties
set obj [get_filesets sources_1]
set_property "top" "flashing_LED_wrapper" $obj

# create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
    create_fileset -constrset constrs_1
}

# set 'constrs_1' fileset object
set obj [get_filesets constrs-1]

# add/import constrs file and set constrs file properties
set file "[file normalize "$origin_dir/zc706_leds.xdc"]"
set file_added [add_files -norecurse -fileset $obj $file]
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets constrs_1] [list "*$file"]]
set_property "file_type" "XDC" $file_obj

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]
set_property "target_constrs_file" $file $obj

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
# Empty (no sources present)

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" "flashing_LED_wrapper" $obj
set_property "xelab.nosort" "1" $obj
set_property "xelab.unifast" "" $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
  create_run -name synth_1 -part xc7z045ffg900-2 -flow {Vivado Synthesis 2019} -strategy "Vivado Synthesis Defaults" -constrset constrs_1
} else {
  set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
  set_property flow "Vivado Synthesis 2019" [get_runs synth_1]
}
set obj [get_runs synth_1]

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
  create_run -name impl_1 -part xc7z045ffg900-2 -flow {Vivado Implementation 2019} -strategy "Vivado Implementation Defaults" -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
  set_property flow "Vivado Implementation 2019" [get_runs impl_1]
}
set obj [get_runs impl_1]
set_property "steps.write_bitstream.args.readback_file" "0" $obj
set_property "steps.write_bitstream.args.verbose" "0" $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

# Now create the board design
source "$origin_dir/block_design.tcl"

# Only one board design, this is safe
set bdFile [get_property FILE_NAME [get_bd_designs]]
make_wrapper -import -fileset [get_filesets sources_1] -top [get_files $bdFile]

puts "INFO: Project created:zc706_flashing_leds"