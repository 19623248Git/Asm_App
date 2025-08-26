section .data
        ; This is the sockaddr_in structure for binding to an IP and port.
        socket_address:
                dw 2                    ; sin_family: AF_INET (IPv4)
                dw 0x901F               ; sin_port: 8080 (0x1F90), stored byte-swapped (big-endian).
        sin_addr: dd 0x00000000          ; sin_addr: INADDR_ANY (bind to any available IP 0.0.0.0)
        sin_zero: dq 0                   ; 8 bytes of padding, must be zero.

        saddress_len equ $ - socket_address

        ; variable of true for setsockopt.
        socket_on: dd 1

        ; Syscall Error Messages
        socket_err_msg db 'Error: Could not create socket.', 0x0a, 0
        socket_err_len equ $ - socket_err_msg
        bind_err_msg db 'Error: Could not bind to port 8080.', 0x0a, 0
        bind_err_len equ $ - bind_err_msg
        listen_err_msg db 'Error: Could not listen on socket.', 0x0a, 0
        listen_err_len equ $ - listen_err_msg
        accept_err_msg db 'Error: Could not accept new connection.', 0x0a, 0
        accept_err_len equ $ - accept_err_msg
        fork_err_msg db 'Error: Could not fork new process.', 0x0a, 0
        fork_err_len equ $ - fork_err_msg

        ; Method messages for logging/debugging
        get_msg db 'processing GET request.', 0x0a, 0
        get_len equ $ - get_msg
        post_msg db 'processing POST request.', 0x0a, 0
        post_len equ $ - post_msg
        put_msg db 'processing PUT request.', 0x0a, 0
        put_len equ $ - put_msg
        delete_msg db 'processing DELETE request.', 0x0a, 0
        delete_len equ $ - delete_msg

        ; Header and separator definitions for parsing
        expect_header db 'Expect: 100-continue'
        expect_header_len equ $ - expect_header
        crlf_separator db 0x0d, 0x0a, 0x0d, 0x0a
        crlf_separator_len equ $ - crlf_separator

        ; Filepath construction parts
        app_dir_prefix db 'app/img/', 0
        app_dir_prefix_len equ $ - app_dir_prefix - 1
        final_filename_suffix db '.png', 0
        final_suffix_len equ $ - final_filename_suffix - 1
        
        ; --- FIXED: Keys for parsing ---
        gallery_path_key   db '/gallery/', 0
        gallery_path_key_len equ $ - gallery_path_key - 1

        ; HTTP Responses
        continue_response db 'HTTP/1.1 100 Continue', 0x0d, 0x0a, 0x0d, 0x0a
        continue_response_len equ $ - continue_response
        http_201_response db 'HTTP/1.1 201 Created', 0x0d, 0x0a, 'Content-Length: 0', 0x0d, 0x0a, 0x0d, 0x0a
        http_201_len equ $ - http_201_response
        http_204_response db 'HTTP/1.1 204 No Content', 0x0d, 0x0a, 0x0d, 0x0a
        http_204_len equ $ - http_204_response
        http_400_response:
                db 'HTTP/1.1 400 Bad Request', 0x0d, 0x0a
                db 'Content-Type: text/html', 0x0d, 0x0a
                db 'Content-Length: 50', 0x0d, 0x0a
                db 'Connection: close', 0x0d, 0x0a
                db 0x0d, 0x0a  ; Blank line
                db '<html><body><h1>400 Bad Request</h1></body></html>'
        http_400_len equ $ - http_400_response
        http_404_response:
                db 'HTTP/1.1 404 Not Found', 0x0d, 0x0a, 'Content-Type: text/html', 0x0d, 0x0a
                db 'Content-Length: 48', 0x0d, 0x0a, 'Connection: close', 0x0d, 0x0a, 0x0d, 0x0a
                db '<html><body><h1>404 Not Found</h1></body></html>'
        http_404_len equ $ - http_404_response

        web_root          db 'app', 0  ; The root directory for serving files
        web_root_len      equ $ - web_root - 1
        index_html_path   db '/index.html', 0
        ; --- FIXED: API Path ---
        gallery_path      db '/gallery', 0
        gallery_path_len  equ $ - gallery_path - 1
        img_dir_path      db 'app/img', 0

        ; Content-Type Headers
        content_type_html  db 'Content-Type: text/html', 0x0d, 0x0a
        content_type_html_len equ $ - content_type_html
        content_type_png   db 'Content-Type: image/png', 0x0d, 0x0a
        content_type_png_len equ $ - content_type_png
        content_type_jpg   db 'Content-Type: image/jpeg', 0x0d, 0x0a
        content_type_jpg_len equ $ - content_type_jpg
        content_type_css   db 'Content-Type: text/css', 0x0d, 0x0a
        content_type_css_len equ $ - content_type_css
        content_type_js    db 'Content-Type: application/javascript', 0x0d, 0x0a
        content_type_js_len equ $ - content_type_js
        content_type_ico   db 'Content-Type: image/x-icon', 0x0d, 0x0a
        content_type_ico_len equ $ - content_type_ico
        content_type_bin   db 'Content-Type: application/octet-stream', 0x0d, 0x0a ; Default
        content_type_bin_len equ $ - content_type_bin
        content_type_json  db 'Content-Type: application/json', 0x0d, 0x0a
        content_type_json_len equ $ - content_type_json

        ; HTTP 200 OK Response parts
        http_200_ok        db 'HTTP/1.1 200 OK', 0x0d, 0x0a
        http_200_ok_len    equ $ - http_200_ok
        content_len_header db 'Content-Length: '
        content_len_len    equ $ - content_len_header
        crlf               db 0x0d, 0x0a
        crlf_len           equ $ - crlf

