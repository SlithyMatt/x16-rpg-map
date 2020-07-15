DEPENDENCIES = core graphics music map sound
INC_FLAGS = $(foreach d, $(DEPENDENCIES), -I ../../$d)

ALL_OBJS = map_test.o
ALL_HDRS = $(wildcard *.inc) $(foreach d, $(DEPENDENCIES), $(wildcard ../../$d/*.inc))

DEPENDENCY_OBJS = $(foreach d, $(DEPENDENCIES), $(patsubst %.asm,%.o,$(wildcard ../../$d/*.asm)))

all: $(ALL_OBJS) $(ALL_HDRS) buildmap.exe
	for d in $(DEPENDENCIES); do \
		$(MAKE) -C ../../$$d module; \
	done
	cl65 -t cx16 -o RPGMAP.PRG -m rpgmap.mmap $(ALL_OBJS) $(DEPENDENCY_OBJS)

%.o: %.asm
	ca65 -t cx16 -o $@ -l $(patsubst %.asm,%.list,$<) $(INC_FLAGS) $<

buildmap.exe: buildmap.c
	gcc -o buildmap.exe buildmap.c

clean:
	rm -f *.o
	rm -f *.PRG
	rm -f *.mmap
	rm -f *.list
