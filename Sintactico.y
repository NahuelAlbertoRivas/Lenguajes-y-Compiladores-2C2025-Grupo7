// Usa Lexico_ClasePractica
//Solo expresion_aritmeticaes sin ()

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "y.tab.h"
#include "tabla.h" /* Archivo para la tabla de simbolos */
#include "Tercetos.h" /* Archivo para la tabla de simbolos */
#include "utilidades/pila.h"
#include "utilidades/hashmap.h"
#include "utilidades/acciones_semanticas.h"

#define VERDADERO   1
#define FALSO       0
#define CAMPO_NULO SHRT_MIN

#define HASHMAP_SIZE 10
#define ERROR_APERTURA_ARCHIVO -213
#define PROCESO_EXITOSO 0

int yystopparser=0;
extern FILE  *yyin; // Tuve que declararlo como extern para que compile

int yyerror();
int yylex();

int validar_existencia_id(const char *id);
int verificar_tipo_resultado_asignado(const char *id, const char *tipo_esperado);
int acciones_definicion_variable(const char *id, int codValidacion);
int acciones_asignacion_tipo(const char *tipoDato);
int acciones_asignacion_variable_general(const char *id, int codValidacion, const char *tipoResultado);
int acciones_asignacion_literal(const char *id, int codValidacionId, int codValCadenaAsignada);
int acciones_definicion_tipo_retorno(const char *id, int codValidacion);
int acciones_verificacion_compatibilidad_tipo(int codValidacion, const char *tipoCte);
int acciones_parametro_read(const char *id, int codValidacion);
void tercetos_expresion_condicion_AND();

int ProgramaInd;
int DefInitInd;
int BloqueAsigInd;
int ListaIdInd;
int TipoDatoInd;
int ListaSentenciasInd;
int SentenciaInd;
int AsignacionInd;
int CondicionalSiInd;
int BloqueAsociadoInd;
int BucleInd;
int LlamadaFuncInd;
int ListaArgsInd;
int EntradaSalidaInd;
int ExpresionInd;
int ExpresionLogicaInd;
int ExpresionparaCondicionInd;
int ValorBooleanoInd;
int ExpresionRelacionalInd;
int ExpresionAritmeticaInd;
int TerminoInd;
int FactorInd;

// Indices Auxiliares (Para expresiones dobles)
int ExpresionAritmeticaInd2;

int ExpresionParaCondicionInd2;

int BloqueAsociadoInd2;

int Xind; //Auxiliar para los tipos de datos

/*
char ETDind[MAX_LONG_TD]; //Tipo de Dato Expresión
char TTDind[MAX_LONG_TD]; //Tipo de Dato Término
char FTDind[MAX_LONG_TD]; //Tipo de Dato Factor
*/

int _contadorSentencias;
int _resExpRelacional;
int _resExpresionLogica;
int _saltoCeldas;
int _tercetoNoDefinido;
const char *_tipoDatoExpresionActual;

%}

%union {
    struct {
        char* str;
        int codValidacion;
    } datosToken;
    int   num;
}

%token <datosToken> ID
%token <datosToken> CTE_STRING
%token <datosToken> CTE_REAL
%token <datosToken> CTE_INT

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

%token <datosToken> TD_INT        
%token <datosToken> TD_FLOAT          
%token <datosToken> TD_STRING         
%token <datosToken> TD_BOOLEAN        

%token CMP_MAYOR            
%token CMP_MENOR            
%token CMP_MAYOR_IGUAL      
%token CMP_MENOR_IGUAL     
%token CMP_DISTINTO         
%token CMP_ES_IGUAL     

%left OP_AND
%nonassoc OP_OR
%right OP_NOT

%%

programa:
    def_init lista_sentencias
    {
        ProgramaInd = crearTerceto(" ", DefInitInd, ListaSentenciasInd);
        printf("R1. Programa -> Def_Init Lista_Sentencias\n");
    }
    ;
    
def_init:
    INIT LLA_ABR bloque_asig LLA_CIE
    {
        DefInitInd = BloqueAsigInd;
        printf("\t\tR2. Def_Init -> init { Bloque_Asig }\n");
    }
    ;

