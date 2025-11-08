include number.asm
include macros2.asm

.MODEL LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 40


.DATA
varFloat		dd		?
varInt		dd		?
a		dd		?
b		dd		?
c		dd		?
d		dd		?
e		dd		?
f		dd		?
x		dd		?
s_varStr		db MAXTEXTSIZE dup (?), '$'
s_base		db MAXTEXTSIZE dup (?), '$'
varBool		dd		?
y		dd		?
_cte_1		dd		1.0
_cte_3		dd		3.0
_cte_cad_1		db		"a es mas grande que b",'$', 23 dup (?)

.CODE

START:

mov  AX, @data
mov  DS, AX
mov  es, ax

fld _cte_1
fstp a

fld _cte_3
fstp b

ETIQUETA_6:

fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_20

jmp ETIQUETA_12

ETIQUETA_12:
displayString _cte_cad_1
newLine

fld a
fld _cte_1
fadd

fstp a

jmp ETIQUETA_6

ETIQUETA_20:
mov  ax, 4c00h
int  21h
STRLEN PROC NEAR
    mov bx,0
STRL01:
    cmp BYTE PTR [SI+BX],'$'
    je STREND
    inc BX
    jmp STRL01
STREND:
    ret
STRLEN ENDP

COPIAR PROC NEAR
    call STRLEN
    cmp bx,MAXTEXTSIZE
    jle COPIARSIZEOK
    mov bx,MAXTEXTSIZE
COPIARSIZEOK:
    mov cx,bx
    cld
    rep movsb
    mov al,'$'
    mov BYTE PTR [DI],al
    ret
COPIAR ENDP

END START
