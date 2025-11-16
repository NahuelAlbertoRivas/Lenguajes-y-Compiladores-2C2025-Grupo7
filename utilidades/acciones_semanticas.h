#ifndef ACCIONES_SEMANTICAS
#define ACCIONES_SEMANTICAS

#include "pila.h"
#include "hashmap.h"
#include "../tabla.h"
#include <stdbool.h>

#define TAM_MAX_STRING 50

#define ACCION_EXITOSA 542
#define VERIFICACION_OK 65
#define VALIDACION_OK 546
#define ERR_VALIDACION -654
#define DEF_VARIABLES_DUPLICADAS -412
#define VARIABLE_NO_DEFINIDA -499
#define ASIGNACION_NO_COMPATIBLE -787
#define EXPRESION_NO_COMPATIBLE -882
#define ERROR_INESPERADO -765
#define ADVERTENCIA_CASTEO -871
#define ID_NO_VALIDO -876
#define CTE_NO_VALIDA -333
#define MEMORIA_NO_SUFICIENTE -999
#define PARAMETRO_NO_VALIDO -111
#define IGUALES 0
#define DIV_CERO -2131

#define DINTEGER "Int"
#define DSTRING "String"
#define DFLOAT "Float"
#define DBOOLEAN "Boolean"
#define DCTESTRING "CTE_STRING"
#define DCTEFLOAT "CTE_REAL"
#define DCTEINT "CTE_INT"

typedef struct
{
    char id[TAM_MAX_STRING];
    int pos_en_tabla;
} tVar;

int asignar_tipo(tPila *pilaVars, HashMap *hashmap, Tabla *tabla, const char *tipoDato);
int verificar_existencia_variable(HashMap *hashmap, const char *id);
int verificar_compatibilidad_asignacion(HashMap *hashmap, Tabla *tabla, const char *id, const char *tipo_esperado);
int establecer_tipo_dato_esperado(HashMap *hashmap, Tabla *tabla, const char *id, char *tipo_esperado);
int verificar_compatibilidad_tipos_datos(const char *tipo1, const char *tipo2);

#endif