bloque_asig:
    lista_id DOS_PUNTOS tipo_dato
    {
        BloqueAsigInd = crearTerceto(":", ListaIdInd, TipoDatoInd);
        printf("\t\t\tR3. Bloque_Asig -> Lista_Id : Tipo_Dato\n");
    }
    | bloque_asig lista_id DOS_PUNTOS tipo_dato
    {
        BloqueAsigInd = crearTerceto(" ", BloqueAsigInd, ListaIdInd);
        printf("\t\t\tR4. Bloque_Asig -> Bloque_Asig Lista_Id : Tipo_Dato\n");
    }
    ;

lista_id:
    ID
    {
        if(acciones_definicion_variable($1.str, $1.codValidacion) != ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
        ListaIdInd = crearTercetoUnitarioStr($1.str);
        printf("\t\t\t\tR5. Lista_Id -> [ID: '%s']\n", $1.str);
        free($1.str);
    } 
    | lista_id COMA ID 
    {
        if(acciones_definicion_variable($3.str, $3.codValidacion) != ACCION_EXITOSA)
        {
            YYABORT;
        } 
        ListaIdInd = crearTerceto(", ", ListaIdInd, crearTercetoUnitarioStr($3.str));
        printf("\t\t\t\tR6. Lista_Id -> Lista_Id COMA [ID: '%s']\n",$3.str); 
        free($3.str);
    }
    ;

tipo_dato:
    TD_BOOLEAN 
    {
        TipoDatoInd = crearTercetoUnitarioStr(DBOOLEAN);
        printf("\t\t\t\tR7. Tipo_Dato -> %s\n", $1.str); 
        if(acciones_asignacion_tipo($1.str) != ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
    }
    | TD_INT 
    {
        TipoDatoInd = crearTercetoUnitarioStr(DINTEGER);
        if(acciones_asignacion_tipo($1.str) != ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
        printf("\t\t\t\tR8. Tipo_Dato -> %s\n", $1.str);
        free($1.str); 
    }
    | TD_FLOAT 
    {
        TipoDatoInd = crearTercetoUnitarioStr(DFLOAT);
        printf("\t\t\t\tR9. Tipo_Dato -> %s\n", $1.str); 
        if(acciones_asignacion_tipo($1.str) != ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
    }
    | TD_STRING 
    {
        TipoDatoInd = crearTercetoUnitarioStr(DSTRING);
        if(acciones_asignacion_tipo($1.str)!=ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
        printf("\t\t\t\tR10. Tipo_Dato -> %s\n", $1.str);
        free($1.str);
    }
    ;

lista_sentencias:
    sentencia 
    {
        ListaSentenciasInd = SentenciaInd;
        _contadorSentencias = 1;
        printf("\t\nR11. Lista_Sentencias -> Sentencia\n");
    }
    | lista_sentencias sentencia 
    {
        ListaSentenciasInd = crearTerceto(" ", ListaSentenciasInd, SentenciaInd);
        _contadorSentencias++;
        printf("\t\nR12. Lista_Sentencias -> Lista_Sentencias Sentencia\n");
    }
    ;

sentencia:  	   
	asignacion 
    {
        SentenciaInd = AsignacionInd;
        printf("\t\tR13. Sentencia -> Asignacion\n");
    } 
    | condicional_si 
    {
        SentenciaInd = CondicionalSiInd;
        printf("\t\tR14. Sentencia -> Condicional_Si\n");
    }
    | bucle 
    {
        SentenciaInd = BucleInd;
        printf("\t\tR15. Sentencia -> While\n");
    }
    | llamada_func 
    {
        SentenciaInd = LlamadaFuncInd;
        printf("\t\tR16. Sentencia -> LLamada_Func\n");
    }
    | entrada_salida 
    {
        SentenciaInd = EntradaSalidaInd;
        printf("\t\tR17. sentencia -> entrada_salida\n");
    }
    ;

asignacion: 
    ID OP_ASIG expresion_aritmetica 
    {
        if(acciones_asignacion_variable_general($1.str, $1.codValidacion, _tipoDatoExpresionActual) != ACCION_EXITOSA)
        {
            free($1.str); 
            YYABORT;
        }
        AsignacionInd = crearTerceto(":=", crearTercetoUnitarioStr($1.str), ExpresionAritmeticaInd);
        printf("\t\t\tR18. Asignacion -> [ID: '%s']:= Expresion_Aritmetica\n",$1.str);
        free($1.str);
    }
    | ID OP_ASIG valor_booleano 
    {
        if(acciones_asignacion_variable_general($1.str, $1.codValidacion, DBOOLEAN) != ACCION_EXITOSA)
        {
            free($1.str); 
            YYABORT;
        }
        AsignacionInd = crearTerceto(":=", crearTercetoUnitarioStr($1.str), ValorBooleanoInd);
        printf("\t\t\tR19. Asignacion -> [ID: '%s']:= valor_booleano\n", $1.str);
        free($1.str);
    }
    | ID OP_UN_INC 
    {
        if(acciones_asignacion_variable_general($1.str, $1.codValidacion, DINTEGER)!=ACCION_EXITOSA)
        {
            free($1.str); 
            YYABORT;
        }
        AsignacionInd = crearTerceto("++", crearTercetoUnitarioStr($1.str), CAMPO_NULO);
        printf("\t\t\tR20. Asignacion -> [ID: '%s']++\n",$1.str);
        free($1.str);
    }
    | ID OP_UN_DEC 
    {
        if(acciones_asignacion_variable_general($1.str, $1.codValidacion, DINTEGER)!=ACCION_EXITOSA)
        {
            free($1.str); 
            YYABORT;
        }
        AsignacionInd = crearTerceto("--", crearTercetoUnitarioStr($1.str), CAMPO_NULO);
        printf("\t\t\tR21. Asignacion -> [ID: '%s']--\n",$1.str);
        free($1.str);
    }
    | ID OP_ASIG CTE_STRING 
    {
        if(acciones_asignacion_literal($1.str, $1.codValidacion, $3.codValidacion)!=ACCION_EXITOSA)
        {
            if($1.str)
            {
                free($1.str);
            }
            if($3.str)
            {
                free($1.str);
            }
            YYABORT;
        }
        AsignacionInd = crearTerceto(":=", crearTercetoUnitarioStr($1.str), crearTercetoUnitarioStr($3.str));
        printf("\t\t\tR22. Asignacion -> [ID: '%s']:= \"%s\"\n", $1.str, $3.str);
        free($1.str);
        free($3.str);
    }
	;

condicional_si:
    IF PAR_ABR expresion_logica PAR_CIE bloque_asociado %prec MENOS_QUE_ELSE
    {
        crearTerceto(":=", _resExpresionLogica, ExpresionLogicaInd);
        Xind = crearTerceto("CMP", _resExpresionLogica, 1);
        crearTerceto("BNE", _saltoCeldas, CAMPO_NULO);
        crearTerceto("if", ExpresionLogicaInd, BloqueAsociadoInd2);
        modificarOperandoIzquierdoConTerceto(Xind, _contadorSentencias + 1);
        printf("\t\t\tR22. Condicional_Si -> if(Expresion) Bloque_Asociado\n");
    }
    | IF PAR_ABR expresion_logica PAR_CIE bloque_asociado ELSE bloque_asociado
    {
        crearTerceto(":=", _resExpresionLogica, ExpresionLogicaInd);
        Xind = crearTerceto("CMP", _resExpresionLogica, 1);
        crearTerceto("BNE", _saltoCeldas, CAMPO_NULO);
        crearTerceto("if", ExpresionLogicaInd, BloqueAsociadoInd2);
        modificarOperandoIzquierdoConTerceto(Xind, _contadorSentencias + 1);
        crearTerceto("else", BloqueAsociadoInd2, BloqueAsigInd);
        modificarOperandoIzquierdoConTerceto(Xind, _contadorSentencias + 1);
        printf("\t\t\tR23. Condicional_Si -> if(Expresion) Bloque_Asociado else Bloque_Asociado\n");
    }
    ;

bloque_asociado:
    sentencia 
    {
        BloqueAsociadoInd2 = BloqueAsociadoInd;
        BloqueAsociadoInd = SentenciaInd;
        _contadorSentencias = 1;
        printf("\t\t\t\tR24. Bloque_Asociado -> Sentencia\n");
    }
    | LLA_ABR lista_sentencias LLA_CIE 
    {
        BloqueAsociadoInd2 = BloqueAsociadoInd;
        BloqueAsociadoInd = ListaSentenciasInd;
        _contadorSentencias++;
        printf("\t\t\t\tR25. Bloque_Asociado -> { Lista_Sentencias }\n");
    }
    ;

bucle:
    WHILE PAR_ABR expresion_logica 
    {
        crearTerceto(":=", _resExpresionLogica, ExpresionLogicaInd);
        Xind = crearTerceto("CMP", _resExpresionLogica, 1);
        crearTerceto("BNE", _saltoCeldas, CAMPO_NULO);
    }
    PAR_CIE bloque_asociado
    {
        crearTerceto("while", ExpresionLogicaInd, BloqueAsociadoInd2);
        modificarOperandoIzquierdoConTerceto(Xind, _contadorSentencias + 1);
        printf("\t\t\tR26. Bucle -> while(Expresion) Bloque_Asociado\n");
    }
    ;

llamada_func:
    FN_EQUALEXPRESSIONS PAR_ABR lista_args PAR_CIE 
    {
        LlamadaFuncInd = crearTerceto("equalExpressions", ListaArgsInd, CAMPO_NULO);
        printf("\t\t\tR27. Llamada_Func -> funcion_especial(Lista_Args)\n");
    }
    | FN_ISZERO PAR_ABR expresion PAR_CIE 
    {
        LlamadaFuncInd = crearTerceto("equalExpressions", ExpresionInd, CAMPO_NULO);
        printf("\t\t\tR28. Llamada_Func -> funcion_especial(Lista_Args)\n");
    }
    ;

lista_args:
    expresion 
    {
        ListaArgsInd = ExpresionInd;
        printf("\t\t\t\tR29. lista_args -> expresion\n");
    }
    | lista_args COMA expresion 
    {
        ListaArgsInd = crearTerceto(", ", ListaArgsInd, ExpresionInd);
        printf("\t\t\t\tR30. lista_args -> lista_args , expresion \n");
    }
    ;

entrada_salida: 
    WRITE PAR_ABR factor PAR_CIE 
    {
        EntradaSalidaInd = 
        printf("\t\t\tR31. entrada_salida -> WRITE (factor)\n");
    }
    | WRITE PAR_ABR CTE_STRING PAR_CIE 
    {
        if($3.codValidacion!=VALIDACION_OK)
        {
            YYABORT;
        } 
        printf("\t\t\tR31. entrada_salida -> WRITE (CTE_STRING)\n");
    }
    | READ PAR_ABR ID PAR_CIE 
    {
        if(acciones_parametro_read($3.str, $3.codValidacion)!=ACCION_EXITOSA)
        {
            if($3.str)
            {
                free($3.str);
            } 
            YYABORT;
        } 
        printf("\t\t\tR32. entrada_salida -> READ([ID: '%s'])\n",$3.str);
        free($3.str);
    }
	;

expresion: 
    expresion_aritmetica 
    {
        ExpresionInd = ExpresionAritmeticaInd;
        printf("\t\t\t\tR33. Expresion -> Expresion_Aritmetica\n");
    }
    | expresion_logica 
    {
        ExpresionInd = ExpresionLogicaInd;
        printf("\t\t\t\tR34. Expresion -> Expresion_Logica\n");
    }
	;

expresion_logica:
    expresion_para_condicion OP_AND expresion_para_condicion 
    {
        ExpresionLogicaInd = crearTerceto("AND", ExpresionParaCondicionInd2, ExpresionparaCondicionInd);
        Xind = crearTerceto("+", ExpresionParaCondicionInd2, ExpresionparaCondicionInd);
        crearTerceto(":=", _resExpresionLogica, Xind);
        crearTerceto("CMP", _resExpresionLogica, 2);
        crearTerceto("BNE", Xind + 6, CAMPO_NULO);
        crearTerceto(":=", _resExpresionLogica, VERDADERO);
        crearTerceto("BI", Xind + 7, CAMPO_NULO);
        crearTerceto(":=", _resExpresionLogica, FALSO);
        printf("\t\t\t\t\tR35. Expresion_Logica -> Expresion AND Expresion\n");
    }
    | expresion_para_condicion OP_OR expresion_para_condicion 
    {
        ExpresionLogicaInd = crearTerceto("OR", ExpresionParaCondicionInd2, ExpresionparaCondicionInd);
        Xind = crearTerceto("+", ExpresionParaCondicionInd2, ExpresionparaCondicionInd);
        crearTerceto(":=", _resExpresionLogica, Xind);
        crearTerceto("CMP", _resExpresionLogica, 1);
        crearTerceto("BLT", Xind + 6, CAMPO_NULO);
        crearTerceto(":=", _resExpresionLogica, VERDADERO); 
        crearTerceto("BI", Xind + 7, CAMPO_NULO);
        crearTerceto(":=", _resExpresionLogica, FALSO);
        printf("\t\t\t\t\tR36. Expresion_Logica -> Expresion OR Expresion\n");
    }
    | OP_NOT expresion_para_condicion %prec NEGACION 
    {
        ExpresionLogicaInd = crearTerceto("NOT", ExpresionparaCondicionInd, CAMPO_NULO);
        Xind = crearTerceto(":=", _resExpresionLogica, ExpresionparaCondicionInd);
        crearTerceto("CMP", _resExpresionLogica, 0);
        crearTerceto("BNE", Xind + 5, CAMPO_NULO);
        crearTerceto(":=", _resExpresionLogica, VERDADERO); 
        crearTerceto("BI", Xind + 6, CAMPO_NULO);
        crearTerceto(":=", _resExpresionLogica, FALSO);
        printf("\t\t\t\t\tR37. Expresion_Logica -> NOT Expresion\n");
    }
    | expresion_para_condicion 
    {
        ExpresionLogicaInd = ExpresionparaCondicionInd;
        Xind = crearTerceto(":=", _resExpresionLogica, ExpresionparaCondicionInd);
        crearTerceto("CMP", _resExpresionLogica, 1);
        crearTerceto("BNE", Xind + 5, CAMPO_NULO);
        crearTerceto(":=", _resExpresionLogica, VERDADERO); 
        crearTerceto("BI", Xind + 6, CAMPO_NULO);
        crearTerceto(":=", _resExpresionLogica, FALSO);
        printf("\t\t\t\t\tR38. Expresion_Logica -> valor_booleano\n");
    }
    ;

expresion_para_condicion:
    valor_booleano 
    {
        ExpresionParaCondicionInd2 = ExpresionparaCondicionInd;
        ExpresionparaCondicionInd = ValorBooleanoInd;
        printf("\t\t\t\t\tR39. Expresion_Para_Condicion -> Valor_Booleano\n");
    }
    | expresion_relacional 
    {
        ExpresionParaCondicionInd2 = ExpresionparaCondicionInd;
        ExpresionparaCondicionInd = ExpresionRelacionalInd;
        printf("\t\t\t\t\tR40. Expresion_Para_Condicion -> Expresion_Relacional\n");
    }
    ;

valor_booleano:   
    llamada_func 
    {
        ValorBooleanoInd = LlamadaFuncInd;
        printf("\t\t\t\t\t\t\tR41. Valor_Booleano -> Llamada_Func\n");
    }
    | TRUE 
    {
        ValorBooleanoInd = crearTercetoUnitarioStr("true");
        printf("\t\t\t\t\tR42. Valor_Booleano -> TRUE\n");
    }
    | FALSE 
    {
        ValorBooleanoInd = crearTercetoUnitarioStr("false");
        printf("\t\t\t\t\tR43. Valor_Booleano -> FALSE\n");
    }
    ;

expresion_relacional:
    expresion_aritmetica CMP_MAYOR expresion_aritmetica 
    {
        Xind = crearTerceto("CMP", ExpresionAritmeticaInd2, ExpresionAritmeticaInd);
        ExpresionRelacionalInd = Xind;
        crearTerceto("BLE", Xind + 4, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, VERDADERO);
        crearTerceto("BI", Xind + 5, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, FALSO);
        printf("\t\t\t\t\tR44. Expresion_Relacional -> Expresion_Aritmetica > Expresion_Aritmetica\n");
    }
    | expresion_aritmetica CMP_MENOR expresion_aritmetica 
    {
        Xind = crearTerceto("CMP", ExpresionAritmeticaInd2, ExpresionAritmeticaInd);
        ExpresionRelacionalInd = Xind;
        crearTerceto("BGE", Xind + 4, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, VERDADERO);
        crearTerceto("BI", Xind + 5, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, FALSO);
        printf("\t\t\t\t\tR45. Expresion_Relacional -> Expresion_Aritmetica < Expresion_Aritmetica\n");
    }
    | expresion_aritmetica CMP_ES_IGUAL expresion_aritmetica 
    {
        Xind = crearTerceto("CMP", ExpresionAritmeticaInd2, ExpresionAritmeticaInd);
        ExpresionRelacionalInd = Xind;
        crearTerceto("BNE", Xind + 4, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, VERDADERO);
        crearTerceto("BI", Xind + 5, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, FALSO);
        printf("\t\t\t\t\tR46. Expresion_Relacional -> Expresion_Aritmetica == Expresion_Aritmetica\n");
    }
    | expresion_aritmetica CMP_MAYOR_IGUAL expresion_aritmetica 
    {
        Xind = crearTerceto("CMP", ExpresionAritmeticaInd2, ExpresionAritmeticaInd);
        ExpresionRelacionalInd = Xind;
        crearTerceto("BLT", Xind + 4, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, VERDADERO);
        crearTerceto("BI", Xind + 5, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, FALSO);
        printf("\t\t\t\t\tR47. Expresion_Relacional -> Expresion_Aritmetica >= Expresion_Aritmetica\n");
    }
    | expresion_aritmetica CMP_MENOR_IGUAL expresion_aritmetica 
    {
        Xind = crearTerceto("CMP", ExpresionAritmeticaInd2, ExpresionAritmeticaInd);
        ExpresionRelacionalInd = Xind;
        crearTerceto("BGT", Xind + 4, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, VERDADERO);
        crearTerceto("BI", Xind + 5, CAMPO_NULO);
        crearTerceto(":=", _resExpRelacional, FALSO);
        printf("\t\t\t\t\tR48. Expresion_Relacional -> Expresion_Aritmetica <= Expresion_Aritmetica\n");
    }
    ;
    
expresion_aritmetica:
    termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        ExpresionAritmeticaInd = TerminoInd;
        printf("\t\t\t\t\tR49. Expresion_Aritmetica -> Termino\n");
    }
    | OP_RES expresion_aritmetica %prec MENOS_UNARIO 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        ExpresionAritmeticaInd = crearTerceto("-", ExpresionAritmeticaInd, TerminoInd);
        printf("\t\t\t\t\tR50. Expresion_Aritmetica -> - Expresion_Aritmetica\n");
    }
	| expresion_aritmetica OP_SUM termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        ExpresionAritmeticaInd = crearTerceto("+", ExpresionAritmeticaInd, TerminoInd);
        printf("\t\t\t\t\tR51. Expresion_Aritmetica -> Expresion_Aritmetica + Termino\n");
    }
	| expresion_aritmetica OP_RES termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        ExpresionAritmeticaInd = crearTerceto("-", ExpresionAritmeticaInd, TerminoInd);
        printf("\t\t\t\t\tR52. Expresion_Aritmetica -> Expresion_Aritmetica - Termino\n");
    }
    ;

termino:
    factor 
    {
        printf("\t\t\t\t\t\tR53. Termino -> Factor\n");
        TerminoInd = FactorInd;
    }
    | termino OP_MUL factor 
    {
        printf("\t\t\t\t\t\tR54. Termino -> Termino * Factor\n");
        TerminoInd = crearTerceto("*", TerminoInd, FactorInd);
    }
    | termino OP_DIV factor 
    {
        printf("\t\t\t\t\t\tR55. Termino -> Termino / Factor\n");
        TerminoInd = crearTerceto("/", TerminoInd, FactorInd);
    }
    | termino OP_MOD factor 
    {
        printf("\t\t\t\t\t\tR56. Termino -> Termino % Factor\n");
        TerminoInd = crearTerceto("%", TerminoInd, FactorInd);
    }
    ;

factor: 
    ID 
    {
        if(acciones_verificacion_compatibilidad_tipo($1.codValidacion, NULL) != ACCION_EXITOSA)
        {
            if($1.str)
            {
                free($1.str);
            } 
            YYABORT;
        }
        FactorInd = crearTercetoUnitarioStr($1.str);
        printf("\t\t\t\t\t\t\tR57. Factor -> [ID: '%s']\n", $1.str); 
        free($1.str);
    }
    | CTE_INT 
    {
        if(acciones_verificacion_compatibilidad_tipo($1.codValidacion, DINTEGER) != ACCION_EXITOSA)
        {
            if($1.str)
            {
                free($1.str);
            } 
            YYABORT;
        }
        FactorInd = crearTercetoUnitarioStr($1.str);
        printf("\t\t\t\t\t\t\tR58. Factor -> [CTE_INT: '%s']\n", $1.str); 
        free($1.str);
    }
    | CTE_REAL 
    {
        if(acciones_verificacion_compatibilidad_tipo($1.codValidacion, DFLOAT) != ACCION_EXITOSA)
        {
            if($1.str)
            {
                free($1.str);
            } 
            YYABORT;
        }
        FactorInd = crearTercetoUnitarioStr($1.str);
        printf("\t\t\t\t\t\t\tR59. Factor -> [CTE_REAL: '%s']\n", $1.str); 
        free($1.str);
    }
    | PAR_ABR expresion PAR_CIE 
    {
        printf("\t\t\t\t\t\t\tR60. Factor -> (Expresion)\n");
    }
    ;

%%

Tabla tabla;
HashMap *hashmap;
tPila pilaVars;
FILE *ptercetos;

int main(int argc, char *argv[])
{
    hashmap = create_HashMap(HASHMAP_SIZE);
    crear_pila(&pilaVars);
    tVar tmp;

    printf("\n-----------------------------------------------------------------------------------------------------------------\n");
    printf("                                        INICIO PROCESO ANALISIS SINTACTICO                                        ");
    printf("\n-----------------------------------------------------------------------------------------------------------------\n");

    iniciar_tabla(&tabla);
    _tipoDatoExpresionActual = NULL;
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
        return ERROR_APERTURA_ARCHIVO;
    }
    
    if(yyparse() == PROCESO_EXITOSO)
    {
        printf("\n-----------------------------------------------------------------------------------------------------------------\n");
        printf("                                     LA SINTAXIS DEL PROGRAMA ES CORRECTA                                            ");
        printf("\n-----------------------------------------------------------------------------------------------------------------\n");
    }
    mostrar_tabla(&tabla);

    guardar_tabla_en_archivo(&tabla, "Symbol-Table.txt");
    printf("\n\nFinalizando recursos y saliendo...\n\n");
	fclose(yyin);
    vaciar_pila(&pilaVars);
    destroy_HashMap(hashmap);
    if(ver_tope(&pilaVars, &tmp, sizeof(tVar)) == TODO_OK)
        printf("no se vacia correctamente");

    imprimirTercetos();

    printf("\n\nPROCESO EXITOSO\n\n");

    return PROCESO_EXITOSO;
}

