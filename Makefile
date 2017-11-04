# After setting up the appropriate variable values below, do the
# following to build everything and path-profile the execution.
#
# make run
#
# Only 'make' will just build the scimark2 binary.

# Paths for LLVM 5.0.0 and llvm-epp binary
LLVM_DIR=$(HOME)/software/llvm-5.0.0
LLVM_BINDIR=$(LLVM_DIR)/bin
LLVM_LIBDIR=$(LLVM_DIR)/lib
LLVM_EPP_BINDIR=$(LLVM_BINDIR)

PROFILE_NAME=scimark2-profile.txt

# We replace the original cc with wllvw, which we use to create the
# initial bitcode.
# CC = cc
CC = PATH=$(LLVM_BINDIR):$$PATH LLVM_COMPILER=clang wllvm

# We need debug option for llvm-epp to display line numbers.
CFLAGS = -g

LDFLAGS = 

OBJS = FFT.o kernel.o Stopwatch.o Random.o SOR.o SparseCompRow.o \
	array.o MonteCarlo.o LU.o


.SUFFIXES: .c .o

.c.o:
	$(CC) $(CFLAGS) -c $<

all: scimark2

run: scimark2.epp
	LD_LIBRARY_PATH=$(LLVM_DIR)/lib ./scimark2.epp
	PATH=$(LLVM_BINDIR):$(LLVM_EPP_BINDIR):$$PATH llvm-epp -p=$(PROFILE_NAME) scimark2.bc

scimark2 : scimark2.o $(OBJS)
	$(CC) $(CFLAGS) -o scimark2 scimark2.o $(OBJS) $(LDFLAGS) -lm

scimark2.bc : scimark2
	PATH=$(LLVM_BINDIR):$$PATH LLVM_COMPILER=clang extract-bc scimark2

$(PROFILE_NAME) : scimark2.bc
	PATH=$(LLVM_BINDIR):$(LLVM_EPP_BINDIR):$$PATH llvm-epp scimark2.bc -o $(PROFILE_NAME)

scimark2.epp : $(PROFILE_NAME) scimark2.epp.bc
	$(CC) $(CFLAGS) scimark2.epp.bc -o scimark2.epp -lepp-rt -lm

clean:
	rm -f $(OBJS) scimark2 scimark2.o scimark2.epp *.bc .*.bc .*.o $(PROFILE_NAME)
