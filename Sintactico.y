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

// #define VERDADERO   1
// #define FALSO       0
// #define CAMPO_NULO SHRT_MIN

#define HASHMAP_SIZE 10
#define ERROR_APERTURA_ARCHIVO -213
#define PROCESO_EXITOSO 0

int yystopparser = 0;
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
void recorrer_lista_argumentos_equalexpressions(tPila *pilaIndiceTercetosFuncionesEspeciales);
void completar_bi_equalexpressions(tPila *pilaBI);

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
int SentenciaInd2;
int Xind; //Auxiliar para los tipos de datos

char operandoDerAux[50];
char operandoIzqAux[50];

//int _contadorSentencias;
//int _resExpRelacional;
// int @resExpresionLogica;
// int _saltoCeldas;
// int _tercetoNoDefinido;
int _inicioBucle;
int _inicioExpresion;
const char *_tipoDatoExpresionActual;

tPila pilaSentencias;
tPila pilaListaSentencias;
tPila pilaExpresionesLogicas;
tPila pilaIndiceTercetosFuncionesEspeciales;
tPila pilaBI;

tPila pilaValoresBooleanos;

int indice = 0;
int indiceActual = 0;
int indiceDesapilado = 0;

bool _secuenciaAND = false;
bool _soloAritmetica = true;
bool _soloBooleana = true;

Tabla tabla;
HashMap *hashmap;
tPila pilaVars;
FILE *ptercetos;

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

%nonassoc OP_OR
%left OP_AND
%right OP_NOT
%nonassoc PRIORIDAD_EXPRESION

%%

programa:
    def_init lista_sentencias
    {
        //sprintf(operandoIzqAux, "[%d]", DefInitInd);
        //sprintf(operandoDerAux, "[%d]", ListaSentenciasInd);
        //ProgramaInd = crearTerceto("PROGRAMA", operandoIzqAux, operandoDerAux);
        printf("R1. Programa -> Def_Init Lista_Sentencias\n");
    }
    ;
    
def_init:
    INIT LLA_ABR bloque_asig LLA_CIE
    {
        //DefInitInd = BloqueAsigInd;
        printf("\t\tR2. Def_Init -> init { Bloque_Asig }\n");
    }
    ;

bloque_asig:
    lista_id DOS_PUNTOS tipo_dato
    {
        //BloqueAsigInd2 = BloqueAsigInd;
        //BloqueAsigInd = ListaIdInd;
        //sprintf(operandoIzqAux, "[%d]", ListaIdInd);
        //sprintf(operandoDerAux, "[%d]", TipoDatoInd);
        //BloqueAsigInd = crearTerceto("DOS_PUNTOS", operandoIzqAux, operandoDerAux);
        printf("\t\t\tR3. Bloque_Asig -> Lista_Id : Tipo_Dato\n");
    }
    | bloque_asig lista_id DOS_PUNTOS tipo_dato
    {
        //BloqueAsigInd2 = BloqueAsigInd;
        //sprintf(operandoIzqAux, "[%d]", ListaIdInd);
        //sprintf(operandoDerAux, "[%d]", TipoDatoInd);
        //indiceActual = crearTerceto("DOS_PUNTOS", operandoIzqAux, operandoDerAux);
        //sprintf(operandoIzqAux, "[%d]", BloqueAsigInd2);
        //sprintf(operandoDerAux, "[%d]", indiceActual);
        //BloqueAsigInd = crearTerceto("BLOQUE_ASIG", operandoIzqAux, operandoDerAux);
        printf("\t\t\tR4. Bloque_Asig -> Bloque_Asig Lista_Id : Tipo_Dato\n");
    }
    ;

