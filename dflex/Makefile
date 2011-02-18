include ../makeconfig.conf

IPATH=-I../../libhurt/ -I../cup/

OBJS=dflex.action.o dflex.charclasses.o dflex.charclassexception.o dflex.charclassinterval.o \
dflex.charset.o dflex.countemitter.o dflex.charsetenumerator.o dflex.dfa.o

all:dflex

dflex: $(OBJS)

clean:
	rm *.o

dflex.action.o: dflex/action.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/action.d -ofdflex.action.o 

dflex.charclasses.o: dflex/charclasses.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/charclasses.d -ofdflex.charclasses.o 

dflex.charclassexception.o: dflex/charclassexception.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/charclassexception.d -ofdflex.charclassexception.o 

dflex.charclassinterval.o: dflex/charclassinterval.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/charclassinterval.d -ofdflex.charclassinterval.o 

dflex.charset.o: dflex/charset.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/charset.d -ofdflex.charset.o 

dflex.charsetenumerator.o: dflex/charsetenumerator.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/charsetenumerator.d -ofdflex.charsetenumerator.o 

dflex.countemitter.o: dflex/countemitter.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/countemitter.d -ofdflex.countemitter.o 

dflex.dfa.o: dflex/dfa.d Makefile ../makeconfig.conf
	$(DC) $(CFLAGS) $(IPATH) dflex/dfa.d -ofdflex.dfa.o 
