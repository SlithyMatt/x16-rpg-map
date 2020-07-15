MODULES = core graphics map music sound

INC_FLAGS = $(foreach d, $(MODULES), -I $d)

ROOT_OBJS = $(patsubst %.asm,%.o,$(wildcard *.asm))
ROOT_HDRS = $(wildcard *.inc)

MODULE_OBJS = $(foreach d, $(MODULES), $(patsubst %.asm,%.o,$(wildcard $d/*.asm)))

all: $(ROOT_OBJS) $(ROOT_HDRS)
	for d in $(MODULES); do \
		$(MAKE) -C $$d; \
	done
	cl65 -t cx16 -o MAPGAME.PRG -m mapgame.mmap $(ROOT_OBJS) $(MODULE_OBJS)

%.o: %.asm
	ca65 -t cx16 -o $@ $(INC_FLAGS) $<

clean:
	rm -f *.o
	rm -f MAPGAME.PRG
	rm -f mapgame.mmap
	for d in $(MODULES); do \
		$(MAKE) -C $$d clean; \
	done
