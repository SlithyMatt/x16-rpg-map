DEPENDENCIES = core map graphics music
INC_FLAGS = $(foreach d, $(DEPENDENCIES), -I ../../$d) -I ..

ALL_OBJS = sound_test.o
ALL_HDRS = $(wildcard *.inc) $(foreach d, $(DEPENDENCIES), $(wildcard ../../$d/*.inc))

DEPENDENCY_OBJS = $(foreach d, $(DEPENDENCIES), $(patsubst %.asm,%.o,$(wildcard ../../$d/*.asm))) $(wildcard ../*.o)

all: $(ALL_OBJS) $(ALL_HDRS)
	for d in $(DEPENDENCIES); do \
		$(MAKE) -C ../../$$d; \
	done

	cl65 -t cx16 -o SOUNDTST.PRG -m SOUNDTST.mmap $(ALL_OBJS) $(DEPENDENCY_OBJS)

%.o: %.asm
	ca65 -t cx16 -o $@ $(INC_FLAGS) $<