int yyerror(void)
{
    printf("Error Sintactico\n");
}

int acciones_definicion_variable(const char *id, int codValidacion)
{
    tVar tmp;
    int res;

    if(codValidacion != VALIDACION_OK)
    {
        return ID_NO_VALIDO;
    }

    if(ver_tope(&pilaVars, &tmp, sizeof(tVar)) != TODO_OK)
    {
        return ERROR_INESPERADO;
    }
    
    if(verificar_existencia_variable(hashmap, id) != VARIABLE_NO_DEFINIDA)
    {
        fprintf(stderr, "\nERROR: ID definido previamente: %s\n", id);
        return DEF_VARIABLES_DUPLICADAS;
    }

    if(tmp.pos_en_tabla == NO_SE_AGREGA)
    {
        fprintf(stderr, "\nERROR: ID definido previamente: %s\n", id);
        return ERROR_INESPERADO;
    }

    res = add_HashMapEntry(hashmap, tmp.id, tmp.pos_en_tabla);
    if(res == HM_DUPLICATE_KEY)
    {
        fprintf(stderr, "\nERROR: ID definido previamente: %s\n", id);
        return res;
    }
    if(res == HM_NOT_ENOUGH_MEMORY)
    {
        fprintf(stderr, "\nERROR INESPERADO\n");
        return res;
    }

    return ACCION_EXITOSA;
}

