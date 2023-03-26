;24.03.22
;=================================================

section .rodata

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
                        dq      Case_err        ;w - error
                        dq      Case_hex        ;x

;=================================================

section .data

buf_zero:       db 0
Buffer:         times 64 db 0
BufferLng:      equ $ - Buffer

Error:          db 0xA, "==Wrong specification==", 0xA, "==0nly these speceficators are supported:==", 0xA, "==b c d i o p s u x==", 0xA
ErrorLng:       equ $ - Error

message db "%s %d %u %b %o %x", 0

;=================================================

section .text

global _start

_start:
                push -123
                push -123
                push -123
                push -123
                push -123
                push message
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
                pop r10         ;store return address

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
                push r10         ;restore return address

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
; %c printf style processing
;=================================================
; Expects:      None
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_chr:
                pop rax
                push rsi                ;store line

                mov [Buffer], al

                mov rsi, Buffer

                call PutChar

                pop rsi                 ;restore line

                jmp MYprintf.poop

;=================================================
; %s printf style processing
;=================================================
; Expects:      None
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_str:
                pop rax

                push rsi

                mov rsi, rax

                call Strlen

                call PutS

                pop rsi


                jmp MYprintf.poop

;=================================================
; %b printf style processing
;=================================================
; Expects:      None
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_bin:
                pop rax         ;Number
                mov rbx, 2     ;Radix
                mov rdi, Buffer ;Buffer

                call UNtoSC

                jmp MYprintf.poop

;=================================================
; %u printf style processing
;=================================================
; Expects:      None
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_uns:
                pop rax         ;Number
                mov rbx, 10     ;Radix
                mov rdi, Buffer ;Buffer

                call UNtoSC

                jmp MYprintf.poop

;=================================================
; %d printf style processing
;=================================================
; Expects:      None
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_dec:
                mov rax, [rsp]          ;peek number
                cmp rax, 0
                jge .no_minus

                mov al, '-'
                push rsi                ;store line

                mov [Buffer], al

                mov rsi, Buffer

                call PutChar

                pop rsi                 ;restore line

                pop rax

                dec rax                 ;dop code => norm code
                not rax

                push rax

.no_minus:
                pop rax         ;Number
                mov rbx, 10     ;Radix
                mov rdi, Buffer ;Buffer

                call UNtoSC

                jmp MYprintf.poop

;=================================================
; %o printf style processing
;=================================================
; Expects:      None
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_oct:
                pop rax         ;Number
                mov rbx, 8     ;Radix
                mov rdi, Buffer ;Buffer

                call UNtoSC

                jmp MYprintf.poop

;=================================================
; %h printf style processing
;=================================================
; Expects:      None
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_hex:
                pop rax         ;Number
                mov rbx, 16     ;Radix
                mov rdi, Buffer ;Buffer

                call UNtoSC

                jmp MYprintf.poop

;=================================================
; %ANY_WRONG printf style processing
;=================================================
; Expects:      None
; Entry:        None
; Exit:         None
; Eliminate:    RSI, RDX, RAX
;=================================================
Case_err:
                push rsi

                mov rsi, Error
                mov rdx, ErrorLng
                call PutS

                pop rsi

                jmp MYprintf.poop

;=================================================
; Unsigned Numbers to String Converter
;=================================================
; Expects:      Buffer for digits (size ~30)
; Entry:        Buffer in RDI, Number in RAX, Radix in RBX
; Exit:         None
; Eliminate:    RSI, RDI, RAX, RBX, RDX
;=================================================
UNtoSC:
                push rsi

.one_digit:
                xor rdx, rdx    ;rdx <- 0

                div rbx         ;rdx:rax / rbx => rax * rbx + (rdx)

.transform:
                add dl, '0'     ;0 -> '0'

                cmp dl, '9'
                ja .letter_shift

.put:
                mov [rdi], dl
                inc rdi

                cmp rax, rbx
                jae .one_digit

                cmp al, 0
                je .skip_last_digit

                mov dl, al
                mov al, 0
                jmp .transform

.skip_last_digit:

                dec rdi
                mov rsi, rdi
.print:
                mov al, [rsi]
                cmp al, 0               ;check if terminate
                je .terminate

                call PutChar

                dec rsi
                jmp .print

.terminate:
                pop rsi

                ret


.letter_shift:
                add dl, 'A' - '9' - 1
                jmp .put

;=================================================
; Outputs char to a console
;=================================================
; Expects:      Line ends with terminate symbol 0
; Entry:        RSI = Address of string
; Exit:         RDX = Length of line
; Eliminate:    RDX, RAX
;=================================================
Strlen:
                mov rdx, rsi

                dec rdx         ;compensate
.one_char:
                inc rdx
                mov al, [rdx]
                cmp al, 0       ;check if terminate
                jne .one_char

                sub rdx, rsi

                ret
;=================================================
; Outputs char to a console
;=================================================
; Expects:      None
; Entry:        RSI = Address of string
; Exit:         None
; Eliminate:    RSI, RDI, RDX, RAX
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
; Entry:        RSI = Address of string RDX = Number of symbols
; Exit:         None
; Eliminate:    RSI, RDI, RDX, RAX
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
;=================================================
