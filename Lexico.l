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

/* Defines */

/* Variables Globales */
FILE  *yyin;
int yylval;
char *yyltext;


int yyerror(void);

%}

/*---------------------------------------------*/
/* Seccion Conjuntos y Regex */
/*---------------------------------------------*/

/* Opciones */
%option noyywrap  
%option yylineno 

/* Conjuntos */
DIGITO			    [0-9]
DIGITO_POSITIVO     [1-9]
LETRA			    [a-zA-Z]
LETRA_MIN           [a-z]
LETRA_MAY           [A-Z]

HEXA                [0-9a-fA-F]
OCTAL               [0-7]

CARACTER_SIMPLE     [^\"\\\n] 

/* Regex: Operadores matematicos */
OP_ASIG   		    ":""="
OP_SUM		        "+"
OP_MUL              "*"
OP_RES		        "-"
OP_DIV              "/"

/* Regex: Comparadores */
CMP_MAYOR            ">"
CMP_MENOR            "<"
CMP_MAYOR_IGUAL      ">="
CMP_MENOR_IGUAL      "<="
CMP_DISTINTO         "!="
CMP_ES_IGUAL         "=="

/* Regex: Operadores matematicos */
OP_AND              "AND"
OP_OR               "OR"
OP_NOT              "NOT"

/* Regex: Simbolos Especiales
PAR_ABR             "("
PAR_CIE		        ")"
COR_ABR             "["
COR_CIE             "]"
LLA_ABR             "{"
LLA_CIE             "}"
PUNTO               "."
DOS_PUNTOS          ":"
COMA                ","
PUNTO_COMA          ";"
NUMERAL             "#"
COMILLA_DOBLE       "\""
COMILLA_SIMPLE      "\'"

/* Regex: Palabras Reservadas */
WHILE               "while"
IF                  "if"
ELSE                "else"

TD_INT              "Int"
TD_FLOAT            "Float"
TD_STRING           "String"
TD_BOOLEAN          "Boolean"

WRITE               "write"
READ                "read"
INIT                "init"

FN_EQUALEXPRESSIONS "equalExpressions"
FN_ISZERO           "isZero"

/* Regex: TOKENS*/
ESCAPE_SIMPLE       \\[\'\"\\\?abfnrtv]   
ESCAPE_OCTAL        \\{OCTAL}{1,3}       
ESCAPE_HEX          \\x{HEXA}+          
ESCAPE              ({ESCAPE_SIMPLE}|{ESCAPE_OCTAL}|{ESCAPE_HEX})
CARACTER            ({CARACTER_SIMPLE}|{ESCAPE})

CTE_INT		        {DIGITO}+
CTE_REAL_POS        {DIGITO}+{PUNTO}{DIGITO}+ | {DIGITO}+{PUNTO}{DIGITO}* | {DIGITO}*{PUNTO}{DIGITO}+
CTE_STRING          {COMILLA_DOBLE}{CARACTER}*{COMILLA_DOBLE}
ID			        {LETRA}({LETRA}|{DIGITO})*

/*---------------------------------------------*/
/* Seccion Definición de Reglas */
/*---------------------------------------------*/

%%

{CTE}			    {printf("\nConstante: %s\n", yytext);return CTE;}
{ID}			    printf("\nIdentificador: %s\n", yytext);return ID;}
{OP_SUM}		    {printf("\nSuma: %s\n", yytext);return OP_SUM;}
{OP_AS}			    {printf("\nAsignacion: %s\n", yytext);return OP_AS;}
{OP_MUL}		    {printf("\nMultiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		    {printf("\nResta: %s\n", yytext);return OP_RES;}
{OP_DIV}		    {printf("\nDivision: %s\n", yytext);return OP_DIV;}
{PA}			    {printf("\nParAbre: %s\n", yytext);return PA;}
{PC}			    {printf("\nParCierra: %s\n", yytext);return PC;}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"
.			        { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%

/*---------------------------------------------*/
/* Seccion Codigo */
/*---------------------------------------------*/
