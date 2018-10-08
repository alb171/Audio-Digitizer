set_global_assignment -entity "LCD_Clock_Generator" -library "lib_LCD_Clock_Generator" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "LCD_Clock_Generator" -library "lib_LCD_Clock_Generator" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "LCD_Clock_Generator" -library "lib_LCD_Clock_Generator" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_LCD_Clock_Generator" -name SPD_FILE [file join $::quartus(sip_path) "LCD_Clock_Generator.spd"]

set_global_assignment -library "lib_LCD_Clock_Generator" -name MISC_FILE [file join $::quartus(sip_path) "LCD_Clock_Generator_sim/LCD_Clock_Generator.vo"]
