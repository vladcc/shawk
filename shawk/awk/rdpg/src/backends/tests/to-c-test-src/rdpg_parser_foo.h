// <header>
#ifndef RDPG_PARSER_FOO_H
#define RDPG_PARSER_FOO_H
#include "rdpg_usr_foo.h"

#include <stddef.h>
#include <stdbool.h>

typedef enum tok_id_foo tok_id_foo;
typedef struct usr_ctx_foo usr_ctx_foo;

typedef struct prs_ctx_foo {
	void * ctx;
} prs_ctx_foo;

bool rdpg_parse_foo(prs_ctx_foo * prs, usr_ctx_foo * usr);
const tok_id_foo * rdpg_expect_foo(prs_ctx_foo * prs, size_t * out_size);

// <usr-callbacks>
void err_crit_foo(const char * msg);
void tok_err_foo(usr_ctx_foo * usr, prs_ctx_foo * prs);
tok_id_foo tok_next_foo(usr_ctx_foo * usr);
// </usr-callbacks>
#endif
// </header>