lista_id:
    ID
    {
        //ListaIdInd2 = ListaIdInd;
        if(acciones_definicion_variable($1.str, $1.codValidacion) != ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
        //ListaIdInd = crearTercetoUnitarioStr($1.str);
        printf("\t\t\t\tR5. Lista_Id -> [ID: '%s']\n", $1.str);
        free($1.str);
    } 
    | lista_id COMA ID 
    {        
        //ListaIdInd2 = ListaIdInd;
        if(acciones_definicion_variable($3.str, $3.codValidacion) != ACCION_EXITOSA)
        {
            YYABORT;
        } 
        //sprintf(operandoIzqAux, "[%d]", ListaIdInd);
        //sprintf(operandoDerAux, "[%d]", crearTercetoUnitarioStr($3.str));
        //ListaIdInd = crearTerceto("COMA", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\tR6. Lista_Id -> Lista_Id COMA [ID: '%s']\n",$3.str); 
        free($3.str);
    }
    ;

tipo_dato:
    TD_BOOLEAN 
    {
        //TipoDatoInd = crearTercetoUnitarioStr(DBOOLEAN);
        printf("\t\t\t\tR7. Tipo_Dato -> %s\n", $1.str); 
        if(acciones_asignacion_tipo($1.str) != ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
    }
    | TD_INT 
    {
        //TipoDatoInd = crearTercetoUnitarioStr(DINTEGER);
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
        //TipoDatoInd = crearTercetoUnitarioStr(DFLOAT);
        printf("\t\t\t\tR9. Tipo_Dato -> %s\n", $1.str); 
        if(acciones_asignacion_tipo($1.str) != ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
    }
    | TD_STRING 
    {
        //TipoDatoInd = crearTercetoUnitarioStr(DSTRING);
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
        poner_en_pila(&pilaListaSentencias, &ListaSentenciasInd, sizeof(ListaSentenciasInd));
        printf("\t\nR11. Lista_Sentencias -> Sentencia\n");
    }
    | lista_sentencias sentencia 
    {
        ListaSentenciasInd2 = ListaSentenciasInd;
        ListaSentenciasInd = SentenciaInd;
        if(sacar_de_pila(&pilaListaSentencias, &Xind, sizeof(Xind)) == TODO_OK)
        {
            ListaSentenciasInd2 = Xind;
        }
        //sprintf(operandoIzqAux, "[%d]", ListaSentenciasInd2);
        //sprintf(operandoDerAux, "[%d]", ListaSentenciasInd);
        //ListaSentenciasInd = crearTerceto("LISTA_SENTENCIAS", operandoIzqAux, operandoDerAux);
        poner_en_pila(&pilaListaSentencias, &ListaSentenciasInd, sizeof(ListaSentenciasInd));
        printf("\t\nR12. Lista_Sentencias -> Lista_Sentencias Sentencia\n");
    }
    ;

sentencia:  	   
	asignacion 
    {
        SentenciaInd2 = SentenciaInd;
        SentenciaInd = AsignacionInd;
        printf("\t\tR13. Sentencia -> Asignacion\n");
    } 
    | condicional_si 
    {
        SentenciaInd2 = SentenciaInd;
        SentenciaInd = CondicionalSiInd;
        printf("\t\tR14. Sentencia -> Condicional_Si\n");
    }
    | bucle 
    {
        SentenciaInd2 = SentenciaInd;
        SentenciaInd = BucleInd;
        printf("\t\tR15. Sentencia -> While\n");
    }
    | llamada_func 
    {
        SentenciaInd2 = SentenciaInd;
        SentenciaInd = LlamadaFuncInd;
        printf("\t\tR16. Sentencia -> LLamada_Func\n");
    }
    | entrada_salida 
    {
        SentenciaInd2 = SentenciaInd;
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
        AsignacionInd = crearTerceto(":=", operandoIzqAux, operandoDerAux);
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
        //sprintf(operandoDerAux, "[%d]", ValorBooleanoInd);
        char valorBoleanoString[50];
        sacar_de_pila(&pilaValoresBooleanos, valorBoleanoString, sizeof(valorBoleanoString));
        AsignacionInd = crearTerceto(":=", operandoIzqAux, valorBoleanoString);
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

        int IDind = crearTercetoUnitarioStr($1.str);

        sprintf(operandoIzqAux, "[%d]", IDind);
        sprintf(operandoDerAux, "%d", 1);
        Xind = crearTerceto("+", operandoIzqAux, operandoDerAux);
        sprintf(operandoIzqAux, "[%d]", IDind);
        sprintf(operandoDerAux, "[%d]", Xind);
        AsignacionInd = crearTerceto(":=", operandoIzqAux, operandoDerAux);

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

        int IDind = crearTercetoUnitarioStr($1.str);

        sprintf(operandoIzqAux, "[%d]", IDind);
        sprintf(operandoDerAux, "%d", 1);
        Xind = crearTerceto("-", operandoIzqAux, operandoDerAux);
        sprintf(operandoIzqAux, "[%d]", IDind);
        sprintf(operandoDerAux, "[%d]", Xind);
        AsignacionInd = crearTerceto(":=", operandoIzqAux, operandoDerAux);

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
        AsignacionInd = crearTerceto(":=", operandoIzqAux, operandoDerAux);
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
        printf("\t\t\tR23. Condicional_Si -> if(Expresion) Bloque_Asociado\n");
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
        printf("\t\t\tR24. Condicional_Si -> if(Expresion) Bloque_Asociado else Bloque_Asociado\n");
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
        poner_en_pila(&pilaListaSentencias, &SentenciaInd, sizeof(SentenciaInd));
        printf("\t\t\t\tR25. Bloque_Asociado -> Sentencia\n");
    }
    | LLA_ABR lista_sentencias LLA_CIE 
    {
        BloqueAsociadoInd2 = BloqueAsociadoInd;
        BloqueAsociadoInd = ListaSentenciasInd;
        printf("\t\t\t\tR26. Bloque_Asociado -> { Lista_Sentencias }\n");
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
        printf("\t\t\t\tR27. Bucle -> while ( Expresion_Logica )\n");
    }
    ;

llamada_func:
    FN_EQUALEXPRESSIONS PAR_ABR 
    {
        crearTerceto(":=", "@resEqualExpressions", "FALSO");
        if(get_HashMapEntry_value(hashmap, "@resEqualExpressions") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resEqualExpressions", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resEqualExpressions", "Boolean");
        }
    }
    lista_args PAR_CIE 
    {
        recorrer_lista_argumentos_equalexpressions(&pilaIndiceTercetosFuncionesEspeciales);
        //sprintf(operandoDerAux, "[%d]", ListaArgsInd);
        //LlamadaFuncInd = crearTerceto("LLAMADA_FUNC", "FN_EQUALEXPRESSIONS", operandoDerAux);
        printf("\t\t\tR28. Llamada_Func -> equalExpressions(Lista_Args)\n");

        completar_bi_equalexpressions(&pilaBI);
        //sacar_de_pila(&pilaBI, &indiceDesapilado, sizeof(indiceActual));
        //modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);

        char valoroBoolStr[50] = "@resEqualExpressions";
        poner_en_pila(&pilaValoresBooleanos, valoroBoolStr, sizeof(valoroBoolStr));
    }
    | FN_ISZERO PAR_ABR expresion_aritmetica PAR_CIE 
    {
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        //LlamadaFuncInd = crearTerceto("LLAMADA_FUNC", "FN_ISZERO", operandoDerAux);
        printf("\t\t\tR29. Llamada_Func -> isZero(Lista_Args)\n");

        Xind = crearTerceto("CMP", operandoDerAux, "0");
        sprintf(operandoIzqAux, "[%d]", Xind + 4);
        crearTerceto("BNE", operandoIzqAux, "_"); // + 1
        Xind = crearTerceto(":=", "@resIsZero", "VERDADERO"); // + 2
        if(get_HashMapEntry_value(hashmap, "@resIsZero") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resIsZero", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resIsZero", "Boolean");
        }
        sprintf(operandoIzqAux, "[%d]", Xind + 3);
        crearTerceto("BI",operandoIzqAux, "_"); // + 3
        crearTerceto(":=", "@resIsZero", "FALSO"); // + 4
        if(get_HashMapEntry_value(hashmap, "@resIsZero") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resIsZero", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resIsZero", "Boolean");
        }

        char valoroBoolStr[50] = "@resIsZero";
        poner_en_pila(&pilaValoresBooleanos, valoroBoolStr, sizeof(valoroBoolStr));
    }
    ;

