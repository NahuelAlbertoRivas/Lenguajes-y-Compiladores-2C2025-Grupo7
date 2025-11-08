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
_cte_2		dd		2.0
_cte_3		dd		3.0
@resEqualExpressions		dd		?
_cte_0		dd		0.0
@pivote		dd		?
_cte_1		dd		1.0
@actual		dd		?

.CODE

START:

mov  AX, @data
mov  DS, AX
mov  es, ax

fld _cte_2
fstp a

fld _cte_3
fstp b

DisplayFloat a, 2
newLine

fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_18

jmp ETIQUETA_30

ETIQUETA_18:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_24

jmp ETIQUETA_30

ETIQUETA_24:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_30

jmp ETIQUETA_30

ETIQUETA_30:
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
