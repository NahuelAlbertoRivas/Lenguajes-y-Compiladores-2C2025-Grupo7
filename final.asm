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
_cte_cad_2		db		"a es mas grande que b (a > b)",'$', 31 dup (?)
_cte_cad_3		db		"a es mas chico o igual a b (a <= b)",'$', 37 dup (?)
_cte_cad_4		db		"a y c mas grandes que b [a > b & c > b]",'$', 41 dup (?)
_cte_cad_5		db		"a es mas grande que b y c es mas grande que b",'$', 47 dup (?)
_cte_cad_6		db		"a no es mas grande que b -> !(a > b)",'$', 38 dup (?)
_cte_0		dd		0.0
_cte_5		dd		5.0
_cte_cad_7		db		"a es mas grande que b y c",'$', 27 dup (?)
_cte_99999_990000000		dd		99999.990000000
_cte_99_000000000		dd		99.000000000
_cte_0_999900000		dd		0.999900000
_cte_cad_8		db		"@sdadasjfla%dfg",'$', 17 dup (?)
_cte_cad_9		db		"asldk  fh sjf",'$', 15 dup (?)
_cte_27		dd		27.0
_cte_500		dd		500.0
_cte_34		dd		34.0
_cte_cad_10		db		"ewr",'$', 5 dup (?)

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
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_27

jmp ETIQUETA_25

ETIQUETA_25:
displayString _cte_cad_1
newLine

ETIQUETA_27:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_35

jmp ETIQUETA_32

ETIQUETA_32:
displayString _cte_cad_2
newLine

jmp ETIQUETA_37

ETIQUETA_35:
displayString _cte_cad_3
newLine

ETIQUETA_37:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_49

jmp ETIQUETA_42

ETIQUETA_42:
fld c
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_49

jmp ETIQUETA_47

ETIQUETA_47:
displayString _cte_cad_4
newLine

ETIQUETA_49:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_54

jmp ETIQUETA_59

ETIQUETA_54:
fld c
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_61

jmp ETIQUETA_59

ETIQUETA_59:
displayString _cte_cad_5
newLine

ETIQUETA_61:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_66

jmp ETIQUETA_68

ETIQUETA_66:
displayString _cte_cad_6
newLine

ETIQUETA_68:
fld a
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_82

jmp ETIQUETA_73

ETIQUETA_73:
fld b
fld c
fxch
fcom
fstsw ax
sahf
ffree
jae ETIQUETA_82

jmp ETIQUETA_78

ETIQUETA_78:
fld _cte_5
fstp a

jmp ETIQUETA_85

ETIQUETA_82:
fld _cte_1
fstp b

ETIQUETA_85:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_97

jmp ETIQUETA_90

ETIQUETA_90:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_97

jmp ETIQUETA_95

ETIQUETA_95:
displayString _cte_cad_7
newLine

ETIQUETA_97:
fld _cte_99999.990000000
fstp varFloat

fld _cte_99.000000000
fstp varFloat

fld _cte_0.999900000
fstp varFloat

fld varStr
fstp "@sdADaSjfla%dfg"

fld varStr
fstp "asldk  fh sjf"

fld _cte_27
fld c
fsub

fstp x

fld d
fld _cte_500
fadd

fstp x

fld _cte_34
fld _cte_3
fmul

fstp x

fld e
fld f
fdiv

fstp x

getString s_base
newLine

displayString _cte_cad_10
newLine

DisplayFloat varInt, 2
newLine

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
