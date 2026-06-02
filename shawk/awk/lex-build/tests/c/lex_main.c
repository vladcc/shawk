#include "lex.h"

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

const char * lex_usr_get_input(void * arg, size_t * out_len)
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

void do_peek_n_back(lex_state * lex)
{
	MY_ASSERT(lex_get_input_line_num(lex) == 1);
	MY_ASSERT(lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(lex_peek_ch(lex) == 'o');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == lex_get_curr_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 1) == lex_peek_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(lex_peek_ch_n(lex, 4) == 'b');

	lex_back_pos(lex);
	MY_ASSERT(lex_get_input_line_num(lex) == 1);
	MY_ASSERT(lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(lex_peek_ch(lex) == 'o');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == lex_get_curr_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 1) == lex_peek_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(lex_peek_ch_n(lex, 4) == 'b');
	MY_ASSERT(lex_peek_ch_n(lex, -1) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, -1000) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, 1000) == '\0');

	lex_back_pos(lex);
	lex_back_pos(lex);
	lex_back_pos(lex);
	MY_ASSERT(lex_get_input_line_num(lex) == 1);
	MY_ASSERT(lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(lex_peek_ch(lex) == 'o');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == lex_get_curr_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 1) == lex_peek_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(lex_peek_ch_n(lex, 4) == 'b');

	MY_ASSERT(lex_read_ch(lex) == 'o');
	MY_ASSERT(lex_get_input_line_num(lex) == 1);
	MY_ASSERT(lex_get_input_line_pos(lex) == 2);
	MY_ASSERT(lex_get_curr_ch(lex) == 'o');
	MY_ASSERT(lex_peek_ch(lex) == '_');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == lex_get_curr_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 1) == lex_peek_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 2) == ' ');
	MY_ASSERT(lex_peek_ch_n(lex, 3) == 'b');
	MY_ASSERT(lex_peek_ch_n(lex, 4) == 'a');

	MY_ASSERT(lex_read_ch(lex) == '_');
	MY_ASSERT(lex_get_input_line_num(lex) == 1);
	MY_ASSERT(lex_get_input_line_pos(lex) == 3);
	MY_ASSERT(lex_get_curr_ch(lex) == '_');
	MY_ASSERT(lex_peek_ch(lex) == ' ');
	MY_ASSERT(lex_peek_ch_n(lex, -2) == 'f');
	MY_ASSERT(lex_peek_ch_n(lex, -1) == 'o');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == lex_get_curr_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 1) == lex_peek_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 2) == 'b');
	MY_ASSERT(lex_peek_ch_n(lex, 3) == 'a');
	MY_ASSERT(lex_peek_ch_n(lex, 4) == 'r');

	lex_back_pos(lex);
	MY_ASSERT(lex_get_input_line_num(lex) == 1);
	MY_ASSERT(lex_get_input_line_pos(lex) == 2);
	MY_ASSERT(lex_get_curr_ch(lex) == 'o');
	MY_ASSERT(lex_peek_ch(lex) == '_');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == lex_get_curr_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 1) == lex_peek_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 2) == ' ');
	MY_ASSERT(lex_peek_ch_n(lex, 3) == 'b');
	MY_ASSERT(lex_peek_ch_n(lex, 4) == 'a');

	lex_back_pos(lex);
	MY_ASSERT(lex_get_input_line_num(lex) == 1);
	MY_ASSERT(lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(lex_peek_ch(lex) == 'o');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == lex_get_curr_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 1) == lex_peek_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(lex_peek_ch_n(lex, 4) == 'b');

	lex_back_pos(lex);
	MY_ASSERT(lex_get_input_line_num(lex) == 1);
	MY_ASSERT(lex_get_input_line_pos(lex) == 1);
	MY_ASSERT(lex_get_curr_ch(lex) == 'f');
	MY_ASSERT(lex_peek_ch(lex) == 'o');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == lex_get_curr_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 1) == lex_peek_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 2) == '_');
	MY_ASSERT(lex_peek_ch_n(lex, 3) == ' ');
	MY_ASSERT(lex_peek_ch_n(lex, 4) == 'b');

	while (lex_peek_ch(lex) != '\n')
		lex_read_ch(lex);
	MY_ASSERT(lex_get_input_line_num(lex) == 1);
	MY_ASSERT(lex_get_input_line_pos(lex) == 11);

	MY_ASSERT(lex_read_ch(lex) == '\n');
	lex_bump_line_num(lex);
	MY_ASSERT(lex_get_input_line_num(lex) == 2);
	MY_ASSERT(lex_get_input_line_pos(lex) == 0);

	lex_read_ch(lex);
	MY_ASSERT(lex_get_input_line_num(lex) == 2);
	MY_ASSERT(lex_get_input_line_pos(lex) == 1);

	while (lex_peek_ch(lex) != '\n')
		lex_read_ch(lex);
	MY_ASSERT(lex_get_input_line_num(lex) == 2);
	MY_ASSERT(lex_get_input_line_pos(lex) == 11);

	MY_ASSERT(lex_get_curr_ch(lex) == 'Z');
	MY_ASSERT(lex_peek_ch(lex) == '\n');
	MY_ASSERT(lex_peek_ch_n(lex, -3) == ' ');
	MY_ASSERT(lex_peek_ch_n(lex, -2) == 'B');
	MY_ASSERT(lex_peek_ch_n(lex, -1) == 'A');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == lex_get_curr_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 1) == lex_peek_ch(lex));
	MY_ASSERT(lex_peek_ch_n(lex, 2) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, 3) == '\0');

	MY_ASSERT(lex_read_ch(lex) == '\n');
	MY_ASSERT(lex_get_curr_ch(lex) == '\n');
	MY_ASSERT(lex_peek_ch(lex) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, -1) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, 1) == '\0');

	MY_ASSERT(lex_read_ch(lex) == '\0');
	MY_ASSERT(lex_get_curr_ch(lex) == '\0');
	MY_ASSERT(lex_peek_ch(lex) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, -1) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, 1) == '\0');

	MY_ASSERT(lex_read_ch(lex) == '\0');
	MY_ASSERT(lex_get_curr_ch(lex) == '\0');
	MY_ASSERT(lex_peek_ch(lex) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, -1) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, 0) == '\0');
	MY_ASSERT(lex_peek_ch_n(lex, 1) == '\0');
}