lista_args:
    expresion_aritmetica
    {
        sprintf(operandoDerAux, "[%d]", getIndice()-1);
        ListaArgsInd = crearTerceto(":=", "@pivote", operandoDerAux);
        if(get_HashMapEntry_value(hashmap, "@pivote") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@pivote", 0);
            agregar_a_tabla_variables_internas(&tabla, "@pivote", "Int");
        }
        printf("\t\t\t\tR30. lista_args -> expresion_aritmetica\n");
        
    }
    | lista_args COMA expresion_aritmetica 
    {
        sprintf(operandoIzqAux, "[%d]", ListaArgsInd);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);

        poner_en_pila(&pilaIndiceTercetosFuncionesEspeciales, &ExpresionAritmeticaInd, sizeof(ExpresionAritmeticaInd));
        printf("Apile %d\n", ExpresionAritmeticaInd);

        sprintf(operandoDerAux, "[%d]", getIndice()-1);
        ListaArgsInd = crearTerceto(":=", "@actual", operandoDerAux);
        if(get_HashMapEntry_value(hashmap, "@actual") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@actual", 0);
            agregar_a_tabla_variables_internas(&tabla, "@actual", "Int");
        }
        
        printf("\t\t\t\tR31. lista_args -> lista_args , expresion_aritmetica \n");

        crearTerceto("CMP", "@pivote", "@actual");
        sprintf(operandoIzqAux, "[%d]", ListaArgsInd+5);
        crearTerceto("BNE", operandoIzqAux, "_");
        crearTerceto(":=", "@resEqualExpressions", "VERDADERO");
        if(get_HashMapEntry_value(hashmap, "@resEqualExpressions") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resEqualExpressions", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resEqualExpressions", "Boolean");
        }
        int IndBI = crearTerceto("BI","", "_");

        poner_en_pila(&pilaBI, &IndBI, sizeof(IndBI));
    }
    ;

