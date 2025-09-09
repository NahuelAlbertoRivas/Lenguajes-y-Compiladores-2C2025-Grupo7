#include <stdio.h>
#include <stdlib.h>
#include "tabla.h"

#include <float.h> /* Libreria para el manejo de floats, tiene el maximo de tamaño de reales de 32 bits*/
#include <limits.h> /* Libreria para el manejo de enteros, tiene el maximo de tamaño de enteros de 16 bits*/
#include <string.h> /* Libreria para el manejo de strings*/
#include <ctype.h>

#define TRUE 1
#define FALSE 0

int bandera = 0;

void iniciar_tabla(Tabla *tabla) {
    tabla->nFilas = 0;
}

void normalizar_real(const char *entrada, char *salida, size_t tam_salida) {
    // Convertimos la cadena a float (32 bits)
    float numero = strtof(entrada, NULL);

    // Escribimos en el buffer de salida con 6 decimales fijos
    // snprintf evita desbordamientos de memoria
    snprintf(salida, tam_salida, "%.6f", numero);
}

void agregar_a_tabla(Tabla *tabla, const char* nombre, char* tipo_token){

    char salida[10000] = "";
    char nombre2[10000] = "";

    if(bandera == 0){
        bandera = 1;
        iniciar_tabla(tabla);
    }
    
    if(strcmp(tipo_token, "CTE_REAL") == 0){
        //normalizar_real(nombre, salida, sizeof(salida));
        strcpy(salida, nombre);
    }
    
    if(strcmp(tipo_token, "CTE_STRING") == 0){
        for (int i = 0; i < strlen(nombre); i++) {
            salida[i]=tolower((unsigned char) nombre[i]);
        }
        salida[strlen(nombre)] = '\0';
    }

    if (strcmp(tipo_token, "CTE_INT") == 0) {
        int numero = atoi(nombre); // convertir la cadena 'nombre' a entero
        snprintf(salida, sizeof(salida), "%d", numero); // pasar el entero a 'salida'
    }

    if(strcmp(tipo_token, "ID") == 0){
        for (int i = 0; i < strlen(nombre); i++) {
            salida[i]=tolower((unsigned char) nombre[i]);
        }
        salida[strlen(nombre)] = '\0';
    }

    
    if (existe_en_tabla(tabla, salida, tipo_token) == FALSE){
        int lexemas_ingresados = tabla->nFilas;
            char* nombre1 = malloc(strlen(nombre) + 1); // +1 para "_" +1 para '\0'
        if(strcmp(tipo_token, "ID") == 0){
            if (!nombre1) { perror("malloc"); return; }
            // Asignar memoria
            tabla->filas[lexemas_ingresados].nombre = malloc(strlen(nombre) + 1);
            tabla->filas[lexemas_ingresados].valor = malloc(2);
            tabla->filas[lexemas_ingresados].tipoDato = malloc(strlen(tipo_token) + 1);
            
            //Rellenar valores
            strcpy(nombre1, nombre);            
            strcpy(tabla->filas[lexemas_ingresados].nombre, nombre1);
            strcpy(tabla->filas[lexemas_ingresados].valor, "-");
            strcpy(tabla->filas[lexemas_ingresados].tipoDato, tipo_token);
            free(nombre1);
        } else {
            char* nombre1 = malloc(strlen(nombre) + 2); // +1 para "_" +1 para '\0'
            if (!nombre1) { perror("malloc"); return; }
            // Asignación de memoria
            tabla->filas[lexemas_ingresados].nombre = malloc(strlen(nombre) + 1);
            tabla->filas[lexemas_ingresados].valor = malloc(strlen(nombre) + 1);
            tabla->filas[lexemas_ingresados].tipoDato = malloc(strlen(tipo_token) + 1);
            tabla->filas[lexemas_ingresados].longitud = (int) strlen(nombre);

            //Rellenar valores
            strcpy(nombre1, "_");
            strcpy(nombre1 + 1, nombre);
            strcpy(tabla->filas[lexemas_ingresados].nombre, nombre1);
            strcpy(tabla->filas[lexemas_ingresados].valor, nombre);
            strcpy(tabla->filas[lexemas_ingresados].tipoDato, tipo_token);
            free(nombre1);
        }

        tabla->nFilas++;
    }

    guardar_tabla_en_archivo(tabla, "Salida.txt");
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
                nombre_tabla++; // mover puntero al siguiente carácter
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
                nombre_tabla++; // mover puntero al siguiente carácter
            }

            if (strcmp(nombre_tabla, valor) == 0) {
                return TRUE; 
            }
        }
        return FALSE; 

     }

}

void mostrar_tabla(const Tabla *tabla) {
    printf("-------------------------------------------------------------------------------------------------------------------------------------\n");
    printf("| %-50s | %-50s | %-10s | %-10s |\n", 
           "Nombre", "Valor", "Longitud", "TipoDato");
    printf("-------------------------------------------------------------------------------------------------------------------------------------\n");

    for (int i = 0; i < tabla->nFilas; i++) {
        printf("| %-50s | %-50s | %-10d | %-10s |\n",
               tabla->filas[i].nombre ? tabla->filas[i].nombre : "-",
               tabla->filas[i].valor  ? tabla->filas[i].valor  : "-",
               tabla->filas[i].longitud,
               tabla->filas[i].tipoDato ? tabla->filas[i].tipoDato : "-");
    }

    printf("-------------------------------------------------------------------------------------------------------------------------------------\n");
}

void guardar_tabla_en_archivo(const Tabla *tabla, const char *nombreArchivo) {
    FILE *f = fopen(nombreArchivo, "w");
    if (!f) {
        perror("Error al abrir el archivo");
        return;
    }

    fprintf(f, "-------------------------------------------------------------------------------------------------------------------------------------\n");
    fprintf(f, "| %-50s | %-50s | %-10s | %-10s |\n", 
            "Nombre", "Valor", "Longitud", "TipoDato");
    fprintf(f, "-------------------------------------------------------------------------------------------------------------------------------------\n");

    for (int i = 0; i < tabla->nFilas; i++) {
        fprintf(f, "| %-50s | %-50s | %-10d | %-10s |\n",
                tabla->filas[i].nombre ? tabla->filas[i].nombre : "-",
                tabla->filas[i].valor  ? tabla->filas[i].valor  : "-",
                tabla->filas[i].longitud,
                tabla->filas[i].tipoDato ? tabla->filas[i].tipoDato : "-");
    }

    fprintf(f, "-------------------------------------------------------------------------------------------------------------------------------------\n");

    fclose(f);
}