#ifndef RDPG_USR_H
#define RDPG_USR_H

enum tok_id {
	NONE,
	L_PAR,
	R_PAR,
	NUMBER,
	POW,
	DIV,
	MUL,
	MINUS,
	PLUS,
	SEMI,
	EOI,
	ERR,
};

typedef struct lex_prs_ctx lex_prs_ctx;
struct usr_ctx {
	lex_prs_ctx * ctx;
};
#endif
