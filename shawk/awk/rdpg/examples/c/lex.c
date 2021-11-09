#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

typedef enum token {
	ERR, PLUS, MINUS, MUL, DIV, EXP, NUMBER, LPAR, RPAR, SEMI, EOI, TAIL
} token;

typedef struct lex_state {
	const char * line;
	int line_len;
	int pos;
	double number;
	token curr_tok;
} lex_state;

#define lex_get_line(plex) ((const char *)plex->line)
#define lex_get_line_pos(plex) ((int)plex->pos)

#define BUFF_SZ 32

const char * lex_tok_to_str(token tok)
{
	static const char * toks[] = {
		"error", "+", "-", "*", "/", "^", "number", "(", ")", ";", "EOI"
	};

	return toks[tok];
}

void lex_init(lex_state * lex, const char * line)
{
	memset(lex, 0, sizeof(*lex));
	lex->line = line;
	lex->line_len = strlen(line);
	
	int last = lex->line_len-1;
	char * ln = (char *)lex->line;
	if ('\n' == ln[last])
		ln[last] = '\0';
}

token lex_get_token(lex_state * lex)
{
	return lex->curr_tok;
}

int lex_get_number(lex_state * lex)
{
	return lex->number;
}

bool lex_tok_match(lex_state * lex, token tok)
{
	return (lex->curr_tok == tok);
}

#define lex_get_ch(lex)\
((lex->pos < lex->line_len) ? lex->line[lex->pos] : '\0')

#define lex_next_ch(lex)      (lex->pos++)
#define lex_reset_pos(lex)    (lex->pos = 0)
#define lex_set_tok(lex, tok) (lex->curr_tok = tok)

token lex_tok_next(lex_state * lex)
{
	token tok = ERR;
	while (true)
	{
		int ch = lex_get_ch(lex);
		switch (ch)
		{
			case ' ': case '\t': lex_next_ch(lex); continue;
			case '\0': tok = EOI; goto next;
			case '+': tok = PLUS; goto next;
			case '-': tok = MINUS; goto next;
			case '*': tok = MUL; goto next;
			case '/': tok = DIV; goto next;
			case '^': tok = EXP; goto next;
			case '(': tok = LPAR; goto next;
			case ')': tok = RPAR; goto next;
			case ';': tok = SEMI; goto next;
			default:
			{
				if (isdigit(ch))
				{
					char buff[BUFF_SZ];
					
					int i = 0;
					do
					{
						buff[i++] = ch;
						lex_next_ch(lex);
						ch = lex_get_ch(lex);
					} while (isdigit(ch));
					
					buff[i] = '\0';
					sscanf(buff, "%lf", &(lex->number));
					
					tok = NUMBER;
					goto out;
				}
				printf("warning: ignoring unknown char '%c'\n", ch);
				lex_next_ch(lex);
			}
		}
	}
	
next:
	lex_next_ch(lex);
out:
	lex_set_tok(lex, tok);
	return tok;
}