section .bss
        request_buffer: resb 8192
        req_buff_len equ $ - request_buffer
        socket_fd: resq 1
        client_fd: resq 1
        end_pointer: resq 1
        full_temp_path: resb 256
        pid_string_buffer: resb 20
        boundary_string: resb 256
        boundary_len: resq 1
        parsed_filename: resb 256
        filename_len: resq 1
        final_filepath: resb 256
        file_copy_buffer: resb 8192
        stat_buf: resb 144
        file_path: resb 256
        file_size_ascii: resb 20
        header_buffer:   resb 512
        dir_buffer: resb 1024
        json_buffer: resb 4096

section .text
        extern memmem
        extern find_content_length_value
        extern strtoll
        extern integer_to_ascii
        extern build_temp_filename
        extern find_boundary_value
        extern find_filename_value

        global _start
        
_start:
        mov rax, 41
        mov rdi, 2
        mov rsi, 1
        mov rdx, 0
        syscall
        mov [socket_fd], rax
        cmp rax, -1
        je .socket_error
        mov rax, 54
        mov rdi, [socket_fd]
        mov rsi, 1
        mov rdx, 2
        lea r10, [socket_on]
        mov r8, 4
        syscall
        mov rax, 49
        mov rdi, [socket_fd]
        lea rsi, [socket_address]
        mov rdx, saddress_len
        syscall
        cmp rax, 0
        jne .bind_error
        mov rax, 50
        mov rdi, [socket_fd]
        mov rsi, 128
        syscall
        cmp rax, 0
        jne .listen_error

.main_loop:
        mov rax, 43
        mov rdi, [socket_fd]
        mov rsi, 0
        mov rdx, 0
        syscall
        mov [client_fd], rax
        cmp rax, -1
        je .accept_error
        mov rax, 57
        syscall
        cmp rax, 0
        jl .fork_error
        je .child_process
        mov rax, 3
        mov rdi, [client_fd]
        syscall
        jmp .main_loop

.child_process:
        mov rax, 3
        mov rdi, [socket_fd]
        syscall

        mov rax, 0
        mov rdi, [client_fd]
        lea rsi, [request_buffer]
        mov rdx, req_buff_len
        syscall
        mov r12, rax

        lea rdi, [request_buffer]
        mov rsi, r12
        lea rdx, [expect_header]
        mov rcx, expect_header_len
        call memmem
        cmp rax, 0
        je .skip_continue_response

        mov rax, 1
        mov rdi, [client_fd]
        lea rsi, [continue_response]
        mov rdx, continue_response_len
        syscall

