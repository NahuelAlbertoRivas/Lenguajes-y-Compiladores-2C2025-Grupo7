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
#include "utilidades/lista.h"
#include "utilidades/acciones_semanticas.h"

#define ES_LETRA_MAYUSC(x)((x>64) && (x<91))

#define HASHMAP_SIZE 10
#define ERROR_APERTURA_ARCHIVO -213
#define PROCESO_EXITOSO 0

#define MAX_RES_EXP 50

#define NOMBRE_ARCHIVO_ASM "final.asm"
#define NOMBRE_ARCHIVO_TABLA "Symbol-Table.txt"
#define NOMBRE_ARCHIVO_TERCETOS "intermediate-code.txt"

typedef struct {
    int cantThenTotal;
    int cantElseTotal;
    int cantSecuenciaAnd;
    int inicioBloqueAsociado;
} DatosEstructura;

// Asembler
// Estructura para mapear nombres de la tabla de simbolos a nombres de variables ASM
typedef struct {
    char indice[50];
    char variable[100];
} datoAsm;

// Vector para la tabla de variables ASM
typedef struct {
    datoAsm items[500];
    int count;
} VectorDatosAsm;

// Pila de strings (para operandos de la pila ASM)
typedef struct {
    char items[500][100];
    int count;
} PilaStrings;

// Vector de strings (para etiquetas de ciclos/saltos)
typedef struct {
    char items[500][100];
    int count;
} VectorStrings;

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
int establecer_nuevo_operando_izquierdo(void *nro_terceto, void *nro_branch_actualizado);
void acciones_expresion_logica();
void inicializar_recursos_internos();

void reemplazarGuionBajo(char *str);
void eliminar_corchetes(char *str);
void Pila_Push(PilaStrings* pila, const char* item);
void Pila_Pop(PilaStrings* pila, char* buffer);
void VectorDatos_Add(VectorDatosAsm* vec, datoAsm dato);
const char* VectorDatos_Buscar(VectorDatosAsm* vec, const char* indice);
void VectorStr_Add(VectorStrings* vec, const char* str);
void VectorStr_Eliminar(VectorStrings* vec, const char* str);
void generar_assembler(char* nombre_archivo_asm, char* nombre_archivo_tabla, char* nombre_archivo_tercetos);
int esNumero(const char *str);
void reemplazarGuionBajo(char *str);
void reemplazar_booleanos(char *operadorIzq, char *operadorDer);

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
int Xind;

char operandoDerAux[50];
char operandoIzqAux[50];
char operadorAux[50];

int _contadorExpresionesLogicas = 0;
int _ultRefContadorEstructuras = 0;
int _contadorSecuenciaAnd = 0;
int _contadorThenActual = 0;
int _contadorThenTotal = 0;
int _contadorElseActual = 0;
int _contadorElseTotal = 0;
DatosEstructura datosEstructuraActual;
int _contadorBucles = 0;
int _inicioBucle;
int _inicioExpresion;
int _inicioBloqueAsociado;
int _indiceBIif;
const char *_tipoDatoExpresionActual;

tLista listaAuxiliar;
tPila pilaBranchThen;
tPila pilaBranchElse;
tPila pilaValoresBooleanos;
tPila pilaIndiceTercetosFuncionesEspeciales;
tPila pilaBI;
tPila pilaEstructurasAnidadas;
tPila pilaSecuenciaAnd;

int indice=0;
int indiceActual=0;
int indiceDesapilado = 0;
int indiceBranchThen;
int indiceBranchElse;

int indiceExpresiones = 0;

int _contadorExpresionesAnidadas = 0;
int _contadorEstructurasAnidadas = 0;

bool _secuenciaAND = false;
bool _secuenciaNOT = false;
bool _soloAritmetica = true;
bool _soloBooleana = true;
bool _expresionNueva = true;
bool _expresionAnidada = false;
bool _accionesExpresionAnidada = false;

char _resExpresionRelacional[MAX_RES_EXP];
char _resExpresionLogica[MAX_RES_EXP];
char _expresionEmparentadaActual[4];


Tabla tabla;
HashMap *hashmap;
HashMap *hashmapEstructurasAnidadas;
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
        printf("R1. Programa -> Def_Init Lista_Sentencias\n");
        generar_assembler("final.asm", "Symbol-Table.txt","intermediate-code.txt");
    }
    ;
    
def_init:
    INIT LLA_ABR bloque_asig LLA_CIE
    {
        printf("\t\tR2. Def_Init -> init { Bloque_Asig }\n");
    }
    ;

bloque_asig:
    lista_id DOS_PUNTOS tipo_dato
    {
        printf("\t\t\tR3. Bloque_Asig -> Lista_Id : Tipo_Dato\n");
    }
    | bloque_asig lista_id DOS_PUNTOS tipo_dato
    {
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
        printf("\t\t\t\tR5. Lista_Id -> [ID: '%s']\n", $1.str);
        free($1.str);
    } 
    | lista_id COMA ID 
    {
        if(acciones_definicion_variable($3.str, $3.codValidacion) != ACCION_EXITOSA)
        {
            YYABORT;
        } 
        printf("\t\t\t\tR6. Lista_Id -> Lista_Id COMA [ID: '%s']\n",$3.str); 
        free($3.str);
    }
    ;

