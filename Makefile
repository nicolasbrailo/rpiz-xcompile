hello: test.c
	./mount_rpy_root.sh
	clang -o $@ -target arm-linux-gnueabihf -mcpu=arm1176jzf-s --sysroot ./mnt/ $^
	./umount_rpy_root.sh

deploy: hello
	scp ./hello 10.0.0.146:/home/batman/test

install_sys_deps:
	sudo apt-get install -y clang

