; Write an X86/64 ALP to accept a string and display its length
; Author: Dushyant Krishna Sharma
; Roll No: 7223

%macro io 4
	mov rax,%1         ; System call number
	mov rdi,%2         ; File descriptor (1 = stdout, 0 = stdin)
	mov rsi,%3         ; Address of the message buffer
	mov rdx,%4         ; Length of the message buffer
	syscall            ; Invoke system call
%endmacro

section .data
	; Display messages
	msg db "Roll no- 7223",10,"Name : Dushyant Krishna Sharma",10,"Write X86/64 ALP to accept a string and display its length.",10,"Date: 29 January 2025",10
	msglen equ $-msg

	msg1 db "Enter Your String:",10
	msg1len equ $-msg1

	msg2 db "Method 1 (without loop):",10
	msg2len equ $-msg2

	msg3 db "Method 2 (with loop):",10
	msg3len equ $-msg3

	count db 5   ; Unused variable in the code
	newline db 10
	len2 db 0    ; Variable to store the computed string length using loop

section .bss
	string resb 30   ; Buffer to store the input string (max 30 characters)
	asciinum resb 2  ; Buffer to store ASCII representation of length

section .text
global _start

_start:
	; Display initial message
	io 1,1,msg,msglen
	io 1,1,msg1,msg1len

	; Read input string from user
	io 0,0,string,30

	; Method 1: Calculate length without a loop
	dec rax         ; Reduce the value of rax by 1 to remove newline character
	mov rbx,rax     ; Store length in rbx
	io 1,1,msg2,msg2len
	call hex_ascii8 ; Convert and print length

	; Method 2: Calculate length using a loop
	io 1,1,msg3,msg3len
	mov rsi,string  ; Load string address into rsi

back:
	mov al,[rsi]    ; Load current character
	cmp al,10       ; Check for newline character
	je skip         ; If newline, exit loop
	inc byte[len2]  ; Increment length counter
	inc rsi         ; Move to next character
	loop back       ; Repeat until end of string

skip:
	mov bl,[len2]   ; Store computed length in bl
	call hex_ascii8 ; Convert and print length

	; Exit program
	mov rax,60      ; syscall: exit
	mov rdi,0       ; exit code 0
	syscall

; Convert an 8-bit value to hexadecimal ASCII and print it
hex_ascii8:
	mov rsi,asciinum  ; Point to output buffer
	mov rcx,2         ; Convert 2 hex digits

next2:
	rol bl,4          ; Rotate left 4 bits to process next hex digit
	mov al,bl         ; Copy current hex digit
	and al,0Fh        ; Mask lower 4 bits
	cmp al,9          ; Check if digit is 0-9
	jbe add30h        ; If yes, add '0'
	add al,7h         ; Convert A-F characters

add30h:
	add al,30h        ; Convert to ASCII
	mov [rsi],al      ; Store ASCII character
	inc rsi           ; Move buffer pointer
	loop next2        ; Repeat for next hex digit

	; Print the converted hexadecimal length
	io 1,1,asciinum,2
	io 1,1,newline,1
	ret

