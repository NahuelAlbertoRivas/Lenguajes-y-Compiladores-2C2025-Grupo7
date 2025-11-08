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
_cte_2		dd		2.0
@resEqualExpressions		dd		?
@pivote		dd		?
@actual		dd		?

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
fld _cte_99999_990000000
fstp varFloat

fld _cte_99_000000000
fstp varFloat

fld _cte_0_999900000
fstp varFloat

lea si, _cte_cad_8
lea di, s_varStr
call COPIAR

lea si, _cte_cad_9
lea di, s_varStr
call COPIAR

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

fld _cte_2
fstp a

fld _cte_3
fstp b

fld a
fld b
fadd

fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_156

jmp ETIQUETA_213

ETIQUETA_156:
fld b
fld _cte_2
fmul

fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_164

jmp ETIQUETA_213

ETIQUETA_164:
fld _cte_3
fld _cte_2
fadd

fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_172

jmp ETIQUETA_213

ETIQUETA_172:
fld a
fld b
fadd

fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_180

jmp ETIQUETA_213

ETIQUETA_180:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_186

jmp ETIQUETA_213

ETIQUETA_186:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_191

jmp ETIQUETA_213

ETIQUETA_191:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_196

jmp ETIQUETA_213

ETIQUETA_196:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_202

jmp ETIQUETA_213

ETIQUETA_202:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_207

jmp ETIQUETA_213

ETIQUETA_207:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_213

jmp ETIQUETA_213

ETIQUETA_213:
fld :=
fld _cte_5
fsub

fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_226

jmp ETIQUETA_314

ETIQUETA_226:
fld a
fld b
fadd

fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_234

jmp ETIQUETA_314

ETIQUETA_234:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_240

jmp ETIQUETA_314

ETIQUETA_240:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_245

jmp ETIQUETA_314

ETIQUETA_245:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_250

jmp ETIQUETA_314

ETIQUETA_250:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_255

jmp ETIQUETA_314

ETIQUETA_255:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_260

jmp ETIQUETA_314

ETIQUETA_260:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_266

jmp ETIQUETA_314

ETIQUETA_266:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_271

jmp ETIQUETA_314

ETIQUETA_271:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_276

jmp ETIQUETA_314

ETIQUETA_276:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_281

jmp ETIQUETA_314

ETIQUETA_281:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_287

jmp ETIQUETA_314

ETIQUETA_287:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_292

jmp ETIQUETA_314

ETIQUETA_292:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_297

jmp ETIQUETA_314

ETIQUETA_297:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_303

jmp ETIQUETA_314

ETIQUETA_303:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_308

jmp ETIQUETA_314

ETIQUETA_308:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_314

jmp ETIQUETA_314

ETIQUETA_314:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_326

jmp ETIQUETA_636

ETIQUETA_326:
fld :=
fld _cte_5
fsub

fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_333

jmp ETIQUETA_636

ETIQUETA_333:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_339

jmp ETIQUETA_636

ETIQUETA_339:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_345

jmp ETIQUETA_636

ETIQUETA_345:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_351

jmp ETIQUETA_636

ETIQUETA_351:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_357

jmp ETIQUETA_636

ETIQUETA_357:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_362

jmp ETIQUETA_636

ETIQUETA_362:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_367

jmp ETIQUETA_636

ETIQUETA_367:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_372

jmp ETIQUETA_636

ETIQUETA_372:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_377

jmp ETIQUETA_636

ETIQUETA_377:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_382

jmp ETIQUETA_636

ETIQUETA_382:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_387

jmp ETIQUETA_636

ETIQUETA_387:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_392

jmp ETIQUETA_636

ETIQUETA_392:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_397

jmp ETIQUETA_636

ETIQUETA_397:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_402

jmp ETIQUETA_636

ETIQUETA_402:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_408

jmp ETIQUETA_636

ETIQUETA_408:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_413

jmp ETIQUETA_636

ETIQUETA_413:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_418

jmp ETIQUETA_636

ETIQUETA_418:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_423

jmp ETIQUETA_636

ETIQUETA_423:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_428

jmp ETIQUETA_636

ETIQUETA_428:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_433

jmp ETIQUETA_636

ETIQUETA_433:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_438

jmp ETIQUETA_636

ETIQUETA_438:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_443

jmp ETIQUETA_636

ETIQUETA_443:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_448

jmp ETIQUETA_636

ETIQUETA_448:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_454

jmp ETIQUETA_636

ETIQUETA_454:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_459

jmp ETIQUETA_636

ETIQUETA_459:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_464

jmp ETIQUETA_636

ETIQUETA_464:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_469

jmp ETIQUETA_636

ETIQUETA_469:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_474

jmp ETIQUETA_636

ETIQUETA_474:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_479

jmp ETIQUETA_636

ETIQUETA_479:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_484

jmp ETIQUETA_636

ETIQUETA_484:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_489

jmp ETIQUETA_636

ETIQUETA_489:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_495

jmp ETIQUETA_636

ETIQUETA_495:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_500

jmp ETIQUETA_636

ETIQUETA_500:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_505

jmp ETIQUETA_636

ETIQUETA_505:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_510

jmp ETIQUETA_636

ETIQUETA_510:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_515

jmp ETIQUETA_636

ETIQUETA_515:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_520

jmp ETIQUETA_636

ETIQUETA_520:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_525

jmp ETIQUETA_636

ETIQUETA_525:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_531

jmp ETIQUETA_636

ETIQUETA_531:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_536

jmp ETIQUETA_636

ETIQUETA_536:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_541

jmp ETIQUETA_636

ETIQUETA_541:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_546

jmp ETIQUETA_636

ETIQUETA_546:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_551

jmp ETIQUETA_636

ETIQUETA_551:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_556

jmp ETIQUETA_636

ETIQUETA_556:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_562

jmp ETIQUETA_636

ETIQUETA_562:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_567

jmp ETIQUETA_636

ETIQUETA_567:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_572

jmp ETIQUETA_636

ETIQUETA_572:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_577

jmp ETIQUETA_636

ETIQUETA_577:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_582

jmp ETIQUETA_636

ETIQUETA_582:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_588

jmp ETIQUETA_636

ETIQUETA_588:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_593

jmp ETIQUETA_636

ETIQUETA_593:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_598

jmp ETIQUETA_636

ETIQUETA_598:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_603

jmp ETIQUETA_636

ETIQUETA_603:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_609

jmp ETIQUETA_636

ETIQUETA_609:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_614

jmp ETIQUETA_636

ETIQUETA_614:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_619

jmp ETIQUETA_636

ETIQUETA_619:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_625

jmp ETIQUETA_636

ETIQUETA_625:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_630

jmp ETIQUETA_636

ETIQUETA_630:
fld @pivote
fld @actual
fxch
fcom
fstsw ax
sahf
ffree
jne ETIQUETA_636

jmp ETIQUETA_636

ETIQUETA_636:
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
