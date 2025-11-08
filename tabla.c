#include <stdio.h>
#include <stdlib.h>
#include "tabla.h"
#include "utilidades/pila.h"
#include "utilidades/hashmap.h"

/* Libreria para el manejo de floats, tiene el maximo de tamaño de reales de 32 bits */
#include <float.h>
/* Libreria para el manejo de enteros, tiene el maximo de tamaño de enteros de 16 bits */
#include <limits.h>
/* Libreria para el manejo de strings */
#include <string.h>
/* Libreria para el manejo de conversión de caracteres (tolower()) */
#include <ctype.h>

#define TRUE 1
#define FALSE 0

int bandera = 0;

void iniciar_tabla(Tabla *tabla) 
{
    tabla->nFilas = 0;
    bandera = 1;
}


int agregar_a_tabla(Tabla *tabla, const char* nombre, char* tipo_token){

    char salida[10000] = "";
    char nombre2[10000] = "";
    int pos = NO_SE_AGREGA;

    if(bandera == 0)
    {
        bandera = 1;
        iniciar_tabla(tabla);
    }
    
    if(strcmp(tipo_token, "CTE_REAL") == 0){
        strcpy(salida, nombre);
    }
    
    if(strcmp(tipo_token, "CTE_STRING") == 0){
        for (int i = 0; i < strlen(nombre); i++) {
            salida[i] = tolower((unsigned char) nombre[i]);
        }
        salida[strlen(nombre)] = '\0';
    }

    if (strcmp(tipo_token, "CTE_INT") == 0) {
        int numero = atoi(nombre); 
        snprintf(salida, sizeof(salida), "%d", numero); 
    }

    if(strcmp(tipo_token, "ID") == 0){
        for (int i = 0; i < strlen(nombre); i++) {
            salida[i] = nombre[i];
        }
        salida[strlen(nombre)] = '\0';
    }

    
    if (existe_en_tabla(tabla, salida, tipo_token) == FALSE)
    {
        int lexemas_ingresados = tabla->nFilas;
        char* nombre1;
        if(strcmp(tipo_token, "ID") == 0){
            nombre1 = malloc(strlen(salida) + 1);
            if (!nombre1) { perror("malloc"); return SIN_MEMORIA; }

            if(strcmp(tipo_token, "CTE_INT") == 0 || strcmp(tipo_token, "CTE_REAL") == 0){
                tabla->filas[lexemas_ingresados].tipoDato = malloc(strlen(tipo_token) + 1);
                strcpy(tabla->filas[lexemas_ingresados].tipoDato, tipo_token);
            }
            /* Asignar de memoria */
            tabla->filas[lexemas_ingresados].nombre = malloc(strlen(nombre) + 1);
            tabla->filas[lexemas_ingresados].valor = malloc(2);
            tabla->filas[lexemas_ingresados].longitud = 0;
            
            /* Rellenar valores */
            strcpy(nombre1, salida);            
            strcpy(tabla->filas[lexemas_ingresados].nombre, nombre1);
            strcpy(tabla->filas[lexemas_ingresados].valor, "-");
            free(nombre1);
        } else if(strcmp(tipo_token, "CTE_INT") == 0 || strcmp(tipo_token, "CTE_REAL") == 0) { 
            nombre1 = malloc(strlen(salida) + 1);
            if (!nombre1) { perror("malloc"); return SIN_MEMORIA; }

            tabla->filas[lexemas_ingresados].valor = malloc(strlen(salida) + 1);
            tabla->filas[lexemas_ingresados].nombre = malloc(strlen(salida) + 1);
            tabla->filas[lexemas_ingresados].tipoDato = malloc(strlen(tipo_token) + 1);
            tabla->filas[lexemas_ingresados].longitud = 0;

            strcpy(nombre1, salida);            
            reemplazar(nombre1, '.', '_');
            strcpy(tabla->filas[lexemas_ingresados].nombre, nombre1);
            strcpy(tabla->filas[lexemas_ingresados].tipoDato, tipo_token);
            strcpy(tabla->filas[lexemas_ingresados].valor, salida);

            free(nombre1);
        }
        else {
            nombre1 = malloc(strlen(salida) + 2); // +1 para "_" +1 para '\0'
            if (!nombre1) { perror("malloc"); return SIN_MEMORIA; }
            /* Asignar de memoria */
            tabla->filas[lexemas_ingresados].nombre = malloc(strlen(salida) + 2);
            tabla->filas[lexemas_ingresados].valor = malloc(strlen(salida) + 1);
            tabla->filas[lexemas_ingresados].tipoDato = malloc(strlen(tipo_token) + 1);
            tabla->filas[lexemas_ingresados].longitud = (int) strlen(salida);

            /* Rellenar valores */
            strcpy(nombre1, "_");
            strcpy(nombre1 + 1, salida);
            strcpy(tabla->filas[lexemas_ingresados].nombre, nombre1);
            strcpy(tabla->filas[lexemas_ingresados].valor, salida);
            strcpy(tabla->filas[lexemas_ingresados].tipoDato, tipo_token);
            free(nombre1);
        }
        pos = tabla->nFilas;
        tabla->nFilas++;
    }

    return pos;
}

