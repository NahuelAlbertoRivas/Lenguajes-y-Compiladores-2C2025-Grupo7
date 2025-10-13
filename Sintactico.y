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

int acciones_definicion_variable(const char *id, int codValidacion);
int acciones_asignacion_tipo(const char *tipoDato);
int acciones_asignacion_variable_general(const char *id, int codValidacion, const char *tipoResultado);
int acciones_asignacion_literal(const char *id, int codValidacionId, int codValCadenaAsignada);
int acciones_definicion_tipo_retorno(const char *id, int codValidacion);
int acciones_verificacion_compatibilidad_tipo(int codValidacion, const char *tipoCte);
int acciones_parametro_read(const char *id, int codValidacion);

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

int ListaSentenciasInd2;

int ListaIdInd2;

int BloqueAsigInd2;

int ExpresionRelacionalInd2;

int ExpresionLogicaInd2;

int Xind; //Auxiliar para los tipos de datos

char operandoDerAux[50];
char operandoIzqAux[50];

int _contadorSentencias;
int _resExpRelacional;
int _resExpresionLogica;
int _saltoCeldas;
int _tercetoNoDefinido;
int _inicioBucle;
int _inicioExpresion;
const char *_tipoDatoExpresionActual;

tPila pilaSentencias;

int indice=0;
int indiceActual=0;
int indiceDesapilado = 0;

bool _secuenciaAND = false;
bool _soloAritmetica = true;
bool _soloBooleana = true;

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

%left CMP_MAYOR CMP_MENOR CMP_MAYOR_IGUAL CMP_MENOR_IGUAL CMP_DISTINTO CMP_ES_IGUAL

%nonassoc PREC_RELACIONAL

%left OP_AND
%nonassoc OP_OR
%right OP_NOT

%%

programa:
    def_init lista_sentencias
    {
        sprintf(operandoIzqAux, "[%d]", DefInitInd);
        sprintf(operandoDerAux, "[%d]", ListaSentenciasInd);
        ProgramaInd = crearTerceto("PROGRAMA", operandoIzqAux, operandoDerAux);
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
        BloqueAsigInd2 = BloqueAsigInd;
        BloqueAsigInd = ListaIdInd;
        sprintf(operandoIzqAux, "[%d]", ListaIdInd);
        sprintf(operandoDerAux, "[%d]", TipoDatoInd);
        BloqueAsigInd = crearTerceto("DOS_PUNTOS", operandoIzqAux, operandoDerAux);
        printf("\t\t\tR3. Bloque_Asig -> Lista_Id : Tipo_Dato\n");
    }
    | bloque_asig lista_id DOS_PUNTOS tipo_dato
    {
        BloqueAsigInd2 = BloqueAsigInd;
        sprintf(operandoIzqAux, "[%d]", ListaIdInd);
        sprintf(operandoDerAux, "[%d]", TipoDatoInd);
        indiceActual = crearTerceto("DOS_PUNTOS", operandoIzqAux, operandoDerAux);
        sprintf(operandoIzqAux, "[%d]", BloqueAsigInd2);
        sprintf(operandoDerAux, "[%d]", indiceActual);
        BloqueAsigInd = crearTerceto("BLOQUE_ASIG", operandoIzqAux, operandoDerAux);
        printf("\t\t\tR4. Bloque_Asig -> Bloque_Asig Lista_Id : Tipo_Dato\n");
    }
    ;

