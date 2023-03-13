build:
	rm src/*.bin
	nasm -fbin src/boot.asm -o src/boot.bin
	nasm -fbin src/game.asm -o src/game.bin
	cat src/boot.bin src/game.bin > out/program.bin

qemu:
	nasm -fbin src/boot.asm -o src/boot.bin
	nasm -fbin src/game.asm -o src/game.bin
	cat src/boot.bin src/game.bin > out/program.bin
	qemu-system-i386 out/program.bin


clean:
	rm src/*.bin
