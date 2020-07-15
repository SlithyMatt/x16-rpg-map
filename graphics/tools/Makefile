APPS = $(patsubst %.c,%.exe,$(wildcard *.c))
OBJS = maketilemap.o
HDRS = $(wildcard *.h)

IFLAGS = -I/usr/include/libxml2
LFLAGS = -ljson-c -lxml2

all: $(APPS) $(OBJS) $(HDRS)

module: $(OBJS) $(HDRS)

%.exe: %.c
	gcc -o $@ $(IFLAGS) -DSTANDALONE $< $(LFLAGS)

%.o: %.c
	gcc -o $@ $(IFLAGS) -c $<

clean:
	rm -f *.o
	rm -f *.exe
