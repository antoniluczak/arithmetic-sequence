global arithmetic_sequence

section .text

; Przekazane parametry (zgodnie z System V AMD64 ABI):
; rdi - A_0
; rsi - A_1
; rdx - A_k
; rcx - n
; r8  - k 
;
; Wynik:
; rax - młodsze 64 bity z górnych 128 bitów wyniku
; rdx - starsze 64 bity z górnych 128 bitów wyniku
;
; Wykorzystanie rejestrów w pętli po inicjalizacji:
; rsi - wskaźnik na A1 dla k >= 0 oraz A0 dla k < 0
; r9  - wskaźnik na A0 dla k >= 0 oraz A1 dla k < 0
; rdi - wskaźnik na wynik
; r8  - k dla k >= 0 oraz 1 - k dla k < 0
; r11 - przeniesienie z dodawania
; r10b - pożyczka z odejmowania

arithmetic_sequence:
        mov     r9, rdi         ; Przenosimy wskaźnik A0 do r9
        mov     rdi, rdx        ; Przenosimy wskaźnik wyniku do rdi.
        xor     r11d, r11d
        xor     r10d, r10d

        test    r8, r8          ; Sprawdzamy znak k.
        jns     .main_loop

        ; Jeżeli k jest ujemne, to zamiast liczyć k * (A1 - A0) + A0,
        ; liczymy (1 - k) * (A0 - A1) + A1. Dalej przez B0 oraz B1 będziemy
        ; rozumieli liczby o adresach zapisanych w r9 oraz rsi odpowiednio.

        neg     r8
        inc     r8 
        xchg    rsi, r9         ; Zamieniamy role A0 oraz A1.          

        ; Obliczamy pierwsze 64n bitów wyniku.
.main_loop:
        lodsq                   ; Wczytujemy słowo liczby B1 do akumulatora
                                ; oraz przechodzimy do kolejnego słowa.
        shr     r10b, 1
        sbb     rax, [r9]       ; Obliczamy kolejne słowo liczby B1 - B0.
        setc    r10b

        mul     r8              ; Mnożymy słowo B1 - B0 przez k (lub 1 - k)

        add     rax, r11        ; Dodajemy przeniesienie z poprzedniej iteracji.
        adc     rdx, 0
        add     rax, [r9]       ; Dodajemy odpowiednie słowo B0.
        adc     rdx, 0

        ; Iloczyn dwóch liczb 64 bitowych zwiększony o sumę dwóch liczb
        ; 64 bitowych mieści się w 128 bitach, zatem nie gubimy potencjalnego
        ; przeniesienia dla wyższych słów wyniku.

        stosq                   ; Zapisujemy słowo wyniku oraz zwiększamy
                                ; wskaźnik wyniku o 8.
        mov     r11, rdx
        add     r9, 8
        loop     .main_loop     ; Wracamy na początek pętli, jeżeli n > 0
                                ; oraz dekrementujemy wartość n.

        ; Obliczamy dwa najbardziej znaczące słowa wyniku.
        ; Wykonujemy dwa przejścia analogiczne do powyższej pętli.
        mov     r9, [r9 - 8]    ; Zapisujemy ostatnie słowo B0.
        sar     r9, 63          ; Generujemy maskę rozszerzenia znaku dla B0.

        mov     cl, 2           ; Pętla zostanie wykonana dokładnie dwa razy.

.result_loop:
        mov     rax, [rsi - 8]  ; Zapisujemy ostatnie słowo B1 w akumulatorze.
        sar     rax, 63         ; Generujemy maskę rozszerzenia znaku dla B1.
        shr     r10b, 1         ; Odtwarzamy ostatnią pożyczkę z pętli głównej.
        sbb     rax, r9         ; Obliczamy kolejne słowo różnicy B1 - B0.
        setc    r10b
        
        mul     r8              ; Mnożymy słowo B1 - B0 przez k (lub 1 - k)

        add     rax, r11        ; Dodajemy przeniesienie z poprzedniej iteracji.
        adc     rdx, 0
        add     rax, r9         ; Dodajemy odpowiednie słowo B0.
        adc     rdx, 0
        
        mov     r11, rdx
        xchg    rax, rdi        ; W pierwszej iteracji młodsze słowo wyniku
                                ; ląduje w rdi. W drugiej iteracji młodsze słowo
                                ; wyniku ląduje w rax, a starsze w rdi.
        loop    .result_loop

        mov     rdx, rdi

        ret