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
//	MINUS,
	PLUS,
	SEMI,
	EOI,
	ERR,
};

struct usr_ctx {
	void * ctx;
};
#endif