entrada_salida: 
    WRITE PAR_ABR factor PAR_CIE 
    {
        sprintf(operandoDerAux, "[%d]", FactorInd);
        EntradaSalidaInd = crearTerceto("ENTRADA_SALIDA", "WRITE", operandoDerAux);
        printf("\t\t\tR32. entrada_salida -> WRITE (factor)\n");
    }
    | WRITE PAR_ABR CTE_STRING PAR_CIE 
    {
        if($3.codValidacion!=VALIDACION_OK)
        {
            YYABORT;
        }
        sprintf(operandoDerAux, "[%d]", crearTercetoUnitarioStr($3.str));
        EntradaSalidaInd = crearTerceto("ENTRADA_SALIDA", "WRITE", operandoDerAux);
        printf("\t\t\tR33. entrada_salida -> WRITE (CTE_STRING)\n");
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
        EntradaSalidaInd = crearTerceto("ENTRADA_SALIDA", "READ", operandoDerAux);
        printf("\t\t\tR34. entrada_salida -> READ([ID: '%s'])\n",$3.str);
        free($3.str);
    }
	;

expresion: 
    expresion_logica 
    {
        ExpresionInd = ExpresionLogicaInd;
        printf("\t\t\t\tR35. Expresion -> Expresion_Logica\n");
    }
	;

