#ifndef RDPG_USR_FOO_H
#define RDPG_USR_FOO_H

enum tok_id_foo {
	NONE_FOO,
	L_PAR_FOO,
	R_PAR_FOO,
	NUMBER_FOO,
	POW_FOO,
	DIV_FOO,
	MUL_FOO,
	MINUS_FOO,
	PLUS_FOO,
	SEMI_FOO,
	EOI_FOO,
	ERR_FOO
};

struct usr_ctx_foo {
	void * ctx;
};
#endif
