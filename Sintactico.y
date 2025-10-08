// Usa Lexico_ClasePractica
//Solo expresion_aritmeticaes sin ()

%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h" 
#include "tabla.h" /* Archivo para la tabla de simbolos */

int yystopparser=0;
extern FILE  *yyin; // Tuve que declararlo como extern para que compile

int yyerror();
int yylex();

%}

%union {
    char* str; 
    int   num;
}

%token <str> ID
%token <str> CTE_STRING
%token <str> CTE_REAL
%token <str> CTE_INT

%token FN_EQUALEXPRESSIONS
%token FN_ISZERO
%token TRUE
%token FALSE

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

%%

programa:
    def_init lista_sentencias {printf("R1. Programa -> Def_Init Lista_Sentencias\n");}
    ;

lista_sentencias:
    //def_init {printf("\t\nR2. Lista_Sentencias -> Def_Init\n");}
    | sentencia {printf("\t\nR3. Lista_Sentencias -> Sentencia\n");}
    | lista_sentencias sentencia {printf("\t\nR4. Lista_Sentencias -> Lista_Sentencias Sentencia\n");}
    ;

tipo_dato:
    TD_BOOLEAN {printf("\t\t\t\tR5. Tipo_Dato -> TD_BOOLEAN\n");}
    | TD_INT {printf("\t\t\t\tR6. Tipo_Dato -> TD_INT\n");}
    | TD_FLOAT {printf("\t\t\t\tR7. Tipo_Dato -> TD_FLOAT\n");}
    | TD_STRING {printf("\t\t\t\tR8. Tipo_Dato -> TD_STRING\n");}
    ;

lista_id:
    ID {printf("\t\t\t\tR9. lista_id -> [ID: '%s']\n", $1); free($1);} 
    | lista_id COMA ID {printf("\t\t\t\tR10. Lista_Id -> lista_id COMA [ID: '%s']\n",$3); free($3);}
    ;

bloque_asig:
    lista_id DOS_PUNTOS tipo_dato {printf("\t\t\tR11. Bloque_Asig -> lista_id : tipo_dato\n");}
    | bloque_asig lista_id DOS_PUNTOS tipo_dato {printf("\t\t\tR12. Bloque_Asig -> Bloque_Asig lista_id : tipo_dato\n");}
    ;

def_init:
    INIT LLA_ABR bloque_asig LLA_CIE {printf("\t\tR13. Def_Init -> INIT { bloque_asig }\n");}
    ;

sentencia:  	   
	asignacion {printf("\t\tR14. sentencia -> Asignacion\n");} 
    | condicional_si {printf("\t\tR15. sentencia -> Condicional_si\n");}
    | bucle {printf("\t\tR16. sentencia -> While\n");}
    | llamada_func {printf("\t\tR17. sentencia -> LLamada_func\n");}
    //| retornar {printf("\t\tR18. sentencia -> retornar\n");}
    | entrada_salida {printf("\t\tR19. sentencia -> entrada_salida\n");}
    ;

entrada_salida: 
    WRITE PAR_ABR factor PAR_CIE {printf("\t\t\tR20. entrada_salida -> WRITE (factor)\n");}
    |  READ PAR_ABR ID PAR_CIE {printf("\t\t\tR21. entrada_salida -> READ([ID: '%s'])\n",$3);free($3);}
	;

asignacion: 
    ID OP_ASIG expresion_aritmetica {printf("\t\t\tR22. Asignacion -> [ID: '%s']:= Expresion_Aritmetica\n",$1);free($1);}
    | ID OP_ASIG Valor_Booleano {printf("\t\t\tR22. Asignacion -> [ID: '%s']:= Valor_Booleano\n",$1);free($1);}
    | ID OP_UN_INC {printf("\t\t\tR23. Asignacion -> [ID: '%s']++\n",$1);free($1);}
    | ID OP_UN_DEC {printf("\t\t\tR24. Asignacion -> [ID: '%s']--\n",$1);free($1);}
    | ID OP_ASIG FALSE {printf("\t\t\tR25. Asignacion -> [ID: '%s'] := Expresion_False\n", $1);free($1);}
    | ID OP_ASIG TRUE {printf("\t\t\tR26. Asignacion -> [ID: '%s'] := Expresion_True\n", $1);free($1);}
	;

bloque_asociado:
    sentencia {printf("\t\t\t\tR27. Bloque_Asociado -> Sentencia\n");}
    | LLA_ABR lista_sentencias LLA_CIE {printf("\t\t\t\tR28. Bloque_Asociado -> { Lista_Sentencias }\n");}
    ;

condicional_si:
    IF PAR_ABR expresion_logica PAR_CIE bloque_asociado %prec MENOS_QUE_ELSE {printf("\t\t\tR29. Condicional_Si -> if(Expresion) Bloque_Asociado\n");}
    | IF PAR_ABR expresion_logica PAR_CIE bloque_asociado ELSE bloque_asociado  {printf("\t\t\tR30. Condicional_Si -> if(Expresion) Bloque_Asociado else Bloque_Asociado\n");}
    ;

expresion: 
    expresion_aritmetica {printf("\t\t\t\tR31. Expresion -> Expresion_Aritmetica\n");}
    | expresion_relacional {printf("\t\t\t\tR32. Expresion -> Expresion_Relacional\n");}
    | expresion_logica {printf("\t\t\t\tR33. Expresion -> Expresion_Logica\n");}
	;

bucle:
    WHILE PAR_ABR expresion_logica PAR_CIE bloque_asociado {printf("\t\t\tR34. Bucle -> while(Expresion) Bloque_Asociado\n");}
    ;

