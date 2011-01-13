include ../makeconfig.conf

OBJS=complexsymbolfactory.o defaultsymbolfactory.o lrparser.o symbol.o virtualparsestack.o

all:cup.a

cup.a: $(OBJS)

complexsymbolfactory.o: cup/complexsymbolfactory.d cup/symbol.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) -Isrc -ofcup.complexsymbolfactory.o cup/complexsymbolfactory.d

defaultsymbolfactory.o: cup/defaultsymbolfactory.d cup/symbol.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) -Isrc -ofcup.defaultsymbolfactory.o cup/defaultsymbolfactory.d

lrparser.o: cup/lrparser.d cup/symbol.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) -Isrc -ofcup.lrparser.o cup/lrparser.d

symbol.o: cup/symbol.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) -Isrc -ofcup.symbol.o cup/symbol.d

virtualparsestack.o: cup/virtualparsestack.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) -Isrc -ofcup.virtualparsestack.o cup/virtualparsestack.d
