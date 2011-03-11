include ../makeconfig.conf

IPATH=-I../../libhurt/ -I../cup/

OBJS=dlex.caccept.o dlex.cacceptanchor.o dlex.cspec.o

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
