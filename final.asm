include number.asm
include macros2.asm

.MODEL LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 40


.DATA
a1		dd		?
b1		dd		?
a		dd		?
b		dd		?
ar0		dd		?
var1		dd		?
c		dd		?
d		dd		?
h		dd		?
i		dd		?
j		dd		?
e		dd		?
f		dd		?
s		dd		?
contador		dd		?
D		dd		?
s_p1		db MAXTEXTSIZE dup (?), '$'
s_p2		db MAXTEXTSIZE dup (?), '$'
s_p3		db MAXTEXTSIZE dup (?), '$'
y		dd		?
res		dd		?
_cte_cad_1		db		""a es mas grande que b"",'$', 23 dup (?)
1		dd		?

.CODE

START:

mov  AX, @data
mov  DS, AX
mov  es, ax

ETIQUETA_0:

fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_14

jmp ETIQUETA_6

ETIQUETA_6:
displayString _cte_cad_1
newLine

fld a
fld 1
fadd

fld a
fstp (null)

jmp ETIQUETA_0

ETIQUETA_14:
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
