; X86/64 Assembly Language Program to accept five 64-bit hexadecimal numbers
; from the user, store them in an array, and display them.
; Author: Dushyant krishna Sharma
; Roll No: 7223

%macro io 4
	mov rax,%1    ; System call number (sys_write or sys_read)
	mov rdi,%2    ; File descriptor (1 for stdout, 0 for stdin)
	mov rsi,%3    ; Buffer address
	mov rdx,%4    ; Buffer length
	syscall       ; Perform system call
%endmacro

%macro exit 0
	mov rax,60    ; System call number for exit
	mov rdi,0     ; Exit status (0 for success)
	syscall       ; Perform system call
%endmacro

section .data

	msg1 db "Roll no- 7223",10,"Name : Dushyant krishna Sharma",10,"Write X86/64 ALP to accept five 64 bit hexadecimal numbers from user and store it in an array and display the accepted number.",10
	msg1len equ $-msg1

	

	msg2 db "Enter 5 64-bit hexadecimal numbers:",10  ; Prompt for user input
	msg2len equ $-msg2

	msg3 db "5 64-bit hexadecimal numbers are: ",10   ; Output header
	msg3len equ $-msg3

	newline db 10   ; Newline character

section .bss
	asciinum resb 17   ; Buffer for ASCII representation of numbers (16 digits + null terminator)
	hexnum resq 5      ; Array to store 5 64-bit numbers

section .text
global _start

_start:
	io 1,1,msg1,msg1len   ; Print introductory message
	io 1,1,msg2,msg2len   ; Prompt for user input

	mov rcx,5    ; Loop counter for 5 numbers
	mov rsi,hexnum  ; Pointer to array

next1:
	push rsi
	push rcx
	io 0,0,asciinum,17   ; Read user input (hex string)
	call ascii_hex64      ; Convert ASCII to 64-bit hex
	pop rcx
	pop rsi
	mov [rsi],rbx        ; Store the converted value in the array
	add rsi,8            ; Move to the next storage location
	loop next1           ; Repeat 5 times

	io 1,1,msg3,msg3len  ; Print output header

	mov rsi,hexnum   ; Reset pointer to array
	mov rcx,5        ; Loop counter for 5 numbers

next2:
	push rsi
	push rcx
	mov rbx,[rsi]    ; Load stored number into rbx
	call hex_ascii64 ; Convert 64-bit hex to ASCII
	pop rcx
	pop rsi
	add rsi,8        ; Move to next stored number
	loop next2       ; Repeat 5 times

	exit   ; Exit program

; Subroutine: Convert ASCII hex string to 64-bit integer
ascii_hex64:
	mov rsi,asciinum  ; Load address of ASCII input
	mov rbx,0         ; Initialize output register
	mov rcx,16        ; Process 16 hex digits

next3:
	rol rbx,4         ; Shift left by 4 bits to make room for next digit
	mov al,[rsi]      ; Load next ASCII character
	cmp al,39h        ; Compare with '9'
	jbe sub30h        ; If less, it's 0-9, subtract 0x30
	sub al,7h         ; Otherwise, adjust for A-F

sub30h:
	sub al,30h        ; Convert ASCII to numeric value
	add bl,al         ; Add to result
	inc rsi           ; Move to next character
	loop next3        ; Repeat for 16 characters

	ret

; Subroutine: Convert 64-bit integer to ASCII hex string
hex_ascii64:
	mov rsi,asciinum  ; Load address of output buffer
	mov rcx,16        ; Process 16 hex digits

next4:
	rol rbx,4         ; Shift left by 4 bits
	mov al,bl         ; Extract lower 4 bits
	and al,0fh        ; Mask to get single hex digit
	cmp al,9          ; Compare with 9
	jbe add30h        ; If 0-9, add 0x30

	add al,7h         ; Otherwise, adjust for A-F

add30h:
	add al,30h        ; Convert to ASCII
	mov [rsi],al      ; Store ASCII digit
	inc rsi           ; Move to next character
	loop next4        ; Repeat for 16 characters

	io 1,1,asciinum,16  ; Print converted hex string
	io 1,1,newline,1   ; Print newline

	ret

