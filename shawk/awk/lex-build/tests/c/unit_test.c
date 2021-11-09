#include <stdio.h>
#include "test.h"
#include "lex.h"
#include <ctype.h>
#include <string.h>

#define BUFF_SZ 8
static char g_save[BUFF_SZ];

static bool test_lex(void);

static ftest tests[] = {
	test_lex,
};

//------------------------------------------------------------------------------

static void init_lex(lex_state * lex, char *** usr_arg)
{
	lex_init_info info = {
		.usr_arg = usr_arg,
		.write_buff = g_save,
		.write_buff_len = BUFF_SZ
	};
	
	lex_init(lex, &info);
}

static bool test_lex(void)
{
	static char input[] = "= <= ==!456 foo===while \n whilex123_z if &";
	char * str = input;
	char ** pinput = &str;
	
	lex_state lex_, * lex = &lex_;
	init_lex(lex, &pinput);

	static char unknown[] = "@"; // second line of input
	str = unknown;
	
	check(TOK_EQ == lex_next(lex));
	check(TOK_EQ == lex_get_curr_tok(lex));
	check('=' == lex_get_curr_ch(lex));
	check(' ' == lex_peek_ch(lex));
	check(1 == lex_get_input_pos(lex));
	check(1 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "=") == 0);
	check(lex_match(lex, TOK_EQ));
	check(!lex_match(lex, TOK_ERROR));

	check(TOK_LEQ == lex_next(lex));
	check(TOK_LEQ == lex_get_curr_tok(lex));
	check('=' == lex_get_curr_ch(lex));
	check(' ' == lex_peek_ch(lex));
	check(4 == lex_get_input_pos(lex));
	check(1 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "<=") == 0);
	check(lex_match(lex, TOK_LEQ));
	
	check(TOK_NEQEQEQ == lex_next(lex));
	check(TOK_NEQEQEQ == lex_get_curr_tok(lex));
	check('!' == lex_get_curr_ch(lex));
	check('4' == lex_peek_ch(lex));
	check(8 == lex_get_input_pos(lex));
	check(1 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "==!") == 0);
	check(lex_match(lex, TOK_NEQEQEQ));

	check(TOK_NUMBER == lex_next(lex));
	check(TOK_NUMBER == lex_get_curr_tok(lex));
	check('6' == lex_get_curr_ch(lex));
	check(' ' == lex_peek_ch(lex));
	check(11 == lex_get_input_pos(lex));
	check(1 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "number") == 0);
	check(lex_match(lex, TOK_NUMBER));
	check(strcmp(lex_get_saved(lex), "456") == 0);
	check(3 == lex_get_saved_len(lex));
	check(!lex_match(lex, TOK_ERROR));
	
	check(TOK_ID == lex_next(lex));
	check(TOK_ID == lex_get_curr_tok(lex));
	check('o' == lex_get_curr_ch(lex));
	check('=' == lex_peek_ch(lex));
	check(15 == lex_get_input_pos(lex));
	check(1 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "id") == 0);
	check(lex_match(lex, TOK_ID));
	check(strcmp(lex_get_saved(lex), "foo") == 0);
	check(3 == lex_get_saved_len(lex));

	check(TOK_EQEQEQ == lex_next(lex));
	check(TOK_EQEQEQ == lex_get_curr_tok(lex));
	check('=' == lex_get_curr_ch(lex));
	check('w' == lex_peek_ch(lex));
	check(18 == lex_get_input_pos(lex));
	check(1 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "===") == 0);
	check(lex_match(lex, TOK_EQEQEQ));

	check(TOK_WHILE == lex_next(lex));
	check(TOK_WHILE == lex_get_curr_tok(lex));
	check('e' == lex_get_curr_ch(lex));
	check(' ' == lex_peek_ch(lex));
	check(23 == lex_get_input_pos(lex));
	check(1 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "while") == 0);
	check(lex_match(lex, TOK_WHILE));
	check(strcmp(lex_get_saved(lex), "while") == 0);
	check(5 == lex_get_saved_len(lex));
	check(!lex_match(lex, TOK_ERROR));
	
	check(TOK_ID == lex_next(lex));
	check(TOK_ID == lex_get_curr_tok(lex));
	check('z' == lex_get_curr_ch(lex));
	check(' ' == lex_peek_ch(lex));
	check(12 == lex_get_input_pos(lex));
	check(2 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "id") == 0);
	check(lex_match(lex, TOK_ID));
	check(strcmp(lex_get_saved(lex), "whilex12") == 0);
	check(8 == lex_get_saved_len(lex));

	check(TOK_IF == lex_next(lex));
	check(TOK_IF == lex_get_curr_tok(lex));
	check('f' == lex_get_curr_ch(lex));
	check(' ' == lex_peek_ch(lex));
	check(15 == lex_get_input_pos(lex));
	check(2 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "if") == 0);
	check(lex_match(lex, TOK_IF));
	check(strcmp(lex_get_saved(lex), "if") == 0);
	check(2 == lex_get_saved_len(lex));

	check(TOK_AND == lex_next(lex));
	check(TOK_AND == lex_get_curr_tok(lex));
	check('&' == lex_get_curr_ch(lex));
	check('@' == lex_peek_ch(lex));
	check(17 == lex_get_input_pos(lex));
	check(2 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "&") == 0);
	check(lex_match(lex, TOK_AND));

	static char empty[] = ""; // third line of input
	str = empty;
	
	check(TOK_ERROR == lex_next(lex));
	check(TOK_ERROR == lex_get_curr_tok(lex));
	check('@' == lex_get_curr_ch(lex));
	check('\0' == lex_peek_ch(lex));
	check(18 == lex_get_input_pos(lex));
	check(2 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "I am Error") == 0);
	check(lex_match(lex, TOK_ERROR));
	check(strcmp(lex_get_saved(lex), "@") == 0);
	check(1 == lex_get_saved_len(lex));
	check(!lex_match(lex, TOK_EQ));
	
	check(TOK_EOI == lex_next(lex));
	check(TOK_EOI == lex_get_curr_tok(lex));
	check('\0' == lex_get_curr_ch(lex));
	//check('\0' == lex_peek_ch(lex));
	check(19 == lex_get_input_pos(lex));
	check(2 == lex_get_input_line_no(lex));
	check(strcmp(lex_tok_to_str(lex_get_curr_tok(lex)), "EOI") == 0);
	check(lex_match(lex, TOK_EOI));
	
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

const char * lex_usr_get_input(void * arg)
{
	return **((const char ***)arg);
}

tok_id lex_usr_get_word(lex_state * lex)
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

tok_id lex_usr_on_unknown_ch(lex_state * lex)
{
	lex_save_begin(lex);
	lex_save_ch(lex);
	lex_save_end(lex);
	
	return TOK_ERROR;
}

int main(void)
{
	init_tbl(base_tbl);
	return run_tests();
}
//------------------------------------------------------------------------------
