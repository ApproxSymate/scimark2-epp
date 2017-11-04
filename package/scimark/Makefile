# Paths for LLVM 5.0.0 and llvm-epp binary
LLVM_BINDIR=$(HOME)/software/llvm-5.0.0/bin
LLVM_EPP_BINDIR=$(LLVM_BINDIR)

.SUFFIXES: .c .o

.c.o:
	$(CC) $(CFLAGS) -c $<

all: scimark2.bc 

# We replace the original cc with wllvw, which we use to create the
# initial bitcode.
# CC = cc
CC = PATH=$(LLVM_BINDIR):$$PATH LLVM_COMPILER=clang wllvm

# We need debug option for llvm-epp to display line numbers.
CFLAGS = -g

LDFLAGS = 

OBJS = FFT.o kernel.o Stopwatch.o Random.o SOR.o SparseCompRow.o \
	array.o MonteCarlo.o LU.o

scimark2 : scimark2.o $(OBJS)
	$(CC) $(CFLAGS) -o scimark2 scimark2.o $(OBJS) $(LDFLAGS) -lm

scimark2.bc : scimark2
	PATH=$(LLVM_BINDIR):$$PATH LLVM_COMPILER=clang extract-bc scimark2

clean:
	rm -f $(OBJS) scimark2 scimark2.o *.bc .*.bc
