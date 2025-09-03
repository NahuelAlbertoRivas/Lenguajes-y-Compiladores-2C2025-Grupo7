#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Estructura para cada entrada en la tabla de símbolos
typedef struct {
    char *nombre;
    char *valor; 
    int longitud;   
    char *tipoDato;
} InformacionToken;

// Tabla de símbolos dinámica
typedef struct {
    InformacionToken *filas; // arreglo dinámico de tokens
    int nFilas;              // cantidad actual de filas
} Tabla;

// Inicializar tabla
void inicializarTabla(Tabla *t) {
    t->filas = NULL;
    t->nFilas = 0;
}

// Insertar un nuevo token en la tabla
void insertarEnTabla(Tabla *t, const char *nombre, const char *valor, int longitud, const char *tipoDato) {
    // Redimensionar espacio para una fila más
    t->filas = realloc(t->filas, (t->nFilas + 1) * sizeof(InformacionToken));
    if (t->filas == NULL) {
        perror("Error en realloc");
        exit(1);
    }

    // Crear la nueva entrada
    InformacionToken *nuevo = &t->filas[t->nFilas];

    nuevo->nombre = strdup(nombre);   // strdup reserva memoria y copia
    nuevo->valor = strdup(valor);
    nuevo->longitud = longitud;
    nuevo->tipoDato = strdup(tipoDato);

    // Incrementar el contador de filas
    t->nFilas++;
}

// Mostrar la tabla
void mostrarTabla(const Tabla *t) {
    printf("Tabla de simbolos:\n");
    for (int i = 0; i < t->nFilas; i++) {
        printf("Fila %d -> Nombre: %s | Valor: %s | Longitud: %d | Tipo: %s\n",
               i,
               t->filas[i].nombre,
               t->filas[i].valor,
               t->filas[i].longitud,
               t->filas[i].tipoDato);
    }
}

// Liberar memoria
void liberarTabla(Tabla *t) {
    for (int i = 0; i < t->nFilas; i++) {
        free(t->filas[i].nombre);
        free(t->filas[i].valor);
        free(t->filas[i].tipoDato);
    }
    free(t->filas);
    t->filas = NULL;
    t->nFilas = 0;
}

// Verificar si ya existe un valor en la tabla
int verificarDuplicadoPorValor(const Tabla *t, const char *valor) {
    for (int i = 0; i < t->nFilas; i++) {
        if (strcmp(t->filas[i].valor, valor) == 0) {
            return 1; // Encontrado duplicado
        }
    }
    return 0; // No se encontró
}

