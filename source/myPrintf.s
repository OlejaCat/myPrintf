section .rodata
format_table:
	dq print_symbol
	dq 'b'-'%'-1 dup(0)
	dq print_binary
	dq print_char
	dq print_decimal
	dq 'o'-'d'-1 dup(0)
	dq print_octal
	dq 's'-'o'-1 dup(0)
	dq print_string
	dq 'x'-'s'-1 dup(0)
	dq print_hex

section .data
buffer_string:	db 128 dup(0)
buffer_end  	equ $

global myPrintf
section .text

;-----------------------------------------------------------------------------
; ConvertToSystem - Macro to convert number to specified base
;-----------------------------------------------------------------------------
; Converts RAX to string in given base and stores digits in buffer
; Entry: %1 = Target base (immediate value)
;        RAX = Number to convert
;        RSI = Buffer write position
; Exit:  Digits written to buffer, RSI updated
; Destr: RAX, RBX, RDX, RCX
;-----------------------------------------------------------------------------
%macro ConvertToSystem 1
.proceed_digits:
	mov rbx, %1
	xor rdx, rdx
	div rbx
	push rdx
	inc rcx
	test rax, rax
	jz .print_digits
	jmp .proceed_digits

.print_digits:
	test rcx, rcx
	jz .to_string_out
	pop rax
	add rax, '0'
	mov [rsi], al
	inc rsi
	dec rcx
	jmp .print_digits

.to_string_out:
%endmacro

;-----------------------------------------------------------------------------
; putCharWithCheck - Macro to write char with buffer check
;-----------------------------------------------------------------------------
; Writes character to buffer and flushes if full
; Entry: %1 = Character to write
;        RSI = Current buffer position
; Exit:  Character added to buffer, RSI incremented
; Destr: AL, RSI
;-----------------------------------------------------------------------------
%macro putCharWithCheck 1
	mov [rsi], %1
	inc rsi
    call printBufferWithCheck
%endmacro


;-----------------------------------------------------------------------------
; myPrintf - My printf implementation
;-----------------------------------------------------------------------------
; Formats and prints text according to format string with specifiers:
; %b - binary, %c - char, %d - decimal, %o - octal, %s - string, %x - hex
; Pushes registers values on top of stack
; Entry: RDI = Format string
;        Variable arguments in RSI, RDX, RCX, R8, R9, stack
; Exit:  Formatted output written to stdout
; Destr: RAX, RCX, RDX, RSI, RDI, R10, R11
;-----------------------------------------------------------------------------
myPrintf:
	pop r10

	push r9
	push r8
	push rcx
	push rdx
	push rsi

	mov rsi, buffer_string
	jmp formatInputString

formatInputStringBack:
    call printBuffer

	pop rsi
	pop rdx
	pop rcx
	pop r8
	pop r9
	
	push r10
	ret


;-----------------------------------------------------------------------------
; formatInputString - Main format processing loop
;-----------------------------------------------------------------------------
; Processes format string and arguments
; Entry: RDI = Format string
;        RSI = Buffer position
; Exit:  Processed format string with arguments in buffer
; Destr: RAX, RBX, RCX, RDX, RDI, RSI
;-----------------------------------------------------------------------------
formatInputString:
	push rbx
	push rdx

	mov rbx, 16   ; stack shift to get argumants
	mov rdx, rsi  ; saving start of buffer pointer
	xor rcx, rcx

process_string:
	cmp byte [rdi], 0
	je format_input_string_out
	cmp byte [rdi], '%'
	je format
	jmp print_symbol

format:
	inc rdi
	xor rax, rax
	mov al, [rdi]	
	sub al, '%'
    cmp al, 0
    jl error
    cmp al, 'x'-'%'
    ja error
    imul rax, 8
    add rax, format_table 
    mov rax, [rax]
    test rax, rax
    jz error
	jmp rax

print_char:
	mov al, [rsp+rbx]			
	mov [rsi], al 
	inc rsi
	jmp next_argument

print_string:
	push rdi
	mov rdi, [rsp+rbx+8]
	jmp putStringToBuffer

putStringToBufferBack:
	pop rdi	
	jmp next_argument

print_decimal:
	mov rax, [rsp+rbx]	
	jmp putDecimalToBuffer 
    
putDecimalToBufferBack:
	jmp next_argument

print_hex:
	mov rax, [rsp+rbx]
	jmp putHexToBuffer

putHexToBufferBack:
	jmp next_argument

print_octal:
	mov rax, [rsp+rbx]
	jmp putOctalTobuffer

putOctalTobufferBack:
	jmp next_argument

print_binary:
	mov rax, [rsp+rbx]
	jmp putBinaryTobuffer

putBinaryTobufferBack:
	jmp next_argument

print_symbol:
	mov al, byte [rdi]
    putCharWithCheck al
	jmp next_symbol

next_argument:
	inc rcx
	add rbx, 8

next_symbol:
	inc rdi
	jmp process_string

error:
    mov rcx, -1

format_input_string_out:
	mov rax, rcx
	mov rcx, rsi
	sub rcx, rdx

	pop rdx
	pop rbx
    jmp formatInputStringBack


