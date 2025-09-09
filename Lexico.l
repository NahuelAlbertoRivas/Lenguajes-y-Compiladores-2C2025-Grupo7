/* Grupo Nº7 */

/*---------------------------------------------*/
/* Seccion Definiciones */
/*---------------------------------------------*/
%{
/* Includes */
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"

#include <float.h> /* Libreria para el manejo de floats, tiene el maximo de tamaño de reales de 32 bits*/
#include <limits.h> /* Libreria para el manejo de enteros, tiene el maximo de tamaño de enteros de 16 bits*/
#include <string.h> /* Libreria para el manejo de strings*/

#include "tabla.h" /* Archivo para la tabla de simbolos */

/* Defines */
#define TAM_MAX_STRING 50
#define TAM_MAX_ID     100

/* Variables Globales */
FILE  *yyin;

extern Tabla tabla;

extern int yylval; // Tuve que declararlo como extern para que compile
char *yyltext; 

int yyerror(void);


/* Funciones Auxiliares*/
int validar_entero(const char* lexema);
int validar_real(const char* lexema);
int validar_string(const char* lexema);
int validar_id(const char* lexema);

%}

/*---------------------------------------------*/
/* Seccion Conjuntos y Regex */
/*---------------------------------------------*/

/* Opciones */
%option noyywrap  
%option yylineno 

/* Conjuntos */
DIGITO			        [0-9]
DIGITO_POSITIVO         [1-9]
LETRA			        [a-zA-Z]
LETRA_MIN               [a-z]
LETRA_MAY               [A-Z]

HEXA                    [0-9a-fA-F]
OCTAL                   [0-7]

