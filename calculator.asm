    
    
    .MODEL SMALL                    ; Speichermodel deklarieren
                                    ; SMALL = ein Segment CODE und 
                                    ;         ein Segment DATEN
                                    

    .STACK 50h                      ; Stacksegment und Stackgroesse deklarieren
                        
    .DATA                           ; Datensegment deklarieren

b_folge db  7, 50 ;7, 50, 55, 60, 65, 70, 75, 83

w_folge dw  3, 4000, 5000, 6973

text1   db  13, 10, "Mittelwert von einer Byte- oder Wortfolge berechnen (b/w)? : "
        db  "$"
text2   db  13, 10, "Der Mittelwert betraegt: "
        db  "$"
text3   db  "   Rest: "
        db  "$"
        

    .CODE
Startpoint:
start:  mov     ax,@data            ; AX:=@data (Anfangsadresse vom Datensegment)
        mov     ds,ax               ; DS:=AX
eing:   mov     ah,9                ; Auswahl der Funktion 9 (Ausgabe einer ZK)
        mov     dx,OFFSET text1     ; dx:= Anfangsadresse der Zeichenkette
        int     21h                 ; Ausgabe der Zeichenkette text1
        mov     ah,1                ; Sytemruf vorbereiten
        int     21h                 ; Tastatureingabe mit Echo auf dem Bildschirm
        cmp     al,"b"              ; Vergleich mit ASCII-Zeichen von b
        je      byte_f              ; Sprung zu byte_f falls ZF=1 (Bytefolge)
        cmp     al,"w"              ; Vergleich mit ASCII-Zeichen von w 
        jne     eing                ; wenn weder b noch w, dann noch einmal
        mov     cl,1                ; cl:=1 (Wortfolge)
        mov     bx,OFFSET w_folge   ; bx:= Anfangsadresse der Wortfolge
        jmp     weiter              ; Sprung zu weiter, weil Wortfolge
byte_f: 
        mov     cl,0                ; cl:=0 (Bytefolge)
        mov     bx,OFFSET b_folge   ; bx:= Anfangsadresse der Bytefolge
weiter: call    mw                  ; Aufruf des UP Mittelwert (Bsp. 3)
        call    ausgabe             ; Aufruf des UP Ausgabe (Bsp. 8)
        mov     ax, 4c00h
        int     21h                 ; R?ckkehr zu DOS
    

    ; jetzt kommt die Auflistung aller verwendeten Unterprogramme
    
    
    
    ; <====================================================================================================>
    ; |     Bsp. 1: Unser erstes Unterprogramm - Addition von 8bit-Zahlen zur Summe 8bit 
    ; <====================================================================================================>
esu1    PROC            ; UP-Anfang deklarieren  (Pseudobefehl)
        mov al,0        ; AL := 0 = s
m1:     add al, [bx]    ; AL := AL + ai  
        inc bx          ; BX := BX +1
        loop    m1      ; CX := CX -1, Sprung zu m1, wenn CX <> 0
        ret             ; R?cksprung ins aufrufende Programm
esu1    ENDP            ; UP-Ende deklarieren (Pseudobefehl)



    ; <====================================================================================================>
    ; |     Bsp. 2: Unser zweites Unterprogramm - Addition von 16bit-Zahlen zur Summe 16bit 
    ; <====================================================================================================>
esu2    PROC            ; UP-Anfang deklarieren  (Pseudobefehl)
        push    bx      ; Stack := BX
        push    cx      ; Stack := CX
        xor ax, ax      ; AX := AX?? AX = 0 = s
m2:     add ax, [bx]    ; AX := AX + ai  
        inc bx          ; BX := BX +1
        inc bx          ; BX := BX +1
        loop    m2      ; CX := CX -1, Sprung zu m2, wenn CX <> 0
        pop cx          ; CX := Stack
        pop bx          ; BX := Stack
        ret             ; R?cksprung ins aufrufende Programm
esu2    ENDP            ; UP-Ende deklarieren (Pseudobefehl)



    ; <====================================================================================================>
    ; |     Bsp. 3: Unser drittes Unterprogramm - Berechnung des Mittelwertes einer Byte- oder einer Wortfolge
    ; <====================================================================================================>
