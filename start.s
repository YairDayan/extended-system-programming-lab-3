section .text
global _start
global system_call
_start:
	pop     dword ecx							; ecx = argc
	mov     esi, esp							; esi = argv
    ;; lea eax, [esi+4*ecx+4] ; eax = envp = (4*ecx)+esi+4
	mov     eax, ecx							; put the number of arguments into eax
	shl     eax, 2								; compute the size of argv in bytes
	add     eax, esi							; add the size to the address of argv
	add     eax, 4								; skip NULL at the end of argv
	push    dword eax							; char *envp[]
	push    dword esi							; char* argv[]
	push    dword ecx							; int argc

	call    main								; int main( int argc, char *argv[], char *envp[] )

	mov     ebx, eax
	mov     eax, 1
	int     0x80
	nop

system_call:
	push    ebp									; Save caller state
	mov     ebp, esp
	sub     esp, 4								; Leave space for local var on stack
	pushad  									; Save some more caller state

	mov     eax, [ebp+8]						; Copy function args to registers: leftmost...
	mov     ebx, [ebp+12]						; Next argument...
	mov     ecx, [ebp+16]						; Next argument...
	mov     edx, [ebp+20]						; Next argument...
	int     0x80								; Transfer control to operating system
	mov     [ebp-4], eax						; Save returned value...
	popad   									; Restore caller state (registers)
	mov     eax, [ebp-4]						; place returned value where caller can see it
	add     esp, 4								; Restore caller state
	pop     ebp									; Restore caller state
	ret     									; Back to caller

section .data
newline         db      10
Infile          dd      0
Outfile         dd      1

section .bss
buffer          resb    1

section .text
global main
extern strlen

main:
	push    ebp
	mov     ebp, esp
	sub     esp, 4
	mov     dword [ebp-4], 0

.loop:
	mov     eax, [ebp-4]
	cmp     eax, [ebp+8]
	jge     .done

	mov     edx, [ebp+12]
	mov     esi, [edx+eax*4]

	cmp     word [esi], '-i'
	jne     .check_o
	mov     eax, 5
	lea     ebx, [esi+2]
	mov     ecx, 0
	mov     edx, 0644
	int     0x80
	mov     [Infile], eax
	jmp     .print_arg

.check_o:
	cmp     word [esi], '-o'
	jne     .print_arg
	mov     eax, 5
	lea     ebx, [esi+2]
	mov     ecx, 577
	mov     edx, 0644
	int     0x80
	mov     [Outfile], eax

.print_arg:
	push    esi
	push    esi
	call    strlen
	add     esp, 4
	pop     ecx

	mov     edx, eax
	mov     ebx, 1
	mov     eax, 4
	int     0x80

	mov     eax, 4
	mov     ebx, 1
	mov     ecx, newline
	mov     edx, 1
	int     0x80

	inc     dword [ebp-4]
	jmp     .loop

.done:
	call    encode
	mov     eax, 0
	mov     esp, ebp
	pop     ebp
	ret

encode:
	push    ebp
	mov     ebp, esp

.read_loop:
	mov     eax, 3
	mov     ebx, [Infile]
	mov     ecx, buffer
	mov     edx, 1
	int     0x80

	cmp     eax, 0
	jle     .encode_done

	mov     al, [buffer]
	cmp     al, 'A'
	jl      .write_char
	cmp     al, 'Z'
	jg      .write_char
	add     al, 3
	mov     [buffer], al

.write_char:
	mov     eax, 4
	mov     ebx, [Outfile]
	mov     ecx, buffer
	mov     edx, 1
	int     0x80
	jmp     .read_loop

.encode_done:
	mov     esp, ebp
	pop     ebp
	ret
