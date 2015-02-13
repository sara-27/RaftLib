CC    ?= gcc
CXX   ?= g++

PREFIX = /usr/local

include fifo/buffer.makefile

DIRINCS = $(RINGBUFFERDIR) ./

ifneq ($(shell uname -s), Darwin)
RT = -lrt
STATIC = -static -static-libgcc -static-libstdc++
PTHREAD = -lpthread  
endif

TEST = -O0 -g -DUNITTEST=1
RELEASE = -Ofast -mtune=native

BUILD = $(RELEASE)

CFLAGS   =  $(BUILD) -Wall -std=c99 
CXXFLAGS =  $(BUILD) -Wall -std=c++11  -DRDTSCP=1


RAFTLIGHTCXXOBJS = allocate map graphtools port portexception schedule \
                   simpleschedule stdalloc portiterator dynalloc \
                   roundrobin kernel mapbase submap globalmap \
                   systemsignalhandler kerneliterator kernelcontainer 

COBJS   = $(RBCOBJS)
CXXOBJS = $(RBCXXOBJS) $(RAFTLIGHTCXXOBJS)

CFILES = $(addsuffix .c, $(COBJS) )
CXXFILES = $(addsuffix .cpp, $(CXXOBJS) )

OBJS = $(addsuffix .o, $(COBJS) ) $(addsuffix .o, $(CXXOBJS) )


INCS = $(addprefix -I, $(DIRINCS))
LIBS = $(RT) $(PTHREAD)

compile: $(CXXFILES) $(CFILES)
	$(MAKE) $(OBJS)
	$(AR) rvs libraft.a $(OBJS)

install:
	cp libraft.a $(PREFIX)/lib/
	mkdir -p $(PREFIX)/include/raft_dir
	cp *.hpp $(PREFIX)/include/raft_dir/
	cp *.tcc $(PREFIX)/include/raft_dir/
	cp ./fifo/*.hpp $(PREFIX)/include/raft_dir/
	cp ./fifo/*.tcc $(PREFIX)/include/raft_dir/
	cp ./packages/* $(PREFIX)/include/raft_dir/
	cp raft $(PREFIX)/include/
	cp raftio $(PREFIX)/include/
	echo "Install complete!"

uninstall:
	rm -rf $(PREFIX)/lib/libraft.a
	rm -rf $(PREFIX)/include/raft_dir
	rm -rf $(PREFIX)/include/raft
	rm -rf $(PREFIX)/include/raftio
	echo "Uninstalled!"
%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) $(INCS) -o $@ $<

%.o: %.c
	$(CC) -c $(CFLAGS) $(INCS) -o $@ $<

.PHONY: clean
clean:
	rm -rf libraft.a $(OBJS) intelremotemonfifo.*
