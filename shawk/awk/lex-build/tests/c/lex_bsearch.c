// <lex_source>
// generated by lex-c.awk 1.93
#include "lex.h"
#include <string.h>
#include <stdlib.h>

// <lex_token_str>
static const char * tokens[] = {
"=",                "==",               "===",              "==!",              
/* TOK_EQ */        /* TOK_EQEQ */      /* TOK_EQEQEQ */    /* TOK_NEQEQEQ */   
"=!",               "<",                ">",                "<=",               
/* TOK_NEQ */       /* TOK_LESS */      /* TOK_GT */        /* TOK_LEQ */       
">=",               "&",                "EOI",              "/",                
/* TOK_GEQ */       /* TOK_AND */       /* TOK_EOI */       /* TOK_SLASH */     
"if",               "else",             "elif",             "while",            
/* TOK_IF */        /* TOK_ELSE */      /* TOK_ELIF */      /* TOK_WHILE */     
"id",               "number",           "function call",    
/* TOK_ID */        /* TOK_NUMBER */    /* TOK_FCALL */     
"error",
/* TOK_ERROR */
};

const char * lex_tok_to_str(tok_id tok)
{
	return tokens[tok];
}
// </lex_token_str>

// <lex_char_cls_enum>
enum char_cls {
CH_CLS_SPACE = 1,   CH_CLS_WORD,        CH_CLS_NUMBER,      CH_CLS_LESS_THAN,   
CH_CLS_GRTR_THAN,   CH_CLS_NEW_LINE,    CH_CLS_EOI,         CH_CLS_SLASH,       
CH_CLS_AUTO_1_,     CH_CLS_AUTO_2_,     
};
// </lex_char_cls_enum>