lista_id:
    ID
    {
        ListaIdInd2 = ListaIdInd;
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
        ListaIdInd2 = ListaIdInd;
        if(acciones_definicion_variable($3.str, $3.codValidacion) != ACCION_EXITOSA)
        {
            YYABORT;
        } 
        sprintf(operandoIzqAux, "[%d]", ListaIdInd);
        sprintf(operandoDerAux, "[%d]", crearTercetoUnitarioStr($3.str));
        ListaIdInd = crearTerceto("COMA", operandoIzqAux, operandoDerAux);
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
        ListaSentenciasInd2 = ListaSentenciasInd;
        ListaSentenciasInd = SentenciaInd;
        printf("\t\nR11. Lista_Sentencias -> Sentencia\n");
    }
    | lista_sentencias sentencia 
    {
        ListaSentenciasInd2 = ListaSentenciasInd;
        sprintf(operandoIzqAux, "[%d]", ListaSentenciasInd);
        sprintf(operandoDerAux, "[%d]", SentenciaInd);
        ListaSentenciasInd = crearTerceto("LISTA_SENTENCIAS", operandoIzqAux, operandoDerAux);
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
        sprintf(operandoIzqAux, "[%d]", crearTercetoUnitarioStr($1.str));
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        AsignacionInd = crearTerceto("OP_ASIG", operandoIzqAux, operandoDerAux);
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
        sprintf(operandoIzqAux, "[%d]", crearTercetoUnitarioStr($1.str));
        sprintf(operandoDerAux, "[%d]", ValorBooleanoInd);
        AsignacionInd = crearTerceto("OP_ASIG", operandoIzqAux, operandoDerAux);
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
        sprintf(operandoIzqAux, "[%d]", crearTercetoUnitarioStr($1.str));
        AsignacionInd = crearTerceto("OP_UN_INC", operandoIzqAux, "_");
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
        sprintf(operandoIzqAux, "[%d]", crearTercetoUnitarioStr($1.str));
        AsignacionInd = crearTerceto("OP_UN_DEC", operandoIzqAux, "_");
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
        sprintf(operandoIzqAux, "[%d]", crearTercetoUnitarioStr($1.str));
        sprintf(operandoDerAux, "[%d]", crearTercetoUnitarioStr($3.str));
        AsignacionInd = crearTerceto("OP_ASIG", operandoIzqAux, operandoDerAux);
        printf("\t\t\tR22. Asignacion -> [ID: '%s']:= \"%s\"\n", $1.str, $3.str);
        free($1.str);
        free($3.str);
    }
	;

condicional_si:
    IF PAR_ABR expresion PAR_CIE bloque_asociado %prec MENOS_QUE_ELSE
    {
        indiceActual = getIndice(); // [como en crearTerceto() siempre hacemos ++, siempre tenemos el nro. de terceto siguiente al último creado]
        sprintf(operandoIzqAux, "[%d]", indiceActual);
        if(_secuenciaAND)
        {
            while(sacar_de_pila(&pilaSentencias, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
            {
                modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
            }
        }
        else
        {
            sacar_de_pila(&pilaSentencias, &indiceDesapilado, sizeof(indiceActual));
            modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
        }
        printf("\t\t\tR22. Condicional_Si -> if(Expresion) Bloque_Asociado\n");
        _secuenciaAND = false;
        _soloAritmetica = true;
        _soloBooleana = true;
        CondicionalSiInd = _inicioExpresion;
    }
    | IF PAR_ABR expresion PAR_CIE bloque_asociado ELSE
    {
          
        indiceActual = getIndice(); // (1) me guardo el nro. de terceto de BI para actualizarlo una vez que sepa donde termina la última instrucción del bloque ELSE
        crearTerceto("BI", "_saltoCeldas", "_");
        sprintf(operandoIzqAux, "[%d]", indiceActual + 1); // indiceActual + 1 ya sería el nro. de terceto correspondiente a la primer instrucción del bloque ELSE
        if(_secuenciaAND)
        {
            while(sacar_de_pila(&pilaSentencias,&indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK) // (2)
            {
                modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
            }
        }
        else
        {
            sacar_de_pila(&pilaSentencias, &indiceDesapilado, sizeof(indiceDesapilado));
            modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux); // (3)
        }
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual)); // (4)
    }
    bloque_asociado
    {
        indiceActual = getIndice(); // [como en crearTerceto() siempre hacemos ++, siempre tenemos el nro. de terceto siguiente al último creado]
        sprintf(operandoIzqAux, "[%d]", indiceActual);
        sacar_de_pila(&pilaSentencias, &indiceDesapilado, sizeof(indiceDesapilado)); // (1)
        modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux); // (2)
        printf("\t\t\tR23. Condicional_Si -> if(Expresion) Bloque_Asociado else Bloque_Asociado\n");
        _secuenciaAND = false;
        _soloAritmetica = true;
        _soloBooleana = true;
        CondicionalSiInd = _inicioExpresion;
    }
    ;

bloque_asociado:
    sentencia 
    {
        BloqueAsociadoInd2 = BloqueAsociadoInd;
        BloqueAsociadoInd = SentenciaInd;
        printf("\t\t\t\tR24. Bloque_Asociado -> Sentencia\n");
    }
    | LLA_ABR lista_sentencias LLA_CIE 
    {
        BloqueAsociadoInd2 = BloqueAsociadoInd;
        BloqueAsociadoInd = ListaSentenciasInd;
        printf("\t\t\t\tR25. Bloque_Asociado -> { Lista_Sentencias }\n");
    }
    ;

