BITS 64

section .text

print_int: ; rdi: file, rsi: int
	push r12
	sub rsp, 32

	mov rax, rsi
	lea r12, [rsp+31]
	mov byte [r12], 0
	print_int_loop:
		dec r12
		xor rdx, rdx
		mov rcx, 10
		idiv rcx
		add rdx, 0x30
		mov byte [r12], dl

		cmp rax, 0
		jne print_int_loop

	lea rdx, [rsp + 31]
	sub rdx, r12   ; str length
	mov rsi, r12   ; str
	;mov rdi, rdi  ; file stream
	mov rax, 1     ; sys_write
	syscall

	add rsp, 32
	pop r12
	ret

print_char: ; rdi - file stream, rsi - char
	sub rsp, 16
	mov byte [rsp], sil

	mov rdx, 1     ; str length
	mov rsi, rsp   ; str
	;mov rdi, rdi  ; file stream
	mov rax, 1     ; sys_write
	syscall

	add rsp, 16
	ret

strlen: ; rdi - string
	xor rax, rax

	jmp strlen_loop_header
	strlen_loop:
		inc rax
		inc rdi

		strlen_loop_header:
		cmp byte [rdi], 0
		jne strlen_loop

	ret

print_string: ; rdi - file stream, rsi - string
	push r12
	push r13

	mov r12, rdi
	mov r13, rsi
	
	mov rdi, r13
	call strlen

	mov rdx, rax ; str length
	mov rsi, r13 ; str
	mov rdi, r12 ; file stream
	mov rax, 1   ; sys_write
	syscall

	pop r13
	pop r12

	ret