mw      PROC            
        push    bx      ; Stack := BX
        push    cx      ; Stack := CX
        cmp cl, 0       ; cl = 0 ?  (tb = 0 ?), Flags := cl ? 0
        jz  byteop      ; wenn ja Sprung zu byteop
        mov cx, [bx]    ; CX := n  (wort_var)
        inc bx          ; BX := BX +1
        inc bx          ; BX := BX +1
        call    esu2    ; UP esu2 aufrufen
        mov dx, 0       ; Dividend (HWT) vorbereiten
        div cx          ; AX := (DX,AX)/CX = s/n = aq     (dx := Rest)
ende:   pop cx          ; CX := Stack
        pop bx          ; BX := Stack
        ret             ; R?cksprung ins aufrufende Programm

byteop: mov ch, 0       ; CH := 0
        mov cl,[bx]     ; CL := n   (byte_var)
        mov dl, cl      ; DL := n
        inc bx          ; BX := BX +1
        call    esu1    ; UP esu1 aufrufen
        mov ah, 0       ; Dividend  (HWT)  vorbereiten
        div dl          ; AL := AX/DL = s/n = aq   (ah := Rest)
        jmp ende        ; Sprung zur Marke ende

mw      ENDP            
    
    

    ; <====================================================================================================>
    ; |     Bsp. 8: Unterprogramm zur Ausgabe des Mittelwertes mw und des Restes einer Folge von Byte- bzw. Wort-Elementen auf dem Bildschirm
    ; <====================================================================================================>
ausgabe PROC    
        cmp cl, 0               ; Mittelwert einer Byte- oder Wortfolge ausgeben?
        je  mw_byte             ; Sprung zu mw_byte, wenn Ausgabe mw einer Bytefolge
        push    dx              ; Rest retten
        push    ax              ; MW retten
        mov ah,9                ; Funktion 9 ausw?hlen
        mov dx, OFFSET text2    ; DX:= Anfangsadresse der ZK text2
        int 21h                 ; Ausgabe der Zeichenkette text2
        pop ax                  ; AX := Mittelwert (Wortfolge)
        call    ausg_dez        ; Ausgabe des Mittelwertes (Bsp. 6)
        mov ah,9
        mov dx, OFFSET text3
        int 21h                 ; Ausgabe der Zeichenkette text3
        pop ax                  ; AX := Rest (Wortfolge)
        call    ausg_dez        ; Ausgabe des Restes (Bsp. 6)
        ret

mw_byte:    
        push    ax              ; MW und Rest retten
        mov ah,9
        mov dx, OFFSET text2
        int 21h                 ; Ausgabe der Zeichenkette text2
        pop ax                  ; AL := Mittelwert, AH := Rest (Bytefolge)
        push    ax              ; und noch weiter im Stack retten
        mov ah,0                ; Rest l?schen
        call    ausg_dez        ; Ausgabe des Mittelwertes (Bsp. 6)
        mov ah,9
        mov dx, OFFSET text3
        int 21h                 ; Ausgabe der Zeichenkette text3
        pop ax                  ; AL := Mittelwert, AH := Rest (Bytefolge)
        mov al,ah               ; AL := Rest
        mov ah,0                ; AH := 0
        call    ausg_dez        ; Ausgabe des Restes (Bsp. 6)
        ret
ausgabe ENDP 



    ; <====================================================================================================>
    ; |     Bsp. 6: Unterprogramm zur Konvertierung einer 16bit Dualzahl in ein Dezimalzahl und Ausgabe auf dem Monitor
    ; <====================================================================================================>
ausg_dez    PROC 
        mov bx,10       ; Divisor nach BX laden
        xor cx,cx       ; Schleifenz?hler auf Null

rech:   xor dx,dx       ; Dividend (HWT) vorbereiten
        div bx          ; AX:=DXAX/BX (AX durch 10 teilen), DX:=Rest
        push    dx      ; Rest der Division auf den Stack
        inc cx          ; Anzahl der Ziffern Z?hlen
        or  ax,ax       ; Ist Ergebnis schon Null?
        jnz rech        ; Nein, dann noch einmal

        mov ah,2        ; Funktionsnummer f?r Zeichenausgabe
aus:    pop dx          ; Ziffer wieder vom Stack holen
        add dl,"0"      ; AL := AL+30H (in ASCII umwandeln)
        int 21h         ; und danach ausgeben
        loop    aus     ; Schleife wiederholen entsprechend der Anzahl
                        ; der Ziffern
        ret
ausg_dez    ENDP 




END Startpoint          ;Ende des zu assemblierenden Quelltextes