CC 		  = /usr/bin/gcc
CFLAGS  = -Wall -Wextra -O3 -fno-tree-vectorize -fomit-frame-pointer -lcrypto -march=native 
CFLAGS2  = -Wall -Wextra -O3 -fno-tree-vectorize -fomit-frame-pointer -march=native -std=c99 
CFLAGS3  = -Wall -Wextra -O3 -fno-tree-vectorize -fomit-frame-pointer -march=native 
CLANG   = clang -march=native -O3 -fomit-frame-pointer -fwrapv -Qunused-arguments
RM 		  = /bin/rm


all: test/PQCgenKAT_kem \
     test/test_kex \
     test/kem \

SOURCES = pack_unpack.c poly.c rng.c fips202.c verify.c cbd.c poly_mul.c SABER_indcpa.c kem.c
HEADERS = SABER_params.h pack_unpack.h poly.h rng.h fips202.h verify.h cbd.h poly_mul.h SABER_indcpa.h kem.h 



test/test_kex: $(SOURCES) $(HEADERS) test/test_kex.c
	$(CC) $(CFLAGS3) -o $@ $(SOURCES) test/test_kex.c -lcrypto

test/PQCgenKAT_kem: $(SOURCES) $(HEADERS) test/PQCgenKAT_kem.c 
	$(CC) $(CFLAGS3) -o $@ $(SOURCES) test/PQCgenKAT_kem.c -lcrypto

test/kem: $(SOURCES) $(HEADERS) test/kem.c
	$(CC) $(CFLAGS3) -o $@ $(SOURCES) test/kem.c -lcrypto

rng.o: rng.c
	$(CC) $(CFLAGS2) -c rng.c -lcrypto -o $@ 

fips202.o: fips202.c
	$(CLANG) -c $^ -o $@

.PHONY: clean test

test: 
	./test/test_kex
	./test/PQCgenKAT_kem
	./test/kem

clean:
	-$(RM) *.o
	-$(RM) -r test/test_kex
	-$(RM) -r test/kem
	-$(RM) -r test/PQCgenKAT_kem
