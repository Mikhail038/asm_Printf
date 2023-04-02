
VR_C	= test
VR_ASM 	= printf

.PHONY: all
all:
#@echo "==Compiling C file;"

	@echo "==Compiling Assembler file"
	@nasm -g -f elf64 -l $(VR_ASM).lst -o $(VR_ASM).o -g $(VR_ASM).asm

	@echo "==Compiling main"
	@gcc -c $(VR_C).c -o $(VR_C).o -O0

	@echo "==Linking files"
	@gcc -no-pie $(VR_C).o printf.o -o $(VR_C)

#@ld -no-pie printf.o -o printf_exec
	@echo "==Finished"

#=============================================================

.PHONY: clean
clean:
	@echo "==Cleaning object files";
	@rm -rf *.o
	@echo "==Finished"

#=============================================================


.PHONY: fclean
fclean:
	@echo "==Cleaning logs, object files and executable";
	@rm -rf *.o *.lst printf_exec
	@echo "==Finished"

