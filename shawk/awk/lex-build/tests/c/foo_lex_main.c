#include "foo_lex.h"

#include <stdio.h>
#include <ctype.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>

#define BUFF_SZ (8*1024)

static bool g_do_peek_n_back_pos;

enum {WORD_ = 1, NUM_};
static char base_tbl[0xFF+1];
#define is_word(ch) (base_tbl[(unsigned char)ch] == WORD_)
#define is_num(ch) (base_tbl[(unsigned char)ch] == NUM_)
#define is_word_num(ch) ((unsigned char)base_tbl[(unsigned char)ch])
void init_tbl(char * tbl)
{
	for (int i = 0; i < 127; ++i)
	{
		if (isalpha(i) || '_' == i)
			tbl[i] = WORD_;
		else if (isdigit(i))
			tbl[i] = NUM_;
	}
}

const char * foo_lex_usr_get_input(void * arg, size_t * out_len)
{
	char * buff = (char *)arg;
	size_t read = fread(buff, 1, BUFF_SZ, stdin);
	buff[read] = '\0';
	*out_len = read;
	return buff;
}

void my_assert(bool expr, const char * str_expr, unsigned int line)
{
	if (!expr)
	{
		fprintf(
			stderr,
			"error: line %u, assertion '%s' failed",
			line,
			str_expr
		);
		exit(EXIT_FAILURE);
	}
}

#define MY_ASSERT(expr) my_assert(expr, #expr, __LINE__)

void do_peek_n_back(foo_lex_state * lex)
{
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(foo_lex_peek_ch(lex) == 'o');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == foo_lex_get_curr_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == foo_lex_peek_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 4) == 'b');

	foo_lex_back_pos(lex);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(foo_lex_peek_ch(lex) == 'o');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == foo_lex_get_curr_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == foo_lex_peek_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 4) == 'b');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -1) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -1000) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1000) == '\0');

	foo_lex_back_pos(lex);
	foo_lex_back_pos(lex);
	foo_lex_back_pos(lex);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(foo_lex_peek_ch(lex) == 'o');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == foo_lex_get_curr_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == foo_lex_peek_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 4) == 'b');

	MY_ASSERT(foo_lex_read_ch(lex) == 'o');
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 2);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'o');
	MY_ASSERT(foo_lex_peek_ch(lex) == '_');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == foo_lex_get_curr_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == foo_lex_peek_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 2) == ' ');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 3) == 'b');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 4) == 'a');

	MY_ASSERT(foo_lex_read_ch(lex) == '_');
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 3);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '_');
	MY_ASSERT(foo_lex_peek_ch(lex) == ' ');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -2) == 'f');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -1) == 'o');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == foo_lex_get_curr_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == foo_lex_peek_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 2) == 'b');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 3) == 'a');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 4) == 'r');

	foo_lex_back_pos(lex);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 2);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'o');
	MY_ASSERT(foo_lex_peek_ch(lex) == '_');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == foo_lex_get_curr_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == foo_lex_peek_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 2) == ' ');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 3) == 'b');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 4) == 'a');

	foo_lex_back_pos(lex);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(foo_lex_peek_ch(lex) == 'o');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == foo_lex_get_curr_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == foo_lex_peek_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 4) == 'b');

	foo_lex_back_pos(lex);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(foo_lex_peek_ch(lex) == 'o');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == foo_lex_get_curr_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == foo_lex_peek_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 4) == 'b');

	while (foo_lex_peek_ch(lex) != '\n')
		foo_lex_read_ch(lex);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 11);

	MY_ASSERT(foo_lex_read_ch(lex) == '\n');
	foo_lex_bump_line_num(lex);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 0);

	foo_lex_read_ch(lex);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 1);

	while (foo_lex_peek_ch(lex) != '\n')
		foo_lex_read_ch(lex);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 11);

	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'Z');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\n');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -3) == ' ');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -2) == 'B');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -1) == 'A');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == foo_lex_get_curr_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == foo_lex_peek_ch(lex));
	MY_ASSERT(foo_lex_peek_ch_n(lex, 2) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 3) == '\0');

	MY_ASSERT(foo_lex_read_ch(lex) == '\n');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '\n');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -1) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == '\0');

	MY_ASSERT(foo_lex_read_ch(lex) == '\0');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '\0');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -1) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == '\0');

	MY_ASSERT(foo_lex_read_ch(lex) == '\0');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '\0');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, -1) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 0) == '\0');
	MY_ASSERT(foo_lex_peek_ch_n(lex, 1) == '\0');
}

