// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
//#include "tablaBck.h" /* Archivo para la tabla de simbolos */

int yystopparser=0;
extern FILE  *yyin; // Tuve que declararlo como extern para que compile

int yyerror();
int yylex();

// extern Tabla tabla;
%}

%token CTE_INT
%token CTE_REAL
%token CTE_STRING
%token ID

%right OP_ASIG
%left OP_DIV OP_MUL OP_MOD
%left OP_RES OP_SUM OP_UN_INC OP_UN_DEC
%right MENOS_UNARIO NEGACION

%token PAR_ABR
%token PAR_CIE
%token PUNTO_COMA
%token COR_ABR            
%token COR_CIE             
%token LLA_ABR             
%token LLA_CIE             
%token COMA             
%token DOS_PUNTOS

%token IF ELSE
%nonassoc MENOS_QUE_ELSE
%nonassoc ELSE 
%token WHILE
%token READ
%token WRITE
%right INIT
%right RET

%token TD_INT        
%token TD_FLOAT          
%token TD_STRING         
%token TD_BOOLEAN        

%token CMP_MAYOR            
%token CMP_MENOR            
%token CMP_MAYOR_IGUAL      
%token CMP_MENOR_IGUAL     
%token CMP_DISTINTO         
%token CMP_ES_IGUAL     

%left OP_AND
%nonassoc OP_OR
%right OP_NOT

%token NUMERAL


%token FN_EQUALEXPRESSIONS
%token FN_ISZERO  

//y := equalExpressions(a + b, 5, b * 2, 3 + 2, a + b)
//Y := isZero( s*7+1-h/2 )   

//if(equalExpressions(a + b, 5, b * 2, 3 + 2, a + b) == TRUE)
//while(isZero( s*7+1-h/2 )  == TRUE)

%%

programa:
    lista_sentencias {printf("    Lista_Sentencias es Programa\n");}
    ;

lista_sentencias:
    def_init {printf("    Def_Init es Lista_Sentencias\n");}
    | sentencia {printf("    Sentencia es Lista_Sentencias\n");}
    | lista_sentencias sentencia {printf("    Lista_Sentencias Sentencia es Lista_Sentencias\n");}
    ;

lista_vars:
    ID {printf("    ID es Lista_Vars\n");}
    | lista_vars COMA ID {printf("    Lista_Vars , ID es Lista_Vars\n");}
    ;

tipo_dato:
    TD_BOOLEAN {printf("    TD_BOOLEAN es Tipo_Dato\n");}
    | TD_INT {printf("    TD_INT es Tipo_Dato\n");}
    | TD_FLOAT {printf("    TD_FLOAT es Tipo_Dato\n");}
    | TD_STRING {printf("    TD_STRING es Tipo_Dato\n");}
    ;

def_lista_vars:
    lista_vars DOS_PUNTOS tipo_dato {printf("    Def_Lista_Vars Lista_Vars es Def_Lista_Vars\n");}
    | def_lista_vars lista_vars DOS_PUNTOS tipo_dato {printf("    Def_Lista_Vars Lista_Vars es Def_Lista_Vars\n");}
    ;

def_init:
    INIT LLA_ABR def_lista_vars LLA_CIE {printf("    INIT { Def_Lista_Vars } es Def_Init\n");}
    ;

sentencia:  	   
	asignacion {printf(" FIN ASIGNACION\n");} 
    | condicional_si {printf(" FIN CONDICIONAL_SI\n");}
    | bucle {printf(" FIN WHILE\n");}
    | llamada_func {printf(" FIN LLAMADA_FUNC\n");}
    | retornar {printf(" FIN RETORNAR\n");}
    | entrada_salida {printf(" FIN RETORNAR\n");}
    | def_lista_vars {printf(" Lista var es sentencia\n");}
    ;

entrada_salida: 
    WRITE PAR_ABR elemento PAR_CIE {printf("    WRITE (elem)  es entrada_salida\n");}
    |  READ PAR_ABR ID PAR_CIE {printf("    READ(ID) es entrada_salida\n");}
	;

elemento: 
    ID {printf("    ID es elemento\n");}
    | CTE_INT {printf("    CTE_INT es elemento\n");}
    | CTE_REAL {printf("    CTE_INT es elemento\n");}
    | CTE_STRING {printf("    CTE_INT es elemento\n");}
	;

