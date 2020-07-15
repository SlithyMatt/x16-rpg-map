DEPENDENCIES = battle graphics map music sound
INC_FLAGS = $(foreach d, $(DEPENDENCIES), -I ../$d)

ALL_OBJS = $(patsubst %.asm,%.o,$(wildcard *.asm))
ALL_HDRS = $(wildcard *.inc) $(foreach d, $(DEPENDENCIES), $(wildcard ../$d/*.inc))

all: $(ALL_OBJS) $(ALL_HDRS)

module: $(ALL_OBJS) $(ALL_HDRS)

%.o: %.asm
	ca65 -t cx16 -o $@ $(INC_FLAGS) $<

clean:
	rm -f *.o