foo_tok_id foo_lex_usr_get_word(foo_lex_state * lex)
{
	if (g_do_peek_n_back_pos)
	{
		do_peek_n_back(lex);
		exit(EXIT_SUCCESS);
	}
	else
	{
		foo_lex_save_begin(lex);

		while (1)
		{
			foo_lex_save_ch(lex);

			if (is_word_num(foo_lex_peek_ch(lex)))
				foo_lex_read_ch(lex);
			else
				break;
		}

		foo_lex_save_end(lex);

		return foo_lex_keyword_or_base(lex, FOO_TOK_ID);
	}
}

foo_tok_id foo_lex_usr_get_number(foo_lex_state * lex)
{
	foo_lex_save_begin(lex);

	while (1)
	{
		foo_lex_save_ch(lex);

		if (is_num(foo_lex_peek_ch(lex)))
			foo_lex_read_ch(lex);
		else
			break;
	}

	foo_lex_save_end(lex);

	return FOO_TOK_NUMBER;
}

foo_tok_id foo_lex_usr_handle_slash(foo_lex_state * lex)
{
	// does nothing here; important in foo_unit_test.c
	return FOO_TOK_SLASH;
}

foo_tok_id foo_lex_usr_on_unknown_ch(foo_lex_state * lex)
{
	// stdout because of diff
	fprintf(
		stdout,
		"error: line %d, pos %d: unknown char '%c'\n",
		foo_lex_get_input_line_num(lex),
		foo_lex_get_input_line_pos(lex),
		foo_lex_get_curr_ch(lex)
	);
	return FOO_TOK_ERROR;
}

static void output(foo_lex_state * lex)
{
	foo_tok_id tok;
	while ((tok = foo_lex_next(lex)) != FOO_TOK_EOI)
	{
		printf("'%s' ", foo_lex_tok_to_str(tok));

		if (tok == FOO_TOK_ID || tok == FOO_TOK_NUMBER)
			printf("'%s' ", foo_lex_get_saved(lex));

		printf("line %d, pos %d",
			foo_lex_get_input_line_num(lex),
			foo_lex_get_input_line_pos(lex)
		);

		putchar('\n');
	}

	// make sure spaces in token strings are handled correctly
	printf("'%s'\n", foo_lex_tok_to_str(FOO_TOK_FCALL));
}

#define REAL_BSZ (BUFF_SZ+1)
int main(int argc, char * argv[])
{
	static char * peek_n_back_opt = "--peek_n_back";
	static char tok_buff[REAL_BSZ];
	static char file_buff[REAL_BSZ];
	init_tbl(base_tbl);

	foo_lex_init_info info = {
		.usr_arg = file_buff,
		.write_buff = tok_buff,
		.write_buff_len = REAL_BSZ
	};

	foo_lex_state lex_, * lex = &lex_;

	if (argc > 1)
	{
		for (int i = 1; i < argc; ++i)
		{
			if (0 == strcmp(argv[i], peek_n_back_opt))
			{
				g_do_peek_n_back_pos = true;
			}
			else
			{
				const char * fname = argv[i];
				if (!freopen(fname, "r", stdin))
				{
					fprintf(
						stderr,
						"lex-c-test: error: can't open file '%s'\n",
						fname
					);
					return -1;
				}

				foo_lex_init(lex, &info);
				output(lex);
			}
		}
	}

	return 0;
}
