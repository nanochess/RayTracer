# Makefile contributed by jtsiomb

src = ray.asm

.PHONY: all
all: ray.img ray.com

ray.img: $(src)
	nasm -f bin -o $@ $(src)

ray.com: $(src)
	nasm -f bin -o $@ -Dcom_file=1 $(src)

.PHONY: clean
clean:
	$(RM) ray.img ray.com

.PHONY: rundosbox
rundosbox: ray.com
	dosbox $<

.PHONY: runqemu
runqemu: ray.img
	qemu-system-i386 -fda ray.img
