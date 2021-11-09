#include <stdio.h>
#include "test.h"
#include "foo_lex.h"
#include <ctype.h>
#include <string.h>

#define BUFF_SZ 8
static char g_save[BUFF_SZ];

static bool test_lex(void);

static ftest tests[] = {
	test_lex,
};

//------------------------------------------------------------------------------

static void init_lex(foo_lex_state * lex, char *** usr_arg)
{
	foo_lex_init_info info = {
		.usr_arg = usr_arg,
		.write_buff = g_save,
		.write_buff_len = BUFF_SZ
	};
	
	foo_lex_init(lex, &info);
}

static bool test_lex(void)
{
	static char input[] = "= <= ==!456 foo===while \n whilex123_z if &";
	char * str = input;
	char ** pinput = &str;
	
	foo_lex_state lex_, * lex = &lex_;
	init_lex(lex, &pinput);

	static char unknown[] = "@"; // second line of input
	str = unknown;
	
	check(FOO_TOK_EQ == foo_lex_next(lex));
	check(FOO_TOK_EQ == foo_lex_get_curr_tok(lex));
	check('=' == foo_lex_get_curr_ch(lex));
	check(' ' == foo_lex_peek_ch(lex));
	check(1 == foo_lex_get_input_pos(lex));
	check(1 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "=") == 0);
	check(foo_lex_match(lex, FOO_TOK_EQ));
	check(!foo_lex_match(lex, FOO_TOK_ERROR));

	check(FOO_TOK_LEQ == foo_lex_next(lex));
	check(FOO_TOK_LEQ == foo_lex_get_curr_tok(lex));
	check('=' == foo_lex_get_curr_ch(lex));
	check(' ' == foo_lex_peek_ch(lex));
	check(4 == foo_lex_get_input_pos(lex));
	check(1 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "<=") == 0);
	check(foo_lex_match(lex, FOO_TOK_LEQ));
	
	check(FOO_TOK_NEQEQEQ == foo_lex_next(lex));
	check(FOO_TOK_NEQEQEQ == foo_lex_get_curr_tok(lex));
	check('!' == foo_lex_get_curr_ch(lex));
	check('4' == foo_lex_peek_ch(lex));
	check(8 == foo_lex_get_input_pos(lex));
	check(1 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "==!") == 0);
	check(foo_lex_match(lex, FOO_TOK_NEQEQEQ));

	check(FOO_TOK_NUMBER == foo_lex_next(lex));
	check(FOO_TOK_NUMBER == foo_lex_get_curr_tok(lex));
	check('6' == foo_lex_get_curr_ch(lex));
	check(' ' == foo_lex_peek_ch(lex));
	check(11 == foo_lex_get_input_pos(lex));
	check(1 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "number") == 0);
	check(foo_lex_match(lex, FOO_TOK_NUMBER));
	check(strcmp(foo_lex_get_saved(lex), "456") == 0);
	check(3 == foo_lex_get_saved_len(lex));
	check(!foo_lex_match(lex, FOO_TOK_ERROR));
	
	check(FOO_TOK_ID == foo_lex_next(lex));
	check(FOO_TOK_ID == foo_lex_get_curr_tok(lex));
	check('o' == foo_lex_get_curr_ch(lex));
	check('=' == foo_lex_peek_ch(lex));
	check(15 == foo_lex_get_input_pos(lex));
	check(1 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "id") == 0);
	check(foo_lex_match(lex, FOO_TOK_ID));
	check(strcmp(foo_lex_get_saved(lex), "foo") == 0);
	check(3 == foo_lex_get_saved_len(lex));

	check(FOO_TOK_EQEQEQ == foo_lex_next(lex));
	check(FOO_TOK_EQEQEQ == foo_lex_get_curr_tok(lex));
	check('=' == foo_lex_get_curr_ch(lex));
	check('w' == foo_lex_peek_ch(lex));
	check(18 == foo_lex_get_input_pos(lex));
	check(1 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "===") == 0);
	check(foo_lex_match(lex, FOO_TOK_EQEQEQ));

	check(FOO_TOK_WHILE == foo_lex_next(lex));
	check(FOO_TOK_WHILE == foo_lex_get_curr_tok(lex));
	check('e' == foo_lex_get_curr_ch(lex));
	check(' ' == foo_lex_peek_ch(lex));
	check(23 == foo_lex_get_input_pos(lex));
	check(1 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "while") == 0);
	check(foo_lex_match(lex, FOO_TOK_WHILE));
	check(strcmp(foo_lex_get_saved(lex), "while") == 0);
	check(5 == foo_lex_get_saved_len(lex));
	check(!foo_lex_match(lex, FOO_TOK_ERROR));
	
	check(FOO_TOK_ID == foo_lex_next(lex));
	check(FOO_TOK_ID == foo_lex_get_curr_tok(lex));
	check('z' == foo_lex_get_curr_ch(lex));
	check(' ' == foo_lex_peek_ch(lex));
	check(12 == foo_lex_get_input_pos(lex));
	check(2 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "id") == 0);
	check(foo_lex_match(lex, FOO_TOK_ID));
	check(strcmp(foo_lex_get_saved(lex), "whilex12") == 0);
	check(8 == foo_lex_get_saved_len(lex));

	check(FOO_TOK_IF == foo_lex_next(lex));
	check(FOO_TOK_IF == foo_lex_get_curr_tok(lex));
	check('f' == foo_lex_get_curr_ch(lex));
	check(' ' == foo_lex_peek_ch(lex));
	check(15 == foo_lex_get_input_pos(lex));
	check(2 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "if") == 0);
	check(foo_lex_match(lex, FOO_TOK_IF));
	check(strcmp(foo_lex_get_saved(lex), "if") == 0);
	check(2 == foo_lex_get_saved_len(lex));

	check(FOO_TOK_AND == foo_lex_next(lex));
	check(FOO_TOK_AND == foo_lex_get_curr_tok(lex));
	check('&' == foo_lex_get_curr_ch(lex));
	check('@' == foo_lex_peek_ch(lex));
	check(17 == foo_lex_get_input_pos(lex));
	check(2 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "&") == 0);
	check(foo_lex_match(lex, FOO_TOK_AND));

	static char empty[] = ""; // third line of input
	str = empty;
	
	check(FOO_TOK_ERROR == foo_lex_next(lex));
	check(FOO_TOK_ERROR == foo_lex_get_curr_tok(lex));
	check('@' == foo_lex_get_curr_ch(lex));
	check('\0' == foo_lex_peek_ch(lex));
	check(18 == foo_lex_get_input_pos(lex));
	check(2 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)),
		"I am Error") == 0);
	check(foo_lex_match(lex, FOO_TOK_ERROR));
	check(strcmp(foo_lex_get_saved(lex), "@") == 0);
	check(1 == foo_lex_get_saved_len(lex));
	check(!foo_lex_match(lex, FOO_TOK_EQ));
	
	check(FOO_TOK_EOI == foo_lex_next(lex));
	check(FOO_TOK_EOI == foo_lex_get_curr_tok(lex));
	check('\0' == foo_lex_get_curr_ch(lex));
	//check('\0' == foo_lex_peek_ch(lex));
	check(19 == foo_lex_get_input_pos(lex));
	check(2 == foo_lex_get_input_line_no(lex));
	check(strcmp(foo_lex_tok_to_str(foo_lex_get_curr_tok(lex)), "EOI") == 0);
	check(foo_lex_match(lex, FOO_TOK_EOI));
	
	return true;
}
//------------------------------------------------------------------------------

int run_tests(void)
{
    int i, end = sizeof(tests)/sizeof(*tests);

    int passed = 0;
    for (i = 0; i < end; ++i)
        if (tests[i]())
            ++passed;

    if (passed != end)
        putchar('\n');

    int failed = end - passed;

    if (failed)
		report(passed, failed);

    return failed;
}
//------------------------------------------------------------------------------

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
	return **((const char ***)arg);
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

foo_tok_id foo_lex_usr_on_unknown_ch(foo_lex_state * lex)
{
	foo_lex_save_begin(lex);
	foo_lex_save_ch(lex);
	foo_lex_save_end(lex);
	
	return FOO_TOK_ERROR;
}

int main(void)
{
	init_tbl(base_tbl);
	return run_tests();
}
//------------------------------------------------------------------------------
