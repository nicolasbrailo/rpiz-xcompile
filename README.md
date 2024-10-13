# rpiz-xcompile

Simple and minimal clang cross compiler for Raspberry pi zero

A way to x-compile things from Debian Bookworm to Raspberry Pi Zero Debian. May work in other platforms.

[Read more here](https://nicolasbrailo.github.io/blog/2024/1012_rpixcompile.html).

Example:

```
./mount_rpy_root.sh
clang -o foo -target arm-linux-gnueabihf -mcpu=arm1176jzf-s --sysroot ./mnt/ foo.c
./umount_rpy_root.sh
```

This has high changes of producing a binary `foo`, which can be run in a Raspberry Pi Zero.