int acciones_asignacion_tipo(const char *tipoDato)
{
    return asignar_tipo(&pilaVars, hashmap, &tabla, tipoDato);
}

int acciones_asignacion_variable_general(const char *id, int codValidacion, const char *tipoResultado)
{

    int res;

    if(codValidacion != VALIDACION_OK)
    {
        return ID_NO_VALIDO;
    }

    res = verificar_existencia_variable(hashmap, id);
    if(res == VARIABLE_NO_DEFINIDA)
    {
        fprintf(stderr, "\nERROR: variable no definida: %s\n", id);
        return res;
    }

    res = verificar_compatibilidad_asignacion(hashmap, &tabla, id, tipoResultado);
    if(res != VERIFICACION_OK)
    {
        return res;
    }

    _tipoDatoExpresionActual = NULL;

    return ACCION_EXITOSA;
}

int acciones_asignacion_literal(const char *id, int codValidacion, int codValCadenaAsignada)
{
    if(codValidacion != VALIDACION_OK)
    {
        return ID_NO_VALIDO;
    }

    if(codValCadenaAsignada != VALIDACION_OK)
    {
        return CTE_NO_VALIDA;
    }

    vaciar_pila(&pilaVars);

    return acciones_asignacion_variable_general(id, codValidacion, DCTESTRING);
}

