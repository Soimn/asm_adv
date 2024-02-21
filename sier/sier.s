BITS 64
global main

%include "common.s"

section .text

main:
	push r12
	push r13
	push r14
	push r15
	sub rsp, 64

	mov r12, [rsi + 8]

	cmp rdi, 2
	je correct_num_args
	mov rdi, 2,
	mov rsi, $incorrect_num_args_msg
	call print_string
	jmp end
	correct_num_args:
	

	cmp byte [r12], 0
	je invalid_deg

	xor r13, r13
	jmp parse_deg_loop
	parse_deg_loop:
		mov dil, byte [r12]
		sub rdi, 0x30
		cmp rdi, 10
		jae invalid_deg

		imul r13, r13, 10
		add r13, rdi

		lea rdi, [r13 - 1]
		cmp rdi, 32
		jae invalid_deg

		inc r12

		parse_deg_loop_header:
		cmp byte [r12], 0
		jne parse_deg_loop

	jmp valid_deg
	invalid_deg:
	mov rdi, 2
	mov rsi, $invalid_deg_must_be_int_msg
	call print_string
	jmp end

	valid_deg:
	mov [rsp], r13 ; degree
	
	mov r12, 1
	mov cl, r13b
	shl r12, cl

	mov [rsp+8], r12 ; height
	lea r12, [r12*2 - 1]
	mov [rsp+16], r12 ; width

	add r12, 63
	shr r12, 6
	mov [rsp+24], r12 ; line_count

	inc r12
	shl r12, 3

	mov rdi, 0    ; addr
	mov rsi, r12  ; length
	mov rdx, 0x3  ; prot
	mov r10, 0x22 ; flags
	mov r8, -1    ; fd
	mov r9,  0    ; offset
	mov rax, 9
	syscall

	cmp rax, 0
	jne valid_memory
	mov rdi, 2
	mov rsi, $failed_to_allocate_memory_msg
	valid_memory:

	mov [rsp+32], rax ; lines

	mov rcx, [rsp+8]
	mov r12, 1
	shl r12, cl
	shr rcx, 6
	mov [rax + rcx*8], r12

	xor r12, r12
	sier_loop:

		xor r13, r13
		sier_print_loop:
			mov rdx, r13
			shr rdx, 6
			mov rdi, [rsp+32]
			mov rdi, [rdi + rdx*8]
			mov rcx, r13
			shr rdi, cl
			and rdi, 0x1

			mov rsi, 0x20
			cmp rdi, 0
			mov rdi, 0x2A
			cmovne rsi, rdi
			mov rdi, 1
			call print_char

			inc r13
			cmp r13, [rsp+16]
			jbe sier_print_loop

		mov rdi, 1
		mov rsi, 0x0A
		call print_char

		xor r13, r13
		xor r14, r14
		sier_update_loop:
			mov rcx, [rsp+32]
			mov r15, [rcx + r13*8]
			mov rdi, [rcx + r13*8]
			mov rdx, [rcx + r13*8 + 8]

			shld r15, r14, 1
			shrd rdi, rdx, 1
			mov r14, r15
			xor r14, rdi

			xchg r14, [rcx + r13*8]
	
			inc r13
			cmp r13, [rsp+24]
			jbe sier_update_loop

		inc r12
		cmp r12, [rsp+8] ; r12 vs height
		jb sier_loop

	end:
	add rsp, 64
	pop r15
	pop r14
	pop r13
	pop r12
	xor rax, rax
	ret

section .data
	incorrect_num_args_msg: db "Incorrect number of arguments. Expected: sier <degree>", 0x0A, 0
	invalid_deg_must_be_int_msg: db "Invalid degree, degree must be a positive integer less than 32", 0x0A, 0
	failed_to_allocate_memory_msg: db "Failed to allocate memory for computation", 0x0A, 0