expresion_logica:
    expresion_logica OP_AND expresion_para_condicion 
    {
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionLogicaInd);
        sprintf(operandoDerAux, "[%d]", ExpresionparaCondicionInd);
        if(sacar_de_pila(&pilaExpresionesLogicas, &Xind, sizeof(Xind)) == TODO_OK) {
            sprintf(operandoIzqAux, "[%d]", Xind);
        }
        
        int izqInd = crearTerceto(":=", "@resOrIzq", operandoIzqAux);
        if(get_HashMapEntry_value(hashmap, "@resOrIzq") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resOrIzq", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resOrIzq", "Boolean");
        }

        int derInd = crearTerceto(":=", "@resOrDer", operandoDerAux);
        if(get_HashMapEntry_value(hashmap, "@resOrDer") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resOrDer", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resOrDer", "Boolean");
        }

        sprintf(operandoIzqAux, "[%d]", izqInd);
        sprintf(operandoDerAux, "[%d]", derInd);
        int resOrInd = crearTerceto("+", operandoIzqAux, operandoDerAux);
        sprintf(operandoIzqAux, "[%d]", resOrInd);

        crearTerceto("CMP", operandoIzqAux, "1");
        indiceActual = getIndice();
        sprintf(operandoIzqAux, "[%d]", indiceActual + 3);
        crearTerceto("BLE", operandoIzqAux, "_");
        ExpresionLogicaInd = crearTerceto(":=", "@resExpresionLogica", "VERDADERO");
        if(get_HashMapEntry_value(hashmap, "@resExpresionLogica") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resExpresionLogica", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resExpresionLogica", "Boolean");
        }
        sprintf(operandoIzqAux, "[%d]", indiceActual + 4);
        crearTerceto("BI", operandoIzqAux, "_");

        ExpresionLogicaInd = crearTerceto(":=", "@resExpresionLogica", "FALSO");
        if(get_HashMapEntry_value(hashmap, "@resExpresionLogica") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resExpresionLogica", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resExpresionLogica", "Boolean");
        } 
        
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        poner_en_pila(&pilaExpresionesLogicas, &Xind, sizeof(Xind));
        
        /*
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionLogicaInd);
        sprintf(operandoDerAux, "[%d]", ExpresionparaCondicionInd);
        if(sacar_de_pila(&pilaExpresionesLogicas, &Xind, sizeof(Xind)) == TODO_OK)
        {
            sprintf(operandoIzqAux, "[%d]", Xind);
        }
        Xind = ExpresionLogicaInd = crearTerceto("AND", operandoIzqAux, operandoDerAux);
        sprintf(operandoDerAux, "[%d]", ExpresionLogicaInd);
        crearTerceto(":=", "@resExpresionLogica", operandoDerAux);
        if(get_HashMapEntry_value(hashmap, "@resExpresionLogica") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resExpresionLogica", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resExpresionLogica", "Boolean");
        }
        crearTerceto("CMP", "@resExpresionLogica", "VERDADERO");
        indiceActual = getIndice(); // obtengo el índice del terceto relativo al salto (BNE en este caso)
        crearTerceto("BNE", "_saltoCeldas", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        _secuenciaAND = true;
        poner_en_pila(&pilaExpresionesLogicas, &Xind, sizeof(Xind));*/
        printf("\t\t\t\t\tR36. Expresion_Logica -> Expresion AND Expresion\n");
    }
    | expresion_logica OP_OR expresion_para_condicion 
    {
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionLogicaInd);
        sprintf(operandoDerAux, "[%d]", ExpresionparaCondicionInd);
        if(sacar_de_pila(&pilaExpresionesLogicas, &Xind, sizeof(Xind)) == TODO_OK) {
            sprintf(operandoIzqAux, "[%d]", Xind);
        }
        
        int izqInd = crearTerceto(":=", "@resOrIzq", operandoIzqAux);
        if(get_HashMapEntry_value(hashmap, "@resOrIzq") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resOrIzq", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resOrIzq", "Boolean");
        }

        int derInd = crearTerceto(":=", "@resOrDer", operandoDerAux);
        if(get_HashMapEntry_value(hashmap, "@resOrDer") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resOrDer", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resOrDer", "Boolean");
        }

        sprintf(operandoIzqAux, "[%d]", izqInd);
        sprintf(operandoDerAux, "[%d]", derInd);
        int resOrInd = crearTerceto("+", operandoIzqAux, operandoDerAux);
        sprintf(operandoIzqAux, "[%d]", resOrInd);

        crearTerceto("CMP", operandoIzqAux, "0");
        indiceActual = getIndice();
        sprintf(operandoIzqAux, "[%d]", indiceActual + 3);
        crearTerceto("BLE", operandoIzqAux, "_");
        ExpresionLogicaInd = crearTerceto(":=", "@resExpresionLogica", "VERDADERO");
        if(get_HashMapEntry_value(hashmap, "@resExpresionLogica") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resExpresionLogica", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resExpresionLogica", "Boolean");
        }
        sprintf(operandoIzqAux, "[%d]", indiceActual + 4);
        crearTerceto("BI", operandoIzqAux, "_");

        ExpresionLogicaInd = crearTerceto(":=", "@resExpresionLogica", "FALSO");
        if(get_HashMapEntry_value(hashmap, "@resExpresionLogica") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resExpresionLogica", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resExpresionLogica", "Boolean");
        } 
        
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        poner_en_pila(&pilaExpresionesLogicas, &Xind, sizeof(Xind));

        printf("\t\t\t\t\tR37. Expresion_Logica -> Expresion OR Expresion\n");

        
        //ExpresionLogicaInd = crearTerceto("OR", operandoIzqAux, operandoDerAux);
        /*sprintf(operandoDerAux, "[%d]", ExpresionLogicaInd);
        crearTerceto(":=", "@resExpresionLogica", operandoDerAux); // con fadd recupero 
        if(get_HashMapEntry_value(hashmap, "@resExpresionLogica") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resExpresionLogica", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resExpresionLogica", "Boolean");
        }

        crearTerceto("CMP", "@resExpresionLogica", "VERDADERO");
        indiceActual = getIndice(); // obtengo el índice del terceto relativo al salto (BNE en este caso)
        crearTerceto("BNE", "_saltoCeldas", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        poner_en_pila(&pilaExpresionesLogicas, &Xind, sizeof(Xind));
        printf("\t\t\t\t\tR37. Expresion_Logica -> Expresion OR Expresion\n");*/
    }
    | OP_NOT expresion_logica %prec NEGACION 
    {
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionLogicaInd);
        ExpresionLogicaInd = crearTerceto("NOT", operandoIzqAux, "_");
        sprintf(operandoDerAux, "[%d]", ExpresionLogicaInd);
        crearTerceto(":=", "@resExpresionLogica", operandoDerAux);
        if(get_HashMapEntry_value(hashmap, "@resExpresionLogica") == HM_KEY_NOT_FOUND){
            add_HashMapEntry(hashmap, "@resExpresionLogica", 0);
            agregar_a_tabla_variables_internas(&tabla, "@resExpresionLogica", "Boolean");
        }
        crearTerceto("CMP", "@resExpresionLogica", "FALSO");
        indiceActual = getIndice(); // me guardo la referencia del nro. de terceto asociado al Branch (BNE en este caso)
        crearTerceto("BNE", "_saltoCeldas", "_");
        poner_en_pila(&pilaSentencias, &indiceActual, sizeof(indiceActual));
        poner_en_pila(&pilaExpresionesLogicas, &Xind, sizeof(Xind));
        printf("\t\t\t\t\tR38. Expresion_Logica -> NOT Expresion\n");
    }
    | expresion_para_condicion %prec PRIORIDAD_EXPRESION
    {
        // lo paso tal cual viene
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        ExpresionLogicaInd = ExpresionparaCondicionInd;
        printf("\t\t\t\t\tR39. Expresion_Logica -> Expresion_Para_Condicion\n");
    }
    ;

