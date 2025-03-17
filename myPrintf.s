section .rodata
format_table:
	dq print_symbol
	dq 60 dup(0)
	dq print_binary
	dq print_char
	dq print_decimal
	dq 10 dup(0)
	dq print_octal
	dq 3 dup(0)
	dq print_string
	dq 4 dup(0)
	dq print_hex

section .data
buffer_string:	db 256 dup(0)
buffer_size  	equ $ - buffer_string

global myPrintf
section .text

myPrintf:
	pop r10

	push r9
	push r8
	push rcx
	push rdx
	push rsi

	mov rsi, buffer_string
	call formatInputString

	xor rdi, rdi
	mov rdx, rcx
	mov rsi, buffer_string
	mov rax, 0x1
	syscall	

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

	mov rbx, 24
	mov rdx, rsi
	xor rcx, rcx

process_string:
	cmp [rdi], byte 0
	je format_input_string_out
	cmp [rdi], byte '%'
	je format
	jmp print_symbol

format:
	inc rdi
	xor rax, rax
	mov al, [rdi]	
	sub al, 37
	jmp [format_table + rax * 8]

print_char:
	mov al, [rsp+rbx]			
	mov [rsi], al 
	inc rsi
	jmp next_argument

print_string:
	push rdi
	mov rdi, [rsp+rbx+8]
	call putStringToBuffer
	pop rdi	
	jmp next_argument

print_decimal:
	mov rax, [rsp+rbx]	
	call putDecimalToBuffer 
	jmp next_argument

print_hex:
	mov rax, [rsp+rbx]
	call putHexToBuffer
	jmp next_argument

print_octal:
	mov rax, [rsp+rbx]
	call putOctalTobuffer
	jmp next_argument

print_binary:
	mov rax, [rsp+rbx]
	call putBinaryTobuffer
	jmp next_argument

print_symbol:
	mov al, byte [rdi]
	mov [rsi], al
	inc rsi
	jmp next_symbol

next_argument:
	inc rcx
	add rbx, 8

next_symbol:
	inc rdi
	jmp process_string

format_input_string_out:
	mov rax, rcx
	mov rcx, rsi
	sub rcx, rdx

	pop rdx
	pop rbx
	ret


putBinaryTobuffer:
	push rbx
	push rcx
	push rdx

	xor rcx, rcx

.binary_proceed_digits:
	mov rbx, 2
	xor rdx, rdx
	div rbx
	push rdx
	inc rcx
	test rax, rax
	jz .binary_print_digits
	jmp .binary_proceed_digits

.binary_print_digits:
	test rcx, rcx
	jz .binary_to_string_out
	pop rax
	add rax, '0'
	mov [rsi], al
	inc rsi
	dec rcx
	jmp .binary_print_digits

.binary_to_string_out:
	pop rdx
	pop rcx
	pop rbx	
	ret

putOctalTobuffer:
	push rbx
	push rcx
	push rdx

	xor rcx, rcx

.octal_proceed_digits:
	mov rbx, 8
	xor rdx, rdx
	div rbx
	push rdx
	inc rcx
	test rax, rax
	jz .octal_print_digits
	jmp .octal_proceed_digits

.octal_print_digits:
	test rcx, rcx
	jz .octal_to_string_out
	pop rax
	add rax, '0'
	mov [rsi], al
	inc rsi
	dec rcx
	jmp .octal_print_digits

.octal_to_string_out:
	pop rdx
	pop rcx
	pop rbx	
	ret

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
	mov [rsi], al
	inc rsi
	dec rcx
	jmp .hex_print_digits

.hex_put_digits_out:
	pop rdx
	pop rcx
	pop rbx
	ret	
	

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
	mov [rsi], al
	inc rsi
	pop rax

.proceed_digits:
	mov rbx, 10
	xor rdx, rdx
	div rbx
	push rdx
	inc rcx
	test rax, rax
	jz .print_digits
	jmp .proceed_digits

.print_digits:
	cmp rcx, 0
	je .decimal_to_string_out
	pop rax
	add rax, '0'
	mov [rsi], al
	inc rsi
	dec rcx
	jmp .print_digits

.decimal_to_string_out:
	pop rdx
	pop rcx
	pop rbx	
	ret

putStringToBuffer:
	push rbx
	push rcx

	mov rbx, rdi 
	xor al, al

.put_char:
	mov cl, [rdi]
	mov [rsi], cl
	inc rsi
	scasb
	jne .put_char

	sub rdi, rbx
	mov rax, rdi 

	pop rcx
	pop rbx

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

	ret	
