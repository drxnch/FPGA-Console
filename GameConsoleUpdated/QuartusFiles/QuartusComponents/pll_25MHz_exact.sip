set_global_assignment -entity "pll_25MHz_exact" -library "lib_pll_25MHz_exact" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pll_25MHz_exact" -library "lib_pll_25MHz_exact" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "pll_25MHz_exact" -library "lib_pll_25MHz_exact" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pll_25MHz_exact" -name SPD_FILE [file join $::quartus(sip_path) "pll_25MHz_exact.spd"]

set_global_assignment -library "lib_pll_25MHz_exact" -name MISC_FILE [file join $::quartus(sip_path) "pll_25MHz_exact_sim/pll_25MHz_exact.vho"]
