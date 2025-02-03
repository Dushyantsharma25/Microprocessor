section .data
    prompt db "Enter five 64-bit hexadecimal numbers:", 0
    prompt_len equ $-prompt
    message db "Five hexadecimal numbers are:", 0
    message_len equ $-message
    hex_numbers resq 5  ; Reserve space for 5 64-bit numbers
    dispbuff db 16 dup(0)  ; Buffer to store ASCII output

section .bss
    ; No specific bss needed for this task

section .text
    global _start

_start:
    ; Display the prompt
    call display
    
    ; Accept the 5 hexadecimal numbers from the user
    mov rcx, 5  ; Loop counter for 5 inputs
    lea rsi, [hex_numbers]
accept_loop:
    call accept
    call Ascii_to_Hex
    add rsi, 8  ; Move to the next slot for the next number
    loop accept_loop
    
    ; Display message "Five hexadecimal numbers are:"
    call display

    ; Display the hexadecimal numbers
    lea rsi, [hex_numbers]
    mov rcx, 5  ; We have 5 numbers to display
display_loop:
    mov rbx, [rsi]  ; Load hex number from the array
    call Hex_to_Ascii
    add rsi, 8  ; Move to the next number in the array
    loop display_loop

    ; Exit the program
    mov rax, 60  ; sys_exit system call
    xor rdi, rdi  ; Return code 0
    syscall

; Macros
%macro display 0
    mov rax, 1        ; sys_write
    mov rdi, 1        ; file descriptor: stdout
    lea rsi, [prompt] ; Address of the message to display
    mov rdx, prompt_len ; Length of the message
    syscall
%endmacro

%macro accept 0
    mov rax, 0        ; sys_read
    mov rdi, 0        ; file descriptor: stdin
    lea rsi, [dispbuff] ; Address of the input buffer
    mov rdx, 16       ; Maximum length of input (ASCII hex chars)
    syscall
%endmacro

; Procedure 1: Ascii_to_Hex
Ascii_to_Hex:
    ; RSI points to the ASCII input
    mov rcx, 16  ; We expect 16 characters (for a 64-bit number)
    xor rbx, rbx  ; Clear RBX, this will hold the final hex number
ascii_to_hex_loop:
    mov al, byte [rsi]  ; Load the ASCII character
    cmp al, '9'  ; Check if the character is between 0-9
    jbe ascii_num_to_digit
    sub al, 'A' - 10   ; Convert 'A'-'F' to 10-15
    jmp store_in_rbx
ascii_num_to_digit:
    sub al, '0'  ; Convert '0'-'9' to 0-9
store_in_rbx:
    shl rbx, 4    ; Shift left to make space for the next digit
    or  rbx, rax  ; Add the current digit to the number
    inc rsi       ; Move to the next character
    loop ascii_to_hex_loop
    ret

; Procedure 2: Hex_to_Ascii
Hex_to_Ascii:
    lea rsi, [dispbuff]  ; Buffer to store the ASCII output
    mov rcx, 16  ; We need to convert 16 digits
hex_to_ascii_loop:
    shl rbx, 4    ; Shift left to get the next 4 bits
    and rbx, 0xF0
    shr rbx, 4    ; Extract the 4 bits (1 hex digit)
    cmp bl, 9
    jbe hex_digit_to_char
    add bl, 'A' - 10
    jmp store_ascii_char
hex_digit_to_char:
    add bl, '0'
store_ascii_char:
    mov [rsi], bl  ; Store the ASCII character
    inc rsi
    loop hex_to_ascii_loop
    ; Print the result
    mov rax, 1        ; sys_write
    mov rdi, 1        ; file descriptor: stdout
    lea rsi, [dispbuff] ; Address of the result buffer
    mov rdx, 16       ; Length of the output (16 characters)
    syscall
    ret
