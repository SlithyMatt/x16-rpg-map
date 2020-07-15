DEPENDENCIES = core map graphics sound music
INC_FLAGS = $(foreach d, $(DEPENDENCIES), -I ../../$d)

ALL_OBJS = music_test.o
ALL_HDRS = $(wildcard *.inc) $(foreach d, $(DEPENDENCIES), $(wildcard ../../$d/*.inc))

DEPENDENCY_OBJS = $(foreach d, $(DEPENDENCIES), $(patsubst %.asm,%.o,$(wildcard ../../$d/*.asm)))

ifndef VGM
VGM = ../vgm/DesperateConfrontation.vgm
endif

all: $(ALL_OBJS) $(ALL_HDRS) vgm
	for d in $(DEPENDENCIES); do \
		$(MAKE) -C ../../$$d module; \
	done
	cl65 -t cx16 -o MUSICTST.PRG -m music_test.mmap $(ALL_OBJS) $(DEPENDENCY_OBJS)

vgm:
	../../music/tools/vgm2x16opm.exe $(VGM) MUSIC.BIN

%.o: %.asm
	ca65 -t cx16 -o $@ -l $(patsubst %.asm,%.list,$<) $(INC_FLAGS) $<

clean:
	rm -f *.o
	rm -f *.PRG
	rm -f *.mmap
	rm -f *.list
	rm -f *.BIN
