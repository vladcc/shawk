#include "foo_lex.h"

#include <stdio.h>
#include <ctype.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>

#define BUFF_SZ (8*1024)

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

const char * foo_lex_usr_get_input(void * arg)
{
	char * buff = (char *)arg;
	size_t read = fread(buff, 1, BUFF_SZ, stdin);
	buff[read] = '\0';
	return buff;
}

foo_tok_id foo_lex_usr_get_word(foo_lex_state * lex)
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

static void my_assert(bool expr, const char * str_expr, size_t line)
{
	if (!expr)
	{
		fprintf(stderr, "error: %zu: assertion '%s' failed\n", line, str_expr);
		exit(EXIT_FAILURE);
	}
}

#define MY_ASSERT(expr) my_assert(expr, #expr, __LINE__)

static void peek_1(foo_lex_state * lex, foo_lex_init_info * info)
{
	foo_lex_init(lex, info);

	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 0);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == -1);
	MY_ASSERT(foo_lex_peek_ch(lex) == 'f');

	MY_ASSERT(foo_lex_read_ch(lex) == 'f');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(foo_lex_peek_ch(lex) == 'o');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);

	MY_ASSERT(foo_lex_read_ch(lex) == 'o');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'o');
	MY_ASSERT(foo_lex_peek_ch(lex) == '_');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 2);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);

	MY_ASSERT(foo_lex_read_ch(lex) == '_');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '_');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\n');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 3);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);

	MY_ASSERT(foo_lex_read_ch(lex) == '\n');
	foo_lex_bump_line_num(lex);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '\n');
	MY_ASSERT(foo_lex_peek_ch(lex) == 'F');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 0);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);

	MY_ASSERT(foo_lex_read_ch(lex) == 'F');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'F');
	MY_ASSERT(foo_lex_peek_ch(lex) == 'O');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);

	MY_ASSERT(foo_lex_read_ch(lex) == 'O');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == 'O');
	MY_ASSERT(foo_lex_peek_ch(lex) == '_');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 2);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);

	MY_ASSERT(foo_lex_read_ch(lex) == '_');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '_');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\n');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 3);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);

	MY_ASSERT(foo_lex_read_ch(lex) == '\n');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '\n');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\0');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 4);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);

	MY_ASSERT(foo_lex_read_ch(lex) == '\0');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '\0');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\0');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 4);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);

	MY_ASSERT(foo_lex_read_ch(lex) == '\0');
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '\0');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\0');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 4);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);
}

static void peek_2(foo_lex_state * lex, foo_lex_init_info * info)
{
	foo_lex_init(lex, info);

	foo_tok_id tok = foo_lex_next(lex);
	MY_ASSERT(FOO_TOK_ID == tok);
	MY_ASSERT(0 == strcmp("fo_", foo_lex_get_saved(lex)));
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 3);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 1);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '_');
	MY_ASSERT(foo_lex_peek_ch(lex) == '\n');

	MY_ASSERT(foo_lex_read_ch(lex) == '\n');
	foo_lex_bump_line_num(lex);
	MY_ASSERT(foo_lex_get_curr_ch(lex) == '\n');
	MY_ASSERT(foo_lex_peek_ch(lex) == 'F');
	MY_ASSERT(foo_lex_get_input_line_pos(lex) == 0);
	MY_ASSERT(foo_lex_get_input_line_num(lex) == 2);
}

static int g_peek;

#define REAL_BSZ (BUFF_SZ+1)
int main(int argc, char * argv[])
{
	static char * opt_peek_1 = "--peek_1";
	static char * opt_peek_2 = "--peek_2";

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
			if (0 == strcmp(opt_peek_1, argv[i]))
			{
				g_peek = 1;
			}
			else if (0 == strcmp(opt_peek_2, argv[i]))
			{
				g_peek = 2;
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

				if (1 == g_peek)
				{
					peek_1(lex, &info);
				}
				else if (2 == g_peek)
				{
					peek_2(lex, &info);
				}
				else
				{
					foo_lex_init(lex, &info);
					output(lex);
				}
			}
		}
	}

	return 0;
}
