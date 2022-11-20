[bits 64]
    sub rsp, 8
    sub rsp, 32
    mov r8, 0
    mov rax, 0xdeadbeef
    add r8, 1
    ;mov[0x502004], r8

    ; beep custom sound
    mov rcx, 0x30
    call MessageBeep
    
    ; custom window screen
    mov rcx, 0
    mov rdx, 0x502000
    mov r8, 0x502005
    mov r9, 4
    call MessageBox

    mov rcx, 0
    call ExitProcess

    add rsp, 32
    add rsp, 8

    ret

MessageBeep:
    jmp [0x503064]

MessageBox:
    jmp [0x50306c]

ExitProcess:
    jmp [0x50307c]