// <lex_src_defines>
#define CHAR_TBL_SZ (0xFF+1)
typedef unsigned char byte;
// </lex_src_defines>
// <lex_char_tbl>
static const byte char_cls_tbl[CHAR_TBL_SZ] = {
/* 000 0x00 '\0' */ CH_CLS_EOI,     
0, 0, 0, 0, 0, 0, 0, 0, 
/* 009 0x09 '\t' */ CH_CLS_SPACE,   /* 010 0x0A '\n' */ CH_CLS_NEW_LINE, 
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
0, 0, 0, 0, 0, 
/* 032 0x20 ' ' */ CH_CLS_SPACE,    
0, 0, 0, 0, 0, 
/* 038 0x26 '&' */ CH_CLS_AUTO_2_,  
0, 0, 0, 0, 0, 0, 0, 0, 
/* 047 0x2F '/' */ CH_CLS_SLASH,    /* 048 0x30 '0' */ CH_CLS_NUMBER,   
/* 049 0x31 '1' */ CH_CLS_NUMBER,   /* 050 0x32 '2' */ CH_CLS_NUMBER,   
/* 051 0x33 '3' */ CH_CLS_NUMBER,   /* 052 0x34 '4' */ CH_CLS_NUMBER,   
/* 053 0x35 '5' */ CH_CLS_NUMBER,   /* 054 0x36 '6' */ CH_CLS_NUMBER,   
/* 055 0x37 '7' */ CH_CLS_NUMBER,   /* 056 0x38 '8' */ CH_CLS_NUMBER,   
/* 057 0x39 '9' */ CH_CLS_NUMBER,   
0, 0, 
/* 060 0x3C '<' */ CH_CLS_LESS_THAN, /* 061 0x3D '=' */ CH_CLS_AUTO_1_,  
/* 062 0x3E '>' */ CH_CLS_GRTR_THAN, 
0, 0, 
/* 065 0x41 'A' */ CH_CLS_WORD,     /* 066 0x42 'B' */ CH_CLS_WORD,     
/* 067 0x43 'C' */ CH_CLS_WORD,     /* 068 0x44 'D' */ CH_CLS_WORD,     
/* 069 0x45 'E' */ CH_CLS_WORD,     /* 070 0x46 'F' */ CH_CLS_WORD,     
/* 071 0x47 'G' */ CH_CLS_WORD,     /* 072 0x48 'H' */ CH_CLS_WORD,     
/* 073 0x49 'I' */ CH_CLS_WORD,     /* 074 0x4A 'J' */ CH_CLS_WORD,     
/* 075 0x4B 'K' */ CH_CLS_WORD,     /* 076 0x4C 'L' */ CH_CLS_WORD,     
/* 077 0x4D 'M' */ CH_CLS_WORD,     /* 078 0x4E 'N' */ CH_CLS_WORD,     
/* 079 0x4F 'O' */ CH_CLS_WORD,     /* 080 0x50 'P' */ CH_CLS_WORD,     
/* 081 0x51 'Q' */ CH_CLS_WORD,     /* 082 0x52 'R' */ CH_CLS_WORD,     
/* 083 0x53 'S' */ CH_CLS_WORD,     /* 084 0x54 'T' */ CH_CLS_WORD,     
/* 085 0x55 'U' */ CH_CLS_WORD,     /* 086 0x56 'V' */ CH_CLS_WORD,     
/* 087 0x57 'W' */ CH_CLS_WORD,     /* 088 0x58 'X' */ CH_CLS_WORD,     
/* 089 0x59 'Y' */ CH_CLS_WORD,     /* 090 0x5A 'Z' */ CH_CLS_WORD,     
0, 0, 0, 0, 
/* 095 0x5F '_' */ CH_CLS_WORD,     
0, 
/* 097 0x61 'a' */ CH_CLS_WORD,     /* 098 0x62 'b' */ CH_CLS_WORD,     
/* 099 0x63 'c' */ CH_CLS_WORD,     /* 100 0x64 'd' */ CH_CLS_WORD,     
/* 101 0x65 'e' */ CH_CLS_WORD,     /* 102 0x66 'f' */ CH_CLS_WORD,     
/* 103 0x67 'g' */ CH_CLS_WORD,     /* 104 0x68 'h' */ CH_CLS_WORD,     
/* 105 0x69 'i' */ CH_CLS_WORD,     /* 106 0x6A 'j' */ CH_CLS_WORD,     
/* 107 0x6B 'k' */ CH_CLS_WORD,     /* 108 0x6C 'l' */ CH_CLS_WORD,     
/* 109 0x6D 'm' */ CH_CLS_WORD,     /* 110 0x6E 'n' */ CH_CLS_WORD,     
/* 111 0x6F 'o' */ CH_CLS_WORD,     /* 112 0x70 'p' */ CH_CLS_WORD,     
/* 113 0x71 'q' */ CH_CLS_WORD,     /* 114 0x72 'r' */ CH_CLS_WORD,     
/* 115 0x73 's' */ CH_CLS_WORD,     /* 116 0x74 't' */ CH_CLS_WORD,     
/* 117 0x75 'u' */ CH_CLS_WORD,     /* 118 0x76 'v' */ CH_CLS_WORD,     
/* 119 0x77 'w' */ CH_CLS_WORD,     /* 120 0x78 'x' */ CH_CLS_WORD,     
/* 121 0x79 'y' */ CH_CLS_WORD,     /* 122 0x7A 'z' */ CH_CLS_WORD,     
0, 0, 0, 0, 0, 
};
#define char_cls_get(ch) ((byte)char_cls_tbl[(byte)(ch)])
// </lex_char_tbl>

