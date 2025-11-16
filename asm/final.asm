include number.asm
include macros2.asm

.MODEL LARGE
.386
.STACK 200h

MAXTEXTSIZE equ 40


.DATA
@resEqualExpressions		dd		?
@resIsZero		dd		?
@pivote		dd		?
@actual		dd		?
@resMul		dd		?
@resAritmPrev		dd		?
_cte_1		dd		1.0
_cte_0		dd		0.0
varFloat		dd		?
j		dd		?
G		dd		?
varInt		dd		?
a		dd		?
b		dd		?
c		dd		?
d		dd		?
e		dd		?
f		dd		?
x		dd		?
h		dd		?
s_varStr		db MAXTEXTSIZE dup (?), '$'
s_base		db MAXTEXTSIZE dup (?), '$'
s_p1		db MAXTEXTSIZE dup (?), '$'
s_p2		db MAXTEXTSIZE dup (?), '$'
s_p3		db MAXTEXTSIZE dup (?), '$'
varBool		dd		?
y		dd		?
res		dd		?
_cte_9		dd		9.0
_cte_5		dd		5.0
_cte_3		dd		3.0
_cte_2		dd		2.0
_cte_cad_1		db		"a es mas grande que b",'$', 23 dup (?)
_cte_33		dd		33.0
_cte_cad_2		db		"c es menor a 6",'$', 16 dup (?)
_cte_cad_3		db		"d es menor a 5",'$', 16 dup (?)
_cte_cad_4		db		"paso fin de a > b",'$', 19 dup (?)
_cte_cad_5		db		"a es mas grande que b (a > b)",'$', 31 dup (?)
_cte_cad_6		db		"a es mas chico o igual a b (a <= b)",'$', 37 dup (?)
_cte_4		dd		4.0
_cte_cad_7		db		"a y c mas grandes que b [a > b & c > b]",'$', 41 dup (?)
_cte_cad_8		db		"a es mas grande que b o c es mas grande que b",'$', 47 dup (?)
_cte_cad_9		db		"a no es mas grande que b -> !(a > b)",'$', 38 dup (?)
_cte_cad_10		db		"b ahora vale 1",'$', 16 dup (?)
_cte_10		dd		10.0
_cte_cad_11		db		"a es mas grande que b y c",'$', 27 dup (?)
_cte_99999_990000000		dd		99999.990000000
_cte_99_000000000		dd		99.000000000
_cte_0_999900000		dd		0.999900000
_cte_cad_12		db		"@sdadasjfla%dfg",'$', 17 dup (?)
_cte_cad_13		db		"asldk  fh sjf",'$', 15 dup (?)
_cte_24		dd		24.0
_cte_27		dd		27.0
_cte_cad_14		db		"27 - c = 3",'$', 12 dup (?)
_cte_500		dd		500.0
_cte_cad_15		db		"x es igual a 500?",'$', 19 dup (?)
_cte_cad_16		db		"x es 500",'$', 10 dup (?)
_cte_cad_17		db		"x en realidad es el siguiente nro:",'$', 36 dup (?)
_cte_cad_18		db		"ingrese un nro",'$', 16 dup (?)
_cte_cad_19		db		"ewr es una cte string",'$', 23 dup (?)
_cte_50		dd		50.0
_cte_100		dd		100.0
_cte_cad_20		db		"a + b = 100",'$', 13 dup (?)
_cte_101		dd		101.0
_cte_45		dd		45.0
_cte_99		dd		99.0
_cte_0_500000000		dd		0.500000000
_cte_cad_21		db		"parte true estructura mas interna",'$', 35 dup (?)
_cte_cad_22		db		"parte else estructura mas interna",'$', 35 dup (?)
_cte_55		dd		55.0
_cte_cad_23		db		"efectivamente no es 0",'$', 23 dup (?)
_cte_34		dd		34.0
_cte_344		dd		344.0
_cte_56		dd		56.0
_cte_1000		dd		1000.0
_cte_cad_24		db		"34 * 344 / 5 - 56 * 2 * 100 + 55 * 1000 = ",'$', 44 dup (?)
msgDivCero db "Error: division por cero detectada. Abortando...",'$', 50 dup (?)
.CODE