expresion_para_condicion:
    expresion_relacional
    {
        if(_soloAritmetica)
        {    
            sprintf(operandoDerAux, "[%d]", ExpresionRelacionalInd);
            indiceActual = crearTerceto(":=", "@resExpresionAritmetica", operandoDerAux);
            if(get_HashMapEntry_value(hashmap, "@resExpresionAritmetica") == HM_KEY_NOT_FOUND) {
                add_HashMapEntry(hashmap, "@resExpresionAritmetica", 0);
                agregar_a_tabla_variables_internas(&tabla, "@resExpresionAritmetica", "Int");
            }   
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
        printf("\t\t\t\t\tR41. Expresion_Relacional -> Expresion_Aritmetica > Expresion_Aritmetica\n");
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
        printf("\t\t\t\t\tR42. Expresion_Relacional -> Expresion_Aritmetica < Expresion_Aritmetica\n");
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
        printf("\t\t\t\t\tR43. Expresion_Relacional -> Expresion_Aritmetica == Expresion_Aritmetica\n");
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
        printf("\t\t\t\t\tR44. Expresion_Relacional -> Expresion_Aritmetica != Expresion_Aritmetica\n");
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
        printf("\t\t\t\t\tR45. Expresion_Relacional -> Expresion_Aritmetica >= Expresion_Aritmetica\n");
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
        printf("\t\t\t\t\tR46. Expresion_Relacional -> Expresion_Aritmetica <= Expresion_Aritmetica\n");
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
        printf("\t\t\t\t\tR47. Expresion_Relacional -> Expresion_Relacional == Valor_Booleano\n");
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
        printf("\t\t\t\t\tR48. Expresion_Relacional -> Expresion_Relacional != Valor_Booleano\n");
    }
    | valor_booleano 
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        ExpresionRelacionalInd = ValorBooleanoInd;
        _soloAritmetica = false;
        printf("\t\t\t\t\tR49. Expresion_Relacional -> Valor_Booleano\n");
    }
    | expresion_aritmetica 
    {
        ExpresionRelacionalInd2 = ExpresionRelacionalInd;
        ExpresionRelacionalInd = ExpresionAritmeticaInd;
        _soloBooleana = false;
        printf("\t\t\t\tR50. Expresion_Relacional -> Expresion_Aritmetica\n");
    }
    ;

