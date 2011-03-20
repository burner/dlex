include ../makeconfig.conf

IPATH=-I../../libhurt/ -I../cup/

OBJS=dlex.cemit.o dlex.caccept.o dlex.cacceptanchor.o dlex.cspec.o dlex.calloc.o dlex.cbunch.o \
dlex.cdfa.o dlex.cdtrans.o dlex.cerror.o dlex.cinput.o dlex.clexgen.o dlex.cmakenfa.o dlex.cminimize.o \
dlex.cnfa.o dlex.cnfa2dfa.o dlex.cnfapair.o dlex.cset.o dlex.csimpliynfa.o dlex.cutility.o dlex.enumeration.o \
dlex.sparsebitset.o dlex.main.o dlex.vector.o dlex.stack.o

all:dlex

dlex: $(OBJS)
	dmd *.o *.a -ofDlex

clean:
	rm *.o

dlex.caccept.o: dlex/caccept.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/caccept.d -ofdfex.caccept.o 

dlex.cacceptanchor.o: dlex/cacceptanchor.d dlex/caccept.d dlex/cspec.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cacceptanchor.d -ofdfex.cacceptanchor.o 

dlex.cspec.o: dlex/cspec.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cspec.d -ofdfex.cspec.o 

dlex.calloc.o: dlex/calloc.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/calloc.d -ofdfex.calloc.o 

dlex.cbunch.o: dlex/cbunch.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cbunch.d -ofdfex.cbunch.o 

dlex.cdfa.o: dlex/cdfa.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cdfa.d -ofdfex.cdfa.o 

dlex.cdtrans.o: dlex/cdtrans.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cdtrans.d -ofdfex.cdtrans.o 

dlex.cemit.o: dlex/cemit.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cemit.d -ofdfex.cemit.o 

dlex.cerror.o: dlex/cerror.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cerror.d -ofdfex.cerror.o 

dlex.cinput.o: dlex/cinput.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cinput.d -ofdfex.cinput.o 

dlex.clexgen.o: dlex/clexgen.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/clexgen.d -ofdfex.clexgen.o 

dlex.cmakenfa.o: dlex/cmakenfa.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cmakenfa.d -ofdfex.cmakenfa.o 

dlex.cminimize.o: dlex/cminimize.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cminimize.d -ofdfex.cminimize.o 

dlex.cnfa.o: dlex/cnfa.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cnfa.d -ofdfex.cnfa.o 

dlex.cnfa2dfa.o: dlex/cnfa2dfa.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cnfa2dfa.d -ofdfex.cnfa2dfa.o 

dlex.cnfapair.o: dlex/cnfapair.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cnfapair.d -ofdfex.cnfapair.o 

dlex.cset.o: dlex/cset.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cset.d -ofdfex.cset.o 

dlex.csimpliynfa.o: dlex/csimplifynfa.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/csimplifynfa.d -ofdfex.csimplifynfa.o 

dlex.cutility.o: dlex/cutility.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cutility.d -ofdfex.cutility.o 

dlex.enumeration.o: dlex/enumeration.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/enumeration.d -ofdfex.enumeration.o 

dlex.sparsebitset.o: dlex/sparsebitset.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/sparsebitset.d -ofdfex.sparsebitset.o 

dlex.main.o: dlex/main.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/main.d -ofdfex.main.o 

dlex.stack.o: dlex/stack.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/stack.d -ofdfex.stack.o 

dlex.vector.o: dlex/vector.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/vector.d -ofdfex.vector.o 