.skip_continue_response:
        jmp .handle_request

.handle_request:
        lea rsi, [request_buffer]
        mov rdx, r12
        mov rax, 1
        mov rdi, 1
        syscall

        mov eax, dword [request_buffer]

        cmp eax, "GET "
        je .handle_get
        cmp eax, "POST"
        je .handle_post
        cmp eax, "PUT "
        je .handle_put
        cmp eax, "DELE"
        je .handle_delete
        jmp .handle_bad_request

.handle_get:
    mov rax, 1
    mov rdi, 1
    lea rsi, [get_msg]
    mov rdx, get_len
    syscall

    lea r8, [request_buffer + 4] 
    mov rdi, r8             
    mov rcx, 2048           
    mov al, ' '             
    repne scasb             
    cmp rcx, 0
    je .handle_bad_request
    mov rdx, rdi
    sub rdx, r8
    dec rdx
    mov rax, r8

    mov [filename_len], rdx
    lea rdi, [parsed_filename]
    mov rsi, rax
    mov rcx, rdx
    rep movsb
    mov byte [rdi], 0

    mov rdi, [filename_len]
    cmp rdi, gallery_path_len
    jne .check_root_path
    mov rcx, rdi
    lea rsi, [gallery_path]
    lea rdi, [parsed_filename]
    repe cmpsb
    je .handle_api_list_images

.check_root_path:
    mov r10d, dword [filename_len]
    cmp r10d, 1
    jne .build_full_path
    lea r10, [parsed_filename]
    cmp byte [r10], '/'
    jne .build_full_path
    
    lea rdi, [parsed_filename]
    lea rsi, [index_html_path]
    mov rcx, 12
    rep movsb
    mov qword [filename_len], 11

.build_full_path:
    lea rdi, [file_path]
    lea rsi, [web_root]
    mov rcx, web_root_len
    rep movsb
    
    lea rsi, [parsed_filename]
    mov ecx, dword [filename_len]
    rep movsb
    mov byte [rdi], 0

    mov rax, 4
    lea rdi, [file_path]
    lea rsi, [stat_buf]
    syscall
    cmp rax, 0
    jl .handle_not_found

    mov r13, [stat_buf + 48]
    mov rdi, r13
    lea rsi, [file_size_ascii]
    call integer_to_ascii
    mov r14, rax

    lea rdi, [parsed_filename]
    mov rsi, [filename_len]
    call determine_content_type
    mov r10, rax
    mov r11, rdx

    lea rdi, [header_buffer]
    mov r15, rdi
    lea rsi, [http_200_ok]
    mov rcx, http_200_ok_len
    rep movsb
    mov rsi, r10
    mov rcx, r11
    rep movsb
    lea rsi, [content_len_header]
    mov rcx, content_len_len
    rep movsb
    lea rsi, [file_size_ascii]
    mov rcx, r14
    rep movsb
    lea rsi, [crlf]
    mov rcx, crlf_len
    rep movsb
    lea rsi, [crlf]
    mov rcx, crlf_len
    rep movsb

    mov rdx, rdi
    sub rdx, r15
    mov rax, 1
    mov rdi, [client_fd]
    lea rsi, [header_buffer]
    syscall

    mov rax, 2
    lea rdi, [file_path]
    mov rsi, 0
    mov rdx, 0
    syscall
    mov r15, rax
    cmp r15, 0
    jl .handle_not_found

.send_file_loop:
    mov rax, 0
    mov rdi, r15
    lea rsi, [file_copy_buffer]
    mov rdx, 8192
    syscall
    cmp rax, 0
    jle .send_file_finished
    mov rdx, rax
    mov rax, 1
    mov rdi, [client_fd]
    lea rsi, [file_copy_buffer]
    syscall
    jmp .send_file_loop

