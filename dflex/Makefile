include ../makeconfig.conf

IPATH=-I../../libhurt/

OBJS=dflex.action.o dflex.countemitter.o

all:dflex

dflex: $(OBJS)

clean:
	rm *.o

dflex.action.o: dflex/action.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/action.d -ofdflex.action.o 

dflex.countemitter.o: dflex/countemitter.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/countemitter.d -ofdflex.countemitter.o 
