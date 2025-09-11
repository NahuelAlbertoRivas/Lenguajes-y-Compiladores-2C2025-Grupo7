#ifndef TABLA_H
#define TABLA_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAM_TABLA 10000

// Estructura para cada entrada en la tabla de símbolos
typedef struct {
    char *nombre;
    char *valor; 
    int longitud;   
    char *tipoDato;
} InformacionToken;

// Tabla de símbolos
typedef struct {
    InformacionToken filas[TAM_TABLA];
    int nFilas;         
} Tabla;

void iniciar_tabla(Tabla *tabla);
void normalizar_real(const char *entrada, char *salida, size_t tam_salida);
void agregar_a_tabla(Tabla *tabla, const char* nombre, char* tipo_token);
int existe_en_tabla(Tabla *tabla, char *valor, char* tipo_token);
void guardar_tabla_en_archivo(const Tabla *tabla, const char *nombreArchivo);

#endif