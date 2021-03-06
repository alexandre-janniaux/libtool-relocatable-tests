LIBTOOL ?= libtool
LIBTOOL_OPTIONS = --tag=CC --verbose
CC ?= cc
CXX ?= c++
LD ?= $(CC)

LTCOMPILE = $(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=compile
LTLINK = $(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=link

# Using -L and -l works with libtool
#EXTERNAL_LDFLAGS = -L$(shell pwd) -lexternal
# But we want to avoid the .a archives being shipped into
# the final archive, and actually linked to the last target
EXTERNAL_LDFLAGS = libexternal.a

all: libmain_lib.la exe
	./exe

libexternal.a: extern_lib.c
	$(CC) -fPIC -c -o extern_lib.o extern_lib.c
	$(AR) cru $@ extern_lib.o

stats: libmain_lib.la
	@du -h .libs/lib.a .libs/libmain_lib.a
	@printf "\n - Show lib.a content:\n"
	@nm .libs/lib.a
	@printf "\n - Show libtest_cpp.a content:\n"
	@nm .libs/libtest_cpp.a
	@printf "\n - Show libmainlib.la.o content:\n"
	@nm .deps/libmain_lib.la.o
	@printf "\n - Show mainlib.a content:\n"
	@nm .libs/libmain_lib.a

lib.la: lib.c libexternal.a
	mkdir -p .deps/
	$(LTCOMPILE) $(CC) -c -static -fPIC lib.c -o .deps/lib.lo
	$(LTLINK) $(LD) -static -export-symbols-regex "^vlc_entry" -o $@ \
		-Wl,--whole-archive .deps/lib.lo -Wl,--no-whole-archive $(EXTERNAL_LDFLAGS)

libtest_cpp.la: libtest.cpp libexternal.a
	mkdir -p .deps/
	$(LTCOMPILE) $(CXX) -c -static -fPIC libtest.cpp -o .deps/libtest.lo
	$(LTLINK) $(LD) -static -export-symbols-regex "^vlc_entry" -o $@ \
		.deps/libtest.lo $(EXTERNAL_LDFLAGS)

libmain_lib.la: main_lib.c lib.la libtest_cpp.la
	mkdir -p .deps/
	$(LTCOMPILE) $(CC) -c -fPIC -static main_lib.c -o .deps/main_lib.lo
	$(LTLINK) $(LD) -static -export-symbols-regex "^vlc_entry|^entrypoint" -o .deps/$@.o \
		-Wl,--whole-archive .deps/main_lib.lo lib.la -Wl,--no-whole-archive -static-libstdc++ -static-libgcc
	echo "# Generated by $$($(LIBTOOL) --version | head -n1)" > .deps/$@.lo
	echo "non_pic_object='$@.o'" >> .deps/$@.lo
	echo "pic_object='$@.o'" >> .deps/$@.lo
	$(LTLINK) $(LD) -static -o libmain_lib.la .deps/$@.lo \
		lib.la libtest_cpp.la -rpath /usr/local/lib

exe: libmain_lib.la stats
	$(LTCOMPILE) $(CC) -c -o .deps/main.lo main.c
	$(LTLINK) $(CXX) -o $@ .deps/main.lo libmain_lib.la -lstdc++

clean:
	rm -rf lib.la libmain_lib.la libtest_cpp.la .deps/ .libs/