;-----------------------------------------------------------------------------
; putBinaryToBuffer - Handles '%b' format specifier
;-----------------------------------------------------------------------------
; Outputs unsigned binary number from arguments
; Entry: RAX = 64-bit unsigned integer
;        RSI = Buffer position
; Exit:  Binary string added to buffer
; Destr: RAX, RBX, RCX, RDX, RSI
;-----------------------------------------------------------------------------
putBinaryTobuffer:
	push rbx
	push rcx
	push rdx

	xor rcx, rcx
    ConvertToSystem 2

	pop rdx
	pop rcx
	pop rbx	
    jmp putBinaryTobufferBack

;-----------------------------------------------------------------------------
; putOctalToBuffer - Handles '%o' format specifier
;-----------------------------------------------------------------------------
; Outputs unsigned octal number from arguments
; Entry: RAX = 64-bit unsigned integer
;        RSI = Buffer position
; Exit:  Octal string added to buffer
; Destr: RAX, RBX, RCX, RDX, RSI
;-----------------------------------------------------------------------------
putOctalTobuffer:
	push rbx
	push rcx
	push rdx

	xor rcx, rcx
    ConvertToSystem 8

	pop rdx
	pop rcx
	pop rbx	
    jmp putOctalTobufferBack


;-----------------------------------------------------------------------------
; putHexToBuffer - Handles '%x' format specifier
;-----------------------------------------------------------------------------
; Outputs unsigned hex number from arguments
; Entry: RAX = 64-bit unsigned integer
;        RSI = Buffer position
; Exit:  Hex string added to buffer
; Destr: RAX, RBX, RCX, RDX, RSI
;-----------------------------------------------------------------------------
putHexToBuffer:
	push rbx
	push rcx
	push rdx

	xor rcx, rcx

.hex_proceed_digits:
	mov rbx, 16
	xor rdx, rdx
	div rbx
	push rdx
	inc rcx
	test rax, rax
	jz .hex_print_digits
	jmp .hex_proceed_digits

.hex_print_digits:
	test rcx, rcx
	jz .hex_put_digits_out	
	pop rax
	cmp rax, 9
	ja .hex_letter_digit
	add rax, '0'
	jmp .hex_paste_to_buffer
	
.hex_letter_digit:
	sub rax, 10
	add rax, 'a'
			
.hex_paste_to_buffer:
    putCharWithCheck al
	dec rcx
	jmp .hex_print_digits

.hex_put_digits_out:
	pop rdx
	pop rcx
	pop rbx
    jmp putHexToBufferBack
	

;-----------------------------------------------------------------------------
; putDecimalToBuffer - Handles '%d' format specifier
;-----------------------------------------------------------------------------
; Outputs signed decimal number from arguments
; Entry: EAX = 32-bit signed integerb
;        RSI = Buffer position
; Exit:  Decimal string added to buffer
; Destr: RAX, RBX, RCX, RDX, RSI
;-----------------------------------------------------------------------------
putDecimalToBuffer:
	push rbx
	push rcx
	push rdx

	xor rcx, rcx

	cmp eax, 0
	jl .negative_number
	jmp .proceed_digits

.negative_number:
	neg eax
	push rax
	xor rax, rax
	mov al, '-'
    putCharWithCheck al
	pop rax

    ConvertToSystem 10

	pop rdx
	pop rcx
	pop rbx	
    jmp putDecimalToBufferBack


;-----------------------------------------------------------------------------
; putStringToBuffer - Handles '%s' format specifier
;-----------------------------------------------------------------------------
; Outputs null-terminated string from arguments
; Entry: RDI = String pointer
;        RSI = Buffer position
; Exit:  String copied to buffer
; Destr: RAX, RCX, RDI, RSI
;-----------------------------------------------------------------------------
putStringToBuffer:
	push rbx
	push rcx

	mov rbx, rdi 
	xor al, al

.put_char:
	mov cl, [rdi]
    putCharWithCheck cl
	scasb
	jne .put_char

	sub rdi, rbx
	mov rax, rdi 

	pop rcx
	pop rbx
    jmp putStringToBufferBack


;-----------------------------------------------------------------------------
; printBufferWithCheck - Flushes buffer if full
;-----------------------------------------------------------------------------
; Checks buffer position and flushes if reached end
; Entry: RSI = Current buffer position
; Exit:  Buffer flushed if full, RSI reset if flushed
; Destr: RAX, RCX, RDX, RSI
;-----------------------------------------------------------------------------
printBufferWithCheck:
    test rsi, buffer_end
    jz .clear_buffer
    jmp .print_buffer_out

.clear_buffer:
    call printBuffer

.print_buffer_out:
    ret


;-----------------------------------------------------------------------------
; putBinaryToBuffer - Handles '%b' format specifier
;-----------------------------------------------------------------------------
; Outputs unsigned binary number from arguments
; Entry: RAX = 64-bit unsigned integer
;        RSI = Buffer position
; Exit:  Binary string added to buffer
; Destr: RAX, RBX, RCX, RDX, RSI
;-----------------------------------------------------------------------------
printBuffer:
    push rax
    push rcx
    push rdx
    push rdi

    mov rcx, rsi
    sub rcx, buffer_string
	xor rdi, rdi
	mov rdx, rcx 
	mov rsi, buffer_string
	mov rax, 0x1            ; first command write
	syscall	
    
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret
