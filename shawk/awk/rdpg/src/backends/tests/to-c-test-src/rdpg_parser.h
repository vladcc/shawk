// <header>
#ifndef RDPG_PARSER_H
#define RDPG_PARSER_H
#include "rdpg_usr.h"

#include <stddef.h>
#include <stdbool.h>

typedef enum tok_id tok_id;
typedef struct usr_ctx usr_ctx;

typedef struct prs_ctx {
	void * ctx;
} prs_ctx;

bool rdpg_parse(prs_ctx * prs, usr_ctx * usr);
const tok_id * rdpg_expect(prs_ctx * prs, size_t * out_size);

// <usr-callbacks>
void err_crit(const char * msg);
void tok_err(usr_ctx * usr, prs_ctx * prs);
tok_id tok_next(usr_ctx * usr);
// </usr-callbacks>
#endif
// </header>
