DEPENDENCIES = core graphics music
INC_FLAGS = $(foreach d, $(DEPENDENCIES), -I ../$d)

ALL_OBJS = $(patsubst %.asm,%.o,$(wildcard *.asm))
ALL_HDRS = $(wildcard *.inc) $(foreach d, $(DEPENDENCIES), $(wildcard ../$d/*.inc))

all: $(ALL_OBJS) $(ALL_HDRS) module_test

module: $(ALL_OBJS) $(ALL_HDRS)

%.o: %.asm
	ca65 -t cx16 -o $@ -l $(patsubst %.asm,%.list,$<) $(INC_FLAGS) $<

clean:
	rm -f *.o
	$(MAKE) -C test clean

module_test:
	$(MAKE) -C test
