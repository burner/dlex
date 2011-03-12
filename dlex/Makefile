include ../makeconfig.conf

IPATH=-I../../libhurt/ -I../cup/

OBJS=dlex.caccept.o dlex.cacceptanchor.o dlex.cspec.o dlex.calloc.o dlex.cbunch.o \
dlex.cdfa.o dlex.cdtrans.o dlex.cerror.o dlex.cinput.o dlex.clexgen.o

all:dlex

dlex: $(OBJS)

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
