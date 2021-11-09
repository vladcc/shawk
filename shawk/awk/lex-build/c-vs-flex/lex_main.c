#include "lex.h"

#include <stdio.h>
#include <ctype.h>
#include <time.h>
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

const char * lex_usr_get_input(void * arg)
{
	char * buff = (char *)arg;
	int read = fread(buff, 1, BUFF_SZ, stdin);
	buff[read] = '\0';
	return buff;
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

	return lex_keyword_or_base(lex, ID);
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
	
	return NUM;
}

tok_id lex_usr_on_unknown_ch(lex_state * lex)
{
	fprintf(stderr, "error: unknown char '%c' 0x%X; quitting\n",
		lex_get_curr_ch(lex), (uint)lex_get_curr_ch(lex));
	exit(EXIT_FAILURE);
}

static void output(lex_state * lex)
{
    clock_t begin, end;
    double time;

    begin = clock();

	while (lex_next(lex) != TOK_EOI)
		printf("%s\n", lex_tok_to_str(lex_get_curr_tok(lex)));
    
    end = clock();
    time = (double)(end - begin) / CLOCKS_PER_SEC;
    fprintf(stderr, "%f sec\n", time);
}

static void silent(lex_state * lex)
{
    clock_t begin, end;
    double time;

    begin = clock();
    
    while (lex_next(lex) != TOK_EOI)
        continue;
    
    end = clock();
    time = (double)(end - begin) / CLOCKS_PER_SEC;
    printf("%f sec\n", time);
}

#define REAL_BSZ (BUFF_SZ+1)
int main(int argc, char * argv[])
{
	static char tok_buff[REAL_BSZ];
	static char file_buff[REAL_BSZ];
	init_tbl(base_tbl);

	if (argc > 1)
	{
		const char * fname = argv[1];
		if (!freopen(fname, "r", stdin))
		{
			fprintf(stderr, "error: can't open file '%s'\n", fname);
			return -1;
		}
	}
	
	lex_init_info info = {
		.usr_arg = file_buff,
		.write_buff = tok_buff,
		.write_buff_len = REAL_BSZ
	};

	lex_state lex_, * lex = &lex_;
	lex_init(lex, &info);

	if (argc > 2)
        output(lex);
    else
		silent(lex);
	
	return 0;
}
