#ifndef TABLA_H
#define TABLA_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TAM_TABLA 10000
#define SIN_MEMORIA -33
#define NO_SE_AGREGA -32
#define TABLA_NO_INICIALIZADA -123
#define ACTUALIZACION_CORRECTA 45

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
int agregar_a_tabla(Tabla *tabla, const char* nombre, char* tipo_token);
int existe_en_tabla(Tabla *tabla, char *valor, char* tipo_token);
void guardar_tabla_en_archivo(const Tabla *tabla, const char *nombreArchivo);
void mostrar_tabla(const Tabla *tabla);
int actualizar_tipo_dato(Tabla *tabla, int pos, const char *tipoDato);
const char *obtener_tipo_dato(Tabla *tabla, int pos);

void agregar_a_tabla_variables_internas(Tabla *tabla, char* nombre, char* tipo_token);
void reemplazar(char* palabra, char buscar, char reemplazar);

//int copiarTablaDeSimbolos(Lista* lista_externa);

//int copiarTablaDeSimbolos(Lista* lista_externa);

#endif