.send_file_finished:
    mov rax, 3
    mov rdi, r15
    syscall
    jmp .exit_client_success

.handle_api_list_images:
    mov rax, 2
    lea rdi, [img_dir_path]
    mov rsi, 0x10000
    mov rdx, 0
    syscall
    cmp rax, 0
    jl .handle_not_found
    mov r15, rax

    lea r14, [json_buffer]
    mov byte [r14], '['
    inc r14
    mov r13, 0

.read_dir_loop:
    mov rax, 217
    mov rdi, r15
    lea rsi, [dir_buffer]
    mov rdx, 1024
    syscall
    cmp rax, 0
    jle .build_json_end

    mov rbx, dir_buffer
    mov rcx, rax

.parse_dents_loop:
    cmp rcx, 0
    jle .read_dir_loop

    cmp byte [rbx + 18], 8 
    jne .next_dent

    mov rdx, rbx
    add rdx, 19
    mov rdi, rdx
    push rbx
    push rcx
    mov rcx, 255 
    xor al, al   
    repne scasb
    mov r8, rdi  
    sub r8, rdx  
    dec r8       
    pop rcx
    pop rbx
    
    cmp r8, 4
    jl .next_dent

    cmp dword [rdx + r8 - 4], '.png'
    jne .next_dent

    cmp r13, 0
    je .is_first_entry
    mov byte [r14], ','
    inc r14
.is_first_entry:
    mov r13, 1
    mov byte [r14], '"'
    inc r14
    
    push rcx
    mov rsi, rdx  
    mov rdi, r14  
    mov rcx, r8   
    rep movsb
    mov r14, rdi 
    pop rcx
    
    mov byte [r14], '"'
    inc r14

.next_dent:
    movzx rax, word [rbx + 16]
    add rbx, rax
    sub rcx, rax
    jmp .parse_dents_loop

.build_json_end:
    mov byte [r14], ']'
    inc r14

    mov rax, 3
    mov rdi, r15
    syscall

    lea rsi, [json_buffer]
    mov rdx, r14
    sub rdx, rsi

    lea rdi, [header_buffer]
    mov r15, rdi
    lea rsi, [http_200_ok]
    mov rcx, http_200_ok_len
    rep movsb
    lea rsi, [content_type_json]
    mov rcx, content_type_json_len
    rep movsb
    lea rsi, [content_len_header]
    mov rcx, content_len_len
    rep movsb
    
    push rdi
    mov rsi, rdi
    mov rdi, rdx
    call integer_to_ascii
    pop rdi
    add rdi, rax

    lea rsi, [crlf]
    mov rcx, crlf_len
    rep movsb
    lea rsi, [crlf]
    mov rcx, crlf_len
    rep movsb

    mov rdx, rdi
    sub rdx, r15
    mov rax, 1
    mov rdi, [client_fd]
    lea rsi, [header_buffer]
    syscall

    lea rsi, [json_buffer]
    lea rdi, [json_buffer]
    mov rdx, r14
    sub rdx, rdi
    mov rax, 1
    mov rdi, [client_fd]
    syscall

    jmp .exit_client_success