int existe_en_tabla(Tabla *tabla, char *valor, char* tipo_token) {

    if(strcmp(tipo_token, "ID") == 0){
        for (int i = 0; i < tabla->nFilas; i++) {      
            if (strcmp(tabla->filas[i].nombre, valor) == 0) {
                return TRUE; 
            }
        }
        return FALSE; 

    } else if(strcmp(tipo_token, "CTE_REAL") == 0) {
        for (int i = 0; i < tabla->nFilas; i++) {      
            char *nombre_tabla = tabla->filas[i].nombre;

            if (nombre_tabla[0] == '_') {
                nombre_tabla++;
            }

            if (strcmp(nombre_tabla, valor) == 0) {
                return TRUE; 
            }
        }
        return FALSE; 

    } else{

        for (int i = 0; i < tabla->nFilas; i++) {      
            char *nombre_tabla = tabla->filas[i].nombre;

            if (nombre_tabla[0] == '_') {
                nombre_tabla++;
            }

            if (strcmp(nombre_tabla, valor) == 0) {
                return TRUE; 
            }
        }
        return FALSE; 
     }

}

int actualizar_tipo_dato(Tabla *tabla, int pos, const char *tipoDato)
{
    if(bandera == 0)
    {
        return TABLA_NO_INICIALIZADA;
    }

    //tabla->filas[pos].tipoDato = malloc(strlen(tipoDato) + 1);
    //strcpy(tabla->filas[pos].tipoDato, tipoDato);
    tabla->filas[pos].tipoDato = strdup(tipoDato);

    return ACTUALIZACION_CORRECTA;
}

const char *obtener_tipo_dato(Tabla *tabla, int pos)
{
    if(bandera == 0)
    {
        return NULL;
    }

    return tabla->filas[pos].tipoDato;
}

void agregar_a_tabla_variables_internas(Tabla *tabla, char* nombre, char* tipo_token)
{
    int lexemas_ingresados = tabla->nFilas;
    
    tabla->filas[lexemas_ingresados].nombre = malloc(strlen(nombre) + 2);

    if(tabla->filas[lexemas_ingresados].nombre == NULL)
    {
        return;
    }

    tabla->filas[lexemas_ingresados].tipoDato = malloc(strlen(tipo_token) + 1);

    if(tabla->filas[lexemas_ingresados].tipoDato == NULL)
    {
        free(tabla->filas[lexemas_ingresados].nombre);
        return;
    }

    tabla->filas[lexemas_ingresados].valor = malloc(2);

    if(tabla->filas[lexemas_ingresados].valor == NULL)
    {
        free(tabla->filas[lexemas_ingresados].nombre);
        free(tabla->filas[lexemas_ingresados].tipoDato);
        return;
    }

    strcpy(tabla->filas[lexemas_ingresados].nombre, nombre);
    strcpy(tabla->filas[lexemas_ingresados].tipoDato, tipo_token);
    strcpy(tabla->filas[lexemas_ingresados].valor, "-");
    tabla->filas[lexemas_ingresados].longitud = 0;

    printf("\n%s    %s      %d\n", tabla->filas[lexemas_ingresados].nombre, 
                                    tabla->filas[lexemas_ingresados].tipoDato, lexemas_ingresados);

    tabla->nFilas++;
}

void guardar_tabla_en_archivo(const Tabla *tabla, const char *nombreArchivo) {
    FILE *f = fopen(nombreArchivo, "w");
    if (!f) {
        perror("Error al abrir el archivo");
        return;
    }

    char buffer[32];  // suficiente para un int
    const char* longitudStr;

    fprintf(f, "-------------------------------------------------------------------------------------------------------------------------------------\n");
    fprintf(f, "| %-52s | %-10s | %-50s | %-10s |\n", 
            "Nombre", "TipoDato", "Valor", "Longitud");
    fprintf(f, "-------------------------------------------------------------------------------------------------------------------------------------\n");

    for (int i = 0; i < tabla->nFilas; i++) 
    {
        if (tabla->filas[i].longitud == 0)
        {
            longitudStr = "-";
        }
        else 
        {
            snprintf(buffer, sizeof(buffer), "%d", tabla->filas[i].longitud);
            longitudStr = buffer;
        }

        fprintf(f, "| %-52s | %-10s | %-50s | %-10s |\n",
                tabla->filas[i].nombre ? tabla->filas[i].nombre : "-",
                tabla->filas[i].tipoDato ? tabla->filas[i].tipoDato : "-",
                tabla->filas[i].valor  ? tabla->filas[i].valor  : "-",
                longitudStr);
        
        if(tabla->filas[i].nombre)
        {
            free(tabla->filas[i].nombre);
        }
        if(tabla->filas[i].valor)
        {
            free(tabla->filas[i].valor);
        }
        if(tabla->filas[i].tipoDato)
        {
            free(tabla->filas[i].tipoDato);
        }
    }

    fprintf(f, "-------------------------------------------------------------------------------------------------------------------------------------\n");

    fclose(f);
}

void reemplazar(char* palabra, char buscar, char reemplazar){
    for (char* p = palabra; *p != '\0'; ++p) {
        if (*p == buscar) {
            *p = reemplazar;
        }
    }
}

void imprimir_datos_vars_internas(void *nombre, void *pf)
{
    ;
}