#include "acciones_semanticas.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int asignar_tipo(tPila *pilaVars, HashMap *hashmap, Tabla *tabla, const char *tipoDato)
{
    tVar tmp;

    while(sacar_de_pila(pilaVars, &tmp, sizeof(tVar)) != PILA_VACIA)
    {
        if(tmp.pos_en_tabla == NO_SE_AGREGA)
        {
            fprintf(stderr, "\nERROR INESPERADO\n");
            return ERROR_INESPERADO;
        }
        else
        {
            actualizar_tipo_dato(tabla, tmp.pos_en_tabla, tipoDato);
        }
    }
    return ACCION_EXITOSA;
}

int verificar_existencia_variable(HashMap *hashmap, const char *id)
{
    int pos = get_HashMapEntry_value(hashmap, id);

    if(pos == HM_KEY_NOT_FOUND)
    {
        return VARIABLE_NO_DEFINIDA;
    }

    return VERIFICACION_OK;
}

int verificar_compatibilidad_asignacion(HashMap *hashmap, Tabla *tabla, const char *id, const char *tipo_resultado)
{
    int indice = get_HashMapEntry_value(hashmap, id),
        res;
    char *tipo_dato_id;

    if(indice == HM_KEY_NOT_FOUND)
    {
        fprintf(stderr, "\nERROR INESPERADO: no se encontró referencia sobre ID: %s\n", id);
        return ERROR_INESPERADO;
    }
    tipo_dato_id = strdup(obtener_tipo_dato(tabla, indice));
    res = verificar_compatibilidad_tipos_datos(tipo_dato_id, tipo_resultado);
    if(res != VERIFICACION_OK)
    {
        fprintf(stderr, "\nERROR: no se puede asignar %s a %s (ID: %s)\n", tipo_resultado, tipo_dato_id, id);
    }
    else
    {
        res = VERIFICACION_OK;
    }

    free(tipo_dato_id);

    return res;
}

int verificar_compatibilidad_tipos_datos(const char *tipo1, const char *tipo2)
{
    if(!strcmp(tipo1, DINTEGER) && !strcmp(tipo2, DFLOAT))
    {
        printf("\nADVERTENCIA: seria pertinente castear la operacion\n");
    }
    else if(strcmp(tipo1, tipo2)
           && (strcmp(tipo1, DSTRING) || strcmp(tipo2, DCTESTRING))
           && (strcmp(tipo1, DFLOAT) || strcmp(tipo2, DCTEFLOAT))
           && (strcmp(tipo1, DINTEGER) || strcmp(tipo2, DCTEINT))  
           && (strcmp(tipo1, DFLOAT) || strcmp(tipo2, DINTEGER))    )
    {
        return ASIGNACION_NO_COMPATIBLE;
    }

    return VERIFICACION_OK;
}

/***************************************/

int establecer_tipo_dato_esperado(HashMap *hashmap, Tabla *tabla, const char *id, char *tipo_esperado)
{
    int indice = get_HashMapEntry_value(hashmap, id),
        res;

    if(indice == HM_KEY_NOT_FOUND)
    {
        fprintf(stderr, "\nERROR INESPERADO: no se encontró referencia sobre ID: %s\n", id);
        return ERROR_INESPERADO;
    }

    if(tipo_esperado)
    {
        free(tipo_esperado);
    }

    tipo_esperado = strdup(obtener_tipo_dato(tabla, indice));

    fprintf(stderr, "\nEEEEE %s\n", tipo_esperado);

    if(tipo_esperado == NULL)
    {
        fprintf(stderr, "\nERROR INESPERADO\n");
        return ERROR_INESPERADO;
    }

    return ACCION_EXITOSA;
}

int _reservar_asignando_string(char *buffer, const char *source)
{
    if(buffer)
    {
        return PARAMETRO_NO_VALIDO;
    }
    
    buffer = strdup(source);

    if(!buffer)
    {
        return MEMORIA_NO_SUFICIENTE;
    }

    return ACCION_EXITOSA;
}

int _liberar_recursos_string(char *str)
{
    if(str)
    {
        free(str);
        str = NULL;
    } 

    return ACCION_EXITOSA;
}

/*
int asignar_tipo_validando(tPila *pilaVars, HashMap *hashmap, Tabla *tabla, const char *tipoDato)
{
    tVar tmp;
    int pos_en_tabla;

    while(sacar_de_pila(pilaVars, &tmp, sizeof(tVar)) != PILA_VACIA)
    {
        if((tmp.pos_en_tabla == NO_SE_AGREGA) || (add_HashMapEntry(hashmap, tmp.id, tmp.pos_en_tabla) == HM_DUPLICATE_KEY))
        {
            fprintf(stderr, "\nERROR: definicion de ID duplicada: %s\n", tmp.id);
            return DEF_VARIABLES_DUPLICADAS;
        }
        else
        {
            //printf("\n\ntoken  -->  %s   ;    index -->  %d\n\n", tmp.id, tmp.pos_en_tabla);
            actualizar_tipo_dato(tabla, tmp.pos_en_tabla, tipoDato);
        }
    }
    return ACCION_EXITOSA;
}
*/