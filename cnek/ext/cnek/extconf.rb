require "mkmf"

$CFLAGS << " -std=gnu99 -O3 -Wall -Wextra"

create_makefile("cnek")
