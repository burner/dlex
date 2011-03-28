include ../makeconfig.conf
CFLAGS+=-unittest

IPATH=-I../../libhurt/ -I../cup/

OBJS=dlex.cemit.o dlex.caccept.o dlex.cacceptanchor.o dlex.cspec.o dlex.calloc.o dlex.cbunch.o \
dlex.cdfa.o dlex.cdtrans.o dlex.cerror.o dlex.cinput.o dlex.clexgen.o dlex.cmakenfa.o dlex.cminimize.o \
dlex.cnfa.o dlex.cnfa2dfa.o dlex.cnfapair.o dlex.cset.o dlex.csimpliynfa.o dlex.cutility.o dlex.enumeration.o \
dlex.sparsebitset.o dlex.main.o dlex.vector.o dlex.stack.o

all:crude

crude:
	dmd -I../../libhurt/ -I../cup -m32 -gc `find dlex -name \*.d` *.a -ofDlex -debug=debugversion -debug

dlex: $(OBJS)
	dmd dlex/vector.d dlex/stack.d -I../../libhurt/ *.o *.a -ofDlex -m32

clean:
	rm *.o
	rm Dlex

dlex.caccept.o: dlex/caccept.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/caccept.d -ofdlex.caccept.o 

dlex.cacceptanchor.o: dlex/cacceptanchor.d dlex/caccept.d dlex/cspec.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cacceptanchor.d -ofdlex.cacceptanchor.o 

dlex.calloc.o: dlex/calloc.d dlex/cdfa.d dlex/cnfa.d dlex/cnfapair.d dlex/cspec.d dlex/cset.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/calloc.d -ofdlex.calloc.o 

dlex.cspec.o: dlex/cspec.d dlex/caccept.d dlex/cdtrans.d dlex/clexgen.d dlex/cnfa.d dlex/cdfa.d dlex/cutility.d dlex/cutility.d \
dlex/sparsebitset.d dlex/vector.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cspec.d dlex/vector.d -ofdlex.cspec.o 

dlex.cbunch.o: dlex/cbunch.d dlex/caccept.d dlex/cnfa.d dlex/cspec.d dlex/sparsebitset.d dlex/vector.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cbunch.d -ofdlex.cbunch.o 

dlex.cdfa.o: dlex/cdfa.d dlex/caccept.d dlex/cnfa.d dlex/cspec.d dlex/sparsebitset.d dlex/vector.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cdfa.d -ofdlex.cdfa.o 

dlex.cdtrans.o: dlex/cdtrans.d dlex/caccept.d dlex/cspec.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cdtrans.d -ofdlex.cdtrans.o 

dlex.cemit.o: dlex/cemit.d dlex/caccept.d dlex/cspec.d dlex/cdtrans.d dlex/cutility.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cemit.d -ofdlex.cemit.o 

dlex.cerror.o: dlex/cerror.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cerror.d -ofdlex.cerror.o 

dlex.cinput.o: dlex/cinput.d dlex/cutility.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cinput.d -ofdlex.cinput.o 

dlex.clexgen.o: dlex/clexgen.d dlex/caccept.d dlex/cdtrans.d dlex/cemit.d dlex/cerror.d dlex/cinput.d dlex/cmakenfa.d dlex/cminimize.d \
dlex/cnfa2dfa.d dlex/cset.d dlex/csimplifynfa.d dlex/cspec.d dlex/cnfa.d dlex/cutility.d dlex/enumeration.d dlex/sparsebitset.d \
dlex/vector.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/clexgen.d -ofdlex.clexgen.o 

dlex.cmakenfa.o: dlex/cmakenfa.d dlex/caccept.d dlex/calloc.d dlex/cerror.d dlex/cspec.d dlex/cinput.d dlex/clexgen.d dlex/cnfa.d dlex/cnfapair.d \
dlex/cset.d dlex/cutility.d dlex/sparsebitset.d dlex/vector.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cmakenfa.d -ofdlex.cmakenfa.o 

dlex.cminimize.o: dlex/cminimize.d dlex/caccept.d dlex/cdtrans.d dlex/cspec.d dlex/cutility.d dlex/sparsebitset.d dlex/vector.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cminimize.d -ofdlex.cminimize.o 

dlex.cnfa.o: dlex/cnfa.d dlex/caccept.d dlex/cspec.d dlex/cset.d dlex/sparsebitset.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cnfa.d -ofdlex.cnfa.o 

dlex.cnfa2dfa.o: dlex/cnfa2dfa.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cnfa2dfa.d -ofdlex.cnfa2dfa.o 

dlex.cnfapair.o: dlex/cnfapair.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cnfapair.d -ofdlex.cnfapair.o 

dlex.cset.o: dlex/cset.d dlex/cbunch.d dlex/cdfa.d dlex/cdtrans.d dlex/clexgen.d dlex/cspec.d dlex/cnfa.d dlex/sparsebitset.d dlex/cutility.d \
dlex/calloc.d dlex/vector.d dlex/stack.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cset.d dlex/stack.d -ofdlex.cset.o 

dlex.csimpliynfa.o: dlex/csimplifynfa.d dlex/cnfa.d dlex/cspec.d dlex/cset.d dlex/sparsebitset.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/csimplifynfa.d -ofdlex.csimplifynfa.o 

dlex.cutility.o: dlex/cutility.d dlex/cerror.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/cutility.d -ofdlex.cutility.o 

dlex.enumeration.o: dlex/enumeration.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/enumeration.d -ofdlex.enumeration.o 

dlex.sparsebitset.o: dlex/sparsebitset.d dlex/enumeration.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/sparsebitset.d -ofdlex.sparsebitset.o 

dlex.main.o: dlex/main.d dlex/clexgen.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/main.d -ofdlex.main.o 

dlex.stack.o: dlex/stack.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/stack.d -ofdlex.stack.o 

dlex.vector.o: dlex/vector.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dlex/vector.d -ofdlex.vector.o 
