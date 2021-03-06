// <lex_header>
// generated by lex-c.awk 1.93
#ifndef LEX_H
#define LEX_H

// <lex_includes>
#include <stdbool.h>
// </lex_includes>

// <lex_tok_id_enum>
typedef enum tok_id {
PLUS,               MINUS,              MULT,               DIVD,               
/* "+" */           /* "-" */           /* "*" */           /* "/" */           
MODUL,              INCR,               DECR,               EQEQ,               
/* "%" */           /* "++" */          /* "--" */          /* "==" */          
NEQ,                GRTR,               LESS,               GEQ,                
/* "!=" */          /* ">" */           /* "<" */           /* ">=" */          
LEQ,                LAND,               LOR,                LNOT,               
/* "<=" */          /* "&&" */          /* "||" */          /* "!" */           
AMPRS,              BOR,                XOR,                LSHFT,              
/* "&" */           /* "|" */           /* "^" */           /* "<<" */          
RSHFT,              EQ,                 PLEQ,               MINEQ,              
/* ">>" */          /* "=" */           /* "+=" */          /* "-=" */          
MULTEQ,             DIVEQ,              MODEQ,              LPAR,               
/* "*=" */          /* "/=" */          /* "%=" */          /* "(" */           
RPAR,               LCURLY,             RCURLY,             LSQUARE,            
/* ")" */           /* "{" */           /* "}" */           /* "[" */           
RSQUARE,            SEMI,               COMMA,              TOK_EOI,            
/* "]" */           /* ";" */           /* "," */           /* "EOI" */         
AUTO,               BREAK,              CASE,               CHAR,               
/* "auto" */        /* "break" */       /* "case" */        /* "char" */        
CONST,              CONTINUE,           DEFAULT,            DO,                 
/* "const" */       /* "continue" */    /* "default" */     /* "do" */          
DOUBLE,             ELSE,               ENUM,               EXTERN,             
/* "double" */      /* "else" */        /* "enum" */        /* "extern" */      
FLOAT,              FOR,                GOTO,               IF,                 
/* "float" */       /* "for" */         /* "goto" */        /* "if" */          
INT,                LONG,               REGISTER,           RETURN,             
/* "int" */         /* "long" */        /* "register" */    /* "return" */      
SHORT,              SIGNED,             SIZEOF,             STATIC,             
/* "short" */       /* "signed" */      /* "sizeof" */      /* "static" */      
STRUCT,             SWITCH,             TYPEDEF,            UNION,              
/* "struct" */      /* "switch" */      /* "typedef" */     /* "union" */       
UNSIGNED,           VOID,               VOLATILE,           WHILE,              
/* "unsigned" */    /* "void" */        /* "volatile" */    /* "while" */       
ID,                 NUM,                
/* "id" */          /* "number" */      
TOK_ERROR,
/* "error" */
} tok_id;
// </lex_tok_id_enum>

// <lex_structs>
typedef struct lex_state {
	const char * input;
	unsigned int input_pos;
	int curr_ch;
	tok_id curr_tok;
	unsigned int input_line;
	void * usr_arg;
	char * write_buff;
	unsigned int write_buff_len;
	unsigned int write_buff_pos;
} lex_state;

typedef struct lex_init_info {
	void * usr_arg;   // the argument to lex_usr_get_input()
	char * write_buff;   // lex_save_ch() saves here
	unsigned int write_buff_len; // includes the '\0'
} lex_init_info;
// </lex_structs>

// <lex_usr_defined>
// return text input; when done return "", never NULL
const char * lex_usr_get_input(void * usr_arg);
// user events
tok_id lex_usr_get_word(lex_state * lex);
tok_id lex_usr_get_number(lex_state * lex);
tok_id lex_usr_on_unknown_ch(lex_state * lex);
// </lex_usr_defined>

// <lex_static_inline>
// read the next character, advance the input
static inline int lex_read_ch(lex_state * lex)
{
	lex->curr_ch = *lex->input++;
	++lex->input_pos;
	if (!(*lex->input))
		lex->input = lex_usr_get_input(lex->usr_arg);
	return lex->curr_ch;
}

// look at, but do not read, the next character
static inline int lex_peek_ch(lex_state * lex)
{return *lex->input;}

// call this before writing to the lexer write space
static inline void lex_save_begin(lex_state * lex)
{lex->write_buff_pos = 0;}

// call this to write to the lexer write space
static inline bool lex_save_ch(lex_state * lex)
{
	bool is_saved = (lex->write_buff_pos < lex->write_buff_len);
	if (is_saved)
		lex->write_buff[lex->write_buff_pos++] = lex->curr_ch;
	return is_saved;
}
// call this to write to the lexer write space
static inline bool lex_save_ch_usr(lex_state * lex, char ch)
{
	bool is_saved = (lex->write_buff_pos < lex->write_buff_len);
	if (is_saved)
		lex->write_buff[lex->write_buff_pos++] = ch;
	return is_saved;
}

// call this after you're done writing to the lexer write space
static inline void lex_save_end(lex_state * lex)
{lex->write_buff[lex->write_buff_pos] = '\0';}

// get what you've written
static inline char * lex_get_saved(lex_state * lex)
{return lex->write_buff;}

// see how long it is
static inline unsigned int lex_get_saved_len(lex_state * lex)
{return lex->write_buff_pos;}

// so it's possible for the user to access their argument back
static inline void * lex_get_usr_arg(lex_state * lex)
{return lex->usr_arg;}

// get the character position on the current input line
static inline unsigned int lex_get_input_pos(lex_state * lex)
{return lex->input_pos;}

// get the number of the current input line
static inline unsigned int lex_get_input_line_no(lex_state * lex)
{return lex->input_line;}

// get the last character the lexer read
static inline int lex_get_curr_ch(lex_state * lex)
{return lex->curr_ch;}

// get the last token the lexer read
static inline tok_id lex_get_curr_tok(lex_state * lex)
{return lex->curr_tok;}

// see if tok is the same as the token in the lexer
static inline bool lex_match(lex_state * lex, tok_id tok)
{return (lex->curr_tok == tok);}

static inline void lex_init(lex_state * lex, lex_init_info * init)
{
	lex->input = lex_usr_get_input(init->usr_arg);
	lex->input_pos = 0;
	lex->curr_ch = -1;
	lex->curr_tok = TOK_ERROR;
	lex->input_line = 1;
	lex->usr_arg = init->usr_arg;
	lex->write_buff = init->write_buff;
	lex->write_buff_len = init->write_buff_len;
	lex->write_buff_pos = 0;
}
// </lex_static_inline>

// <lex_public>
// returns the string representation of tok
const char * lex_tok_to_str(tok_id tok);

// reads and returns the next token from the input
tok_id lex_next(lex_state * lex);

// returns the token for the keyword in lex's write buffer, or base if not a
// keyword; lookup method: ifs
tok_id lex_keyword_or_base(lex_state * lex, tok_id base);
// </lex_public>

#endif
// </lex_header>
