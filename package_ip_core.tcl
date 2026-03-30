set script_dir [file dirname [file normalize [info script]]]
set rtl_dir [file join $script_dir rtl]
set ip_root [file join $script_dir ip_repo axi_dualport_hb_bridge]
set component_xml [file join $ip_root component.xml]

file delete -force $ip_root
file mkdir $ip_root

proc configure_core_metadata {core} {
    set_property name axi_dualport_hb_bridge $core
    set_property display_name {AXI Dual-Port HyperBus Bridge} $core
    set_property description {Bridge that splits one 64-bit AXI4 slave interface across two parallel 32-bit AXI4 master interfaces.} $core
    set_property version 1.0 $core
    set_property core_revision 1 $core
    set_property vendor_display_name {GHL} $core
    set_property supported_families {artix7 Production kintex7 Production virtex7 Production zynq Production zynquplus Production spartanuplus Production} $core

    foreach busif {s_axi m0_axi m1_axi} {
        if {[llength [ipx::get_bus_interfaces $busif -of_objects $core]] > 0} {
            ipx::associate_bus_interfaces -busif $busif -clock i_axi_aclk $core
        }
    }

    set clk_if [ipx::get_bus_interfaces i_axi_aclk -of_objects $core]
    if {[llength $clk_if] > 0} {
        set clk_param [ipx::get_bus_parameters FREQ_HZ -of_objects $clk_if]
        if {[llength $clk_param] == 0} {
            set clk_param [ipx::add_bus_parameter FREQ_HZ $clk_if]
        }
        set_property value 50000000 $clk_param
    }
}

create_project -in_memory axi_dualport_hb_bridge_ip_pack
set_property target_language Verilog [current_project]
add_files -norecurse [file join $rtl_dir axi_dualport_hb_bridge.sv]
set_property top axi_dualport_hb_bridge [current_fileset]
update_compile_order -fileset sources_1

ipx::package_project \
    -root_dir $ip_root \
    -vendor ghl.local \
    -library user \
    -taxonomy /UserIP \
    -import_files \
    -set_current true

set core [ipx::current_core]
configure_core_metadata $core
ipx::create_xgui_files $core
ipx::update_checksums $core
ipx::check_integrity $core
ipx::save_core $core
close_project

set core [ipx::open_core $component_xml]
configure_core_metadata $core
ipx::update_checksums $core
ipx::check_integrity $core
ipx::save_core $core
