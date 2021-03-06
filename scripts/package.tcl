###############################################################
# Include PSI packaging commands
###############################################################
source ../../../TCL/PsiIpPackage/PsiIpPackage.tcl
namespace import -force psi::ip_package::latest::*

###############################################################
# General Information
###############################################################
set IP_NAME fpga_base
set IP_VERSION 1.4
set IP_REVISION "auto"
set IP_LIBRARY PSI
set IP_DESCIRPTION "FPGA Version information (SW and FW build date)"

init $IP_NAME $IP_VERSION $IP_REVISION $IP_LIBRARY
set_description $IP_DESCIRPTION
set_logo_relative "../doc/psi_logo_150.gif"
###############################################################
# Add Source Files
###############################################################

#Relative Source Files
add_sources_relative { \
	../hdl/fpga_base_date_package.vhd \
	../hdl/fpga_base_v1_0.vhd \
	../hdl/fpga_base_scripted_info_pkg.vhd \
}	

#PSI Common
add_lib_relative \
	"../../../VHDL/psi_common/hdl"	\
	{ \
		psi_common_array_pkg.vhd \
		psi_common_math_pkg.vhd \
		psi_common_logic_pkg.vhd \
		psi_common_pl_stage.vhd \
		psi_common_axi_slave_ipif.vhd \
	}
	
###############################################################
# Driver Files
###############################################################	
add_drivers_relative ../drivers/fpga_base { \
	src/fpga_base.c \
	src/fpga_base.h \
}

###############################################################
# GUI Parameters
###############################################################

#User Parameters
gui_add_page "Configuration"

gui_create_parameter "C_VERSION" "Version"
gui_add_parameter

gui_create_parameter "C_VERSION_MAJOR" "Major version (max 16 char)"
gui_add_parameter

gui_create_parameter "C_VERSION_MINOR" "Minor version (max 16 char)"
gui_add_parameter

gui_create_parameter "C_USE_INFO_FROM_SCRIPT" "Use Build-Info from Python Script (not from Vivado TCL)"
gui_parameter_set_widget_checkbox
gui_add_parameter

gui_create_parameter "C_FREQ_AXI_CLK_HZ" "AXI clock frequency in Hz"
gui_add_parameter

gui_create_parameter "C_FREQ_BLINKING_LED_HZ" "Blinking led frequency in Hz)"
gui_add_parameter

gui_create_user_parameter "IMPL_BLINK" boolean true "Implement Blinking LED"
gui_add_parameter

gui_create_user_parameter "IMPL_SWITCH" boolean true "Implement Switch inputs"
gui_add_parameter

gui_create_user_parameter "IMPL_LED" boolean true "Implement LED outputs"
gui_add_parameter

###############################################################
# Optional Ports
###############################################################
add_port_enablement_condition "o_blink" "\$IMPL_BLINK"
add_port_enablement_condition "o_led" "\$IMPL_LED"
add_port_enablement_condition "i_sw" "\$IMPL_SWITCH"
#None

###############################################################
# Package Core
###############################################################
set TargetDir ".."
#											Edit  Synth	
package_ip $TargetDir            			false true xc7a200t




