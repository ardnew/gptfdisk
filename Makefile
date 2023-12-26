SHELL:=/bin/bash

#
# Invoke make via setarch(8), included with package util-linux, to configure the
# target architecture and personality traits.
#
# For example, on x86_64 (amd64), you can cross-compile this package as a 32-bit
# x86 executable with command "setarch linux32 -- make [flags]".
#
# For non-Linux or non-IA32/IA64 target architectures, you should be using one
# of the other Makefiles provided! i.e., "Makefile.<target>"
#
OS:=linux-gnu
ARCH:=$(strip $(shell arch))
TARGET:=$(ARCH)-$(OS)
CC:=$(TARGET)-gcc
CXX:=$(TARGET)-g++
PKG:=$(TARGET)-pkg-config

ARCHFLAGS+=-march=$(subst _,-,$(ARCH))
ifeq ($(ARCH),$(strip $(shell $(CC) -v 2>&1 | \
  grep -oE 'arch-32=[^[:space:]]+' | cut -sd= -f2)))
ARCHFLAGS+=-m32
PKG_CONFIG_PATH:=$(subst $(eval ) ,:,$(realpath $(wildcard lib/*/lib/pkgconfig)))
LDLIB:=$(dir $(firstword $(subst :, ,$(PKG_CONFIG_PATH))))
endif

LIB_NAMES=crc32 support guid gptpart mbrpart basicmbr mbr gpt bsd parttypes attributes diskio diskio-unix
MBR_LIBS=support diskio diskio-unix basicmbr mbrpart

DEFINES+=_FILE_OFFSET_BITS=64
ifneq (,$(strip $(UNICODE)))
  DEFINES+=USE_UTF16
endif

ifneq (,$(strip $(VERBOSE)))
  CFLAGS+=-v
  LDFLAGS+=-Wl,--verbose
endif

LINKAGE:=-static -static-libgcc -static-libstdc++

CFLAGS+=$(ARCHFLAGS) $(addprefix -D,$(DEFINES)) $(LINKAGE) -Wall
CXXFLAGS+=$(CFLAGS)
LDFLAGS+=$(ARCHFLAGS) $(addprefix -L,$(LDLIB)) $(LINKAGE)

OUTPUT:=cgdisk gdisk sgdisk fixparts

.PHONY: all test lint clean depend

all: $(OUTPUT)

test:
	./gdisk_test.sh

lint:	#no pre-reqs
	lint $(SRCS)

clean:	#no pre-reqs
	rm -f core *.o *~ gdisk sgdisk cgdisk fixparts

# what are the source dependencies
depend: $(SRCS)
	$(DEPEND) $(SRCS)

.SECONDEXPANSION:

gdisk: OBJS+=$(addsuffix .o,$(LIB_NAMES) gdisk gpttext) 
gdisk: DEPS+=uuid
gdisk: DEPS+=icu-io icu-uc

cgdisk: OBJS+=$(addsuffix .o,$(LIB_NAMES) $@ gptcurses)
cgdisk: DEPS+=uuid ncursesw
cgdisk: DEPS+=icu-io icu-uc

sgdisk: OBJS+=$(addsuffix .o,$(LIB_NAMES) $@ gptcl)
sgdisk: DEPS+=uuid popt
sgdisk: DEPS+=icu-io icu-uc

fixparts: OBJS+=$(addsuffix .o,$(MBR_LIBS) $@)

CFLAGS+=$(and $(DEPS),$(shell $(PKG) --cflags $(DEPS)))
LDFLAGS+=$(and $(DEPS),$(shell $(PKG) --libs $(DEPS)))

$(OUTPUT): $$(OBJS)
	$(CXX) $(OBJS) $(LDFLAGS) -o $@

# makedepend dependencies below -- type "makedepend *.cc" to regenerate....
# DO NOT DELETE
