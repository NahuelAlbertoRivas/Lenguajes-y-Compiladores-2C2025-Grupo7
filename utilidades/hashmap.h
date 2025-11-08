#ifndef HASHMAP
#define HASHMAP

#define HASHMAP_UNDEFINED -11
#define HM_NOT_ENOUGH_MEMORY -12
#define HM_KEY_NOT_FOUND -22
#define HM_SUCCESS 44
#define HM_DUPLICATE_KEY -13

typedef struct HashMapEntry
{
    char *key;
    int value;
    struct HashMapEntry *next;
} HashMapEntry;

typedef struct
{
    HashMapEntry **table;
    int hsize;
} HashMap;

typedef void (*Task)(void *, void *);

HashMap *create_HashMap(int hsize);
int add_HashMapEntry(HashMap *hashmap, const char *key, int value);
int get_HashMapEntry_value(HashMap *hashmap, const char *key);
int update_HashMapEntry_value(HashMap *hashmap, const char *key, int val);
int remove_HashMapEntry(HashMap *hashmap, const char *key);
void destroy_HashMap(HashMap *hashmap);
void show_HashMap (HashMap *hashmap);

void map_HashMap(HashMap *hashmap, Task td, void *context);

#endif
