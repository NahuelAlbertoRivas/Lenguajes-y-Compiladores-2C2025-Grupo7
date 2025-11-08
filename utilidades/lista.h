#ifndef LISTA
#define LISTA

#ifndef STALIB
#define STDLIB
#include <stdlib.h>
#endif // STALIB

#ifndef STRING
#define STRING
#include <string.h>
#endif // STRING

#ifndef STDIO
#define STDIO
#include <stdio.h>
#endif // STDIO

#ifndef STDBOOL
#define STDBOOL
#include <stdbool.h>
#endif // STDBOOL

#ifndef TODO_OK
#define TODO_OK 0
#endif // TODO_OK

#ifndef SIN_MEM
#define SIN_MEM 1
#endif // SIN_MEM

#ifndef CLA_DUP
#define CLA_DUP 2
#endif // CLA_DUP

#ifndef BUSCADO
#define BUSCADO 8080
#endif // BUSCADO

#define NO_ENTRA -32
#define D_INS 32

#ifndef minimo
#define minimo(X, Y) ( (X) <= (Y)?(X):(Y) )
#endif // minimo

typedef struct sNodoLista
{
    void *info;
    unsigned tamInfo;
    struct sNodoLista *sig;
} tNodoLista;

typedef tNodoLista *tLista;

typedef int (*Comparar)(const void *, const void *);

typedef int (*Accion)(void *);

typedef int (*accionManejoDatos)(void *, void *);

typedef int (*Acumular)(void **, unsigned *, const void *, unsigned);

void crearLista(tLista *p);

int listaVacia(const tLista *p);

int listaLlena(const tLista *p, unsigned cantBytes);

int vaciarLista(tLista *p);

int vaciarListaYMostrar(tLista *p, void (*mostrar)(const void *, FILE *), FILE *fp);

int ponerAlComienzo(tLista *p, const void *d, unsigned cantBytes);

int sacarPrimeroLista(tLista *p, void *d, unsigned cantBytes);

int verPrimeroLista(const tLista *p, void *d, unsigned cantBytes);

int ponerAlFinal(tLista *p, const void *d, unsigned cantBytes);

int sacarUltimoLista(tLista *p, void *d, unsigned cantBytes);

int verUltimoLista(const tLista *p, void *d, unsigned cantBytes);

int mostrarLista(const tLista *p, void (*mostrar)(const void *, FILE *), FILE *fp);

int mostrarListaAlReves(const tLista *p, void (*mostrar)(const void *, FILE *), FILE *fp);

int mostrarListaAlRevesYVaciar(tLista *p, void (*mostrar)(const void *, FILE *), FILE *fp);

int ponerEnOrden(tLista *p, const void *d, unsigned cantBytes, int (*comparar)(const void *, const void *),
                int (*acumular)(void **, unsigned *, const void *, unsigned));

void ordenar(tLista *p, int (*comparar)(const void *, const void *));

tLista *buscarDirMenorOMayor(tLista *pl, int (*comparar)(const void *, const void *));

int ordenarNodosLista(tLista *pl, int (*comparar)(const void *, const void *));

bool listaCrearDeArchivos(tLista *, const char *, size_t, Comparar);

tLista *obtenerLaDireccionDelSiguiente(tLista *pl);

int accionarSobreElPrimero(tLista *pl, void *recurso, accionManejoDatos tarea);

tLista *buscarDirClave(tLista *pl, void *clave, int (*comparar)(const void *, const void *));

int mapLista(const tLista *p, int (*accion)(void *, void *), void *contexto);

int insertarOrdenadoDescConLimite(tLista *pl, const void *info, unsigned tamInfo, Comparar cmp, Acumular acm, unsigned limite);

#endif