CARACTER_SIMPLE         [^\"\\\n] 

/* Regex: Operadores matematicos */
OP_ASIG   		        ":""="
OP_SUM		            "+"
OP_MUL                  "*"
OP_RES		            "-"
OP_DIV                  "/"
OP_MOD                  "%"

OP_UN_INC		        "++"
OP_UN_DEC               "--"

/* Regex: Comparadores */
CMP_MAYOR               ">"
CMP_MENOR               "<"
CMP_MAYOR_IGUAL         ">="
CMP_MENOR_IGUAL          "<="
CMP_DISTINTO            "!="
CMP_ES_IGUAL            "=="

/* Regex: Operadores matematicos */
OP_AND                  "AND"
OP_OR                   "OR"
OP_NOT                  "NOT"

/* Regex: Simbolos Especiales*/
PAR_ABR                 "("
PAR_CIE		            ")"
COR_ABR                 "["
COR_CIE                 "]"
LLA_ABR                 "{"
LLA_CIE                 "}"
PUNTO                   "."
DOS_PUNTOS              ":"
COMA                    ","
PUNTO_COMA              ";"
NUMERAL                 "#"
COMILLA_DOBLE           "\""
COMILLA_SIMPLE          "\'"
UNDERSCORE              "_"

/* Regex: Palabras Reservadas */
WHILE                   "while"
IF                      "if"
ELSE                    "else"

TD_INT                  "Int"
TD_FLOAT                "Float"
TD_STRING               "String"
TD_BOOLEAN              "Boolean"

WRITE                   "write"
READ                    "read"
INIT                    "init"
TRUE                    "true"
FALSE                   "false"

FN_EQUALEXPRESSIONS     "equalExpressions"
FN_ISZERO               "isZero"

RET                     "return"

/* Regex: COMENTARIO*/
COMMENT                 "#+".*"+#"

/* Regex: TOKENS*/
ESCAPE_SIMPLE           \\[\'\"\\\?abfnrtv]   
ESCAPE_OCTAL            \\{OCTAL}{1,3}       
ESCAPE_HEX              \\x{HEXA}+          
ESCAPE                  ({ESCAPE_SIMPLE}|{ESCAPE_OCTAL}|{ESCAPE_HEX})
CARACTER                ({CARACTER_SIMPLE}|{ESCAPE})

CTE_INT		            {DIGITO}+
CTE_REAL                ({DIGITO}+{PUNTO}{DIGITO}+|{DIGITO}+{PUNTO}{DIGITO}*|{DIGITO}*{PUNTO}{DIGITO}+)
CTE_STRING              {COMILLA_DOBLE}{CARACTER_SIMPLE}*{COMILLA_DOBLE}
ID			            {LETRA}({LETRA}|{DIGITO}|{UNDERSCORE})*

/*---------------------------------------------*/
/* Seccion Definición de Reglas */
/*---------------------------------------------*/

%%
{IF}			        {printf("\nPalabra Reservada: %s\n", yytext);return IF;}
{WHILE}			        {printf("\nPalabra Reservada: %s\n", yytext);return WHILE;}
{ELSE}			        {printf("\nPalabra Reservada: %s\n", yytext);return ELSE;}
{WRITE}			        {printf("\nPalabra Reservada: %s\n", yytext);return WRITE;}
{READ}			        {printf("\nPalabra Reservada: %s\n", yytext);return READ;}
{INIT}			        {printf("\nPalabra Reservada: %s\n", yytext);return INIT;}
{TD_INT}			    {printf("\nPalabra Reservada: %s\n", yytext);return TD_INT;}
{TD_FLOAT}			    {printf("\nPalabra Reservada: %s\n", yytext);return TD_FLOAT;}
{TD_STRING}			    {printf("\nPalabra Reservada: %s\n", yytext);return TD_STRING;}
{TD_BOOLEAN}	        {printf("\nPalabra Reservada: %s\n", yytext);return TD_BOOLEAN;}
{OP_AND}		        {printf("\nOperador: %s\n", yytext);return OP_AND;}
{OP_OR}		            {printf("\nOperador: %s\n", yytext);return OP_OR;}
{OP_NOT}		        {printf("\nOperador: %s\n", yytext);return OP_NOT;}
{FN_ISZERO}		        {printf("\nPalabra Reservada: %s\n", yytext);return FN_ISZERO;}
{FN_EQUALEXPRESSIONS}	{printf("\nPalabra Reservada: %s\n", yytext);return FN_EQUALEXPRESSIONS;}
{TRUE}	                {printf("\nPalabra Reservada: %s\n", yytext);return TRUE;}
{FALSE}	                {printf("\nPalabra Reservada: %s\n", yytext);return FALSE;}
{ID}			        {return validar_id(yytext);}
{OP_SUM}		        {printf("\nSuma: %s\n", yytext);return OP_SUM;}
{OP_ASIG}			    {printf("\nAsignacion: %s\n", yytext);return OP_ASIG;}
{OP_MUL}		        {printf("\nMultiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		        {printf("\nResta: %s\n", yytext);return OP_RES;}
{OP_DIV}		        {printf("\nDivision: %s\n", yytext);return OP_DIV;}
{PAR_ABR}			    {printf("\nParAbre: %s\n", yytext);return PAR_ABR;}
{PAR_CIE}			    {printf("\nParCierra: %s\n", yytext);return PAR_CIE;}
{PUNTO_COMA}            {printf("\nPunto y Coma: %s\n", yytext);return PUNTO_COMA;}
{COR_ABR}               {printf("\nCorchete Abre: %s\n", yytext);return COR_ABR;}
{COR_CIE}               {printf("\nCorchete Cierra: %s\n", yytext);return COR_CIE;}
{LLA_ABR}               {printf("\nLLave abre: %s\n", yytext);return LLA_ABR;}
{LLA_CIE}               {printf("\nLLave cierra: %s\n", yytext);return LLA_CIE;}
{CMP_MAYOR}			    {printf("\nComparador: %s\n", yytext);return CMP_MAYOR;}
{CMP_MENOR}			    {printf("\nComparador: %s\n", yytext);return CMP_MENOR;}
{CMP_MAYOR_IGUAL}	    {printf("\nComparador: %s\n", yytext);return CMP_MAYOR_IGUAL;}
{CMP_MENOR_IGUAL}	    {printf("\nComparador: %s\n", yytext);return CMP_MENOR_IGUAL;}
{CMP_DISTINTO}		    {printf("\nComparador: %s\n", yytext);return CMP_DISTINTO;}
{CMP_ES_IGUAL}		    {printf("\nComparador: %s\n", yytext);return CMP_ES_IGUAL;}
{COMMENT}		        {/*printf("\nComentario ignorado: %s\n", yytext);*/}
{COMA}		            {printf("\nComa: %s\n", yytext);return COMA;}
{DOS_PUNTOS}            {printf("\nDos puntos: %s\n", yytext);return DOS_PUNTOS;}
{OP_UN_INC}		        {printf("\nIncremento Unario: %s\n", yytext);return OP_UN_INC;}
{OP_UN_DEC}		        {printf("\nDecremento Unario: %s\n", yytext);return OP_UN_DEC;}

{CTE_INT}               { return validar_entero(yytext); }
{CTE_REAL}              { return validar_real(yytext); }
{CTE_STRING}            { return validar_string(yytext); }

"\n"
"\t"
"\n\t"
" "
"\r\n"
.			            { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}
%%

/*---------------------------------------------*/
/* Seccion Codigo */
/*---------------------------------------------*/

int validar_entero(const char* lexema) {
    errno = 0;
    long value = strtol(lexema, NULL, 10);

    if (errno == ERANGE || value < SHRT_MIN || value > SHRT_MAX) {
        fprintf(stderr, "ERROR: Constante entera fuera de rango (maximo 16 bits): %s\n", lexema);
        exit(1);
    }

    printf("\nConstante entera: %s\n", lexema);
    agregar_a_tabla(&tabla, lexema, "CTE_INT");
    
    return CTE_INT;
}

void normalizar_real_lexico(const char *entrada, char *salida, size_t tam_salida) {
    // Convertimos la cadena a float (32 bits)
    float numero = strtof(entrada, NULL);

    // Imprimimos con 6 decimales fijos (ajusta según consigna)
    snprintf(salida, tam_salida, "%.9f", numero);
}

int validar_real(const char* lexema) {
    errno = 0;
    float value = strtof(lexema, NULL);

    if (errno == ERANGE || value > FLT_MAX || value < -FLT_MAX) {
        fprintf(stderr, "ERROR: Constante real fuera de rango (maximo 32 bits): %s\n", lexema);
        exit(1);
    }

    char normalizado[64];
    normalizar_real_lexico(lexema, normalizado, sizeof(normalizado));

    printf("\nConstante real: %s (normalizado: %s)\n", lexema, normalizado);

    // Guardar el valor normalizado, no el lexema original
    agregar_a_tabla(&tabla, normalizado, "CTE_REAL");

    return CTE_REAL;
}

int validar_string(const char* lexema) {
    size_t len = strlen(lexema);
    if (len < 2 || len - 2 > TAM_MAX_STRING) {
        fprintf(stderr, "ERROR: Constante string demasiado larga (maximo 50): %s\n", lexema);
        exit(1);
    }
    printf("\nConstante string: %s\n", lexema);
    agregar_a_tabla(&tabla, lexema, "CTE_STRING");
    return CTE_STRING;
}

int validar_id(const char* lexema) {
    size_t len = strlen(lexema);
    if (len < 0 || len > TAM_MAX_ID) {
        fprintf(stderr, "ERROR: ID demasiado largao (maximo 100): %s\n", lexema);
        exit(1);
    }
    printf("\nIdentificador: %s\n", lexema);
    agregar_a_tabla(&tabla, lexema, "ID");
    return ID;
}