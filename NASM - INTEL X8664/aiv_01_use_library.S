[bits 64]
sub rsp, 8
sub rsp, 32

call bohwrapper

add rsp, 32
add rsp, 8

loop:
    jmp loop
ret

bohwrapper:
    jmp[0x402038]