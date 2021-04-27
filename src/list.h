// vim:filetype=c
#ifndef LIST_H
#define LIST_H

#include "piece.h"

#define list_val_t piece_t

typedef struct lnode lnode;
typedef struct lnode {
	list_val_t val;
	lnode* next;
} lnode;

typedef struct list {
	unsigned int count;
	lnode* first;
	lnode* last; // for fast append
} list;

// debug
void* dmalloc(size_t sz);
void  dfree(void* mem);
void  checkatend(void);
// end of debug

void  lprint(list* l);

list* linit(unsigned int num, list_val_t val[num]);
void  lfree(list* l);

void  lappend(list* l, list_val_t val);
void* ldel   (list* l, unsigned int d);

#endif

