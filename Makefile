LIBTOOL = libtool
LIBTOOL_OPTIONS = --tag=CC

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
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=compile gcc -c -static -fPIC lib.c -o .deps/lib.lo
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=link gcc -static -export-symbols-regex "^vlc_entry" -o $@ \
		-Wl,--whole-archive .deps/lib.lo -Wl,--no-whole-archive

libmain_lib.la: main_lib.c lib.la
	mkdir -p .deps/
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=compile gcc -c -fPIC -static main_lib.c -o .deps/main_lib.lo
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=link gcc -static -export-symbols-regex "^vlc_entry|^entrypoint" -o .deps/$@.lo \
		-Wl,--whole-archive .deps/main_lib.lo lib.la -Wl,--no-whole-archive
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=link gcc -fPIC -export-symbols-regex "^vlc_entry|^entrypoint" -o $@ \
		-Wl,--whole-archive .deps/$@.o -Wl,--no-whole-archive

exe: libmain_lib.la stats
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=compile cc -c -o .deps/main.lo main.c
	$(LIBTOOL) $(LIBTOOL_OPTIONS) --mode=link cc -o $@ .deps/main.lo libmain_lib.la

clean:
	rm -rf lib.la libmain_lib.la .deps/ .libs/
