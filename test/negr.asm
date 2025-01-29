;
; Name:     PixelAddr
; Function: Определяет позицию пикселя в буфере VGA в режиме 640x480
; Caller:   AX = y-координата 0-479
;       BX = x-координата 0-639
; Returns:  AH = битовая маска
;       BX = смещение байта в видеобуфере
;       CL = число сдвигов для сдвига маски влево
;       ES = сегмент видеобуфера
BytesPerLine    EQU 80      ; число байт в одной гор.линии
VideoBufferSeg  EQU 0A000h
PixelAddr   PROC    near
        mov cl,bl       ; CL := младший байт x
        push    dx      ; сохраним DX
        mov dx,BytesPerLine ; AX := y * BytesPerLine
        mul dx
        pop dx
        shr bx,1
        shr bx,1
        shr bx,1        ; BX := x/8
        add bx,ax       ; BX := y*BytesPerLine + x/8
                    ; BX -  смещение байта в видеобуфере
        mov ax,VideoBufferSeg
        mov es,ax       ; ES:BX := адрес байта пикселя
        and cl,7        ; CL := x & 7
        xor cl,7        ; CL := число сдвигов для сдвига маски влево
        mov ah,1        ; AH := несдвинутая маска
        ret
PixelAddr   ENDP
;
; Name:     SetPixel
; Function: Устанавливает значение пикселя в режиме 640x480
;           void SetPixel(x,y,n);
;           int x,y;        /* координаты пикселя */
;
;           int n;          /* цвет пикселя */
RMWbits     EQU 0       ; read-modify-write bits
SetPixel    PROC    ARGx:word, ARGy:word, ARGn:word
uses        cx, dx, bx, es
        mov ax,ARGy     ; AX := y
        mov bx,ARGx     ; BX := x
        call    PixelAddr   ; AH := битовая маска
                    ; ES:BX -> буфер
                    ; CL := число сдвигов
; установка регистра битовой маски графического контроллера (GC)
        shl ah,cl       ; AH := битовая маска в соответствующей позиции
        mov dx,3CEh     ; порт регистра адреса GC
        mov al,8        ; AL := номер регистра битовой маски
        out dx,ax
; установка регистра режима GC
        mov ax,0005h    ; AL :=  номер регистра режима
                    ; AH :=  режим записи 0 (биты 0,1)
                    ;    режим чтения 0 (бит 3)
        out dx,ax
; установка регистра выбора вращения/функции
        mov ah,RMWbits  ; AH := биты Read-Modify-Write (=0)
        mov al,3        ; AL := регистр выбора Data Rotate/Function
        out dx,ax
; установка регистров установки/сброса и разрешения установки/сброса
        mov ah,byte ptr ARGn; AH := цвет пикселя
        mov al,0        ; AL := регистр установки/сброса
        out dx,ax
        mov ax,0F01h    ; AH := разрешаем все цветовые слои
                    ; AL := регистр разрешения установки/сброса
        out dx,ax
; установка значения пикселя
        or  es:[bx],al  ; загрузка в защелки во время чтения
                    ; и установка во время записи
; восстановим значения по-умолчанию
        mov ax,0FF08h   ; маска битов
        out dx,ax
        mov ax,0005     ; регистр режима
        out dx,ax
        mov ax,0003     ; выбор функции
        out dx,ax
        mov ax,0001     ; разрешение установки/сброса
        out dx,ax
        ret
SetPixel    ENDP