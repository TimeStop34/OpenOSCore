;---------- NASM-загрузчик ----------;
bits 16 
org 0x7c00 
boot:

halt:
    cli
    hlt

times 510 - ($-$$) db 0 
dw 0xaa55
