# In order to execute
# vivado -mode batch -source flash_fpga.tcl -tclargs <proyect_name> 

# Example 
# vivado -mode batch -source scripts/flash.tcl -tclargs JACAA 

# Suppress command echoing
#tclsh -notrace

# Check if at least two arguments are provided
if {$argc < 1} {
  puts "Usage: -source <script_name> -tclargs <project_name>"
  exit 1
}

puts "Starting to flash..."

# Getting the arguments
set project_name [lindex $argv 0]

# Opening a hardware session
puts "Openning a hardware session..."
open_hw_manager
connect_hw_server
open_hw_target

# Looking for FPGA
puts "Looking for FPGA..."
current_hw_device [lindex [get_hw_devices] 0]

# Programming FPGA with the bitstream
puts "Flashing..."
set_property PROGRAM.FILE ./$project_name/$project_name.bit [current_hw_device]
program_hw_devices [current_hw_device]

# Closing the hardware session
close_hw_target
disconnect_hw_server
close_hw_manager

# Closing Vivado
exit

puts "Bitstream flashed sucessfully"

