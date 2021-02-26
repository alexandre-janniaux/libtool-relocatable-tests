LIBTOOL ?= libtool
LIBTOOL_OPTIONS = --tag=CC
CC ?= cc

all: libmain_lib.la exe
	./exe

stats: libmain_lib.la
	@du -h .libs/lib.a .libs/libmain_lib.a
	@printf "\n - Show lib.a content:\n"
	@nm .libs/lib.a
	@printf "\n - Show libmainlib.la.o content:\n"
	@nm .deps/libmain_lib.la.o
	@printf "\n - Show mainlib.a content:\n"
	@nm .libs/libmain_lib.a

lib.la: lib.c
	mkdir -p .deps/
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=compile $(CC) -c -static -fPIC lib.c -o .deps/lib.lo
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=link $(CC) -static -export-symbols-regex "^vlc_entry" -o $@ \
		-Wl,--whole-archive .deps/lib.lo -Wl,--no-whole-archive

libmain_lib.la: main_lib.c lib.la
	mkdir -p .deps/
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=compile $(CC) -c -fPIC -static main_lib.c -o .deps/main_lib.lo
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=link $(CC) -static -export-symbols-regex "^vlc_entry|^entrypoint" -o .deps/$@.o \
		-Wl,--whole-archive .deps/main_lib.lo lib.la -Wl,--no-whole-archive
	echo "# Generated by libtool (GNU libtool) 2.4.6.42-b88ce-dirty" > .deps/$@.lo
	echo "non_pic_object='$@.o'" >> .deps/$@.lo
	echo "pic_object=" >> .deps/$@.lo
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=link $(CC) -static -o libmain_lib.la .deps/$@.lo

exe: libmain_lib.la stats
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=compile $(CC) -c -o .deps/main.lo main.c
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=link $(CC) -o $@ .deps/main.lo libmain_lib.la

clean:
	rm -rf lib.la libmain_lib.la .deps/ .libs/