expresion_logica:
    expresion_para_condicion OP_AND expresion_para_condicion {printf("\t\t\t\t\tR35. Expresion_Logica -> Expresion AND Expresion\n");}
    | expresion_para_condicion OP_OR expresion_para_condicion {printf("\t\t\t\t\tR36. Expresion_Logica -> Expresion OR Expresion\n");}
    | OP_NOT expresion_para_condicion %prec NEGACION {printf("\t\t\t\t\tR37. Expresion_Logica -> NOT Expresion\n");}
    | expresion_para_condicion {printf("\t\t\t\t\tR38. Expresion_Logica -> Valor_Booleano\n");}
    ;

 Valor_Booleano:   
    llamada_func {printf("\t\t\t\t\t\t\tR54. Factor -> Llamada_Func\n");}
    | TRUE {printf("\t\t\t\t\tR34. Valor_Booleano -> TRUE\n");}
    | FALSE {printf("\t\t\t\t\tR35. Valor_Booleano -> FALSE\n");}
    ;

expresion_para_condicion:
    Valor_Booleano | expresion_relacional;

expresion_relacional:
    expresion_aritmetica CMP_MAYOR expresion_aritmetica {printf("\t\t\t\t\tR38. expresion_relacional -> Expresion_aritmetica > Expresion_aritmetica\n");}
    | expresion_aritmetica CMP_MENOR expresion_aritmetica {printf("\t\t\t\t\tR39. expresion_relacional -> Expresion_aritmetica < Expresion_aritmetica\n");}
    | expresion_aritmetica CMP_ES_IGUAL expresion_aritmetica {printf("\t\t\t\t\tR40. expresion_relacional -> Expresion_aritmetica == Expresion_aritmetica\n");}
    | expresion_aritmetica CMP_MAYOR_IGUAL expresion_aritmetica {printf("\t\t\t\t\tR40. expresion_relacional -> Expresion_aritmetica >= Expresion_aritmetica\n");}
    | expresion_aritmetica CMP_MENOR_IGUAL expresion_aritmetica {printf("\t\t\t\t\tR40. expresion_relacional -> Expresion_aritmetica <= Expresion_aritmetica\n");}
    ;
    
expresion_aritmetica:
    termino {printf("\t\t\t\t\tR41. Expresion_Aritmetica -> Termino\n");}
    | OP_RES expresion_aritmetica %prec MENOS_UNARIO {printf("\t\t\t\t\tR42. Expresion_aritmetica -> - Expresion_Aritmetica\n");}
	| expresion_aritmetica OP_SUM termino {printf("\t\t\t\t\tR43. Expresion_aritmetica -> Expresion_aritmetica + Termino\n");}
	| expresion_aritmetica OP_RES termino {printf("\t\t\t\t\tR44. Expresion_aritmetica -> Expresion_aritmetica - Termino\n");}
    ;

termino:
    factor {printf("\t\t\t\t\t\tR45. Termino -> Factor\n");}
    | termino OP_MUL factor {printf("\t\t\t\t\t\tR46. Termino -> Termino * Factor\n");}
    | termino OP_DIV factor {printf("\t\t\t\t\t\tR47. Termino -> Termino / Factor\n");}
    | termino OP_MOD factor {printf("\t\t\t\t\t\tR48. Termino -> Termino % Factor\n");}
    ;

factor: 
    ID {printf("\t\t\t\t\t\t\tR49. Factor -> [ID: '%s']\n", $1); free($1);}
    | CTE_INT {printf("\t\t\t\t\t\t\tR50. Factor -> [CTE_INT: '%s']\n",$1);free($1);}
    | CTE_REAL {printf("\t\t\t\t\t\t\tR51. Factor -> [CTE_REAL: '%s']\n", $1); free($1);}
    | PAR_ABR expresion_aritmetica PAR_CIE {printf("\t\t\t\t\t\t\tR52. Factor -> Expresion entre parentesis\n");}
    | CTE_STRING {printf("\t\t\t\t\t\t\tR53. Factor -> [CTE_STRING: %s]\n", $1); free($1);} 
    //| llamada_func {printf("\t\t\t\t\t\t\tR54. Factor -> Llamada_Func\n");}
    ;

lista_args:
    expresion {printf("\t\t\t\tR55. lista_args -> expresion\n");}
    | lista_args COMA expresion {printf("\t\t\t\tR56. lista_args -> lista_args , expresion \n");}
    ;

llamada_func:
    FN_EQUALEXPRESSIONS PAR_ABR lista_args PAR_CIE {printf("\t\t\tR57. Llamada_Func -> funcion_especial(Lista_Args)\n");}
    | FN_ISZERO PAR_ABR expresion PAR_CIE {printf("\t\t\tR58. Llamada_Func -> funcion_especial(Lista_Args)\n");}
    //| ID PAR_ABR PAR_CIE {printf("\t\t\tR59. Llamada_Func -> [ID: '%s']()\n", $1); free($1);}
    ;

//retornar:
    //RET expresion {printf("\t\t\tR60. Retornar -> RET Expresion\n");}
//    ;

%%

Tabla tabla;

int main(int argc, char *argv[])
{
    printf("\n-----------------------------------------------------------------------------------------------------------------\n");
    printf("                                        INICIO PROCESO ANALISIS SINTACTICO                                        ");
    printf("\n-----------------------------------------------------------------------------------------------------------------\n");

    iniciar_tabla(&tabla); 
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
    }
    else
    { 
        yyparse();
    }
	fclose(yyin);

    printf("\n-----------------------------------------------------------------------------------------------------------------\n");
    printf("                                     LA SINTAXIS DEL PROGRAMA ES CORRECTA                                            ");
    printf("\n-----------------------------------------------------------------------------------------------------------------\n");
    
    return 0;
}

int yyerror(void)
{
    printf("Error Sintactico\n");
    exit (1);
}