valor_booleano:   
    llamada_func 
    {
        ValorBooleanoInd = LlamadaFuncInd;
        printf("\t\t\t\t\t\t\tR51. Valor_Booleano -> Llamada_Func\n");
    }
    | TRUE 
    {
        ValorBooleanoInd = crearTercetoUnitarioStr("VERDADERO");
        char valoroBoolStr[50] = "VERDADERO";
        poner_en_pila(&pilaValoresBooleanos, valoroBoolStr, sizeof(valoroBoolStr));
        printf("\t\t\t\t\tR52. Valor_Booleano -> TRUE\n");
    }
    | FALSE 
    {
        ValorBooleanoInd = crearTercetoUnitarioStr("FALSO");
        char valoroBoolStr[50] = "FALSO";
        poner_en_pila(&pilaValoresBooleanos, valoroBoolStr, sizeof(valoroBoolStr));
        printf("\t\t\t\t\tR53. Valor_Booleano -> FALSE\n");
    }
    ;
    
expresion_aritmetica:
    termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        ExpresionAritmeticaInd = TerminoInd;
        printf("\t\t\t\t\tR54. Expresion_Aritmetica -> Termino\n");
    }
    | OP_RES expresion_aritmetica %prec MENOS_UNARIO 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        ExpresionAritmeticaInd = crearTerceto("-", operandoIzqAux, "_");
        printf("\t\t\t\t\tR55. Expresion_Aritmetica -> - Expresion_Aritmetica\n");
    }
	| expresion_aritmetica OP_SUM termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd);
        sprintf(operandoDerAux, "[%d]", TerminoInd);
        ExpresionAritmeticaInd = crearTerceto("+", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\tR56. Expresion_Aritmetica -> Expresion_Aritmetica + Termino\n");
    }
	| expresion_aritmetica OP_RES termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd);
        sprintf(operandoDerAux, "[%d]", TerminoInd);
        ExpresionAritmeticaInd = crearTerceto("-", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\tR57. Expresion_Aritmetica -> Expresion_Aritmetica - Termino\n");
    }
    ;

