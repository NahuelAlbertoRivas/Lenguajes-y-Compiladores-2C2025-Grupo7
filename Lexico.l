/* Grupo Nº7 */

/*---------------------------------------------*/
/* Seccion Definiciones */
/*---------------------------------------------*/
%{
/* Includes */
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include "y.tab.h"

#include <float.h> /* Libreria para el manejo de floats, tiene el maximo de tamaño de reales de 32 bits*/
#include <limits.h> /* Libreria para el manejo de enteros, tiene el maximo de tamaño de enteros de 16 bits*/
#include <string.h> /* Libreria para el manejo de strings*/

#include "tabla.h" /* Archivo para la tabla de simbolos */
#include "utilidades/pila.h"
#include "utilidades/hashmap.h"
#include "utilidades/lista.h"
#include "utilidades/acciones_semanticas.h"
#include "Tercetos.h"

/* Defines */
#define TAM_MAX_STRING 50
#define TAM_MAX_ID     100
#define CARACTER_NO_RECONOCIDO -4322

typedef struct {
    int cantThenTotal;
    int cantElseTotal;
    int cantSecuenciaAnd;
    int inicioBloqueAsociado;
} DatosEstructura;

/* Variables Globales */
FILE  *yyin;

extern Tabla tabla;
extern HashMap *hashmap;
extern HashMap *hashmapEstructurasAnidadas;
extern tPila pilaVars;
extern tPila pilaValoresBooleanos;
extern tLista listaAuxiliar;
extern tPila pilaBranchThen;
extern tPila pilaBranchElse;
extern tPila pilaIndiceTercetosFuncionesEspeciales;
extern tPila pilaBI;
extern FILE *ptercetos;
extern int _inicioExpresion;
extern int _inicioBloqueAsociado;
extern int _contadorThenActual;
extern int _contadorEstructurasAnidadas;
extern int _ultRefContadorEstructuras;
extern DatosEstructura datosEstructuraActual;
extern int _contadorThenTotal;
extern int _contadorElseTotal;

char *yyltext; 

int yyerror(void);


/* Funciones Auxiliares*/
int validar_entero(const char* lexema);
int validar_real(const char* lexema);
int validar_string(const char* lexema);
int validar_id(const char* lexema);
void finalizar_recursos();
void guardar_conteo_then();

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
LETRA_ESP               [áéíóúÁÉÍÓÚñÑÜü]

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
COMILLA_DOBLE           "\""
COMILLA_SIMPLE          "\'"
UNDERSCORE              "_"
COM_ABR                 "#+"
COM_CIE                 "+#"

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

/* Regex: TOKENS*/
ESCAPE_SIMPLE           \\[\'\"\\\?abfnrtv]   
ESCAPE_OCTAL            \\{OCTAL}{1,3}       
ESCAPE_HEX              \\x{HEXA}+          
ESCAPE                  ({ESCAPE_SIMPLE}|{ESCAPE_OCTAL}|{ESCAPE_HEX})
CARACTER                ({CARACTER_SIMPLE}|{ESCAPE})

CTE_INT		            {DIGITO}+
CTE_REAL                ({DIGITO}+{PUNTO}{DIGITO}+|{DIGITO}+{PUNTO}{DIGITO}*|{DIGITO}*{PUNTO}{DIGITO}+)
CTE_STRING              {COMILLA_DOBLE}({CARACTER_SIMPLE}|{LETRA_ESP}|{SIMBS_LIT}|{SIMBS_ESP})*{COMILLA_DOBLE}
ID			            {LETRA}({LETRA}|{DIGITO}|{UNDERSCORE})*

/* Regex: COMENTARIO*/
OP_O_COMP               ({CMP_ES_IGUAL}|{CMP_DISTINTO}|{CMP_MAYOR}|{CMP_MAYOR_IGUAL}|{CMP_MENOR}|{CMP_MENOR_IGUAL}|{OP_ASIG}|{OP_DIV}|{OP_MOD}|{OP_MUL}|{OP_SUM}|{OP_RES})
COMILLAS                ({COMILLA_DOBLE}|{COMILLA_SIMPLE})
SIMBS_LIT               ({PUNTO}|"\t"|"?"|"¿"|"¡"|"!"|"&"|"@"|" ")
SIMBS_ESP               ({DOS_PUNTOS}|{PUNTO_COMA}|{UNDERSCORE}|"-"|{PAR_ABR}|{PAR_CIE}|{COR_ABR}|{COR_CIE}|{LLA_ABR}|{LLA_CIE}|"/"|"|"|{COMA}|"="|"*"|"\\"|"#")
COMENTARIO              {COM_ABR}({LETRA}|{LETRA_ESP}|{DIGITO}|{OP_O_COMP}|{SIMBS_ESP}|{SIMBS_LIT}|{COMILLAS}|{ESCAPE})*{COM_CIE}

/*---------------------------------------------*/
/* Seccion Definición de Reglas */
/*---------------------------------------------*/

%%
{IF}			        {_inicioExpresion = getIndice();guardar_conteo_then();return IF;}
{WHILE}			        {guardar_conteo_then();return WHILE;}
{ELSE}			        {return ELSE;}
{WRITE}			        {return WRITE;}
{READ}			        {return READ;}
{INIT}			        {return INIT;}
{TD_INT}			    {yylval.datosToken.str=strdup(yytext);return TD_INT;}
{TD_FLOAT}			    {yylval.datosToken.str=strdup(yytext);return TD_FLOAT;}
{TD_STRING}			    {yylval.datosToken.str=strdup(yytext);return TD_STRING;}
{TD_BOOLEAN}	        {yylval.datosToken.str=strdup(yytext);return TD_BOOLEAN;}
{OP_AND}		        {return OP_AND;}
{OP_OR}		            {return OP_OR;}
{OP_NOT}		        {return OP_NOT;}
{FN_ISZERO}		        {return FN_ISZERO;}
{FN_EQUALEXPRESSIONS}	{return FN_EQUALEXPRESSIONS;}
{TRUE}	                {return TRUE;}
{FALSE}	                {return FALSE;}
{ID}			        {return validar_id(yytext);}
{OP_SUM}		        {return OP_SUM;}
{OP_ASIG}			    {return OP_ASIG;}
{OP_MUL}		        {return OP_MUL;}
{OP_RES}		        {return OP_RES;}
{OP_DIV}		        {return OP_DIV;}
{PAR_ABR}			    {return PAR_ABR;}
{PAR_CIE}			    {_inicioBloqueAsociado = getIndice();return PAR_CIE;}
{PUNTO_COMA}            {return PUNTO_COMA;}
{COR_ABR}               {return COR_ABR;}
{COR_CIE}               {return COR_CIE;}
{LLA_ABR}               {_inicioBloqueAsociado = getIndice();return LLA_ABR;}
{LLA_CIE}               {return LLA_CIE;}
{CMP_MAYOR}			    {return CMP_MAYOR;}
{CMP_MENOR}			    {return CMP_MENOR;}
{CMP_MAYOR_IGUAL}	    {return CMP_MAYOR_IGUAL;}
{CMP_MENOR_IGUAL}	    {return CMP_MENOR_IGUAL;}
{CMP_DISTINTO}		    {return CMP_DISTINTO;}
{CMP_ES_IGUAL}		    {return CMP_ES_IGUAL;}
{COMA}		            {return COMA;}
{DOS_PUNTOS}            {return DOS_PUNTOS;}
{OP_UN_INC}		        {return OP_UN_INC;}
{OP_UN_DEC}		        {return OP_UN_DEC;}

{CTE_INT}               { return validar_entero(yytext); }
{CTE_REAL}              { return validar_real(yytext); }
{CTE_STRING}            { return validar_string(yytext); }

{COMENTARIO}            { printf("%s\n", yytext); }

"\n"
"\t"
"\n\t"
" "
"\r\n"
.			            { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); finalizar_recursos(); exit(CARACTER_NO_RECONOCIDO);}
%%

/*---------------------------------------------*/
/* Seccion Codigo */
/*---------------------------------------------*/

int validar_entero(const char* lexema) {
    errno = 0;
    long value = strtol(lexema, NULL, 10);

    if (errno == ERANGE || value < SHRT_MIN || value > SHRT_MAX) {
        fprintf(stderr, "ERROR: Constante entera fuera de rango (maximo 16 bits): %s\n", lexema);
        finalizar_recursos();
        exit(ERR_VALIDACION);
    }
    else
    {
        agregar_a_tabla(&tabla, lexema, "CTE_INT");
        yylval.datosToken.str = strdup(yytext);
    }
    
    return CTE_INT;
}

void normalizar_real_lexico(const char *entrada, char *salida, size_t tam_salida) {
    double  numero = strtod(entrada, NULL);

    snprintf(salida, tam_salida, "%.9f", numero);
}

int validar_real(const char* lexema) {
    errno = 0;
    double value = strtof(lexema, NULL);

    if (errno == ERANGE || value > FLT_MAX || value < -FLT_MAX)
    {
        fprintf(stderr, "ERROR: Constante real fuera de rango (maximo 32 bits): %s\n", lexema);
        finalizar_recursos();
        exit(ERR_VALIDACION);
    }
    else
    {
        char normalizado[64];
        normalizar_real_lexico(lexema, normalizado, sizeof(normalizado));
        agregar_a_tabla(&tabla, normalizado, "CTE_REAL");
        yylval.datosToken.str = strdup(normalizado);
    }
    return CTE_REAL;
}

int validar_string(const char* lexema) {
    size_t len = strlen(lexema);
    if (len < 2 || len - 2 > TAM_MAX_STRING)
    {
        fprintf(stderr, "ERROR: Constante string demasiado larga (maximo 50): %s\n", lexema);
        finalizar_recursos();
        exit(ERR_VALIDACION);

    }
    else
    {
        agregar_a_tabla(&tabla, lexema, "CTE_STRING");
        yylval.datosToken.codValidacion = VALIDACION_OK;
        yylval.datosToken.str = strdup(yytext);
    }
    return CTE_STRING;
}

int validar_id(const char* lexema) {
    size_t len = strlen(lexema);
    int pos;
    tVar tmp;

    if (len < 0 || len > TAM_MAX_ID) {
        fprintf(stderr, "ERROR: ID demasiado largo (maximo 100): %s\n", lexema);
        finalizar_recursos();
        exit(ERR_VALIDACION);
    }
    else
    {
        pos = agregar_a_tabla(&tabla, lexema, "ID");
        strcpy(tmp.id, lexema);
        tmp.pos_en_tabla = pos;
        poner_en_pila(&pilaVars, &tmp, sizeof(tmp));

        yylval.datosToken.codValidacion = VALIDACION_OK;
        yylval.datosToken.str = strdup(yytext);
    }
    return ID;
}

void finalizar_recursos()
{
    printf("\n\nFinalizando recursos y saliendo...\n\n");
    guardar_tabla_en_archivo(&tabla, "Symbol-Table.txt");
    fclose(yyin);
    destroy_HashMap(hashmap);
    vaciarLista(&listaAuxiliar);
    vaciar_pila(&pilaVars);
    vaciar_pila(&pilaBranchThen);
    vaciar_pila(&pilaBranchElse);
    vaciar_pila(&pilaVars);
    vaciar_pila(&pilaIndiceTercetosFuncionesEspeciales);
    vaciar_pila(&pilaBI);
    vaciar_pila(&pilaValoresBooleanos);
    destroy_HashMap(hashmapEstructurasAnidadas);
}

void guardar_conteo_then()
{
    char aux [20];
    _contadorEstructurasAnidadas++;

    if(_contadorEstructurasAnidadas == 1)
    {
        _contadorThenTotal = 0;
        _contadorElseTotal = 0;
        _ultRefContadorEstructuras = _contadorEstructurasAnidadas;
        sprintf(aux, "estructura_%d", _contadorEstructurasAnidadas);
        add_HashMapEntry(hashmapEstructurasAnidadas, aux, 0);
    }
}