include ../makeconfig.conf

IPATH=-I../../libhurt/

OBJS=complexsymbolfactory.o defaultsymbolfactory.o lrparser.o symbol.o virtualparsestack.o

all:cup.a

cup.a: $(OBJS)
	dmd *.o *.a -ofCup

clean:
	rm *.o
	rm cup.a

complexsymbolfactory.o: cup/complexsymbolfactory.d cup/symbol.d cup/symbolfactory.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) -ofcup.complexsymbolfactory.o cup/complexsymbolfactory.d

defaultsymbolfactory.o: cup/defaultsymbolfactory.d cup/symbol.d cup/symbolfactory.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) -ofcup.defaultsymbolfactory.o cup/defaultsymbolfactory.d

lrparser.o: cup/lrparser.d cup/defaultsymbolfactory.d cup/scanner.d cup/symbol.d cup/symbolfactory.d cup/virtualparsestack.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) -ofcup.lrparser.o cup/lrparser.d

symbol.o: cup/symbol.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) -ofcup.symbol.o cup/symbol.d

virtualparsestack.o: cup/virtualparsestack.d cup/symbol.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) -ofcup.virtualparsestack.o cup/virtualparsestack.d