.handle_post:
        mov rax, 1
        mov rdi, 1
        lea rsi, [post_msg]
        mov rdx, post_len
        syscall

        lea rdi, [request_buffer]
        mov rsi, r12
        call find_boundary_value
        cmp rax, 0
        je .handle_bad_request

        lea rdi, [boundary_string + 2]
        mov rsi, rax
        mov rcx, rdx
        rep movsb
        mov word [boundary_string], '--'
        add rdx, 2
        mov [boundary_len], rdx

        lea rdi, [request_buffer]
        mov rsi, r12
        call find_content_length_value
        cmp rax, 0
        je .handle_bad_request

        mov rdi, rax
        lea rsi, [end_pointer]
        mov rdx, 10
        call strtoll
        mov r13, rax

        mov rax, 39
        syscall
        mov rdi, rax
        lea rsi, [pid_string_buffer]
        call integer_to_ascii
        lea rdx, [full_temp_path]
        mov rsi, rax
        lea rdi, [pid_string_buffer]
        call build_temp_filename

        mov rax, 2
        lea rdi, [full_temp_path]
        mov rsi, 65
        mov rdx, 0644o
        syscall
        mov r15, rax

        lea rdi, [request_buffer]
        mov rsi, r12
        lea rdx, [crlf_separator]
        mov rcx, crlf_separator_len
        call memmem
        cmp rax, 0
        je .handle_bad_request
        
        add rax, crlf_separator_len
        mov r9, rax
        
        lea rdi, [request_buffer]
        sub rax, rdi
        mov r10, r12
        sub r10, rax
        
        cmp r10, 0
        jne .process_first_body_chunk

        mov rax, 0
        mov rdi, [client_fd]
        lea rsi, [request_buffer]
        mov rdx, req_buff_len
        syscall
        mov r12, rax
        lea r9, [request_buffer]
        mov r10, r12

.process_first_body_chunk:
        mov rdi, r9
        mov rsi, r10
        call find_filename_value
        cmp rax, 0
        je .handle_bad_request
        mov [filename_len], rdx
        lea rdi, [parsed_filename]
        mov rsi, rax
        mov rcx, rdx
        rep movsb
        mov byte [rdi], 0

        mov rdi, r9
        mov rsi, r10
        lea rdx, [crlf_separator]
        mov rcx, crlf_separator_len
        call memmem
        cmp rax, 0
        je .handle_bad_request

        add rax, crlf_separator_len
        mov rsi, rax
        
        lea rdi, [r9]
        sub rax, rdi
        mov rdx, r10
        sub rdx, rax

        mov rdi, r15
        mov rax, 1
        syscall

        mov r14, r10
        jmp .upload_loop

 .upload_loop:
        cmp r14, r13
        jge .upload_finished

        mov rax, 0
        mov rdi, [client_fd]
        lea rsi, [request_buffer]
        mov rdx, req_buff_len
        syscall
        cmp rax, 0
        jle .upload_finished
        mov r12, rax
        add r14, r12

        lea rdi, [request_buffer]
        mov rsi, r12
        lea rdx, [boundary_string]
        mov rcx, [boundary_len]
        call memmem
        cmp rax, 0
        je .no_boundary_in_chunk

.boundary_in_chunk:
        lea rsi, [request_buffer]
        mov rdx, rax
        sub rdx, rsi
        sub rdx, 2
        mov rdi, r15
        mov rax, 1
        syscall
        jmp .upload_finished

.no_boundary_in_chunk:
        lea rsi, [request_buffer]
        mov rdx, r12
        mov rdi, r15
        mov rax, 1
        syscall
        jmp .upload_loop

.upload_finished:
        mov rax, 3
        mov rdi, r15
        syscall

        lea rdx, [final_filepath]
        mov rsi, [filename_len]
        lea rdi, [parsed_filename]
        call build_final_filepath_with_ext

        mov rax, 82
        lea rdi, [full_temp_path]
        lea rsi, [final_filepath]
        syscall
        
        mov rax, 1
        mov rdi, [client_fd]
        lea rsi, [http_201_response]
        mov rdx, http_201_len
        syscall
        jmp .exit_client_success