int acciones_verificacion_compatibilidad_tipo(int codValidacion, const char *tipoCte) // para verificar tipos de datos y existencia de variables respecto a operandos que se reconocieron en una asignación
{
    const char *tipoDatoLeido;
    tVar tmp;
    int indice;

    if(codValidacion != VALIDACION_OK)
    {
        return ID_NO_VALIDO;
    }

    if(tipoCte != NULL)
    {
        tipoDatoLeido = tipoCte;
    }
    else
    {
        if(ver_tope(&pilaVars, &tmp, sizeof(tVar)) != TODO_OK)
        {
            return ERROR_INESPERADO;
        }

        indice = get_HashMapEntry_value(hashmap, tmp.id);

        if(indice == HM_KEY_NOT_FOUND)
        {
            fprintf(stderr, "\nERROR: variable no definida (ID: %s)\n", tmp.id);
            return VARIABLE_NO_DEFINIDA;
        }

        tipoDatoLeido = obtener_tipo_dato(&tabla, indice);
    } 

    if(tipoDatoLeido == NULL)
    {
        return ERROR_INESPERADO;
    }

    if(_tipoDatoExpresionActual == NULL)
    {
        _tipoDatoExpresionActual = tipoDatoLeido;
    }
    else
    {
        if(verificar_compatibilidad_tipos_datos(tipoDatoLeido, _tipoDatoExpresionActual) != VERIFICACION_OK)
        {
            fprintf(stderr, "\nERROR: incompatibilidad de operandos\n");
            return EXPRESION_NO_COMPATIBLE;
        }
    }
    
    return ACCION_EXITOSA;
}

int acciones_parametro_read(const char *id, int codValidacion)
{
    if(codValidacion != VALIDACION_OK)
    {
        return ID_NO_VALIDO;
    }

    if(verificar_existencia_variable(hashmap, id) != VERIFICACION_OK)
    {
        fprintf(stderr, "\nERROR: variable no definida (ID: %s)\n", id);
        return VARIABLE_NO_DEFINIDA;
    }

    return ACCION_EXITOSA;
}

void tercetos_expresion_condicion_AND()
{
    
}

/* ********************* */

/*
int acciones_expresion_aritm_simple()
{
    tVar tmp;
    int res;
    const char *tipo_dato_termino;

    if(codValidacion != VALIDACION_OK)
    {
        return ID_NO_VALIDO;
    }

    if(ver_tope(&pilaVars, &tmp, sizeof(tVar)) != TODO_OK)
    {
        return ERROR_INESPERADO;
    }

    tipo_dato_termino = obtener_tipo_dato(&tabla, tmp.pos_en_tabla);

    return ACCION_EXITOSA;
}
*/