tipo_dato:
    TD_BOOLEAN 
    {
        printf("\t\t\t\tR7. Tipo_Dato -> %s\n", $1.str); 
        if(acciones_asignacion_tipo($1.str) != ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
    }
    | TD_INT 
    {
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
        printf("\t\t\t\tR9. Tipo_Dato -> %s\n", $1.str); 
        if(acciones_asignacion_tipo($1.str) != ACCION_EXITOSA)
        {
            free($1.str);
            YYABORT;
        }
    }
    | TD_STRING 
    {
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
        ListaSentenciasInd = SentenciaInd;
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
        AsignacionInd = crearTerceto("=", operandoIzqAux, operandoDerAux);
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
        AsignacionInd = crearTerceto("=", operandoIzqAux, operandoDerAux);
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
        int idInd = crearTercetoUnitarioStr($1.str);
        sprintf(operandoIzqAux, "[%d]", idInd);
        int cteInd = crearTercetoUnitarioStr("1");
        sprintf(operandoDerAux, "[%d]", cteInd);
        AsignacionInd = crearTerceto("+", operandoIzqAux, operandoDerAux);
        sprintf(operandoDerAux, "[%d]", AsignacionInd);
        AsignacionInd = crearTerceto("=", operandoIzqAux, operandoDerAux);
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
        int idInd = crearTercetoUnitarioStr($1.str);
        sprintf(operandoIzqAux, "[%d]", idInd);
        int cteInd = crearTercetoUnitarioStr("1");
        sprintf(operandoDerAux, "[%d]", cteInd);
        AsignacionInd = crearTerceto("-", operandoIzqAux, operandoDerAux);
        sprintf(operandoDerAux, "[%d]", AsignacionInd);
        AsignacionInd = crearTerceto("=", operandoIzqAux, operandoDerAux);
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
        AsignacionInd = crearTerceto("=", operandoIzqAux, operandoDerAux);
        printf("\t\t\tR22. Asignacion -> [ID: '%s']:= \"%s\"\n", $1.str, $3.str);
        free($1.str);
        free($3.str);
    }
	;

condicional_si:
    IF PAR_ABR expresion PAR_CIE bloque_asociado %prec MENOS_QUE_ELSE
    {
        int i = _contadorThenTotal, i2 = _contadorElseTotal, tieneEstructuraDatosApilada = 0, inicioExpresionAsociada = _inicioBloqueAsociado;
        DatosEstructura auxDatosEstructura;
        char aux[20];

        sprintf(aux, "estructura_%d", _contadorEstructurasAnidadas);

        tieneEstructuraDatosApilada = get_HashMapEntry_value(hashmapEstructurasAnidadas, aux);

        if((tieneEstructuraDatosApilada != HM_KEY_NOT_FOUND) && (tieneEstructuraDatosApilada == 1))
        {
            if(sacar_de_pila(&pilaEstructurasAnidadas, &auxDatosEstructura, sizeof(auxDatosEstructura)) == TODO_OK)
            {
                i = auxDatosEstructura.cantThenTotal;
                i2 = auxDatosEstructura.cantElseTotal;
                inicioExpresionAsociada = auxDatosEstructura.inicioBloqueAsociado;
            }
        }

        remove_HashMapEntry(hashmapEstructurasAnidadas, aux);

        sprintf(operandoIzqAux, "[%d]", inicioExpresionAsociada);
        while(i > 0)
        {
            if(sacar_de_pila(&pilaBranchThen, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
            {
                modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
            }
            i--;
        }

        indiceActual = getIndice(); // [como en crear_terceto() hacemos indiceTerceto++ en el retorno de cada llamada, con getIndice() siempre tenemos el nro. de terceto siguiente al último creado]
        sprintf(operandoIzqAux, "[%d]", indiceActual);
        
        while(i2 > 0)
        {
            if(sacar_de_pila(&pilaBranchElse, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
            {
                modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
            }

            i2--;
        }

        _contadorEstructurasAnidadas--;
        _ultRefContadorEstructuras--;

        printf("\t\t\tR23. Condicional_Si -> if(Expresion) Bloque_Asociado\n");
    }
    | IF PAR_ABR expresion PAR_CIE bloque_asociado ELSE
    {
        int i = _contadorThenTotal, i2 = _contadorElseTotal, tieneEstructuraDatosApilada = 0, inicioExpresionAsociada = _inicioBloqueAsociado;
        DatosEstructura auxDatosEstructura;
        char aux[20];

        // si no apilé nada para la estructura

        sprintf(aux, "estructura_%d", _contadorEstructurasAnidadas);

        tieneEstructuraDatosApilada = get_HashMapEntry_value(hashmapEstructurasAnidadas, aux);

        if((tieneEstructuraDatosApilada != HM_KEY_NOT_FOUND) && (tieneEstructuraDatosApilada == 1))
        {
            if(sacar_de_pila(&pilaEstructurasAnidadas, &auxDatosEstructura, sizeof(auxDatosEstructura)) == TODO_OK)
            {
                i = auxDatosEstructura.cantThenTotal;
                i2 = auxDatosEstructura.cantElseTotal;
                inicioExpresionAsociada = auxDatosEstructura.inicioBloqueAsociado;
            }
        }

        sprintf(operandoIzqAux, "[%d]", inicioExpresionAsociada);
        while(i > 0)
        {
            if(sacar_de_pila(&pilaBranchThen, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
            {
                modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
            }
            i--;
        }

        // me guardo el nro. de terceto de BI para actualizarlo una vez que sepa donde termina la última instrucción del bloque ELSE
        _indiceBIif = crearTerceto("BI", "_saltoCeldas", "_");
        
        sprintf(operandoIzqAux, "[%d]", getIndice()); // ya sería el nro. de terceto correspondiente a la primer instrucción del bloque ELSE
        
        while(i2 > 0)
        {
            if(sacar_de_pila(&pilaBranchElse, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
            {
                modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
            }
            i2--;
        }

        _contadorEstructurasAnidadas--;
        _ultRefContadorEstructuras--;
    }
    bloque_asociado
    {   
        char aux[20];

        sprintf(operandoIzqAux, "[%d]", getIndice());
        modificarOperandoIzquierdoConTerceto(_indiceBIif, operandoIzqAux);

        printf("\t\t\tR24. Condicional_Si -> if(Expresion) Bloque_Asociado else Bloque_Asociado\n");
    }
    ;

bloque_asociado:
    sentencia 
    {
        BloqueAsociadoInd2 = BloqueAsociadoInd;
        BloqueAsociadoInd = SentenciaInd;
        printf("\t\t\t\tR25. Bloque_Asociado -> Sentencia\n");
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
        sprintf(operadorAux, "Bucle_%d:", _contadorBucles);
        _inicioBucle = crearTercetoUnitarioStr(operadorAux); // me guardo el inicio del bucle
        BucleInd = _inicioBucle;
        _contadorBucles++;
    }
    PAR_ABR expresion PAR_CIE 
    {
        char aux[20];
        int i = _contadorThenTotal, tieneEstructuraDatosApilada = 0;
        DatosEstructura auxDatosEstructura;

        sprintf(aux, "estructura_%d", _contadorEstructurasAnidadas);

        tieneEstructuraDatosApilada = get_HashMapEntry_value(hashmapEstructurasAnidadas, aux);
        
        if((tieneEstructuraDatosApilada != HM_KEY_NOT_FOUND) && (tieneEstructuraDatosApilada == 1))
        {
            if(ver_tope(&pilaEstructurasAnidadas, &auxDatosEstructura, sizeof(auxDatosEstructura)) == TODO_OK)
            {
                i = auxDatosEstructura.cantThenTotal;
            }
        }

        sprintf(operandoIzqAux, "[%d]", getIndice());
        while(i > 0)
        {
            if(sacar_de_pila(&pilaBranchThen, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
            {
                modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
            }
            i--;
        }
    }
    bloque_asociado
    {
        char aux[20];
        int i = _contadorElseTotal, tieneEstructuraDatosApilada = 0;
        DatosEstructura auxDatosEstructura;

        sprintf(operandoIzqAux, "[%d]", _inicioBucle);
        indiceActual = crearTerceto("BI", operandoIzqAux, "_");
        sprintf(operandoIzqAux, "[%d]", indiceActual + 1); // la siguiente instrucción después del BI al final del bucle
        
        sprintf(aux, "estructura_%d", _contadorEstructurasAnidadas);

        tieneEstructuraDatosApilada = get_HashMapEntry_value(hashmapEstructurasAnidadas, aux);

        if((tieneEstructuraDatosApilada != HM_KEY_NOT_FOUND) && (tieneEstructuraDatosApilada == 1))
        {
            if(sacar_de_pila(&pilaEstructurasAnidadas, &auxDatosEstructura, sizeof(auxDatosEstructura)) == TODO_OK)
            {
                i = auxDatosEstructura.cantElseTotal;
            }
        }

        remove_HashMapEntry(hashmapEstructurasAnidadas, aux);

        _contadorEstructurasAnidadas--;
        _ultRefContadorEstructuras--;

        sprintf(operandoIzqAux, "[%d]", getIndice()); // ya sería el nro. de terceto correspondiente a la primer instrucción del bloque ELSE
        while(i > 0)
        {
            if(sacar_de_pila(&pilaBranchElse, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
            {
                modificarOperandoIzquierdoConTerceto(indiceDesapilado, operandoIzqAux);
            }
            i--;
        }

        _secuenciaAND = false;
        _soloAritmetica = true;
        _soloBooleana = true;
        _contadorSecuenciaAnd = 0;

        printf("\t\t\t\tR27. Bucle -> while ( Expresion_Logica )\n");
    }
    ;

llamada_func:
    FN_EQUALEXPRESSIONS PAR_ABR 
    {
        _tipoDatoExpresionActual = NULL;

        int indOpDer = crearTercetoUnitarioStr("FALSE");
        sprintf(operandoDerAux, "[%d]", indOpDer);
        int indOpIzq = crearTercetoUnitarioStr("@resEqualExpressions");
        sprintf(operandoIzqAux, "[%d]", indOpIzq);
        crearTerceto("=", operandoIzqAux, operandoDerAux);
    }
    lista_args PAR_CIE 
    {
        recorrer_lista_argumentos_equalexpressions(&pilaIndiceTercetosFuncionesEspeciales);
        
        printf("\t\t\tR28. Llamada_Func -> equalExpressions(Lista_Args)\n");

        completar_bi_equalexpressions(&pilaBI);

        LlamadaFuncInd = crearTercetoUnitarioStr("@resEqualExpressions");
        
        char valoroBoolStr[50] = "@resEqualExpressions";
        poner_en_pila(&pilaValoresBooleanos, valoroBoolStr, sizeof(valoroBoolStr));
    }
    | FN_ISZERO 
    {
        _tipoDatoExpresionActual = NULL;
    }
    PAR_ABR expresion_aritmetica PAR_CIE 
    {
        printf("\t\t\tR29. Llamada_Func -> isZero(Lista_Args)\n");
        
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd);
        int indOpDer = crearTercetoUnitarioStr("0");
        sprintf(operandoDerAux, "[%d]", indOpDer);
        Xind = crearTerceto("CMP", operandoIzqAux, operandoDerAux);

        sprintf(operandoIzqAux, "[%d]", Xind + 8);
        crearTerceto("BNE", operandoIzqAux, "_"); // + 1

        indOpDer = crearTercetoUnitarioStr("TRUE");
        sprintf(operandoDerAux, "[%d]", indOpDer);
        int indOpIzq = crearTercetoUnitarioStr("@resIsZero");
        sprintf(operandoIzqAux, "[%d]", indOpIzq);
        Xind = crearTerceto("=", operandoIzqAux, operandoDerAux); // + 2
        
        sprintf(operandoIzqAux, "[%d]", Xind + 3);
        crearTerceto("BI",operandoIzqAux, "_"); // + 3

        indOpDer = crearTercetoUnitarioStr("FALSE");
        sprintf(operandoDerAux, "[%d]", indOpDer);
        indOpIzq = crearTercetoUnitarioStr("@resIsZero");
        sprintf(operandoIzqAux, "[%d]", indOpIzq);
        crearTerceto("=", operandoIzqAux, operandoDerAux); // + 4

        LlamadaFuncInd = crearTercetoUnitarioStr("@resIsZero");
        
        char valoroBoolStr[50] = "@resIsZero";
        poner_en_pila(&pilaValoresBooleanos, valoroBoolStr, sizeof(valoroBoolStr));
    }
    ;

lista_args:
    expresion_aritmetica
    {
        int indOpIzq = crearTercetoUnitarioStr("@pivote");
        sprintf(operandoIzqAux, "[%d]", indOpIzq);
        sprintf(operandoDerAux, "[%d]", getIndice()-2);
        ListaArgsInd = crearTerceto("=", operandoIzqAux, operandoDerAux);
        
        printf("\t\t\t\tR30. lista_args -> expresion_aritmetica\n");
        
    }
    | lista_args COMA expresion_aritmetica 
    {
        sprintf(operandoIzqAux, "[%d]", ListaArgsInd);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);

        poner_en_pila(&pilaIndiceTercetosFuncionesEspeciales, &ExpresionAritmeticaInd, sizeof(ExpresionAritmeticaInd));
        
        int indOpIzq = crearTercetoUnitarioStr("@actual");
        sprintf(operandoIzqAux, "[%d]", indOpIzq);
        sprintf(operandoDerAux, "[%d]", getIndice()-2);
        ListaArgsInd = crearTerceto("=", operandoIzqAux, operandoDerAux);
                
        printf("\t\t\t\tR31. lista_args -> lista_args , expresion_aritmetica \n");

        indOpIzq = crearTercetoUnitarioStr("@pivote");
        sprintf(operandoIzqAux, "[%d]", indOpIzq);
        int indOpDer = crearTercetoUnitarioStr("@actual");
        sprintf(operandoDerAux, "[%d]", indOpDer);    
        crearTerceto("CMP", operandoIzqAux, operandoDerAux);


        sprintf(operandoIzqAux, "[%d]", ListaArgsInd+7);
        crearTerceto("BNE", operandoIzqAux, "_");

        indOpDer = crearTercetoUnitarioStr("TRUE");
        sprintf(operandoDerAux, "[%d]", indOpDer);  
        indOpIzq = crearTercetoUnitarioStr("@resEqualExpressions");
        sprintf(operandoIzqAux, "[%d]", indOpIzq);
        crearTerceto("=", operandoIzqAux, operandoDerAux);
        
        int IndBI = crearTerceto("BI","_", "_");

        poner_en_pila(&pilaBI, &IndBI, sizeof(IndBI));
    }
    ;

entrada_salida: 
    WRITE PAR_ABR factor PAR_CIE 
    {
        sprintf(operandoDerAux, "[%d]", FactorInd);
        EntradaSalidaInd = crearTerceto("ENTRADA_SALIDA", "WRITE", operandoDerAux);
        printf("\t\t\tR31. entrada_salida -> WRITE (factor)\n");
    }
    | WRITE PAR_ABR CTE_STRING PAR_CIE 
    {
        if($3.codValidacion!=VALIDACION_OK)
        {
            YYABORT;
        }
        sprintf(operandoDerAux, "[%d]", crearTercetoUnitarioStr($3.str));
        EntradaSalidaInd = crearTerceto("ENTRADA_SALIDA", "WRITE", operandoDerAux);
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
        EntradaSalidaInd = crearTerceto("ENTRADA_SALIDA", "READ", operandoDerAux);
        printf("\t\t\tR32. entrada_salida -> READ([ID: '%s'])\n",$3.str);
        free($3.str);
    }
	;

expresion: 
    expresion_logica 
    {
        char aux[20];
        ExpresionInd = ExpresionLogicaInd;

        if(_expresionNueva)
        {
            if(_contadorExpresionesLogicas == 1)
            {
                sacar_de_pila(&pilaBranchThen, &Xind, sizeof(Xind));
                _contadorThenActual--;
                printf("DESESTIMO THEN");
            }

            if(_ultRefContadorEstructuras != _contadorEstructurasAnidadas)
            {
                // en caso de que se haya progresado en anidamiento, obtengo la entry y seteo que apilé
                if(_contadorEstructurasAnidadas >= 2)
                {
                    sprintf(aux, "estructura_%d", _contadorEstructurasAnidadas - 1);
                    update_HashMapEntry_value(hashmapEstructurasAnidadas, aux, 1);
                }

                datosEstructuraActual.cantThenTotal = _contadorThenTotal;
                datosEstructuraActual.cantElseTotal = _contadorElseTotal;
                // cada elemento apilado corresponde a _contadorEstructurasAnidadas - 1
                poner_en_pila(&pilaEstructurasAnidadas, &datosEstructuraActual, sizeof(datosEstructuraActual));
                _ultRefContadorEstructuras++;

                // creo la entry para la nueva estructura y defino que no apilé nada para la misma
                sprintf(aux, "estructura_%d", _contadorEstructurasAnidadas);
                add_HashMapEntry(hashmapEstructurasAnidadas, aux, 0);

                _contadorThenTotal = 0;
                _contadorElseTotal = 0;
            }

            _contadorThenTotal += _contadorThenActual;
            _contadorElseTotal += _contadorElseActual;

            vaciarLista(&listaAuxiliar);
            _soloAritmetica = true;
            _soloBooleana = true;
            _contadorThenActual = 0;
            _contadorElseActual = 0;

            if(!_expresionAnidada)
            {
                _contadorSecuenciaAnd = 0;
                _secuenciaAND = false;
            }

            _contadorExpresionesLogicas = 0;

            _inicioBloqueAsociado = getIndice();
            datosEstructuraActual.inicioBloqueAsociado = getIndice();

            _accionesExpresionAnidada = false;

            // a1: agregar
            _expresionAnidada = false;
            
            printf("\t\t\t\tR35. Expresion -> Expresion_Logica\n");
        }

        _expresionNueva = true;
    }
	;

expresion_logica:
    expresion_logica OP_AND
    {
        // desestimo el then previo ya que siempre va a ser a la siguiente instrucción
        sacar_de_pila(&pilaBranchThen, &Xind, sizeof(Xind));
        _contadorThenActual--;

        // si estamos en secuencia negada o no, todos los else
        // deben manejarlos una instancia superior

        if(_secuenciaNOT && (_contadorSecuenciaAnd == 1))
        {
            sacar_de_pila(&pilaBranchElse, &Xind, sizeof(Xind));
            _contadorElseActual--;
            ponerAlComienzo(&listaAuxiliar, &Xind, sizeof(Xind));
        }

        _expresionNueva = true;
        _soloAritmetica = true;
        _soloBooleana = true;

        _secuenciaAND = true;
    }
    expresion_para_condicion 
    {
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        ExpresionLogicaInd = ExpresionparaCondicionInd;

        if(_expresionNueva)
        {
            // a4
            //sacar_de_pila(&pilaValoresBooleanos, _resExpresionRelacional, MAX_RES_EXP);

            // q4
            //crearTerceto("CMP", _resExpresionRelacional, "VERDADERO");

            // branch a else
            sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
            // a4
            //indiceBranchElse = crearTerceto("BNE", operandoIzqAux, "_");
            if(_secuenciaNOT == false)
            {
                poner_en_pila(&pilaBranchElse, &indiceBranchElse, sizeof(indiceBranchElse));
                _contadorElseActual++;
            }
            else
            {
                ponerAlComienzo(&listaAuxiliar, &indiceBranchElse, sizeof(indiceBranchElse));
            }

            // branch incondicional then
            // necesito sí o sí tener uno para cada resultado de expresion relacional ya que
            // en casos de negación cambian los comportamientos
            sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
            // a4
            //indiceActual = crearTerceto("BI", operandoIzqAux, "_");
            poner_en_pila(&pilaBranchThen, &indiceBranchThen, sizeof(indiceBranchThen));
            _contadorThenActual++;
            
            _contadorSecuenciaAnd++;

            // si estamos en una SECUENCIA AND NEGADA
            if(_secuenciaNOT && _secuenciaAND)
            {
                int i = _contadorSecuenciaAnd;
                
                // los branchs else deben ir al inicio de la próxima instancia
                // todos los else se comportan como then

                sprintf(operandoIzqAux, "[%d]", indiceBranchElse + 2);
                mapLista(&listaAuxiliar, establecer_nuevo_operando_izquierdo, operandoIzqAux);

                if(_contadorSecuenciaAnd > 2)
                {
                    // el último then se comporta como else, entonces desestimo el anterior
                    sacar_de_pila(&pilaBranchElse, &Xind, sizeof(Xind));
                    _contadorElseActual--;
                    // obtengo el más reciente
                    ver_tope(&pilaBranchThen, &indiceBranchThen, sizeof(indiceBranchThen));
                    sprintf(operandoIzqAux, "[%d]", indiceBranchThen);
                    modificarOperandoIzquierdoConTerceto(Xind, operandoIzqAux);
                }

                sacar_de_pila(&pilaBranchThen, &indiceBranchThen, sizeof(indiceBranchThen));
                _contadorThenActual--;
                // dejo que una instancia superior establezca el fin de cuerpo true
                poner_en_pila(&pilaBranchElse, &indiceBranchThen, sizeof(indiceBranchThen));
                _contadorElseActual++;
            }
            
            // si NO ES NEGADA, ** en una instancia superior **, recupero los else y then involucrados y actualizo 
            // según corresponda

            _contadorExpresionesLogicas++;
            
            // a2: eliminar
            // _expresionAnidada = false;

            printf("\t\t\t\t\tR36. Expresion_Logica -> Expresion AND Expresion\n");
        }
    }
    | expresion_logica OP_OR
    {
        // si previamente NO TENEMOS una SECUENCIA AND o comienza una expresión anidada
        if((_secuenciaAND == false) || _expresionAnidada)
        {
            // desestimo los else
            sacar_de_pila(&pilaBranchElse, &Xind, sizeof(Xind));
            _contadorElseActual--;

            // y si NO es una SECUENCIA NEGADA, los then van al inicio del cuerpo true superior

            // pero si además es una SECUENCIA NEGADA,
            if(_secuenciaNOT)
            {
                // los then se comportan como else
                sacar_de_pila(&pilaBranchThen, &Xind, sizeof(Xind));
                _contadorThenActual--;
                poner_en_pila(&pilaBranchElse, &Xind, sizeof(Xind));
            }
        }
        else if(_contadorSecuenciaAnd) // si TENEMOS SECUENCIA AND
        {
            // si además ES NEGADA,
            if(_secuenciaNOT)
            {   
                // el último else va hacia la parte true de instancia superior
                sacar_de_pila(&pilaBranchElse, &indiceBranchElse, sizeof(indiceBranchElse));
                _contadorElseActual--;

                // el último then debe comportarse como else
                sacar_de_pila(&pilaBranchThen, &indiceBranchThen, sizeof(indiceBranchThen));
                
                poner_en_pila(&pilaBranchThen, &indiceBranchElse, sizeof(indiceBranchElse));

                _contadorSecuenciaAnd--;
                while(_contadorSecuenciaAnd > 0)
                {
                    sacar_de_pila(&pilaBranchElse, &Xind, sizeof(Xind));
                    _contadorElseActual--;
                    _contadorSecuenciaAnd--;
                }

                poner_en_pila(&pilaBranchElse, &indiceBranchThen, sizeof(indiceBranchThen));
                _contadorElseActual++;
            }
            else
            {
                // si hay una secuencia AND y NO es negada,
                
                sprintf(operandoIzqAux, "[%d]", getIndice());
                // desestimo los else del mismo nivel (considerando anidamiento, o no), van hacia la prox eval
                while(_contadorSecuenciaAnd > 0)
                {
                    if(sacar_de_pila(&pilaBranchElse, &Xind, sizeof(Xind)) == TODO_OK)
                    {
                        _contadorElseActual--;
                        modificarOperandoIzquierdoConTerceto(Xind, operandoIzqAux);
                    }
                    _contadorSecuenciaAnd--;
                }
            }
        }

        _secuenciaAND = false;
        _contadorSecuenciaAnd = 0;
        
        _expresionNueva = true;
        _soloAritmetica = true;
        _soloBooleana = true;
    }
    expresion_para_condicion 
    {
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        ExpresionLogicaInd = ExpresionparaCondicionInd;

        if(_expresionNueva)
        {
            sacar_de_pila(&pilaValoresBooleanos, _resExpresionRelacional, MAX_RES_EXP);

            // a4
            //crearTerceto("CMP", _resExpresionRelacional, "VERDADERO");

            // branch a else
            sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
            // a4
            //indiceActual = crearTerceto("BNE", operandoIzqAux, "_");
            poner_en_pila(&pilaBranchElse, &indiceBranchElse, sizeof(indiceBranchElse));
            _contadorElseActual++;

            // branch incondicional then
            // necesito sí o sí tener uno para cada resultado de expresion relacional ya que
            // en casos de negación cambian los comportamientos
            sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
            
            //indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
            poner_en_pila(&pilaBranchThen, &indiceBranchThen, sizeof(indiceBranchThen));
            _contadorThenActual++;

            // si estamos en una SECUENCIA NEGADA
            if(_secuenciaNOT)
            {
                // todos los else se comportan como una secuencia then de AND
                // y el último va hacia la parte true de instancia superior
                sacar_de_pila(&pilaBranchElse, &indiceBranchElse, sizeof(indiceBranchElse));
                _contadorElseActual--;

                // todos los then se comportan como un else
                while(sacar_de_pila(&pilaBranchThen, &indiceDesapilado, sizeof(indiceDesapilado)) == TODO_OK)
                {
                    _contadorThenActual--;
                    poner_en_pila(&pilaBranchElse, &indiceDesapilado, sizeof(indiceDesapilado));
                    _contadorElseActual++;
                }

                poner_en_pila(&pilaBranchThen, &indiceBranchElse, sizeof(indiceBranchElse));
                _contadorThenActual++;
            }
            else // si NO ES UNA SECUENCIA NEGADA
            {
                // los then de cada miembro del OR deben ir a la siguiente instrucción de la parte true superior
                // sprintf(operandoDerAux, "[%d]", getIndice());
                // while(sacar_de_pila(&pilaBranchThen, &Xind, sizeof(Xind)) == TODO_OK)
                //{
                //    _contadorThenActual--;
                //   modificarOperandoIzquierdoConTerceto(Xind, operandoIzqAux);
                //}
            }

            // tengo que tener en cuenta tantos branchs else como operandos izquierdos hayan habido

            _contadorExpresionesLogicas++;

            printf("\t\t\t\t\tR37. Expresion_Logica -> Expresion OR Expresion\n");
        }
    }
    | OP_NOT 
    {
        _secuenciaNOT = true;
    }
    expresion_logica %prec NEGACION 
    {
        ExpresionLogicaInd2 = ExpresionLogicaInd;

        if(_contadorExpresionesLogicas == 1)
        {
            sacar_de_pila(&pilaBranchThen, &indiceBranchThen, sizeof(indiceBranchThen));
            sacar_de_pila(&pilaBranchElse, &indiceBranchElse, sizeof(indiceBranchElse));
            poner_en_pila(&pilaBranchThen, &indiceBranchElse, sizeof(indiceBranchElse));
            poner_en_pila(&pilaBranchElse, &indiceBranchThen, sizeof(indiceBranchThen));
        }
        
        _secuenciaNOT = false;

        printf("\t\t\t\t\tR38. Expresion_Logica -> NOT Expresion\n");
    }
    | expresion_para_condicion %prec PRIORIDAD_EXPRESION
    {
        // lo paso tal cual viene
        ExpresionLogicaInd2 = ExpresionLogicaInd;
        ExpresionLogicaInd = ExpresionparaCondicionInd;

        if(_expresionNueva)
        {
            // a4: eliminar
            //sacar_de_pila(&pilaValoresBooleanos, _resExpresionRelacional, MAX_RES_EXP);
            //crearTerceto("CMP", _resExpresionRelacional, "VERDADERO");

            // branch a else
            //sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
            //indiceBranchElse = crearTerceto("BNE", operandoIzqAux, "_");
            poner_en_pila(&pilaBranchElse, &indiceBranchElse, sizeof(indiceBranchElse));
            _contadorElseActual++;

            // branch incondicional then
            // necesito sí o sí tener uno para cada resultado de expresion relacional ya que
            // en casos de negación cambian los comportamientos
            //sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
            //indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
            poner_en_pila(&pilaBranchThen, &indiceBranchThen, sizeof(indiceBranchThen));
            _contadorThenActual++;

            _contadorSecuenciaAnd++;
            _contadorExpresionesLogicas++;
        }

        printf("\t\t\t\t\tR39. Expresion_Logica -> Expresion_Para_Condicion\n");
    }
    ;

expresion_para_condicion:
    expresion_relacional
    {
        if(_soloAritmetica && _expresionNueva)
        {   
            sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
            int indOpDer = crearTercetoUnitarioStr("0");
            sprintf(operandoDerAux, "[%d]", indOpDer);
            crearTerceto("CMP", operandoIzqAux, operandoDerAux); // cero ya que una expresión aritmética es VERDADERO si es <> 0

            // branch por else
            sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
            indiceBranchElse = crearTerceto("BE", operandoIzqAux, "_");
            
            // branch incondicional del then
            sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
            indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
        }
        if(_soloBooleana && _expresionNueva)
        {
            sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
            int indOpDer = crearTercetoUnitarioStr("true");
            sprintf(operandoDerAux, "[%d]", indOpDer);
            crearTerceto("CMP", operandoIzqAux, operandoDerAux);

            // branch por else
            sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
            indiceBranchElse = crearTerceto("BNE", operandoIzqAux, "_");

            // branch incondicional del then
            sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
            indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
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
        sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);

        //sprintf(_resExpresionRelacional, "@resExpresionRelacional_%d", indiceExpresiones);
        //poner_en_pila(&pilaValoresBooleanos, _resExpresionRelacional, strlen(_resExpresionRelacional));
        //indiceExpresiones++;
        
        //if(get_HashMapEntry_value(hashmap, _resExpresionRelacional) == HM_KEY_NOT_FOUND)
        //{
        //    add_HashMapEntry(hashmap, _resExpresionRelacional, 0);
        //    agregar_a_tabla_variables_internas(&tabla, _resExpresionRelacional, "Boolean");
        //}

        // branch por else
        sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
        indiceBranchElse = crearTerceto("BLE", operandoIzqAux, "_");

        //crearTerceto(":=", _resExpresionRelacional, "VERDADERO");
        
        // branch incondicional del then
        sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
        indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");

        //crearTerceto(":=", _resExpresionRelacional, "FALSO");
        
        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR44. Expresion_Relacional -> Expresion_Aritmetica > Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_MENOR expresion_aritmetica %prec PREC_RELACIONAL
    {
        sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        
        //sprintf(_resExpresionRelacional, "@resExpresion_%d", indiceExpresiones);
        //poner_en_pila(&pilaValoresBooleanos, _resExpresionRelacional, strlen(_resExpresionRelacional));
        //indiceExpresiones++;

        //if(get_HashMapEntry_value(hashmap, _resExpresionRelacional) == HM_KEY_NOT_FOUND)
        //{
        //    add_HashMapEntry(hashmap, _resExpresionRelacional, 0);
        //    agregar_a_tabla_variables_internas(&tabla, _resExpresionRelacional, "Boolean");
        //}
        
        // branch por else
        sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
        indiceBranchElse = crearTerceto("BGE", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "VERDADERO");
        
        // branch incondicional del then
        sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
        indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "FALSO");

        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR45. Expresion_Relacional -> Expresion_Aritmetica < Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_ES_IGUAL expresion_aritmetica %prec PREC_RELACIONAL
    {
        sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        
        //sprintf(_resExpresionRelacional, "@resExpresion_%d", indiceExpresiones);
        //poner_en_pila(&pilaValoresBooleanos, _resExpresionRelacional, strlen(_resExpresionRelacional));
        //indiceExpresiones++;

        //if(get_HashMapEntry_value(hashmap, _resExpresionRelacional) == HM_KEY_NOT_FOUND)
        //{
        //    add_HashMapEntry(hashmap, _resExpresionRelacional, 0);
        //    agregar_a_tabla_variables_internas(&tabla, _resExpresionRelacional, "Boolean");
        //}
        
        // branch por else
        sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
        indiceBranchElse = crearTerceto("BNE", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "VERDADERO");
        
        // branch incondicional del then
        sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
        indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "FALSO");

        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR46. Expresion_Relacional -> Expresion_Aritmetica == Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_DISTINTO expresion_aritmetica %prec PREC_RELACIONAL
    {
        sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);
        
        //sprintf(_resExpresionRelacional, "@resExpresion_%d", indiceExpresiones);
        //poner_en_pila(&pilaValoresBooleanos, _resExpresionRelacional, strlen(_resExpresionRelacional));
        //indiceExpresiones++;
        
        //if(get_HashMapEntry_value(hashmap, _resExpresionRelacional) == HM_KEY_NOT_FOUND)
        //{
        //    add_HashMapEntry(hashmap, _resExpresionRelacional, 0);
        //    agregar_a_tabla_variables_internas(&tabla, _resExpresionRelacional, "Boolean");
        //}
        
        // branch por else
        sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
        indiceBranchElse = crearTerceto("BE", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "VERDADERO");
        
        // branch incondicional del then
        sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
        indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "FALSO");

        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR46. Expresion_Relacional -> Expresion_Aritmetica == Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_MAYOR_IGUAL expresion_aritmetica %prec PREC_RELACIONAL
    {
        sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);

        //sprintf(_resExpresionRelacional, "@resExpresion_%d", indiceExpresiones);
        //poner_en_pila(&pilaValoresBooleanos, _resExpresionRelacional, strlen(_resExpresionRelacional));
        //indiceExpresiones++;
        
        //if(get_HashMapEntry_value(hashmap, _resExpresionRelacional) == HM_KEY_NOT_FOUND)
        //{
        //    add_HashMapEntry(hashmap, _resExpresionRelacional, 0);
        //    agregar_a_tabla_variables_internas(&tabla, _resExpresionRelacional, "Boolean");
        //}

        // branch por else
        sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
        indiceBranchElse = crearTerceto("BLT", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "VERDADERO");
        
        // branch incondicional del then
        sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
        indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "FALSO");

        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR47. Expresion_Relacional -> Expresion_Aritmetica >= Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_MENOR_IGUAL expresion_aritmetica %prec PREC_RELACIONAL
    {
        sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
        sprintf(operandoDerAux, "[%d]", ExpresionAritmeticaInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);

        //sprintf(_resExpresionRelacional, "@resExpresion_%d", indiceExpresiones);
        //poner_en_pila(&pilaValoresBooleanos, _resExpresionRelacional, strlen(_resExpresionRelacional));
        //indiceExpresiones++;

        //if(get_HashMapEntry_value(hashmap, _resExpresionRelacional) == HM_KEY_NOT_FOUND)
        //{
        //    add_HashMapEntry(hashmap, _resExpresionRelacional, 0);
        //    agregar_a_tabla_variables_internas(&tabla, _resExpresionRelacional, "Boolean");
        //}
        
        // branch por else
        sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
        indiceBranchElse = crearTerceto("BGT", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "VERDADERO");
        
        // branch incondicional del then
        sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
        indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "FALSO");

        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR48. Expresion_Relacional -> Expresion_Aritmetica <= Expresion_Aritmetica\n");
    }
    | expresion_relacional CMP_ES_IGUAL valor_booleano 
    {
        sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
        sprintf(operandoDerAux, "[%d]", ValorBooleanoInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);

        //sprintf(_resExpresionRelacional, "@resExpresion_%d", indiceExpresiones);
        //poner_en_pila(&pilaValoresBooleanos, _resExpresionRelacional, strlen(_resExpresionRelacional));
        //indiceExpresiones++;

        //if(_tipoDatoExpresionActual)

        //if(get_HashMapEntry_value(hashmap, _resExpresionRelacional) == HM_KEY_NOT_FOUND)
        //{
        //    add_HashMapEntry(hashmap, _resExpresionRelacional, 0);
        //    agregar_a_tabla_variables_internas(&tabla, _resExpresionRelacional, "Boolean");
        //}
        
        // branch por else
        sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
        indiceBranchElse = crearTerceto("BNE", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "VERDADERO");
        
        // branch incondicional del then
        sprintf(operandoIzqAux, "[%d]", getIndice() + 1);
        indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "FALSO");

        _soloAritmetica = false;
        _soloBooleana = false;
        printf("\t\t\t\t\tR39. Expresion_Para_Condicion -> Valor_Booleano\n");
    }
    | expresion_relacional CMP_DISTINTO valor_booleano 
    {
        sprintf(operandoIzqAux, "[%d]", ExpresionRelacionalInd);
        sprintf(operandoDerAux, "[%d]", ValorBooleanoInd);
        ExpresionRelacionalInd = crearTerceto("CMP", operandoIzqAux, operandoDerAux);

        //sprintf(_resExpresionRelacional, "@resExpresion_%d", indiceExpresiones);
        //poner_en_pila(&pilaValoresBooleanos, _resExpresionRelacional, strlen(_resExpresionRelacional));
        //indiceExpresiones++;

        //if(get_HashMapEntry_value(hashmap, _resExpresionRelacional) == HM_KEY_NOT_FOUND)
        //{
        //    add_HashMapEntry(hashmap, _resExpresionRelacional, 0);
        //    agregar_a_tabla_variables_internas(&tabla, _resExpresionRelacional, "Boolean");
        //}
        
        // branch por else
        sprintf(operandoIzqAux, "[%d]", getIndice() + 3);
        indiceBranchElse = crearTerceto("BE", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "VERDADERO");
        
        // branch incondicional del then
        sprintf(operandoIzqAux, "[%d]", getIndice() + 2);
        indiceBranchThen = crearTerceto("BI", operandoIzqAux, "_");
        
        //crearTerceto(":=", _resExpresionRelacional, "FALSO");

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
        
        if(get_HashMapEntry_value(hashmap, "1") == HM_KEY_NOT_FOUND)
        {
            add_HashMapEntry(hashmap, "1", 0);
            agregar_a_tabla(&tabla, "1", "CTE_INT");
        }
    }
    | FALSE 
    {
        ValorBooleanoInd = crearTercetoUnitarioStr("FALSE");
        printf("\t\t\t\t\tR43. Valor_Booleano -> FALSE\n");

        if(get_HashMapEntry_value(hashmap, "0") == HM_KEY_NOT_FOUND)
        {
            add_HashMapEntry(hashmap, "0", 0);
            agregar_a_tabla(&tabla, "0", "CTE_INT");
        }
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
        ExpresionAritmeticaInd = crearTerceto("-", operandoIzqAux, "_");
        printf("\t\t\t\t\tR50. Expresion_Aritmetica -> - Expresion_Aritmetica\n");
    }
	| expresion_aritmetica OP_SUM termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd);
        sprintf(operandoDerAux, "[%d]", TerminoInd);
        ExpresionAritmeticaInd = crearTerceto("+", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\tR51. Expresion_Aritmetica -> Expresion_Aritmetica + Termino\n");
    }
	| expresion_aritmetica OP_RES termino 
    {
        ExpresionAritmeticaInd2 = ExpresionAritmeticaInd;
        sprintf(operandoIzqAux, "[%d]", ExpresionAritmeticaInd);
        sprintf(operandoDerAux, "[%d]", TerminoInd);
        ExpresionAritmeticaInd = crearTerceto("-", operandoIzqAux, operandoDerAux);
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
        TerminoInd = crearTerceto("*", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\t\tR54. Termino -> Termino * Factor\n");
    }
    | termino OP_DIV factor 
    {
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        sprintf(operandoDerAux, "[%d]", FactorInd);
        TerminoInd = crearTerceto("/", operandoIzqAux, operandoDerAux);
        printf("\t\t\t\t\t\tR55. Termino -> Termino / Factor\n");
    }
    | termino OP_MOD factor 
    {
        sprintf(operandoIzqAux, "[%d]", TerminoInd);
        sprintf(operandoDerAux, "[%d]", FactorInd);
        TerminoInd = crearTerceto("%", operandoIzqAux, operandoDerAux);
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
    | PAR_ABR 
    {
        _soloAritmetica = true;
        _soloBooleana = true;
        _expresionAnidada = true;
        poner_en_pila(&pilaSecuenciaAnd, &_contadorSecuenciaAnd, sizeof(_contadorSecuenciaAnd));
        _contadorSecuenciaAnd = 0;
        _contadorExpresionesAnidadas++;

    }
    expresion PAR_CIE 
    {
        int aux;
        FactorInd = ExpresionInd;
        
        _expresionNueva = false;
        
        if(sacar_de_pila(&pilaSecuenciaAnd, &aux, sizeof(aux)) == TODO_OK)
        {
            _contadorSecuenciaAnd += aux;
        }
        else
        {
            _contadorSecuenciaAnd = 0;
        }

        _contadorExpresionesAnidadas--;

        if(_contadorExpresionesAnidadas == 0)
        {
            _expresionAnidada = false;
        }

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
    crearLista(&listaAuxiliar);
    crear_pila(&pilaVars);
    crear_pila(&pilaBranchThen);
    crear_pila(&pilaBranchElse);
    crear_pila(&pilaIndiceTercetosFuncionesEspeciales);
    crear_pila(&pilaBI);
    crear_pila(&pilaValoresBooleanos);
    crear_pila(&pilaEstructurasAnidadas);
    crear_pila(&pilaSecuenciaAnd);
    hashmapEstructurasAnidadas = create_HashMap(HASHMAP_SIZE);

    printf("\n-----------------------------------------------------------------------------------------------------------------\n");
    printf("                                        INICIO PROCESO ANALISIS SINTACTICO                                        ");
    printf("\n-----------------------------------------------------------------------------------------------------------------\n");

    iniciar_tabla(&tabla);
    _tipoDatoExpresionActual = NULL;
    
    inicializar_recursos_internos();
    
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

    destroy_HashMap(hashmap);
    vaciarLista(&listaAuxiliar);
    vaciar_pila(&pilaVars);
    vaciar_pila(&pilaBranchThen);
    vaciar_pila(&pilaBranchElse);
    vaciar_pila(&pilaIndiceTercetosFuncionesEspeciales);
    vaciar_pila(&pilaBI);
    vaciar_pila(&pilaValoresBooleanos);
    vaciar_pila(&pilaEstructurasAnidadas);
    vaciar_pila(&pilaSecuenciaAnd);
    destroy_HashMap(hashmapEstructurasAnidadas);

    imprimirTercetos();

    return PROCESO_EXITOSO;
}

int yyerror(void)
{
    printf("Error Sintactico\n");
}

void inicializar_recursos_internos()
{
    if(get_HashMapEntry_value(hashmap, "@resEqualExpressions") == HM_KEY_NOT_FOUND)
    {
	    add_HashMapEntry(hashmap, "@resEqualExpressions", 0);
        agregar_a_tabla_variables_internas(&tabla, "@resEqualExpressions", "Boolean");
    }

    if(get_HashMapEntry_value(hashmap, "@resIsZero") == HM_KEY_NOT_FOUND)
    {
        add_HashMapEntry(hashmap, "@resIsZero", 0);
        agregar_a_tabla_variables_internas(&tabla, "@resIsZero", "Boolean");
    }

    if(get_HashMapEntry_value(hashmap, "@pivote") == HM_KEY_NOT_FOUND)
    {
        add_HashMapEntry(hashmap, "@pivote", 0);
        agregar_a_tabla_variables_internas(&tabla, "@pivote", "Int");
    }

    if(get_HashMapEntry_value(hashmap, "@actual") == HM_KEY_NOT_FOUND)
    {
        add_HashMapEntry(hashmap, "@actual", 0);
        agregar_a_tabla_variables_internas(&tabla, "@actual", "Int");
    }
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
    int IndBI, indOpIzq, indOpDer;
    for (int i = 0; i < tam - 1; i++)
    {
        int indicePivote = vec[i];
        indOpIzq = crearTercetoUnitarioStr("@pivote");
        sprintf(operandoIzqAux, "[%d]", indOpIzq);
        sprintf(operandoDerAux, "[%d]", indicePivote);
        crearTerceto(":=", operandoIzqAux, operandoDerAux);

        for (int j = i + 1; j < tam; j++)
        {
            indiceActual = vec[j];
            sprintf(operandoDerAux, "[%d]", indiceActual);
            indOpIzq = crearTercetoUnitarioStr("@actual");
            sprintf(operandoIzqAux, "[%d]", indOpIzq);
            ListaArgsInd = crearTerceto("=", operandoIzqAux, operandoDerAux); // ListaArgsInd = 0
            
            indOpIzq = crearTercetoUnitarioStr("@pivote");
            sprintf(operandoIzqAux, "[%d]", indOpIzq);
            indOpDer = crearTercetoUnitarioStr("@actual");
            sprintf(operandoDerAux, "[%d]", indOpIzq);
            crearTerceto("CMP", operandoIzqAux, operandoDerAux); // + 1
            sprintf(operandoIzqAux, "[%d]", ListaArgsInd + 5);
            crearTerceto("BNE", operandoIzqAux, "_"); // +2
            indOpDer = crearTercetoUnitarioStr("TRUE");
            sprintf(operandoDerAux, "[%d]", indOpIzq);
            indOpIzq = crearTercetoUnitarioStr("@resEqualExpressions");
            sprintf(operandoIzqAux, "[%d]", indOpIzq);
            crearTerceto("=", operandoIzqAux, operandoDerAux); // + 3
            IndBI = crearTerceto("BI", "_", "_"); // + 4

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

/* ****************************************************************************** */

int establecer_nuevo_operando_izquierdo(void *nro_terceto, void *nro_branch_actualizado)
{
    int n_terceto, n_branch;

    if((nro_terceto == NULL) || (nro_branch_actualizado == NULL))
    {
        return 0;
    }

    n_terceto = *((int *) nro_terceto);

    modificarOperandoIzquierdoConTerceto(n_terceto, (char *) nro_branch_actualizado);

    return 1;
}

void acciones_expresion_logica()
{
    char aux[20];

    if(_ultRefContadorEstructuras != _contadorEstructurasAnidadas)
        {
            // en caso de que se haya progresado en anidamiento, obtengo la entry y seteo que apilé
            if(_contadorEstructurasAnidadas >= 2)
            {
                sprintf(aux, "estructura_%d", _contadorEstructurasAnidadas - 1);
                update_HashMapEntry_value(hashmapEstructurasAnidadas, aux, 1);
            }

            datosEstructuraActual.cantThenTotal = _contadorThenTotal;
            datosEstructuraActual.cantElseTotal = _contadorElseTotal;
            datosEstructuraActual.cantSecuenciaAnd = _contadorSecuenciaAnd;
            // cada elemento apilado corresponde a _contadorEstructurasAnidadas - 1
            poner_en_pila(&pilaEstructurasAnidadas, &datosEstructuraActual, sizeof(datosEstructuraActual));
            _ultRefContadorEstructuras++;

            // creo la entry para la nueva estructura y defino que no apilé nada para la misma
            sprintf(aux, "estructura_%d", _contadorEstructurasAnidadas);
            add_HashMapEntry(hashmapEstructurasAnidadas, aux, 0);

            _contadorThenTotal = 0;
            _contadorElseTotal = 0;
            _contadorSecuenciaAnd = 0;
        }

        _contadorThenTotal += _contadorThenActual;
        _contadorElseTotal += _contadorElseActual;

        _soloAritmetica = true;
        _soloBooleana = true;
        _expresionNueva = true;
        vaciarLista(&listaAuxiliar);
        _contadorThenActual = 0;

        _contadorExpresionesLogicas = 0;
}


/***************************************************************************
******************************************************************************
**********************************************************************************/
void reemplazarGuionBajo(char *str) {
    while (*str) {
        if (*str == ' ' || *str == '.' || *str == '-') {
            *str = '_';
        }
        str++;
    }
}

void eliminar_corchetes(char *str) {
    int len = strlen(str);
    if (len > 2 && str[0] == '[' && str[len - 1] == ']') {
        memmove(str, str + 1, len - 2);
        str[len - 2] = '\0';
    }
}

void Pila_Push(PilaStrings* pila, const char* item) {
    if (pila->count < MAX_TERCETOS) {
        strcpy(pila->items[pila->count++], item);
    }
}

void Pila_Pop(PilaStrings* pila, char* buffer) {
    if (pila->count > 0) {
        strcpy(buffer, pila->items[--pila->count]);
    }
}

void VectorDatos_Add(VectorDatosAsm* vec, datoAsm dato) {
    if (vec->count < TAM_TABLA) {
        vec->items[vec->count++] = dato;
    }
}

const char* VectorDatos_Buscar(VectorDatosAsm* vec, const char* indice) {
    for (int i = 0; i < vec->count; i++) {
        if (strcmp(vec->items[i].indice, indice) == 0) {
            return vec->items[i].variable;
        }
    }
    return NULL;
}

void VectorStr_Add(VectorStrings* vec, const char* str) {
    if (vec->count < MAX_TERCETOS) {
        strcpy(vec->items[vec->count++], str);
    }
}

int VectorStr_Buscar(VectorStrings* vec, const char* str) {
    for (int i = 0; i < vec->count; i++) {
        if (strcmp(vec->items[i], str) == 0) {
            return i;
        }
    }
    return -1;
}

void VectorStr_Eliminar(VectorStrings* vec, const char* str) {
    int i = VectorStr_Buscar(vec, str);
    if (i == -1) return;

    for (int j = i; j < vec->count - 1; j++) {
        strcpy(vec->items[j], vec->items[j + 1]);
    }
    vec->count--;
}

void generar_assembler(char* nombre_archivo_asm, char* nombre_archivo_tabla, char* nombre_archivo_tercetos) 
{
    FILE *fileASM = fopen(nombre_archivo_asm, "w");
    if (fileASM == NULL) {
        printf("Error al intentar guardar el codigo assemblr en archivo %s.", nombre_archivo_asm);
        return;
    }

    HashMap *hashmapCteString = create_HashMap(3);

    fprintf(fileASM, "include number.asm\n");
    fprintf(fileASM, "include macros2.asm\n\n");
    
    fprintf(fileASM, ".MODEL LARGE\n");
    fprintf(fileASM, ".386\n");
    fprintf(fileASM, ".STACK 200h\n\n");
    fprintf(fileASM, "MAXTEXTSIZE equ 40\n\n");
    fprintf(fileASM, "\n.DATA\n");

    // Hasta aca esta bien

    VectorDatosAsm ListaVariables;
    ListaVariables.count = 0;
    
    datoAsm dato;
    int contCteCad = 1;

    printf("\n[DEBUG-ASM] Iniciando generacion .DATA. Total de filas en tabla: %d\n", tabla.nFilas);
    fflush(stdout); // Forzamos la salida por si acaso

    for (int i = 0; i < tabla.nFilas; i++) 
    {
        InformacionToken* _simbolo = &tabla.filas[i];

        // DEBUG: Imprimir datos crudos del simbolo actual
        printf("\n[DEBUG-ASM] Procesando fila %d: Nombre='%s'\n", i, _simbolo->nombre);
        printf("    -> TipoDato='%s', Valor='%s', Longitud=%d\n", 
               _simbolo->tipoDato ? _simbolo->tipoDato : "(null)", 
               _simbolo->valor ? _simbolo->valor : "(null)", 
               _simbolo->longitud);

        if (_simbolo->valor && (strcmp(_simbolo->valor, "-") == 0)) 
        {
            
            // DEBUG: Detectado como VARIABLE
            printf("    -> Detectado como: VARIABLE\n");

            // Aseguramos que tipoDato no sea NULL antes de compararlo
            if (_simbolo->tipoDato && strcmp(_simbolo->tipoDato, DSTRING) == 0) {
                // DEBUG: Es un DSTRING
                printf("    -> Tipo: DSTRING. Escribiendo en ASM: s_%s\n", _simbolo->nombre);
                
                fprintf(fileASM, "s_%s\t\tdb MAXTEXTSIZE dup (?), '$'\n", _simbolo->nombre);
                strcpy(dato.indice, _simbolo->nombre);
                sprintf(dato.variable, "s_%s", _simbolo->nombre);
                VectorDatos_Add(&ListaVariables, dato);
            } 
            else 
            {
                // DEBUG: Es otra variable
                printf("    -> Tipo: OTRO (Int/Float). Escribiendo en ASM: %s\n", _simbolo->nombre);

                fprintf(fileASM, "%s\t\tdd\t\t?\n", _simbolo->nombre);
                strcpy(dato.indice, _simbolo->nombre);
                strcpy(dato.variable, _simbolo->nombre);
                VectorDatos_Add(&ListaVariables, dato);
            }
        } 
        else 
        {
            // DEBUG: Detectado como CONSTANTE
            printf("    -> Detectado como: CONSTANTE\n");

            char nombre_limpio[100];
            strcpy(nombre_limpio, _simbolo->nombre);

            if (_simbolo->longitud > 0) 
            {
                // DEBUG: Constante de String
                printf("    -> Tipo: CONSTANTE STRING. Valor: %s\n", _simbolo->valor);

                reemplazarGuionBajo(nombre_limpio);
                fprintf(fileASM, "_cte_cad_%d\t\tdb\t\t%s,'$', %d dup (?)\n", contCteCad, _simbolo->valor, _simbolo->longitud);
                
                add_HashMapEntry(hashmapCteString, _simbolo->valor, contCteCad);

                strcpy(dato.indice, _simbolo->valor);
                sprintf(dato.variable, "_cte_cad_%d", contCteCad);
                contCteCad++;
                VectorDatos_Add(&ListaVariables, dato);
            } 
            else 
            {
                // DEBUG: Constante numerica
                printf("    -> Tipo: CONSTANTE NUMERICA. Valor: %s\n", _simbolo->valor);

                if (strchr(_simbolo->valor, '.') == NULL) 
                {
                    strcpy(dato.indice, _simbolo->nombre);
                    reemplazarGuionBajo(nombre_limpio);
                    fprintf(fileASM, "_cte_%s\t\tdd\t\t%s.0\n", nombre_limpio, _simbolo->valor);
                    sprintf(dato.variable, "_cte_%s", nombre_limpio);
                    VectorDatos_Add(&ListaVariables, dato);
                } 
                else 
                {
                    strcpy(dato.indice, _simbolo->nombre);
                    reemplazarGuionBajo(nombre_limpio);
                    if (_simbolo->valor[0] == '.') 
                    {
                        fprintf(fileASM, "_cte_0%s\t\tdd\t\t0%s\n", nombre_limpio, _simbolo->valor);
                        sprintf(dato.variable, "_cte_0%s", nombre_limpio);
                    } 
                    else 
                    {
                        fprintf(fileASM, "_cte_%s\t\tdd\t\t%s\n", nombre_limpio, _simbolo->valor);
                        sprintf(dato.variable, "_cte_%s", nombre_limpio);
                    }
                    VectorDatos_Add(&ListaVariables, dato);
                }
            }
        }
        // DEBUG: Forzar la escritura al archivo en cada iteracion
        fflush(fileASM); 
    }

    // DEBUG: Fin del bucle
    printf("\n[DEBUG-ASM] Fin del bucle de generacion .DATA.\n");
    fflush(stdout);

    fprintf(fileASM, "\n.CODE\n");
    fprintf(fileASM, "\nSTART:\n\n");
    fprintf(fileASM, "mov  AX, @data\n");
    fprintf(fileASM, "mov  DS, AX\n");
    fprintf(fileASM, "mov  es, ax\n\n");

    PilaStrings pilaASM;
    pilaASM.count = 0;

    VectorStrings pilaCiclos;
    pilaCiclos.count = 0;

    char operadorIzq[50], operadorDer[50];
    char etiquetaComparacion[100];
    int band;
    const char* varAsm;
    // Recorre el vector global 'tercetos'
    for (int i = 0; i < indiceTerceto; i++) 
    {
        terceto* _terceto = &tercetos[i];
        band = 0;
        
        sprintf(etiquetaComparacion, "%d", _terceto->indice);
        if (VectorStr_Buscar(&pilaCiclos, etiquetaComparacion) >= 0) 
        {
            fprintf(fileASM, "ETIQUETA_%s:\n", etiquetaComparacion);
            VectorStr_Eliminar(&pilaCiclos, etiquetaComparacion);
            band = 1;
        }

        if (strcmp(_terceto->operador, "+") == 0) 
        {
            Pila_Pop(&pilaASM, operadorDer);
            Pila_Pop(&pilaASM, operadorIzq);

            if (strcmp(operadorIzq, "@@@") != 0) 
            {
                varAsm = VectorDatos_Buscar(&ListaVariables, operadorIzq);
                fprintf(fileASM, "fld %s\n", varAsm ? varAsm : operadorIzq);
                if (strcmp(operadorDer, "@@@") == 0) 
                {
                    fprintf(fileASM, "fxch\n");
                }
            }

            if (strcmp(operadorDer, "@@@") != 0) {
                varAsm = VectorDatos_Buscar(&ListaVariables, operadorDer);
                fprintf(fileASM, "fld %s\n", varAsm ? varAsm : operadorDer);
            }

            fprintf(fileASM, "fadd\n\n");
            Pila_Push(&pilaASM, "@@@");
        }
        else if (strcmp(_terceto->operador, "-") == 0) 
        {
            Pila_Pop(&pilaASM, operadorDer);
            Pila_Pop(&pilaASM, operadorIzq);

            if (strcmp(operadorIzq, "@@@") != 0) 
            {
                varAsm = VectorDatos_Buscar(&ListaVariables, operadorIzq);
                fprintf(fileASM, "fld %s\n", varAsm ? varAsm : operadorIzq);
                if (strcmp(operadorDer, "@@@") == 0) 
                {
                    fprintf(fileASM, "fxch\n");
                }
            }

            if (strcmp(operadorDer, "@@@") != 0) 
            {
                varAsm = VectorDatos_Buscar(&ListaVariables, operadorDer);
                fprintf(fileASM, "fld %s\n", varAsm ? varAsm : operadorDer);
            }

            fprintf(fileASM, "fsub\n\n");
            Pila_Push(&pilaASM, "@@@");
        } 
        else if (strcmp(_terceto->operador, "*") == 0) 
        {
            Pila_Pop(&pilaASM, operadorDer);
            Pila_Pop(&pilaASM, operadorIzq);

            if (strcmp(operadorIzq, "@@@") != 0) {
                varAsm = VectorDatos_Buscar(&ListaVariables, operadorIzq);
                fprintf(fileASM, "fld %s\n", varAsm ? varAsm : operadorIzq);
                if (strcmp(operadorDer, "@@@") == 0) {
                    fprintf(fileASM, "fxch\n");
                }
            }

            if (strcmp(operadorDer, "@@@") != 0) {
                varAsm = VectorDatos_Buscar(&ListaVariables, operadorDer);
                fprintf(fileASM, "fld %s\n", varAsm ? varAsm : operadorDer);
            }

            fprintf(fileASM, "fmul\n\n");
            Pila_Push(&pilaASM, "@@@");
        } 
        else if (strcmp(_terceto->operador, "/") == 0) 
        {
            Pila_Pop(&pilaASM, operadorDer);
            Pila_Pop(&pilaASM, operadorIzq);

            if (strcmp(operadorIzq, "@@@") != 0) {
                varAsm = VectorDatos_Buscar(&ListaVariables, operadorIzq);
                fprintf(fileASM, "fld %s\n", varAsm ? varAsm : operadorIzq);
                if (strcmp(operadorDer, "@@@") == 0) {
                    fprintf(fileASM, "fxch\n");
                }
            }

            if (strcmp(operadorDer, "@@@") != 0) {
                varAsm = VectorDatos_Buscar(&ListaVariables, operadorDer);
                fprintf(fileASM, "fld %s\n", varAsm ? varAsm : operadorDer);
            }

            fprintf(fileASM, "fdiv\n\n");
            Pila_Push(&pilaASM, "@@@");
        } 
        else if (strcmp(_terceto->operador, "=") == 0) 
        {
            const char* varDer = VectorDatos_Buscar(&ListaVariables, _terceto->operandoDer);
            const char* varIzq = VectorDatos_Buscar(&ListaVariables, _terceto->operandoIzq);

            if (varDer != NULL 
                && (strncmp(varDer, "s_", 2) == 0 
                || strncmp(varDer, "_cte_cad_", 9) == 0)) 
            {
                fprintf(fileASM, "MOV SI, OFFSET %s\n", varDer);
                fprintf(fileASM, "MOV DI, OFFSET %s\n", varIzq);
                fprintf(fileASM, "CALL COPIAR\n\n");
            } 
            else 
            {             
                char auxOperador[50];
                Pila_Pop(&pilaASM, auxOperador);
                if(strcmp(auxOperador, "@@@") != 0)
                {
                    strcpy(operadorIzq, auxOperador);
                    Pila_Pop(&pilaASM, operadorDer);
                }
                
                if (strcmp(auxOperador, "@@@") == 0) 
                {
                    fprintf(fileASM, "fstp %s\n\n", operadorIzq);
                } 
                else // asignacion simple
                {
                    const char* varPila = VectorDatos_Buscar(&ListaVariables, operadorIzq);
                    
                    if(esNumero(operadorDer) == 1)
                    {
                        char aux[50];

                        strcpy(aux, operadorDer);
                        reemplazarGuionBajo(aux);

                        fprintf(fileASM, "fld _cte_%s\n", aux);
                        fprintf(fileASM, "fstp %s\n\n", operadorIzq);
                    }
                    else
                    {
                        if(strchr(operadorIzq, '\"') != NULL)
                        {
                            int i;
                            char auxStr[50];

                            // op der destino

                            for (int i = 0; i < strlen(operadorIzq); i++) 
                            {
                                auxStr[i] = tolower((unsigned char) operadorIzq[i]);
                            }
                            auxStr[strlen(operadorIzq)] = '\0';
                            
                            i = get_HashMapEntry_value(hashmapCteString, auxStr);
                            sprintf(operadorIzq, "_cte_cad_%d", i);

                            fprintf(fileASM, "lea si, %s\n", operadorIzq);
                            fprintf(fileASM, "lea di, s_%s\n", operadorDer);
                            fprintf(fileASM, "call COPIAR\n\n");
                        }
                        else
                        { 
                            if(strcmpi(operadorDer, "TRUE") == 0)
                            {
                                sprintf(operadorDer, "_cte_1");
                            }
                            if(strcmpi(operadorDer, "FALSE") == 0)
                            {
                                sprintf(operadorDer, "_cte_0");
                            }

                            fprintf(fileASM, "fld %s\n", operadorDer);
                            fprintf(fileASM, "fstp %s\n\n", operadorIzq);
                        }
                    }
                }
                Pila_Push(&pilaASM, "###");
            }
        } 
        else if (strcmp(_terceto->operador, "ENTRADA_SALIDA") == 0 && strcmp(_terceto->operandoIzq, "READ") == 0) 
        {
            Pila_Pop(&pilaASM, operadorIzq);

            varAsm = VectorDatos_Buscar(&ListaVariables, operadorIzq);
            if (strncmp(varAsm, "s_", 2) == 0) {
                fprintf(fileASM, "getString %s\n", varAsm);
            } else {
                fprintf(fileASM, "GetFloat %s\n", varAsm);
            }
            fprintf(fileASM, "newLine\n\n");
        } 
        else if (strcmp(_terceto->operador, "ENTRADA_SALIDA") == 0 && strcmp(_terceto->operandoIzq, "WRITE") == 0) 
        {
            Pila_Pop(&pilaASM, operadorIzq);

            if(strchr(operadorIzq, '\"'))
            {
                int longitud = strlen(operadorIzq);

                for (int i = 0; i < longitud; i++) 
                {
                    if(ES_LETRA_MAYUSC(operadorIzq[i]))
                    {
                        operadorIzq[i] = tolower(operadorIzq[i]);
                    }
                }
            }

            varAsm = VectorDatos_Buscar(&ListaVariables, operadorIzq);

            if(varAsm)
            {
                if(strncmp(varAsm, "s_", 2) == 0 || strncmp(varAsm, "_cte_cad_", 9) == 0)
                {
                    fprintf(fileASM, "displayString %s\n", varAsm);
                } else 
                {
                    fprintf(fileASM, "DisplayFloat %s, 2\n", varAsm);
                }
            }
            fprintf(fileASM, "newLine\n\n");
        } 
        else if (strcmp(_terceto->operador, "CMP") == 0) 
        {
            const char* varIzq = VectorDatos_Buscar(&ListaVariables, _terceto->operandoIzq);
            const char* varDer = VectorDatos_Buscar(&ListaVariables, _terceto->operandoDer);

            if (varIzq == NULL) 
            {
                Pila_Pop(&pilaASM, operadorDer);
                Pila_Pop(&pilaASM, operadorIzq);
                varIzq = VectorDatos_Buscar(&ListaVariables, operadorIzq);
                varDer = VectorDatos_Buscar(&ListaVariables, operadorDer);
                reemplazar_booleanos(operadorIzq, operadorDer);
                fprintf(fileASM, "fld %s\n", varIzq ? varIzq : operadorIzq);
                fprintf(fileASM, "fld %s\n", varDer ? varDer : operadorDer);
            } 
            else 
            {
                strcpy(operadorIzq, varIzq);
                strcpy(operadorDer, varDer);
                reemplazar_booleanos(operadorIzq, operadorDer);
                fprintf(fileASM, "fld %s\n", operadorIzq);
                fprintf(fileASM, "fld %s\n", operadorDer);
            }  

            fprintf(fileASM, "fxch\n");
            fprintf(fileASM, "fcom\n");
            fprintf(fileASM, "fstsw ax\n");
            fprintf(fileASM, "sahf\n");
            fprintf(fileASM, "ffree\n");
        } 
        else if (strcmp(_terceto->operador, "BGE") == 0) 
        {
            eliminar_corchetes(_terceto->operandoIzq);
            fprintf(fileASM, "jae ETIQUETA_%s\n\n", _terceto->operandoIzq);
            VectorStr_Add(&pilaCiclos, _terceto->operandoIzq);
        } 
        else if (strcmp(_terceto->operador, "BGT") == 0) 
        {
            eliminar_corchetes(_terceto->operandoIzq);
            fprintf(fileASM, "ja ETIQUETA_%s\n\n", _terceto->operandoIzq);
            VectorStr_Add(&pilaCiclos, _terceto->operandoIzq);
        } 
        else if (strcmp(_terceto->operador, "BLE") == 0) 
        {
            eliminar_corchetes(_terceto->operandoIzq);
            fprintf(fileASM, "jbe ETIQUETA_%s\n\n", _terceto->operandoIzq);
            VectorStr_Add(&pilaCiclos, _terceto->operandoIzq);
        } 
        else if (strcmp(_terceto->operador, "BLT") == 0) 
        {
            eliminar_corchetes(_terceto->operandoIzq);
            fprintf(fileASM, "jb ETIQUETA_%s\n\n", _terceto->operandoIzq);
            VectorStr_Add(&pilaCiclos, _terceto->operandoIzq);
        } 
        else if (strcmp(_terceto->operador, "BE") == 0) { // BE -> BEQ (Branch if Equal)
            eliminar_corchetes(_terceto->operandoIzq);
            fprintf(fileASM, "je ETIQUETA_%s\n\n", _terceto->operandoIzq);
            VectorStr_Add(&pilaCiclos, _terceto->operandoIzq);
        } 
        else if (strcmp(_terceto->operador, "BNE") == 0) 
        {
            eliminar_corchetes(_terceto->operandoIzq);
            fprintf(fileASM, "jne ETIQUETA_%s\n\n", _terceto->operandoIzq);
            VectorStr_Add(&pilaCiclos, _terceto->operandoIzq);
        } 
        else if (strcmp(_terceto->operador, "BI") == 0) {
            eliminar_corchetes(_terceto->operandoIzq);
            fprintf(fileASM, "jmp ETIQUETA_%s\n\n", _terceto->operandoIzq);
            VectorStr_Add(&pilaCiclos, _terceto->operandoIzq);
        } 
        else if (strncmp(_terceto->operador, "Bucle_", 6) == 0 && band == 0) 
        {
            sprintf(etiquetaComparacion, "%d", _terceto->indice);
            fprintf(fileASM, "ETIQUETA_%s:\n\n", etiquetaComparacion);
        }
        else 
        {
            char ultOp[50];

            if(pilaASM.count > 0)
            {
                Pila_Pop(&pilaASM, ultOp);
            }
            else
            {
                strcpy(ultOp, "###");
            }

            // si la operación previa fue arimética
            if(strcmp(ultOp, "@@@") == 0)
            {
                strcpy(operadorIzq, _terceto->operador);
                Pila_Push(&pilaASM, ultOp);
            } 
            else
            {  // si la operación previa NO fue aritmética
                if(strcmp(ultOp, "###") != 0)
                {  // y además NO fue una asignación o caso base
                    Pila_Push(&pilaASM, ultOp);
                }
                Pila_Push(&pilaASM, _terceto->operador);
            }
        }
    } 

    sprintf(etiquetaComparacion, "%d", indiceTerceto);
    if (VectorStr_Buscar(&pilaCiclos, etiquetaComparacion) >= 0) 
    {
        fprintf(fileASM, "ETIQUETA_%s:\n", etiquetaComparacion);
        VectorStr_Eliminar(&pilaCiclos, etiquetaComparacion);
    }

    destroy_HashMap(hashmapCteString);

    fprintf(fileASM, "mov  ax, 4c00h\n");
    fprintf(fileASM, "int  21h\n");
    
    fprintf(fileASM, "STRLEN PROC NEAR\n");
    fprintf(fileASM, "    mov bx,0\n");
    fprintf(fileASM, "STRL01:\n");
    fprintf(fileASM, "    cmp BYTE PTR [SI+BX],'$'\n");
    fprintf(fileASM, "    je STREND\n");
    fprintf(fileASM, "    inc BX\n");
    fprintf(fileASM, "    jmp STRL01\n");
    fprintf(fileASM, "STREND:\n");
    fprintf(fileASM, "    ret\n");
    fprintf(fileASM, "STRLEN ENDP\n\n");

    fprintf(fileASM, "COPIAR PROC NEAR\n");
    fprintf(fileASM, "    call STRLEN\n");
    fprintf(fileASM, "    cmp bx,MAXTEXTSIZE\n");
    fprintf(fileASM, "    jle COPIARSIZEOK\n");
    fprintf(fileASM, "    mov bx,MAXTEXTSIZE\n");
    fprintf(fileASM, "COPIARSIZEOK:\n");
    fprintf(fileASM, "    mov cx,bx\n");
    fprintf(fileASM, "    cld\n");
    fprintf(fileASM, "    rep movsb\n");
    fprintf(fileASM, "    mov al,'$'\n");
    fprintf(fileASM, "    mov BYTE PTR [DI],al\n");
    fprintf(fileASM, "    ret\n");
    fprintf(fileASM, "COPIAR ENDP\n\n");

    fprintf(fileASM, "END START\n");

    fclose(fileASM);
    printf("El archivo %s ha sido generado.\n", nombre_archivo_asm);
}

int esNumero(const char *str) {
    if (str == NULL || *str == '\0') return 0; // cadena vacía o nula

    int puntoEncontrado = 0;

    // Si empieza con signo, lo salteamos
    if (*str == '-' || *str == '+') str++;

    // Recorremos cada carácter
    for (int i = 0; str[i] != '\0'; i++) {
        if (str[i] == '.') {
            if (puntoEncontrado) return 0; // más de un punto → no válido
            puntoEncontrado = 1;
        } else if (!isdigit((unsigned char)str[i])) {
            return 0; // carácter que no es número ni punto → no válido
        }
    }

    // No puede ser solo un punto o signo
    return (*str != '\0');
}

void reemplazar_booleanos(char *operadorIzq, char *operadorDer)
{
    if(operadorIzq && (strcmpi(operadorIzq, "TRUE") == 0))
    {
        sprintf(operadorIzq, "_cte_1");
    }
    if(operadorIzq && (strcmpi(operadorIzq, "FALSE") == 0))
    {
        sprintf(operadorIzq, "_cte_0");
    }
    if(operadorDer && (strcmpi(operadorDer, "TRUE") == 0))
    {
        sprintf(operadorDer, "_cte_1");
    }
    if(operadorDer && (strcmpi(operadorDer, "FALSE") == 0))
    {
        sprintf(operadorDer, "_cte_0");
    }
}