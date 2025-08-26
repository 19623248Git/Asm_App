section .data
        content_length_key      db 'Content-Length:'
        content_length_key_len  equ $ - content_length_key
        content_type_key        db 'Content-Type: multipart/form-data'
        content_type_key_len    equ $ - content_type_key
        boundary_key            db 'boundary='
        boundary_key_len        equ $ - boundary_key
        
        content_disposition_key db 'Content-Disposition: form-data;'
        content_disposition_key_len equ $ - content_disposition_key
        filename_key            db 'filename="'
        filename_key_len        equ $ - filename_key

        gallery_path_key        db '/gallery/'
        gallery_path_key_len    equ $ - gallery_path_key



section .text
        extern memmem
        global find_content_length_value
        global find_boundary_value
        global find_filename_value
        global find_filename_from_url

; Input: RDI = pointer to headers buffer, RSI = length of the headers
; Output: RAX = pointer to the first digit of the value, or 0 if not found.
find_content_length_value:
        push rdi
        push rsi
        lea rdx, [content_length_key]
        mov rcx, content_length_key_len
        call memmem
        cmp rax, 0
        je .cl_not_found
        add rax, content_length_key_len
.skip_whitespace_loop:
        mov cl, byte [rax]
        cmp cl, ' '
        je .is_whitespace
        cmp cl, 0x09
        je .is_whitespace
        jmp .cl_found_value
.is_whitespace:
        inc rax
        jmp .skip_whitespace_loop
.cl_not_found:
        xor rax, rax
.cl_found_value:
.cl_done:
        pop rsi
        pop rdi
        ret

; Input: RDI = pointer to headers buffer, RSI = length of the headers
; Output: RAX = pointer to boundary value, RDX = length of value. RAX=0 on failure.
find_boundary_value:
        push rdi
        push rsi
        push r12
        mov r12, rdi
        lea rdx, [content_type_key]
        mov rcx, content_type_key_len
        call memmem
        cmp rax, 0
        je .boundary_not_found
        mov rdi, rax
        sub rax, r12
        mov rsi, [rsp+8]
        sub rsi, rax
        lea rdx, [boundary_key]
        mov rcx, boundary_key_len
        call memmem
        cmp rax, 0
        je .boundary_not_found
        add rax, boundary_key_len
        mov r12, rax
        mov rdi, r12
.find_cr_loop:
        cmp byte [rdi], 0x0d
        je .found_cr
        inc rdi
        jmp .find_cr_loop
.found_cr:
        mov rdx, rdi
        sub rdx, r12
        mov rax, r12
        jmp .boundary_done
.boundary_not_found:
        xor rax, rax
        xor rdx, rdx
.boundary_done:
        pop r12
        pop rsi
        pop rdi
        ret

; Input: RDI = pointer to buffer containing part headers, RSI = length of buffer
; Output: RAX = pointer to filename, RDX = length of filename. RAX=0 on failure.
find_filename_value:
        push rdi
        push rsi
        push r12
        lea rdx, [content_disposition_key]
        mov rcx, content_disposition_key_len
        call memmem
        cmp rax, 0
        je .filename_not_found
        mov rdi, rax 
        lea rdx, [filename_key]
        mov rcx, filename_key_len
        call memmem
        cmp rax, 0
        je .filename_not_found
        add rax, filename_key_len
        mov r12, rax
        mov rdi, r12
.find_quote_loop:
        cmp byte [rdi], '"'
        je .found_quote
        inc rdi
        jmp .find_quote_loop
.found_quote:
        mov rdx, rdi
        sub rdx, r12
        mov rax, r12
        jmp .filename_done
.filename_not_found:
        xor rax, rax
        xor rdx, rdx
.filename_done:
        pop r12
        pop rsi
        pop rdi
        ret

; --- NEW SUBROUTINE for PUT/DELETE ---
; Input: RDI = pointer to request buffer, RSI = length of buffer
; Output: RAX = pointer to filename, RDX = length of filename. RAX=0 on failure.
find_filename_from_url:
    push rdi
    push rsi
    push r12

    ; 1. Find "/gallery/"
    lea rdx, [gallery_path_key]
    mov rcx, gallery_path_key_len - 1
    call memmem
    cmp rax, 0
    je .url_filename_not_found

    ; 2. Move pointer to start of filename
    add rax, gallery_path_key_len - 1
    mov r12, rax

    ; 3. Find the next space (end of URL)
    mov rdi, r12
.find_space_loop:
    cmp byte [rdi], ' '
    je .found_space
    inc rdi
    jmp .find_space_loop

.found_space:
    ; 4. Calculate length and set return registers
    mov rdx, rdi
    sub rdx, r12  ; rdx = length
    mov rax, r12  ; rax = pointer to start of filename
    jmp .url_filename_done

.url_filename_not_found:
    xor rax, rax
    xor rdx, rdx

.url_filename_done:
    pop r12
    pop rsi
    pop rdi
    ret
