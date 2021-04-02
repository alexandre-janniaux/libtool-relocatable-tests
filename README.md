alexandre@a7dfee665b31:/home/alexandre/workspace/videolabs/vlc-meson/build-iphoneos-arm64/build/modules$ /opt/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang++ -mios-version-min=9.0 -arch arm64 -isysroot /opt/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk -g -Werror=invalid-command-line-argument -Werror=unknown-warning-option -fno-stack-check -stdlib=libc++ -I/home/alexandre/workspace/videolabs/vlc-meson/contrib/aarch64-apple-darwin/include -Wall -Wextra -Wsign-compare -Wundef -Wpointer-arith -Wvolatile-register-var -Wformat -Wformat-security -fvisibility=hidden -fno-math-errno -funsafe-math-optimizations -fno-rounding-math -funroll-loops -fstack-protector-strong -mbranch-protection=standard -Wl,-ios_version_min,9.0 -mios-version-min=9.0 -arch arm64 -Wl,-headerpad_max_install_names -L/home/alexandre/workspace/videolabs/vlc-meson/contrib/aarch64-apple-darwin/lib -r -o .deps/librnnoise_plugin.partial.la.o -fPIC -exported_symbols_list "librnnoise_plugin.la.symbollist" .deps/librnnoise_plugin.partial.la.module.o .libs/librnnoise_plugin.a -L/home/alexandre/workspace/videolabs/vlc-meson/contrib/aarch64-apple-darwin/lib -liconv /home/alexandre/workspace/videolabs/vlc-meson/contrib/aarch64-apple-darwin/lib/librnnoise.a -lm -Wl,-t

ok on Darwin for partial linking, but when creating a convenience library, the .a gets linked into the final objects



commit 4b50692175e010df539241d137bc6ef695481426
Author: Thomas Tanner <tanner@ffii.org>
Date:   Fri Jun 11 23:46:47 1999 +0000

    * ltmain.in: store old archives in deplibs and old_deplibs,
      retain the order of dependency libraries (even old archives),
      determining the absolute directory name didn't work due to a typo,
      add the library search paths of all dependency libraries when
      linking a library (fixes IRIX 5.2 bug)



-      *.o | *.obj | *.a | *.lib)
+      *.o | *.obj)
        # A standard object.
        objs="$objs $arg"
        ;;
@@ -1214,6 +1215,13 @@ compiler."
        libobjs="$libobjs $arg"
        ;;

+      *.a | *.lib)
+       # An archive.
+       deplibs="$deplibs $arg"
+       old_deplibs="$old_deplibs $arg"
+       continue
+       ;;
+
       *.la)
        # A libtool-controlled library.

@@ -1378,6 +1386,7 @@ compiler."
       # Now set the variables for building old libraries.
       build_libtool_libs=no
       oldlibs="$output"
+      objs="$objs$old_deplibs"
       ;;
