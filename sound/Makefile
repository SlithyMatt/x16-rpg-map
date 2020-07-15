DEPENDENCIES = core
INC_FLAGS = $(foreach d, $(DEPENDENCIES), -I ../$d)

ALL_OBJS = $(patsubst %.asm,%.o,$(wildcard *.asm))
ALL_HDRS = $(wildcard *.inc) $(foreach d, $(DEPENDENCIES), $(wildcard ../$d/*.inc))

all: module module_tools

module: $(ALL_OBJS) $(ALL_HDRS)

%.o: %.asm
	ca65 -t cx16 -o $@ $(INC_FLAGS) $<

module_tools:
	$(MAKE) -C tools

clean:
	rm -f *.o
	$(MAKE) -C tools clean