START:

mov  AX, @data
mov  DS, AX
mov  es, ax

fld _cte_9
fstp a

fld _cte_5
fstp b

fld _cte_3
fstp c

fld _cte_2
fstp d

ETIQUETA_12:

fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_63

jmp ETIQUETA_18

ETIQUETA_18:
displayString _cte_cad_1
newLine

fld a
fld _cte_1
fsub

fstp a

fld a

call CheckDivZero

fld _cte_33
fdiv

fstp x

DisplayFloat x, 2
newLine

ETIQUETA_32:

fld c
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_60

jmp ETIQUETA_38

ETIQUETA_38:
displayString _cte_cad_2
newLine

fld c
fld _cte_1
fsub

fstp c

ETIQUETA_45:

fld d
fld _cte_5
fxch
fcom
fstsw ax
sahf
ffree
jae ETIQUETA_59

jmp ETIQUETA_51

ETIQUETA_51:
displayString _cte_cad_3
newLine

fld d
fld _cte_1
fadd

fstp d

jmp ETIQUETA_45

ETIQUETA_59:
jmp ETIQUETA_32

ETIQUETA_60:
displayString _cte_cad_4
newLine

jmp ETIQUETA_12

ETIQUETA_63:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_70

jmp ETIQUETA_68

ETIQUETA_68:
displayString _cte_cad_1
newLine

ETIQUETA_70:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_78

jmp ETIQUETA_75

ETIQUETA_75:
displayString _cte_cad_5
newLine

jmp ETIQUETA_80

ETIQUETA_78:
displayString _cte_cad_6
newLine

ETIQUETA_80:
fld _cte_4
fstp c

fld a
fld _cte_1
fadd

fstp a

fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_100

jmp ETIQUETA_93

ETIQUETA_93:
fld c
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_100

jmp ETIQUETA_98

ETIQUETA_98:
displayString _cte_cad_7
newLine

ETIQUETA_100:
fld _cte_0
fstp a

fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_108

jmp ETIQUETA_113

ETIQUETA_108:
fld c
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_115

jmp ETIQUETA_113

ETIQUETA_113:
displayString _cte_cad_8
newLine

ETIQUETA_115:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_120

jmp ETIQUETA_122

ETIQUETA_120:
displayString _cte_cad_9
newLine

ETIQUETA_122:
fld b
fld _cte_1
fadd

fstp b

fld a
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_141

jmp ETIQUETA_132

ETIQUETA_132:
fld b
fld c
fxch
fcom
fstsw ax
sahf
ffree
jae ETIQUETA_141

jmp ETIQUETA_137

ETIQUETA_137:
fld _cte_5
fstp a

jmp ETIQUETA_146

ETIQUETA_141:
displayString _cte_cad_10
newLine

fld _cte_1
fstp b

ETIQUETA_146:
fld _cte_10
fstp a

fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_161

jmp ETIQUETA_154

ETIQUETA_154:
fld a
fld b
fxch
fcom
fstsw ax
sahf
ffree
jbe ETIQUETA_161

jmp ETIQUETA_159

ETIQUETA_159:
displayString _cte_cad_11
newLine

ETIQUETA_161:
fld _cte_99999_990000000
fstp varFloat

fld _cte_99_000000000
fstp varFloat

fld _cte_0_999900000
fstp varFloat

lea si, _cte_cad_12
lea di, s_varStr
call COPIAR

lea si, _cte_cad_13
lea di, s_varStr
call COPIAR

fld _cte_24
fstp c

fld c
fld _cte_27
fsub

fstp x

fld x
fld _cte_3
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_191

jmp ETIQUETA_189

ETIQUETA_189:
displayString _cte_cad_14
newLine

