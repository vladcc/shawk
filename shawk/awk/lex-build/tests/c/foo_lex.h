// <lex_header>
// generated by lex-c.awk 1.41
#ifndef FOO_LEX_H
#define FOO_LEX_H

#include <stdbool.h>

typedef enum foo_tok_id {
FOO_TOK_EQ,         FOO_TOK_EQEQ,       FOO_TOK_EQEQEQ,     FOO_TOK_NEQEQEQ,    
/* "=" */           /* "==" */          /* "===" */         /* "==!" */         
FOO_TOK_NEQ,        FOO_TOK_LESS,       FOO_TOK_GT,         FOO_TOK_LEQ,        
/* "=!" */          /* "<" */           /* ">" */           /* "<=" */          
FOO_TOK_GEQ,        FOO_TOK_AND,        FOO_TOK_EOI,        FOO_TOK_IF,         
/* ">=" */          /* "&" */           /* "EOI" */         /* "if" */          
FOO_TOK_ELSE,       FOO_TOK_ELIF,       FOO_TOK_WHILE,      FOO_TOK_ID,         
/* "else" */        /* "elif" */        /* "while" */       /* "id" */          
FOO_TOK_NUMBER,     
/* "number" */      
FOO_TOK_ERROR,
/* "I am Error" */
} foo_tok_id;

typedef unsigned int uint;
typedef struct foo_lex_state {
	const char * input;
	uint input_pos;
	int curr_ch;
	foo_tok_id curr_tok;
	uint input_line;
	void * usr_arg;
	char * write_buff;
	uint write_buff_len;
	uint write_buff_pos;
} foo_lex_state;

typedef struct foo_lex_init_info {
	void * usr_arg;   // the argument to foo_lex_usr_get_input()
	char * write_buff;   // foo_lex_save_ch() saves here
	uint write_buff_len; // includes the '\0'
} foo_lex_init_info;

// <lex_usr_defined>
// return text input; when done return "", never NULL
const char * foo_lex_usr_get_input(void * usr_arg);
// user events
foo_tok_id foo_lex_usr_get_word(foo_lex_state * lex);
foo_tok_id foo_lex_usr_get_number(foo_lex_state * lex);
foo_tok_id foo_lex_usr_on_unknown_ch(foo_lex_state * lex);
// </lex_usr_defined>

// read the next character, advance the input
static inline int foo_lex_read_ch(foo_lex_state * lex)
{
	lex->curr_ch = *lex->input++;
	++lex->input_pos;
	if (!(*lex->input))
		lex->input = foo_lex_usr_get_input(lex->usr_arg);
	return lex->curr_ch;
}

// look at, but do not read, the next character
static inline int foo_lex_peek_ch(foo_lex_state * lex)
{return *lex->input;}

// call this before writing to the lexer write space
static inline void foo_lex_save_begin(foo_lex_state * lex)
{lex->write_buff_pos = 0;}

// call this to write to the lexer write space
static inline bool foo_lex_save_ch(foo_lex_state * lex)
{
	bool is_saved = (lex->write_buff_pos < lex->write_buff_len);
	if (is_saved)
		lex->write_buff[lex->write_buff_pos++] = lex->curr_ch;
	return is_saved;
}

// call this after you're done writing to the lexer write space
static inline void foo_lex_save_end(foo_lex_state * lex)
{lex->write_buff[lex->write_buff_pos] = '\0';}

// get what you've written
static inline char * foo_lex_get_saved(foo_lex_state * lex)
{return lex->write_buff;}

// see how long it is
static inline uint foo_lex_get_saved_len(foo_lex_state * lex)
{return lex->write_buff_pos;}

// so it's possible for the user to access their argument back
static inline void * foo_lex_get_usr_arg(foo_lex_state * lex)
{return lex->usr_arg;}

// get the character position on the current input line
static inline uint foo_lex_get_input_pos(foo_lex_state * lex)
{return lex->input_pos;}

// get the number of the current input line
static inline uint foo_lex_get_input_line_no(foo_lex_state * lex)
{return lex->input_line;}

// get the last character the lexer read
static inline int foo_lex_get_curr_ch(foo_lex_state * lex)
{return lex->curr_ch;}

// get the last token the lexer read
static inline foo_tok_id foo_lex_get_curr_tok(foo_lex_state * lex)
{return lex->curr_tok;}

// see if tok is the same as the token in the lexer
static inline bool foo_lex_match(foo_lex_state * lex, foo_tok_id tok)
{return (lex->curr_tok == tok);}

static inline void foo_lex_init(foo_lex_state * lex, foo_lex_init_info * init)
{
	lex->input = foo_lex_usr_get_input(init->usr_arg);
	lex->input_pos = 0;
	lex->curr_ch = -1;
	lex->curr_tok = FOO_TOK_ERROR;
	lex->input_line = 1;
	lex->usr_arg = init->usr_arg;
	lex->write_buff = init->write_buff;
	lex->write_buff_len = init->write_buff_len;
	lex->write_buff_pos = 0;
}

// returns the string representation of tok
const char * foo_lex_tok_to_str(foo_tok_id tok);

// reads and returns the next token from the input
foo_tok_id foo_lex_next(foo_lex_state * lex);

// returns the token for the keyword in lex's write buffer, or base if not a
// keyword; lookup method: ifs
foo_tok_id foo_lex_keyword_or_base(foo_lex_state * lex, foo_tok_id base);

#endif
// </lex_header>
