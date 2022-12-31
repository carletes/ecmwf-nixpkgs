# A development environment for a C program which depends on ecCodes

After activating this development shell (manually with `nix develop`,
or automatically if you have [direnv][] installed), you should be able
to build the sample C program `grib_print_data.c`, which depends on the
ecCodes library:

```
$ mkdir build
$ cd build
$ ecbuild ..
$ make
```

The resulting binary will be linked against ecCodes and its dependencies:

```
$ ls -l bin/grib_print_data
-rwxr-xr-x 1 carlos users 23616 Dec 31 17:20 bin/grib_print_data
$ ldd ./bin/grib_print_data
        linux-vdso.so.1 (0x00007ffde5398000)
        libeccodes.so => /nix/store/945sdcfh9wfb2sh4a504mh5mc7xyqi5x-eccodes-2.27.0/lib/libeccodes.so (0x00007f3178e00000)
        libm.so.6 => /nix/store/ayfr5l52xkqqjn3n4h9jfacgnchz1z7s-glibc-2.35-224/lib/libm.so.6 (0x00007f31791be000)
        libc.so.6 => /nix/store/ayfr5l52xkqqjn3n4h9jfacgnchz1z7s-glibc-2.35-224/lib/libc.so.6 (0x00007f3178a00000)
        libopenjp2.so.7 => /nix/store/w1vs38xy2ji2921wjfyy2rwl0jsjml09-openjpeg-2.5.0/lib/libopenjp2.so.7 (0x00007f3179150000)
        libaec.so.0 => /nix/store/wxzl8lyjh8w0jkx8x3nsm9xzmb703lcm-libaec-1.0.6/lib/libaec.so.0 (0x00007f3179146000)
        libpng16.so.16 => /nix/store/8gmgb7m65nafhhqksc71bsfykggsx2ps-libpng-apng-1.6.37/lib/libpng16.so.16 (0x00007f317910c000)
        libz.so.1 => /nix/store/zaflwh2nwzj1f0wngd7hqm3nvlf3yhsx-zlib-1.2.13/lib/libz.so.1 (0x00007f31790ee000)
        /nix/store/ayfr5l52xkqqjn3n4h9jfacgnchz1z7s-glibc-2.35-224/lib/ld-linux-x86-64.so.2 => /nix/store/ayfr5l52xkqqjn3n4h9jfacgnchz1z7s-glibc-2.35-224/lib64/ld-linux-x86-64.so.2 (0x00007f31792a0000)
```

[direnv]: https://direnv.net/
