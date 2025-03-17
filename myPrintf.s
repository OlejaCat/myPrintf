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

	mov rbx, 32
	mov rdx, rsi
	xor rcx, rcx

.process_string:
	cmp [rdi], byte 0
	je .format_input_string_out
	cmp [rdi], byte '%'
	je .format
	jmp .put_char

.format:
	inc rdi
	cmp [rdi], byte 'c'
	je .print_char
	cmp [rdi], byte 's'
	je .print_string
	cmp [rdi], byte 'd'
	je .print_decimal
	cmp [rdi], byte '%'
	je .put_char

.print_char:
	mov al, [rsp+rbx-8]			
	mov [rsi], al 
	inc rsi
	jmp .next_argument

.print_string:
	push rdi
	mov rdi, [rsp+rbx]
	call putStringToBuffer
	pop rdi	
	jmp .next_argument

.print_decimal:
	push rax
	mov rax, [rsp+rbx]	
	call putDecimalToBuffer 
	pop rax
	jmp .next_argument

.put_char:
	mov al, byte [rdi]
	mov [rsi], al
	inc rsi
	jmp .next_symbol

.next_argument:
	inc rcx
	add rbx, 8

.next_symbol:
	inc rdi
	jmp .process_string

.format_input_string_out:
	mov rax, rcx
	mov rcx, rsi
	sub rcx, rdx

	pop rdx
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

section .data

buffer_string:	db 128 dup(0)
buffer_size  	equ $ - buffer_string


