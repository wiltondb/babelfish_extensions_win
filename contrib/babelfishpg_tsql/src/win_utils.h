
#ifndef WIN_UTILS_H
#define WIN_UTILS_H

#include "pltsql.h"
#include "pltsql-2.h"
#include "pl_explain.h"
#include "session.h"

#include "catalog/namespace.h"
#include "catalog/pg_proc.h"
#include "parser/scansup.h"

#include "guc.h"

List* list_make1_win(void* ptr);

#endif // WIN_UTILS_H 