ETIQUETA_191:
fld _cte_1
fstp d

fld _cte_500
fld d
fadd

fstp x

displayString _cte_cad_15
newLine

fld x
fld _cte_500
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_209

jmp ETIQUETA_206

ETIQUETA_206:
displayString _cte_cad_16
newLine

jmp ETIQUETA_213

ETIQUETA_209:
displayString _cte_cad_17
newLine

DisplayFloat x, 2
newLine

ETIQUETA_213:
displayString _cte_cad_18
newLine

getString s_base
newLine

displayString _cte_cad_19
newLine

fld _cte_50
fstp a

fld _cte_50
fstp b

fld _cte_0
fstp @resEqualExpressions

fld b
fld a
fadd

fstp @pivote

fld _cte_100
fstp @actual

fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_242

ETIQUETA_242:
fld _cte_1
fstp @resEqualExpressions

jmp ETIQUETA_244

ETIQUETA_244:
fld @resEqualExpressions
fld _cte_1
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_251

jmp ETIQUETA_249

ETIQUETA_249:
displayString _cte_cad_20
newLine

ETIQUETA_251:
fld _cte_1
fstp res

fld _cte_1
fstp c

fld _cte_101
fstp d

fld _cte_1
fstp y

fld _cte_0
fstp a

fld _cte_45
fstp b

fld _cte_99
fstp G

fld _cte_0_500000000
fstp j

fld c
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
je ETIQUETA_326

jmp ETIQUETA_280

ETIQUETA_280:
fld d
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
je ETIQUETA_326

jmp ETIQUETA_285

ETIQUETA_285:
fld y
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
je ETIQUETA_326

jmp ETIQUETA_290

ETIQUETA_290:
fld res
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
je ETIQUETA_326

jmp ETIQUETA_295

ETIQUETA_295:
fld a
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
je ETIQUETA_300

jmp ETIQUETA_305

ETIQUETA_300:
fld b
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
je ETIQUETA_326

jmp ETIQUETA_305

ETIQUETA_305:
fld G
fld _cte_100
fxch
fcom
fstsw ax
sahf
ffree
jae ETIQUETA_321

jmp ETIQUETA_310

ETIQUETA_310:
fld j
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
je ETIQUETA_320

jmp ETIQUETA_315

ETIQUETA_315:
lea si, _cte_cad_21
lea di, s_p3
call COPIAR

displayString s_p3
newLine

ETIQUETA_320:
jmp ETIQUETA_326

ETIQUETA_321:
lea si, _cte_cad_22
lea di, s_p1
call COPIAR

displayString s_p1
newLine

ETIQUETA_326:
fld _cte_55
fld _cte_0
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_336

fld _cte_1
fstp @resIsZero

jmp ETIQUETA_335

ETIQUETA_335:
ETIQUETA_336:
fld _cte_0
fstp @resIsZero

fld @resIsZero
fld _cte_1
fxch
fcom
fstsw ax
sahf
ffree
je ETIQUETA_344

jmp ETIQUETA_343

ETIQUETA_343:
displayString _cte_cad_23
newLine

ETIQUETA_344:
fld _cte_344
fld _cte_34
fmul

fld _cte_5

call CheckDivZero

fdiv

fstp @resAritmPrev

fld _cte_2
fld _cte_56
fmul

fld _cte_100
fmul

fld @resAritmPrev

fxch

fsub

fstp @resAritmPrev

fld _cte_1000
fld _cte_55
fmul

fld @resAritmPrev

fxch

fadd

fstp x

displayString _cte_cad_24
newLine

DisplayFloat x, 2
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

CheckDivZero PROC NEAR
    push ax
    push dx

    fldz 
    fcompp

    fstsw ax
    sahf
    jne CDZ_OK

    mov dx, offset msgDivCero
    mov ah, 9
    int 21h
    mov ax, 4C00h
    int 21h

    CDZ_OK:
    pop dx
    pop ax
    ret
CheckDivZero ENDP

END START
