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

%macro putCharWithCheck 1
	mov [rsi], %1
	inc rsi
    call printBufferWithCheck
%endmacro

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


formatInputString:
	push rbx
	push rdx

	mov rbx, 16
	mov rdx, rsi
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


printBufferWithCheck:
    test rsi, buffer_end
    jz .clear_buffer
    jmp .print_buffer_out

.clear_buffer:
    call printBuffer

.print_buffer_out:
    ret


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
	mov rax, 0x1
	syscall	
    
    pop rdi
    pop rdx
    pop rcx
    pop rax
    ret


stringLength:
	push rbx
	push rcx

	mov rbx, rdi
	xor al, al

	mov rcx, 0xffffffff
	repne scasb
	
	sub rdi, rbx
	mov rax, rdi
	
	pop rcx
	pop rbx