bucle:
    WHILE
    {
        _inicioBucle = getIndice(); // me guardo el inicio de la expresión lógica
        BucleInd = _inicioBucle;
    }
    PAR_ABR expresion PAR_CIE bloque_asociado
    {
        sprintf(operandoIzqAux, "[%d]", _inicioBucle);
        indiceActual = crearTerceto("BI", operandoIzqAux, "_");
        sprintf(operandoIzqAux, "[%d]", indiceActual + 1); // la siguiente instrucción después del BI al final del bucle
        if(_secuenciaAND)
        {
            while(sacar_de_pila(&pilaSentencias, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
            {
                modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
            }
        }
        else
        {
            sacar_de_pila(&pilaSentencias, &indiceDesapilado, sizeof(indiceActual));
            modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
        }
        _secuenciaAND = false;
        _soloAritmetica = true;
        _soloBooleana = true;
        printf("\t\t\t\tRn°. Bucle -> while ( Expresion_Logica )\n");
    }
    ;

llamada_func:
    FN_EQUALEXPRESSIONS PAR_ABR lista_args PAR_CIE 
    {
        sprintf(operandoDerAux, "[%d]", ListaArgsInd);
        LlamadaFuncInd = crearTerceto("LLAMADA_FUNC", "FN_EQUALEXPRESSIONS", operandoDerAux);
        printf("\t\t\tR27. Llamada_Func -> funcion_especial(Lista_Args)\n");
    }
    | FN_ISZERO PAR_ABR expresion PAR_CIE 
    {
        sprintf(operandoDerAux, "[%d]", ExpresionInd);
        LlamadaFuncInd = crearTerceto("LLAMADA_FUNC", "FN_ISZERO", operandoDerAux);
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
        sprintf(operandoIzqAux, "[%d]", ListaArgsInd);
        sprintf(operandoDerAux, "[%d]", ExpresionInd);
        ListaArgsInd = crearTerceto("COMA", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\tR30. lista_args -> lista_args , expresion \n");
    }
    ;

entrada_salida: 
    WRITE PAR_ABR factor PAR_CIE 
    {
        sprintf(operandoDerAux, "[%d]", FactorInd);
        crearTerceto("ENTRADA_SALIDA", "WRITE", operandoDerAux);
        printf("\t\t\tR31. entrada_salida -> WRITE (factor)\n");
    }
    | WRITE PAR_ABR CTE_STRING PAR_CIE 
    {
        if($3.codValidacion!=VALIDACION_OK)
        {
            YYABORT;
        }
        sprintf(operandoDerAux, "[%d]", crearTercetoUnitarioStr($3.str));
        crearTerceto("ENTRADA_SALIDA", "WRITE", operandoDerAux);
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
        sprintf(operandoDerAux, "[%d]", crearTercetoUnitarioStr($3.str));
        crearTerceto("ENTRADA_SALIDA", "READ", operandoDerAux);
        printf("\t\t\tR32. entrada_salida -> READ([ID: '%s'])\n",$3.str);
        free($3.str);
    }
	;

expresion: 
    expresion_logica 
    {
        ExpresionInd = ExpresionLogicaInd;
        printf("\t\t\t\tR34. Expresion -> Expresion_Logica\n");
    }
	;

expresion_logica:
    expresion_logica OP_AND expresion_para_condicion 
    {
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionLogicaInd);
        sprintf(operandoDerAux, "[%d]", ExpresionparaCondicionInd);
        ExpresionLogicaInd = crearTerceto("AND", operandoIzqAux, operandoDerAux);
        sprintf(operandoDerAux, "[%d]", ExpresionLogicaInd);
        crearTerceto("OP_ASIG", "_resExpresionLogica", operandoDerAux);
        crearTerceto("CMP", "_resExpresionLogica", "VERDADERO");
        indiceActual = getIndice(); // obtengo el índice del terceto relativo al salto (BNE en este caso)
        crearTerceto("BNE", "_saltoCeldas", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        _secuenciaAND = true;
        printf("\t\t\t\t\tR35. Expresion_Logica -> Expresion AND Expresion\n");
    }
    | expresion_logica OP_OR expresion_para_condicion 
    {
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionLogicaInd);
        sprintf(operandoDerAux, "[%d]", ExpresionparaCondicionInd);
        ExpresionLogicaInd = crearTerceto("OR", operandoIzqAux, operandoDerAux);
        sprintf(operandoDerAux, "[%d]", ExpresionLogicaInd);
        crearTerceto("OP_ASIG", "_resExpresionLogica", operandoDerAux); // con fadd recupero 
        crearTerceto("CMP", "_resExpresionLogica", "VERDADERO");
        indiceActual = getIndice(); // obtengo el índice del terceto relativo al salto (BNE en este caso)
        crearTerceto("BNE", "_saltoCeldas", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        printf("\t\t\t\t\tR36. Expresion_Logica -> Expresion OR Expresion\n");
    }
    | OP_NOT expresion_logica %prec NEGACION 
    {
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionLogicaInd);
        ExpresionLogicaInd = crearTerceto("NOT", operandoIzqAux, "_");
        sprintf(operandoDerAux, "[%d]", ExpresionLogicaInd);
        crearTerceto("OP_ASIG", "_resExpresionLogica", operandoDerAux);
        crearTerceto("CMP", "_resExpresionLogica", "FALSO");
        indiceActual = getIndice(); // me guardo la referencia del nro. de terceto asociado al Branch (BNE en este caso)
        crearTerceto("BNE", "_saltoCeldas", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        printf("\t\t\t\t\tR37. Expresion_Logica -> NOT Expresion\n");
    }
    | expresion_para_condicion 
    {
        // lo paso tal cual viene
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        ExpresionLogicaInd = ExpresionparaCondicionInd;
        printf("\t\t\t\t\tR38. Expresion_Logica -> Expresion_Para_Condicion\n");
    }
    ;

expresion_para_condicion:
    expresion_relacional
    {
        if(_soloAritmetica)
        {    
            sprintf(operandoDerAux, "[%d]", ExpresionRelacionalInd);
            indiceActual = crearTerceto("OP_ASIG", "_resExpresionAritmetica", operandoDerAux);
            sprintf(operandoIzqAux, "[%d]", indiceActual);
            crearTerceto("CMP", operandoIzqAux, "VERDADERO");
            indiceActual = getIndice(); // me guardo la referencia del branch
            crearTerceto("BNE", "_saltoCeldasSiCorresponde", "_");
            poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        }
        if(_soloBooleana)
        {
            sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
            crearTerceto("CMP", operandoIzqAux, "VERDADERO");
            indiceActual = getIndice(); // me guardo la referencia del nro. de terceto asociado al Branch (BNE en este caso)
            crearTerceto("BNE", "_saltoCeldasSiCorresponde", "_");
            poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        }
        ExpresionParaCondicionInd2 = ExpresionparaCondicionInd;
        ExpresionparaCondicionInd = ExpresionRelacionalInd;
        _tipoDatoExpresionActual = NULL;
        printf("\t\t\t\t\tR40. Expresion_Para_Condicion -> Expresion_Relacional\n");
    }
    ;

expresion_relacional:
    expresion_relacional CMP_MAYOR expresion_aritmetica %prec PREC_RELACIONAL
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd2);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        indiceActual = getIndice(); // me guardo la referencia del branch
        crearTerceto("BLE", "_saltoCeldasSiCorresponde", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(Xind)); // está acá simbólicamente, ya que apilo el terceto del salto para luego actualizarlo
        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR44. Expresion_Relacional -> Expresion_Aritmetica > Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_MENOR expresion_aritmetica %prec PREC_RELACIONAL
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd2);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        indiceActual = getIndice(); // me guardo la referencia del branch
        crearTerceto("BGE", "_saltoCeldasSiCorresponde", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(Xind));
        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR45. Expresion_Relacional -> Expresion_Aritmetica < Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_ES_IGUAL expresion_aritmetica %prec PREC_RELACIONAL
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd2);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        indiceActual = getIndice(); // me guardo la referencia del branch
        crearTerceto("BNE", "_saltoCeldasSiCorresponde", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR46. Expresion_Relacional -> Expresion_Aritmetica == Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_DISTINTO expresion_aritmetica %prec PREC_RELACIONAL
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd2);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        indiceActual = getIndice(); // me guardo la referencia del branch
        crearTerceto("BE", "_saltoCeldasSiCorresponde", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR46. Expresion_Relacional -> Expresion_Aritmetica == Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_MAYOR_IGUAL expresion_aritmetica %prec PREC_RELACIONAL
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd2);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        indiceActual = getIndice(); // me guardo la referencia del branch
        crearTerceto("BLT", "_saltoCeldasSiCorresponde", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR47. Expresion_Relacional -> Expresion_Aritmetica >= Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_MENOR_IGUAL expresion_aritmetica %prec PREC_RELACIONAL
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd2);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        indiceActual = getIndice(); // me guardo la referencia del branch
        crearTerceto("BGT", "_saltoCeldasSiCorresponde", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR48. Expresion_Relacional -> Expresion_Aritmetica <= Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_ES_IGUAL valor_booleano 
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd2);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        indiceActual = getIndice(); // me guardo la referencia del branch
        crearTerceto("BE", "_saltoCeldasSiCorresponde", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR39. Expresion_Para_Condicion -> Valor_Booleano\n");
    }
    | expresion_relacional CMP_DISTINTO valor_booleano 
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd2);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        indiceActual = getIndice(); // me guardo la referencia del branch
        crearTerceto("BE", "_saltoCeldasSiCorresponde", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR39. Expresion_Para_Condicion -> Valor_Booleano\n");
    }
    | valor_booleano 
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        ExpresionRelacionalInd = ValorBooleanoInd;
        _soloAritmetica = false;
        printf("\t\t\t\t\tR39. Expresion_Para_Condicion -> Valor_Booleano\n");
    }
    | expresion_aritmetica 
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        ExpresionRelacionalInd = ExpresionAritmeticaInd;
        _soloBooleana = false;
        printf("\t\t\t\tR33. Expresion -> Expresion_Aritmetica\n");
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
        ValorBooleanoInd = crearTercetoUnitarioStr("TRUE");
        printf("\t\t\t\t\tR42. Valor_Booleano -> TRUE\n");
    }
    | FALSE 
    {
        ValorBooleanoInd = crearTercetoUnitarioStr("FALSE");
        printf("\t\t\t\t\tR43. Valor_Booleano -> FALSE\n");
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
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        ExpresionAritmeticaInd = crearTerceto("OP_RES", operandoIzqAux, "_");
        printf("\t\t\t\t\tR50. Expresion_Aritmetica -> - Expresion_Aritmetica\n");
    }
	| expresion_aritmetica OP_SUM termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd);
        sprintf(operandoDerAux, "[%d]", TerminoInd);
        ExpresionAritmeticaInd = crearTerceto("OP_SUM", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\tR51. Expresion_Aritmetica -> Expresion_Aritmetica + Termino\n");
    }
	| expresion_aritmetica OP_RES termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd);
        sprintf(operandoDerAux, "[%d]", TerminoInd);
        ExpresionAritmeticaInd = crearTerceto("OP_RES", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\tR52. Expresion_Aritmetica -> Expresion_Aritmetica - Termino\n");
    }
    ;