termino:
    factor 
    {
        TerminoInd = FactorInd;
        printf("\t\t\t\t\t\tR58. Termino -> Factor\n");
    }
    | termino OP_MUL factor 
    {
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        sprintf(operandoDerAux, "[%d]", FactorInd);
        TerminoInd = crearTerceto("*", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\t\tR59. Termino -> Termino * Factor\n");
    }
    | termino OP_DIV factor 
    {
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        sprintf(operandoDerAux, "[%d]", FactorInd);
        TerminoInd = crearTerceto("/", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\t\tR60. Termino -> Termino / Factor\n");
    }
    | termino OP_MOD factor 
    {
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        sprintf(operandoDerAux, "[%d]", FactorInd);
        TerminoInd = crearTerceto("%", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\t\tR61. Termino -> Termino % Factor\n");
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
        printf("\t\t\t\t\t\t\tR62. Factor -> [ID: '%s']\n", $1.str); 
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
        printf("\t\t\t\t\t\t\tR63. Factor -> [CTE_INT: '%s']\n", $1.str); 
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
        printf("\t\t\t\t\t\t\tR64. Factor -> [CTE_REAL: '%s']\n", $1.str); 
        free($1.str);
    }
    | PAR_ABR expresion PAR_CIE 
    {
        FactorInd = ExpresionInd;
        printf("\t\t\t\t\t\t\tR65. Factor -> (Expresion)\n");
    }
    ;

%%

int main(int argc, char *argv[])
{
    hashmap = create_HashMap(HASHMAP_SIZE);
    crear_pila(&pilaSentencias);
    crear_pila(&pilaVars);
    crear_pila(&pilaListaSentencias);
    crear_pila(&pilaExpresionesLogicas);
    crear_pila(&pilaIndiceTercetosFuncionesEspeciales);
    crear_pila(&pilaBI);
    crear_pila(&pilaValoresBooleanos);

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
    vaciar_pila(&pilaSentencias);
    vaciar_pila(&pilaListaSentencias);
    vaciar_pila(&pilaExpresionesLogicas);
    vaciar_pila(&pilaIndiceTercetosFuncionesEspeciales);
    vaciar_pila(&pilaBI);
    vaciar_pila(&pilaValoresBooleanos);
    destroy_HashMap(hashmap);

    imprimirTercetos();


    return PROCESO_EXITOSO;
}

int yyerror(void)
{
    printf("Error Sintactico\n");
}

/*----------------------------------------------------------------------------
                Funciones de Validacion Semantica
----------------------------------------------------------------------------*/
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


/******************************************************************
                Implementacion Funciones Especiales 
*******************************************************************/

void recorrer_lista_argumentos_equalexpressions(tPila *pilaIndiceTercetosFuncionesEspeciales)
{
    if (pila_vacia(pilaIndiceTercetosFuncionesEspeciales))
        return;

    // Pasar la pila a un vector auxiliar
    int *vec = NULL;
    int tam = 0;
    int aux;

    // Desapilo todo y lo guardo en un vector
    while (!pila_vacia(pilaIndiceTercetosFuncionesEspeciales))
    {
        sacar_de_pila(pilaIndiceTercetosFuncionesEspeciales, &aux, sizeof(int));
        vec = realloc(vec, (tam + 1) * sizeof(int));
        vec[tam++] = aux;
    }

    // Para preservar la pila original, vuelvo a apilar en orden inverso
    for (int i = tam - 1; i >= 0; i--)
        poner_en_pila(pilaIndiceTercetosFuncionesEspeciales, &vec[i], sizeof(int));

    // Ahora 'vec' tiene los índices en orden de aparición
    for (int i = 0; i < tam / 2; i++)
    {
        int tmp = vec[i];
        vec[i] = vec[tam - 1 - i];
        vec[tam - 1 - i] = tmp;
    }

    // Paso 2: Doble bucle de comparación
    int indicePivote;
    int IndBI;
    for (int i = 0; i < tam - 1; i++)
    {
        int indicePivote = vec[i];
        sprintf(operandoDerAux, "[%d]", indicePivote);
        crearTerceto(":=", "@pivote", operandoDerAux);

        for (int j = i + 1; j < tam; j++)
        {
            indiceActual = vec[j];
            sprintf(operandoDerAux, "[%d]", indiceActual);
            ListaArgsInd = crearTerceto(":=", "@actual", operandoDerAux); // ListaArgsInd = 0
            
            crearTerceto("CMP", "@pivote", "@actual"); // + 1
            sprintf(operandoIzqAux, "[%d]", ListaArgsInd + 5);
            crearTerceto("BNE", operandoIzqAux, "_"); // +2
            crearTerceto(":=", "@resEqualExpressions", "VERDADERO"); // + 3
            IndBI = crearTerceto("BI","", "_"); // + 4

            poner_en_pila(&pilaBI, &IndBI, sizeof(IndBI));
        }
    }

    free(vec);
}

void completar_bi_equalexpressions(tPila *PilaBI)
{
    int indiceDesapilado;
    while(sacar_de_pila(PilaBI, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
    {
        sprintf(operandoIzqAux, "[%d]", getIndice());
        modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
    }
}

