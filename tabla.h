#include <stdio.h>
#include <stdlib.h>

// Estructura para manejar la tabla dinámica
typedef struct {
    char *nombre;
    char *valor; 
    int *longitud;   
    char *tipoDato;
} InformacionToken;

typedef struct {
    InformacionToken **filas;      // Puntero a punteros (cada fila)
    int nFilas;       // Cantidad actual de filas
    int columnas;     // Cantidad fija de columnas
} Tabla;

// Inicializar tabla
void inicializarTabla(Tabla *t, int columnas) {
    t->filas = NULL;
    t->nFilas = 0;
    t->columnas = columnas;
}

// Insertar una fila en la tabla
void insertarEnTabla(Tabla *t, InformacionToken *info) {
    // Aumentamos espacio para un puntero más
    t->filas = realloc(t->filas, (t->nFilas + 1) * sizeof(int*));
    if (t->filas == NULL) {
        perror("Error en realloc");
        exit(1);
    }

    // Reservamos espacio para la nueva fila
    t->filas[t->nFilas] = malloc(t->columnas *sizeof(InformacionToken));
    if (t->filas[t->nFilas] == NULL) {
        perror("Error en malloc fila");
        exit(1);
    }

    // Copiamos los valores a la nueva fila
    for (int j = 0; j < t->columnas; j++) {
        t->filas[t->nFilas][j] = valor[j];
    }

    // Incrementamos el contador de filas
    t->nFilas++;
}

// Mostrar la tabla
void mostrarTabla(Tabla *t) {
    for (int i = 0; i < t->nFilas; i++) {
        for (int j = 0; j < t->columnas; j++) {
            printf("%d ", t->filas[i][j]);
        }
        printf("\n");
    }
}

// Liberar memoria
void liberarTabla(Tabla *t) {
    for (int i = 0; i < t->nFilas; i++) {
        free(t->filas[i]);
    }
    free(t->filas);
    t->filas = NULL;
    t->nFilas = 0;
}