termino:
    factor 
    {
        TerminoInd = FactorInd;
        printf("\t\t\t\t\t\tR53. Termino -> Factor\n");
    }
    | termino OP_MUL factor 
    {
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        sprintf(operandoDerAux, "[%d]", FactorInd);
        TerminoInd = crearTerceto("OP_MUL", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\t\tR54. Termino -> Termino * Factor\n");
    }
    | termino OP_DIV factor 
    {
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        sprintf(operandoDerAux, "[%d]", FactorInd);
        TerminoInd = crearTerceto("OP_DIV", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\t\tR55. Termino -> Termino / Factor\n");
    }
    | termino OP_MOD factor 
    {
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        sprintf(operandoDerAux, "[%d]", FactorInd);
        TerminoInd = crearTerceto("OP_MOD", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\t\tR56. Termino -> Termino % Factor\n");
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
        _inicioExpresion = getIndice();
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
        _inicioExpresion = getIndice();
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
        _inicioExpresion = getIndice();
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
    crear_pila(&pilaSentencias);
    crear_pila(&pilaVars);

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

    guardar_tabla_en_archivo(&tabla, "Symbol-Table.txt");
	fclose(yyin);
    vaciar_pila(&pilaVars);
    destroy_HashMap(hashmap);

    imprimirTercetos();

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
    return acciones_asignacion_variable_general(id, codValidacion, DCTESTRING);
}

int acciones_verificacion_compatibilidad_tipo(int codValidacion, const char *tipoCte) // para verificar tipos de datos y existencia de variables respecto a operandos que se reconocieron en una asignación
{
    const char *tipoDatoLeido;
    tVar tmp;
    int indice;

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
    if(verificar_existencia_variable(hashmap, id) != VERIFICACION_OK)
    {
        fprintf(stderr, "\nERROR: variable no definida (ID: %s)\n", id);
        return VARIABLE_NO_DEFINIDA;
    }

    return ACCION_EXITOSA;
}

/************************************************TODAVÍA NO IMPLEMENTADO******************************************************/

void tercetos_expresion_condicion_AND()
{
    
}

/*
int acciones_expresion_aritm_simple()
{
    tVar tmp;
    int res;
    const char *tipo_dato_termino;

    if(ver_tope(&pilaVars, &tmp, sizeof(tVar)) != TODO_OK)
    {
        return ERROR_INESPERADO;
    }

    tipo_dato_termino = obtener_tipo_dato(&tabla, tmp.pos_en_tabla);

    return ACCION_EXITOSA;
}
*/