# Linux makefile for FreeImage

# This file can be generated by ./gensrclist.sh
include Makefile.srcs

# General configuration variables:
DESTDIR ?= /
INCDIR ?= $(DESTDIR)/usr/include
INSTALLDIR ?= $(DESTDIR)/usr/lib

# Converts cr/lf to just lf
DOS2UNIX = dos2unix

LIBRARIES = -lstdc++

MODULES = $(SRCS:.c=.o)
MODULES := $(MODULES:.cpp=.o)
CFLAGS ?= -O3 -fPIC -fexceptions -fvisibility=hidden
# OpenJPEG
CFLAGS += -DOPJ_STATIC
# LibRaw
CFLAGS += -DNO_LCMS
# LibJXR
CFLAGS += -DDISABLE_PERF_MEASUREMENT -D__ANSI__
CFLAGS += $(INCLUDE)
CXXFLAGS ?= -O3 -fPIC -fexceptions -fvisibility=hidden -Wno-ctor-dtor-privacy
# LibJXR
CXXFLAGS += -D__ANSI__
CXXFLAGS += $(INCLUDE)

ifeq ($(shell sh -c 'uname -m 2>/dev/null || echo not'),x86_64)
	CFLAGS += -fPIC
	CXXFLAGS += -fPIC
endif

TARGET  = freeimageturbo
STATICLIB = lib$(TARGET).a
SHAREDLIB = lib$(TARGET)-$(VER_MAJOR).$(VER_MINOR).so
LIBNAME	= lib$(TARGET).so
VERLIBNAME = $(LIBNAME).$(VER_MAJOR)
HEADER = Source/FreeImage.h

LIBJPEGTURBO_A = Source/LibJPEGTurbo/.libs/libturbojpeg.a
LIBJPEGTURBO_O = libjpegturbo
LIBJPEGTURBO_H = Source/LibJPEGTurbo/jconfig.h


default: all

all: dist

dist: FreeImage
	cp *.a Dist
	cp *.so Dist
	cp Source/FreeImage.h Dist

dos2unix:
	@$(DOS2UNIX) $(SRCS) $(INCLS)

FreeImage: $(STATICLIB) $(SHAREDLIB)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

.cpp.o:
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(MODULES): $(LIBJPEGTURBO_H)

$(STATICLIB): $(LIBJPEGTURBO_A) $(MODULES)
	$(AR) r $@ $(MODULES)
	mkdir -p $(LIBJPEGTURBO_O)
	cd $(LIBJPEGTURBO_O); $(AR) x ../$(LIBJPEGTURBO_A)
	$(AR) -r $@ $(LIBJPEGTURBO_O)/*.o

$(SHAREDLIB): $(LIBJPEGTURBO_A) $(MODULES) 
	$(CC) -s -shared -Wl,-soname,$(VERLIBNAME) $(LDFLAGS) -o $@ $(MODULES) $(LIBJPEGTURBO_A)  $(LIBRARIES)

install:
	install -d $(INCDIR) $(INSTALLDIR)
	install -m 644 -o root -g root $(HEADER) $(INCDIR)
	install -m 644 -o root -g root $(STATICLIB) $(INSTALLDIR)
	install -m 755 -o root -g root $(SHAREDLIB) $(INSTALLDIR)
	ln -sf $(SHAREDLIB) $(INSTALLDIR)/$(VERLIBNAME)
	ln -sf $(VERLIBNAME) $(INSTALLDIR)/$(LIBNAME)	
	ldconfig

clean:
	rm -f core Dist/*.* u2dtmp* $(MODULES) $(STATICLIB) $(SHAREDLIB) $(LIBNAME)
	if [ -e Source/LibJPEGTurbo/Makefile ]; then make -C Source/LibJPEGTurbo distclean; fi
	rm -rf $(LIBJPEGTURBO_O) $(LIBJPEGTURBO_A) $(LIBJPEGTURBO_H)
	touch Dist/delete.me

$(LIBJPEGTURBO_H):
	cd Source/LibJPEGTurbo && ./configure --disable-shared --enable-static --with-jpeg8 --with-pic

$(LIBJPEGTURBO_A): $(LIBJPEGTURBO_H)
	cd Source/LibJPEGTurbo && $(MAKE)

