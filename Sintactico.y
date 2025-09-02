// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
int yystopparser=0;
FILE  *yyin;

int yyerror();
int yylex();


%}

%token CTE_INT
%token CTE_REAL_POS
%token CTE_STRING
%token ID

%right OP_ASIG
%left OP_SUM
%left OP_MUL
%left OP_RES
%left OP_DIV
%left OP_MOD

%left OP_UN_INC
%left OP_UN_DEC

%token PAR_ABR
%token PAR_CIE
%token PUNTO_COMA
%token COR_ABR            
%token COR_CIE             
%token LLA_ABR             
%token LLA_CIE             
%token COMA             


%token IF
%token WHILE
%token ELSE
%token READ
%token WRITE
%token INIT

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

%token OP_AND
%token OP_OR
%token OP_NOT

%token NUMERAL

%%

programa:
    lista_sentencias
    ;

lista_sentencias:
    lista_sentencias sentencia
    | sentencia
    ;

sentencia:  	   
	asignacion {printf(" FIN ASIGNACION\n");} 
    | condicional_si {printf(" FIN CONDICIONAL_SI\n");}
    | bucle {printf(" FIN WHILE\n");}
    | llamada_func {printf(" FIN LLAMADA_FUNC\n");}
    ;

asignacion: 
    ID OP_ASIG expresion {printf("    ID = Expresion es Asignacion\n");}
	;

condicional_si:
    IF PAR_ABR condicion PAR_CIE sentencia  %prec LOWER_THAN_ELSE  {printf("    if(Condicion) Sentencia es Condicional_Si\n");}
    | IF PAR_ABR condicion PAR_CIE LLA_ABR lista_sentencias LLA_CIE  {printf("    if(Condicion) {Lista_Sentencias} es Condicional_Si\n");}
    | IF PAR_ABR condicion PAR_CIE sentencia ELSE sentencia {printf("    if(Condicion) Sentencia else Sentencia es Condicional_Si\n");}
    | IF PAR_ABR condicion PAR_CIE LLA_ABR lista_sentencias LLA_CIE ELSE sentencia {printf("    if(Condicion) Lista_Sentencias else Sentencia es Condicional_Si\n");}
    | IF PAR_ABR condicion PAR_CIE LLA_ABR lista_sentencias LLA_CIE ELSE LLA_ABR lista_sentencias LLA_CIE {printf("    if(Condicion) Lista_Sentencias else Lista_Sentencias es Condicional_Si\n");}
    ;

condicion: 
    expresion {printf("    Expresion es Condicion\n");}
    | comparacion {printf("    Comparacion es Condicion\n");}
	;

bucle:
    WHILE PAR_ABR condicion PAR_CIE sentencia {printf("    while(Condicion) Sentencia es Bucle\n");}
    | WHILE PAR_ABR condicion PAR_CIE LLA_ABR lista_sentencias LLA_CIE {printf("    while(Condicion) {Lista_Sentencias} es Bucle\n");}
    ;

comparacion:
    expresion CMP_MAYOR expresion {printf("    Expresion>Expresion es Comparacion\n");}
    | expresion CMP_MENOR expresion {printf("    Expresion<Expresion es Comparacion\n");}
    | expresion CMP_ES_IGUAL expresion {printf("    Expresion==Expresion es Comparacion\n");}
    ;

expresion:
    termino {printf("    Termino es Expresion\n");}
	| expresion OP_SUM termino {printf("    Expresion+Termino es Expresion\n");}
	| expresion OP_RES termino {printf("    Expresion-Termino es Expresion\n");}
    ;

termino: 
    factor {printf("    Factor es Termino\n");}
    | termino OP_MUL factor {printf("     Termino*Factor es Termino\n");}
    | termino OP_DIV factor {printf("     Termino/Factor es Termino\n");}
    | termino OP_MOD factor {printf("     Termino%Factor es Termino\n");}
    ;

factor: 
    ID {printf("    ID es Factor \n");}
    | CTE_INT {printf("    CTE_INT es Factor\n");}
	| PAR_ABR expresion PAR_CIE {printf("    Expresion entre parentesis es Factor\n");}
    ;

lista_args:
    ID {printf("    ID es Lista_Args \n");}
    | lista_args COMA ID {printf("    Lista_Args , ID es Lista_Args \n");}
    ;

llamada_func:
    ID PAR_ABR lista_args PAR_CIE {printf("    ID(Lista_Args) es Llamada_Func \n");}
    ;

%%


int main(int argc, char *argv[])
{
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

