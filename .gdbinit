set verbose on
set follow-fork-mode child
set substitute-path /usr/src/php/ src/php-7.2.3/

set disassembly-flavor intel 

source src/php-7.2.3/.gdbinit

dump_bt executor_globals.current_execute_data
