include ../makeconfig.conf

IPATH=-I../../libhurt/

OBJS=

all:

cup.a: $(OBJS)

clean:
	rm *.o

complexsymbolfactory.o: cup/complexsymbolfactory.d cup/symbol.d cup/symbolfactory.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) -ofcup.complexsymbolfactory.o cup/complexsymbolfactory.d
