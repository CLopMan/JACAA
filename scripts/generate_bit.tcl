# In order to execute
# vivado -mode batch -source <script_name> -tclargs <project_name> <top_module_name_entity> <source_dir>
vivado -mode batch -source scripts/generate_bit.tcl -tclargs JACAA ALU ./src
# Example 
# vivado -mode batch -source scripts/flash.tcl -tclargs JACAA ~/Vivado/


# Suppress command echoing
tclsh -notrace

# Check if at least two arguments are provided
if {$argc < 3} {
  puts "Usage: -source <script_name> -tclargs <project_name> <top_module_name_entity> <source_dir>"
  exit 1
}

puts "Starting to generate bitstream..."

# Assign arguments to variables
set projectName [lindex $argv 0]
set topModuleName [lindex $argv 1]
set srcDir [lindex $argv 2]

# STEP#1: Create or Open the Project
set projectDir ./$projectName
set projectFile $projectDir/$projectName.xpr

if {[file exists $projectFile]} {
  # Attempt to open the existing project file
  puts "Project exists, attempting to open: $projectFile"
  open_project $projectFile
} else {
  # Project directory does not exist, create a new project
  puts "Project does not exist, creating new project: $projectName"
  create_project $projectName $projectDir -part xc7a100tcsg324-1
}

# STEP#2: Add Source Files
puts "Adding files from $srcDir..."
read_vhdl [glob ./$srcDir/src/*.vhd]
read_xdc ./$srcDir/constraints/Nexys-A7-100T-Master.xdc

# STEP#3: Synthesis
puts "Synthesis..."
synth_design -top $topModuleName -part xc7a100tcsg324-1
puts "Synthesis completed"
# STEP#4: Implementation

puts "Implementation..."
opt_design
place_design
phys_opt_design
route_design
puts "Implementation completed"

# STEP#5: Generate Bitstream
puts "Generating Bitstream..."
write_bitstream -force ./$projectName/$projectName.bit
# Save Project and Exit
close_project

puts "Bitstream generated sucessfully"