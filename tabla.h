#ifndef TABLA_H
#define TABLA_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAM_TABLA 1000

// Estructura para cada entrada en la tabla de símbolos
typedef struct {
    char *nombre;
    char *valor; 
    int longitud;   
    char *tipoDato;
} InformacionToken;

// Tabla de símbolos dinámica
typedef struct {
    InformacionToken filas[TAM_TABLA]; // arreglo dinámico de tokens
    int nFilas;              // cantidad actual de filas
} Tabla;

void iniciar_tabla(Tabla *tabla);
void normalizarReal(const char *entrada, char *salida, size_t tam_salida);
void agregarATabla(Tabla *tabla, const char* nombre, char* tipo_token);
int existe_en_tabla(Tabla *tabla, char *valor);
void guardarTablaEnArchivo(const Tabla *tabla, const char *nombreArchivo);

#endif