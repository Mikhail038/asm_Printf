;24.03.22

section .rodata

;=======================================
;%(SYM) MYprintf JUMP TABLE
;=======================================
JUMP_TABLE:
                        dq      Case_bin        ;b
                        dq      Case_chr        ;c
                        dq      Case_dec        ;d
times ('i' - 'd' - 1)   dq      Case_err
                        dq      Case_dec        ;i
times ('o' - 'i' - 1)   dq      Case_err
                        dq      Case_oct        ;o
                        dq      Case_hex        ;p
times ('s' - 'p' - 1)   dq      Case_err
                        dq      Case_str        ;s
                        dq      Case_err        ;t - error
                        dq      Case_uns        ;u
                        dq      Case_err        ;v - error
                        dq      Case_hex        ;x
                        dq      Case_err        ;w - error

section .data

message db "za %c warudo", 0

num     dw -38

section .text

global _start

_start:
                push word [num]
                push message

                call MYprintf

                mov eax,    1
                mov ebx,    0
                int 0x80

;=================================================
; Processes line as printf do
;=================================================
; Expects:      Needed data in stack
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
MYprintf:

                pop rsi         ;load string

                dec rsi         ;compensate
.poop:
                inc rsi
                mov al, byte [rsi]      ;load symbol

                cmp al, 0               ;check if terminate
                je .terminate

                cmp al, '%'             ;check if it is speceficator
                je .special

                call PutChar

                jmp .poop

.terminate:
                ret


.special:
                inc rsi
                mov al, byte [rsi]      ;load next symbol (%X)

                cmp al, '%'
                jne .plazdarm

                call PutChar

                jmp .poop

.plazdarm:
                cmp al, 'b'             ;letter < b
                jb Case_err

                cmp al, 'x'             ;letter > x
                ja Case_err

                mov rax, [((rax - 'b') * 8 + JUMP_TABLE)]
                jmp rax

;=================================================
; Put char in console
;=================================================
; Expects:      char in stack
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_chr:
                jmp MYprintf.poop

;=================================================
; Put char in console
;=================================================
; Expects:      char in stack
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_str:
                jmp MYprintf.poop

;=================================================
; Put char in console
;=================================================
; Expects:      char in stack
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_bin:
                jmp MYprintf.poop

;=================================================
; Put char in console
;=================================================
; Expects:      char in stack
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_uns:
                jmp MYprintf.poop

;=================================================
; Put char in console
;=================================================
; Expects:      char in stack
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_dec:
                jmp MYprintf.poop

;=================================================
; Put char in console
;=================================================
; Expects:      char in stack
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_oct:
                jmp MYprintf.poop

;=================================================
; Put char in console
;=================================================
; Expects:      char in stack
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_hex:
                jmp MYprintf.poop

;=================================================
; Put char in console
;=================================================
; Expects:      char in stack
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_err:

                jmp MYprintf.poop
;=================================================
; Outputs char to a console
;=================================================
; Expects:      None
; Entry:        RSI = Address of string
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
PutChar:
                ; push rcx
                ; push r11

                mov rax, 1
                mov rdi, 1
                mov rdx, 1

                syscall

                ; pop  r11
                ; pop  rcx

                ret

;=================================================
; Outputs string to a console
;=================================================
; Expects:      None
; Entry:        RSI = Address of string EDX = Number of symbols
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
PutS:
                ; push rcx
                ; push r11

                mov rax, 1
                mov rdi, 1

                syscall

                ; pop  r11
                ; pop  rcx

                ret
