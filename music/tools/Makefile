APPS = $(patsubst %.c,%.exe,$(wildcard *.c))
OBJS = $(patsubst %.c,%.o,$(wildcard *.c))
HDRS = $(wildcard *.h)

ifeq ($(OS),Windows_NT)
	MINGW_GCC = x86_64-pc-cygwin-gcc
else
	MINGW_GCC = x86_64-w64-mingw32-gcc
endif

IFLAGS =
LFLAGS =

all: $(APPS) $(OBJS) $(HDRS)

%.exe: %.c
	gcc -o $@ $(IFLAGS) -DSTANDALONE $< $(LFLAGS)

%.o: %.c
	gcc -o $@ $(IFLAGS) -c $<

clean:
	rm -f *.o
	rm -f *.exe
	rm -f *.dll

dll:
	$(MINGW_GCC) -c -o vgmdll.o -DDLLEXPORT vgmdll.c
	$(MINGW_GCC) -o vgm.dll -s -shared vgmdll.o -Wl,--out-implib=libvgm.dll.a \
    -Wl,--export-all-symbols \
    -Wl,--enable-auto-import
