
.PHONY: all
all:
#@echo "==Compiling C file;"
#@gcc -c main.c -o main.o -O0

	@echo "==Compiling Assembler file"
	@nasm -g -f elf64 -l printf.lst -o printf.o -g printf.asm

#@echo "Linking files;"
#@gcc -no-pie main.o printf.o -o main

	@ld -no-pie printf.o -o printf_exec
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