.handle_put:
        mov rax, 1
        mov rdi, 1
        lea rsi, [put_msg]
        mov rdx, put_len
        syscall

        lea rdi, [request_buffer]
        mov rsi, r12
        call find_filename_from_url_no_ext
        cmp rax, 0
        je .handle_bad_request
        mov [filename_len], rdx
        lea rdi, [parsed_filename]
        mov rsi, rax
        mov rcx, rdx
        rep movsb
        mov byte [rdi], 0

        lea rdx, [final_filepath]
        lea rdi, [parsed_filename]
        mov rsi, [filename_len]
        call build_final_filepath_with_ext

        mov rax, 2
        lea rdi, [final_filepath]
        mov rsi, 65
        mov rdx, 0644o
        syscall
        mov r15, rax
        cmp r15, 0
        jl .handle_bad_request

        lea rdi, [request_buffer]
        mov rsi, r12
        call find_content_length_value
        cmp rax, 0
        je .handle_bad_request
        mov rdi, rax
        lea rsi, [end_pointer]
        mov rdx, 10
        call strtoll
        mov r13, rax

        lea rdi, [request_buffer]
        mov rsi, r12
        lea rdx, [crlf_separator]
        mov rcx, crlf_separator_len
        call memmem
        cmp rax, 0
        je .handle_bad_request

        add rax, crlf_separator_len
        mov r9, rax
        lea rdi, [request_buffer]
        sub rax, rdi
        mov r10, r12
        sub r10, rax

        mov rdx, r10
        mov rsi, r9
        mov rdi, r15
        mov rax, 1
        syscall

        mov r14, r10
        jmp .put_loop_simple

.put_loop_simple:
        cmp r14, r13
        jge .put_finished_simple
        mov rax, 0
        mov rdi, [client_fd]
        lea rsi, [request_buffer]
        mov rdx, req_buff_len
        syscall
        cmp rax, 0
        jle .put_finished_simple
        
        mov rdx, rax
        add r14, rdx
        
        mov rax, 1
        mov rdi, r15
        lea rsi, [request_buffer]
        syscall
        
        jmp .put_loop_simple

.put_finished_simple:
        mov rax, 3
        mov rdi, r15
        syscall
        
        mov rax, 1
        mov rdi, [client_fd]
        lea rsi, [http_201_response]
        mov rdx, http_201_len
        syscall
        
        jmp .exit_client_success

.handle_delete:
        mov rax, 1
        mov rdi, 1
        lea rsi, [delete_msg]
        mov rdx, delete_len
        syscall
        
        lea rdi, [request_buffer]
        mov rsi, r12
        call find_filename_from_url_no_ext
        cmp rax, 0
        je .handle_bad_request
        mov [filename_len], rdx
        lea rdi, [parsed_filename]
        mov rsi, rax
        mov rcx, rdx
        rep movsb
        mov byte [rdi], 0

        lea rdx, [final_filepath]
        lea rdi, [parsed_filename]
        mov rsi, [filename_len]
        call build_final_filepath_with_ext

        mov rax, 87
        lea rdi, [final_filepath]
        syscall
        cmp rax, 0
        jl .handle_not_found

        mov rax, 1
        mov rdi, [client_fd]
        lea rsi, [http_204_response]
        mov rdx, http_204_len
        syscall
        jmp .exit_client_success

.handle_bad_request:
        mov rax, 1
        mov rdi, [client_fd]
        lea rsi, [http_400_response]
        mov rdx, http_400_len
        syscall
        jmp .exit_client_success

.handle_not_found:
        mov rax, 1
        mov rdi, [client_fd]
        lea rsi, [http_404_response]
        mov rdx, http_404_len
        syscall
        jmp .exit_client_success

.socket_error:
        lea rsi, [socket_err_msg]
        mov rdx, socket_err_len
        jmp .print_error
.bind_error:
        lea rsi, [bind_err_msg]
        mov rdx, bind_err_len
        jmp .print_error
.listen_error:
        lea rsi, [listen_err_msg]
        mov rdx, listen_err_len
        jmp .print_error
.accept_error:
        lea rsi, [accept_err_msg]
        mov rdx, accept_err_len
        jmp .print_error
.fork_error:
        lea rsi, [fork_err_msg]
        mov rdx, fork_err_len
        jmp .print_error

.print_error:
        mov rax, 1
        mov rdi, 2
        syscall
        jmp .exit_failure

.exit_failure:
        mov rax, 60
        mov rdi, 1
        syscall

.exit_client_success:
        mov rax, 3
        mov rdi, [client_fd]
        syscall
        mov rax, 60
        xor rdi, rdi
        syscall