// <lex_next>
tok_id lex_next(lex_state * lex)
{
	int peek_ch = 0;
	tok_id tok = TOK_ERROR;
	while (true)
	{
		switch (char_cls_get(lex_read_ch(lex)))
		{
			case CH_CLS_SPACE:
			{
				continue;
			} break;
			case CH_CLS_WORD:
			{
				tok = lex_usr_get_word(lex);
				goto done;
			} break;
			case CH_CLS_NUMBER:
			{
				tok = lex_usr_get_number(lex);
				goto done;
			} break;
			case CH_CLS_LESS_THAN:
			{
				tok = TOK_LESS;
				if ('=' == lex_peek_ch(lex))
				{
					lex_read_ch(lex);
					tok = TOK_LEQ;
				}
				goto done;
			} break;
			case CH_CLS_GRTR_THAN:
			{
				tok = TOK_GT;
				if ('=' == lex_peek_ch(lex))
				{
					lex_read_ch(lex);
					tok = TOK_GEQ;
				}
				goto done;
			} break;
			case CH_CLS_NEW_LINE:
			{
				++lex->input_line;
				lex->input_pos = 0;
				continue;
			} break;
			case CH_CLS_EOI:
			{
				tok = TOK_EOI;
				goto done;
			} break;
			case CH_CLS_SLASH:
			{
				tok = lex_usr_handle_slash(lex);
				goto done;
			} break;
			case CH_CLS_AUTO_1_: /* '=' */
			{
				tok = TOK_EQ;
				peek_ch = lex_peek_ch(lex);
				if ('!' == peek_ch)
				{
					lex_read_ch(lex);
					tok = TOK_NEQ;
				}
				else if ('=' == peek_ch)
				{
					lex_read_ch(lex);
					tok = TOK_EQEQ;
					peek_ch = lex_peek_ch(lex);
					if ('!' == peek_ch)
					{
						lex_read_ch(lex);
						tok = TOK_NEQEQEQ;
					}
					else if ('=' == peek_ch)
					{
						lex_read_ch(lex);
						tok = TOK_EQEQEQ;
					}
				}
				goto done;
			} break;
			case CH_CLS_AUTO_2_: /* '&' */
			{
				tok = TOK_AND;
				goto done;
			} break;
			default:
			{
				tok = lex_usr_on_unknown_ch(lex);
				goto done;
			} break;
		}
	}
done:
	return (lex->curr_tok = tok);
}
// </lex_next>

// <lex_keyword_or_base>
#define KW_LONGEST  5 // longest keyword length

tok_id lex_keyword_or_base(lex_state * lex, tok_id base)
{
	// sorted; don't jumble up
	static const char * kws[4] = {
	"elif",        "else",        "if",          "while",       
	};

	static const tok_id tks[4] = {
	TOK_ELIF,      TOK_ELSE,      TOK_IF,        TOK_WHILE,     
	};

	typedef struct kw_len_data {
		unsigned int valid_lengths;
		byte start;
		byte span;
	} kw_len_data;

	static const kw_len_data kwlen[CHAR_TBL_SZ] = {
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, 
	{0x00000010,  0,  2}, /* 'e' */
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0x00000004,  2,  1}, /* 'i' */
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, 
	{0x00000020,  3,  1}, /* 'w' */
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	{0, 0, 0}, {0, 0, 0}, {0, 0, 0}, {0, 0, 0}, 
	};

	tok_id tok = base;
	const char * txt = lex->write_buff;
	byte first = (byte)*txt;
	unsigned int vlens = kwlen[first].valid_lengths;
	unsigned int txt_len = lex->write_buff_pos;

	if (!(txt_len <= KW_LONGEST && (vlens & (1 << txt_len))))
		return tok;

	unsigned int start = kwlen[first].start;
	unsigned int span = kwlen[first].span;
	switch (span)
	{
		case 2:
			if (strcmp(kws[start], txt) == 0)
				return tks[start];
			++start;
		case 1:
			if (strcmp(kws[start], txt) == 0)
				return tks[start];
			return tok;
		default:
		{
			int left = (int)start;
			int right = left + (int)span;
			int mid, res;
			byte second = txt[1];
			const char * pkw = NULL;

			while (left <= right)
			{
				mid = left + ((right - left) / 2);
				pkw = kws[mid];
				if (((res = (pkw[1] - second)) == 0) &&
					(res = strcmp(pkw, txt)) == 0)
					return tks[mid];
				else if (res < 0)
					left = mid + 1;
				else
					right = mid - 1;
			}
			return tok;
		}
	}
}
// </lex_keyword_or_base>
// </lex_source>