asignacion: 
    ID OP_ASIG expresion {printf("    ID := Expresion_Aritmetica es Asignacion\n");}
    | ID OP_UN_INC {printf("    ID++ es Asignacion\n");}
    | ID OP_UN_DEC {printf("    ID-- es Asignacion\n");}
	;

bloque_asociado:
    sentencia {printf("    Sentencia es Bloque_Asociado\n");}
    | LLA_ABR lista_sentencias LLA_CIE {printf("    { Lista_Sentencias } es Bloque_Asociado\n");}
    ;

condicional_si:
    IF PAR_ABR expresion PAR_CIE bloque_asociado %prec MENOS_QUE_ELSE {printf("    if(Expresion) Bloque_Asociado es Condicional_Si\n");}
    | IF PAR_ABR expresion PAR_CIE bloque_asociado ELSE bloque_asociado  {printf("    if(Expresion) Bloque_Asociado else Bloque_Asociado es Condicional_Si\n");}
    ;

expresion: 
    expresion_aritmetica {printf("    Expresion_Aritmetica es Expresion\n");}
    | expresion_relacional {printf("    Expresion_Relacional es Expresion\n");}
    | expresion_logica {printf("    Expresion_Logica es Expresion\n");}
	;

bucle:
    WHILE PAR_ABR expresion PAR_CIE bloque_asociado {printf("    while(Expresion) Bloque_Asociado es Bucle\n");}
    ;

expresion_logica:
    expresion OP_AND expresion {printf("    Expresion AND Expresion es Expresion_Logica\n");}
    | expresion OP_OR expresion {printf("    Expresion OR Expresion es Expresion_Logica\n");}
    | OP_NOT expresion %prec NEGACION {printf("    NOT Expresion es Expresion_Logica\n");}
    ;

expresion_relacional:
    expresion_aritmetica CMP_MAYOR expresion_aritmetica {printf("    Expresion_aritmetica>Expresion_aritmetica es expresion_relacional\n");}
    | expresion_aritmetica CMP_MENOR expresion_aritmetica {printf("    Expresion_aritmetica<Expresion_aritmetica es expresion_relacional\n");}
    | expresion_aritmetica CMP_ES_IGUAL expresion_aritmetica {printf("    Expresion_aritmetica==Expresion_aritmetica es expresion_relacional\n");}
    ;

expresion_aritmetica:
    termino {printf("    Termino es Expresion_Aritmetica\n");}
    | OP_RES expresion_aritmetica %prec MENOS_UNARIO {printf("    - Expresion_Aritmetica es Expresion_aritmetica\n");}
	| expresion_aritmetica OP_SUM termino {printf("    Expresion_aritmetica+Termino es Expresion_aritmetica\n");}
	| expresion_aritmetica OP_RES termino {printf("    Expresion_aritmetica-Termino es Expresion_aritmetica\n");}
    ;

termino: 
    factor {printf("    Factor es Termino\n");}
    | termino OP_MUL factor {printf("     Termino*Factor es Termino\n");}
    | termino OP_DIV factor {printf("     Termino/Factor es Termino\n");}
    | termino OP_MOD factor {printf("     Termino%sFactor es Termino\n","%");}
    ;

factor: 
    ID {printf("    ID es Factor \n");}
    | CTE_INT {printf("    CTE_INT es Factor\n");}
    | PAR_ABR expresion PAR_CIE {printf("    Expresion entre parentesis es Factor\n");}
    | llamada_func {printf("    Llamada_Func es Factor\n");}
    ;

lista_args:
    expresion
    | lista_args COMA expresion {printf("    Lista_Args , ID es Lista_Args \n");}
    ;

llamada_func:
    funcion_especial PAR_ABR lista_args PAR_CIE {printf("    ID(Lista_Args) es Llamada_Func \n");}
    | ID PAR_ABR PAR_CIE {printf("    ID() es Llamada_Func \n");} // Revisar esta regla!!
    ;

funcion_especial:
    FN_EQUALEXPRESSIONS {printf("    FN_EQUALEXPRESSIONS es funcion especial isEqualExpressions\n");}
    | FN_ISZERO {printf("    FN_ISZERO() es funcion especial isZero\n");}
    ;

retornar:
    RET expresion {printf("    RET Expresion es Retornar \n");}
    ;

%%


int main(int argc, char *argv[])
{
    //inicializarTabla(&tabla); 
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else
    { 
        yyparse();
    }
	fclose(yyin);
    
    return 0;
}

int yyerror(void)
{
    printf("Error Sintactico\n");
    exit (1);
}

