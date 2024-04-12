# Ray Tracer in a boot sector

*by Oscar Toledo G. Apr/12/2024*

http://nanochess.org

https://github.com/nanochess

### What is this?

This is a port of the amazing Ray Tracer in Atari 8-bit BASIC by D. Scott Williamson. You can see it at [https://bunsen.itch.io/raytrace-movie-atari-8bit-by-d-scott-williamson](https://bunsen.itch.io/raytrace-movie-atari-8bit-by-d-scott-williamson)

I asked him for permission to make a port to a boot sector, and here it is.

If you are going to run it in real hardware it requires a minimum of a Pentium Pro, otherwise most modern emulators will be able to run it.

### How to use it.

If you want to assemble it, you must download the Netwide Assembler (NASM) from www.nasm.us

Use this command line:

    nasm -f bin ray.asm -Dcom_file=1 -o ray.com
    nasm -f bin ray.asm -Dcom_file=0 -o ray.img

Tested with VirtualBox for macOS running Windows XP running this interpreter, it also works with DOSBox and probably with QEMU:

    qemu-system-x86_64 -fda ray.img

![Ray tracer in a boot sector](RayTracer.png)

## More on this?

Do you want to learn 8086/8088 assembler? Get my books Programming Boot Sector Games containing an 8086/8088 crash course! Also available More Boot Sector Games. Now available from Lulu and Amazon!
