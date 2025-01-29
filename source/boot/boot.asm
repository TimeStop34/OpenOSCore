;---------- NASM-загрузчик ----------;
bits 16 
org 0x7c00 ; Переход к адресу загрузки
boot:	; Код загрузки

halt:	; Остановка процессора до того момента как не произойдет прерывание BIOS/UEFI
    cli
    hlt

times 510 - ($-$$) db 0  ; Заполнение оставшегося места 0 ( Размер сектора загрузки должен быть всегда 512 байт)
dw 0xaa55
