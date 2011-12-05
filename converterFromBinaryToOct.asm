ASSUME CS:CODE, DS:DATA
.386
DATA SEGMENT USE16
	line db 8 dup(0)
	output db 3 dup(0)
	input db 0, "$"
	neg_flag db 0
	new_line db 0dh, 0ah, "$"
	in_mes db "Input the binary number.", 0dh, 0ah, "$"
	out_mes db "This number in octal notation.", 0dh, 0ah, "$"
	err_mes db "Illegal input", 0dh, 0ah, "$"
	tabl db '0' dup(255), 0, 1

DATA ENDS

CODE SEGMENT USE16
	begin:
		mov ax, DATA
		mov ds, ax
		mov ah, 09h
		lea dx, in_mes
		int 21h
		lea bx, tabl
		xor dl, dl
		xor di, di
		
	get_input:
		mov ah, 1h
		int 21h
		cmp al, '-'
		jz minus
		cmp al, 'B'
		jz stop_input
		cmp al, 'b'
		jz stop_input
		cmp al, 0dh
		jz stop_input
		xlat
		cmp al, 0
		jz zero
		cmp al, 1
		jz one
		jmp ill_input
		
	zero:
		lea bx, output
		xor ax, ax
		shld dx, ax, 1
		jmp check_size
	one:
		lea bx, output
		xor ax, ax
		sub ax, 1
		shld dx, ax, 1
		jmp check_size
		
	check_size:
		lea bx, tabl
		inc di
		cmp di, 7
		jz stop_input
		jmp get_input
		
	minus:
		mov bl, neg_flag
		cmp bl, 0
		jnz ill_input
		cmp di, 0
		jnz ill_input
		mov bl, 1
		mov neg_flag, bl
		lea bx, tabl
		jmp get_input
		
	stop_input:
		cmp di, 0
		jz ill_input
		cmp neg_flag, 0
		jz neg_label
		neg dl
		neg_label:
		mov input, dl
		lea dx, new_line
		mov ah, 09h
		int 21h
		jmp translate
	ill_input:
		mov ah, 09h
		lea dx, err_mes
		int 21h
		jmp return
		
	translate:
		mov cx, 3
		mov dl, input
		xor bh, bh
		lea bx, output
		mov si, 1
;		cmp neg_flag, 0
		or dl, dl
		jns cycle
			neg dl
		cycle:
			shrd [bx+si], byte ptr dx, 3
			shr dx, 3
			shr word ptr [bx+si], 5
			add [bx+si], byte ptr 30h
			dec si
		loop cycle
		
	out_number:
		mov ah, 09h
		lea dx, out_mes
		int 21h
		lea bx, output
		mov cx, 3
		mov si, 2
		num_to_symb:
			add [bx+si], byte ptr 30h
			dec si
		loop num_to_symb
		mov cx, 3
		cmp neg_flag, 0
		jz print
		mov ah, 2h
		mov dl, '-'
		int 21h
		lea bx, output
		print:
			mov ah, 2h
			mov dl, [bx]
			int 21h
			inc bx
		loop print
		mov dl, 'Q'
		int 21h
		
	return:
		mov ah, 1
		int 21h
		mov ax, 4c00h
		int 21h

CODE ENDS

END begin