; Input: RDI=req buffer, RSI=len
; Output: RAX=ptr to filename, RDX=len
find_filename_from_url_no_ext:
    push rdi
    push rsi
    push r12
    lea rdx, [gallery_path_key] ; --- FIXED
    mov rcx, gallery_path_key_len ; --- FIXED
    call memmem
    cmp rax, 0
    je .url_filename_not_found
    add rax, gallery_path_key_len ; --- FIXED
    mov r12, rax
    mov rdi, r12
.find_space_loop:
    cmp byte [rdi], ' '
    je .found_space
    inc rdi
    jmp .find_space_loop
.found_space:
    mov rdx, rdi
    sub rdx, r12
    mov rax, r12
    jmp .url_filename_done
.url_filename_not_found:
    xor rax, rax
    xor rdx, rdx
.url_filename_done:
    pop r12
    pop rsi
    pop rdi
    ret

; Input: RDI=ptr to filename (no ext), RSI=len, RDX=dest buffer
build_final_filepath_with_ext:
    push rdi
    push rsi
    mov rdi, rdx
    lea rsi, [app_dir_prefix]
    mov rcx, app_dir_prefix_len
    rep movsb
    pop rcx
    pop rsi
    rep movsb
    lea rsi, [final_filename_suffix]
    mov rcx, final_suffix_len
    rep movsb
    mov byte [rdi], 0
    ret

determine_content_type:
    push    rbp
    mov     rbp, rsp
    push    rdi
    push    rsi
    push    rcx
    push    rbx
    mov     rax, rdi    
    add     rax, rsi    
    dec     rax     
    std             
    mov     rdi, rax    
    mov     rcx, rsi    
    mov     al, '.'   
    repne   scasb
    cld             
    jne     .set_default_content_type
    lea     rbx, [rdi + 2]
    cmp     byte [rbx], 'p'
    jne     .try_jpg
    cmp     byte [rbx+1], 'n'
    jne     .try_jpg
    cmp     byte [rbx+2], 'g'
    jne     .try_jpg
    jmp     .set_png_type
.try_jpg:
    cmp     byte [rbx], 'j'
    jne     .try_css
    cmp     byte [rbx+1], 'p'
    jne     .try_css
    cmp     byte [rbx+2], 'g'
    jne     .try_css
    jmp     .set_jpg_type
.try_css:
    cmp     byte [rbx], 'c'
    jne     .try_js
    cmp     byte [rbx+1], 's'
    jne     .try_js
    cmp     byte [rbx+2], 's'
    jne     .try_js
    jmp     .set_css_type
.try_js:
    cmp     byte [rbx], 'j'
    jne     .try_ico
    cmp     byte [rbx+1], 's'
    jne     .try_ico
    jmp     .set_js_type
.try_ico:
    cmp     byte [rbx], 'i'
    jne     .try_jpeg
    cmp     byte [rbx+1], 'c'
    jne     .try_jpeg
    cmp     byte [rbx+2], 'o'
    jne     .try_jpeg
    jmp     .set_ico_type
.try_jpeg:
    cmp     dword [rbx], 'jpeg'
    je      .set_jpg_type
    jmp     .set_html_type
.set_png_type:
    lea     rax, [content_type_png]
    mov     rdx, content_type_png_len
    jmp     .content_type_done
.set_jpg_type:
    lea     rax, [content_type_jpg]
    mov     rdx, content_type_jpg_len
    jmp     .content_type_done
.set_css_type:
    lea     rax, [content_type_css]
    mov     rdx, content_type_css_len
    jmp     .content_type_done
.set_js_type:
    lea     rax, [content_type_js]
    mov     rdx, content_type_js_len
    jmp     .content_type_done
.set_ico_type:
    lea     rax, [content_type_ico]
    mov     rdx, content_type_ico_len
    jmp     .content_type_done
.set_html_type:
    lea     rax, [content_type_html]
    mov     rdx, content_type_html_len
    jmp     .content_type_done
.set_default_content_type:
    lea     rax, [content_type_bin]
    mov     rdx, content_type_bin_len
.content_type_done:
    pop     rbx
    pop     rcx
    pop     rsi
    pop     rdi
    leave
    ret