tok_id lex_usr_get_word(lex_state * lex)
{
	if (g_do_peek_n_back_pos)
	{
		do_peek_n_back(lex);
		exit(EXIT_SUCCESS);
	}
	else
	{
		lex_save_begin(lex);

		while (1)
		{
			lex_save_ch(lex);

			if (is_word_num(lex_peek_ch(lex)))
				lex_read_ch(lex);
			else
				break;
		}

		lex_save_end(lex);

		return lex_keyword_or_base(lex, TOK_ID);
	}
}

tok_id lex_usr_get_number(lex_state * lex)
{
	lex_save_begin(lex);

	while (1)
	{
		lex_save_ch(lex);

		if (is_num(lex_peek_ch(lex)))
			lex_read_ch(lex);
		else
			break;
	}

	lex_save_end(lex);

	return TOK_NUMBER;
}

tok_id lex_usr_handle_slash(lex_state * lex)
{
	// does nothing here; important in unit_test.c
	return TOK_SLASH;
}

tok_id lex_usr_on_unknown_ch(lex_state * lex)
{
	// stdout because of diff
	fprintf(
		stdout,
		"error: line %d, pos %d: unknown char '%c'\n",
		lex_get_input_line_num(lex),
		lex_get_input_line_pos(lex),
		lex_get_curr_ch(lex)
	);
	return TOK_ERROR;
}

static void output(lex_state * lex)
{
	tok_id tok;
	while ((tok = lex_next(lex)) != TOK_EOI)
	{
		printf("'%s' ", lex_tok_to_str(tok));

		if (tok == TOK_ID || tok == TOK_NUMBER)
			printf("'%s' ", lex_get_saved(lex));

		printf(
			"line %d, pos %d",
			lex_get_input_line_num(lex),
			lex_get_input_line_pos(lex)
		);

		putchar('\n');
	}

	// make sure spaces in token strings are handled correctly
	printf("'%s'\n", lex_tok_to_str(TOK_FCALL));
}

#define REAL_BSZ (BUFF_SZ+1)
int main(int argc, char * argv[])
{
	static char * peek_n_back_opt = "--peek_n_back";
	static char tok_buff[REAL_BSZ];
	static char file_buff[REAL_BSZ];
	init_tbl(base_tbl);

	lex_init_info info = {
		.usr_arg = file_buff,
		.write_buff = tok_buff,
		.write_buff_len = REAL_BSZ
	};

	lex_state lex_, * lex = &lex_;

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

				lex_init(lex, &info);
				output(lex);
			}
		}
	}

	return 0;
}
