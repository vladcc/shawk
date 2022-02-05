#!/usr/bin/awk -f

# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2022-02-05

# Generates a lexer in C. The lexing strategy is quite simple - the next token
# is determined by switch-ing on the class of the current input character and
# then branching on the value of the next character. When a pattern is needed,
# like a number constant, or an id, this is offloaded to the user by the means
# of callback functions. There are two ways to distinguish between keywords and
# ids - an optimized bsearch(), or a literal if - else if tree. The interface
# to both is the same - after an id has been read you call the function and the
# return value is either the token for the keyword in the lexer write buffer, or
# a user provided default value.

# <script>
function SCRIPT_NAME() {return "lex-c.awk"}
function SCRIPT_VERSION() {return "1.7"}
# </script>

# <out_signature>
function out_signature() {
	out_line(sprintf("// generated by %s %s", SCRIPT_NAME(), SCRIPT_VERSION()))
}
# </out_signature>

# <constant_names>
function N_LEX_GET_CURR_CH() {return npref("lex_get_curr_ch")}
function N_LEX_GET_CURR_TOK() {return npref("lex_get_curr_tok")}
function N_LEX_GET_INPUT_LINE_NO() {return npref("lex_get_input_line_no")}
function N_LEX_GET_INPUT_POS() {return npref("lex_get_input_pos")}
function N_LEX_GET_SAVED() {return npref("lex_get_saved")}
function N_LEX_GET_SAVED_LEN() {return npref("lex_get_saved_len")}
function N_LEX_GET_USR_ARG() {return npref("lex_get_usr_arg")}
function N_LEX_INIT() {return npref("lex_init")}
function N_LEX_MATCH() {return npref("lex_match")}
function N_LEX_NEXT() {return npref("lex_next")}
function N_LEX_PEEK_CH() {return npref("lex_peek_ch")}
function N_LEX_READ_CH() {return npref("lex_read_ch")}
function N_LEX_SAVE_BEGIN() {return npref("lex_save_begin")}
function N_LEX_SAVE_CH() {return npref("lex_save_ch")}
function N_LEX_SAVE_END() {return npref("lex_save_end")}
function N_LEX_STATE() {return npref("lex_state")}
function N_LEX_TOK_TO_STR() {return npref("lex_tok_to_str")}
function N_LEX_USR_GET_INPUT() {return npref("lex_usr_get_input")}
function N_LEX_USR_ON_UNKNOWN_CH() {return npref("lex_usr_on_unknown_ch")}
function N_LEX_INIT_INFO() {return npref("lex_init_info")}
function N_TOK_ID() {return npref("tok_id")}
function N_LEX_KEYWORD_OR_BASE() {return npref("lex_keyword_or_base")}
function N_CHAR_CLS() {return npref("char_cls")}
# </constant_names>

# <out_header>
function out_header(    _hdr) {
	_hdr = toupper(npref_get() "LEX_H")
	out_line("// <lex_header>")
	out_signature()
	out_line(sprintf("#ifndef %s", _hdr))
	out_line(sprintf("#define %s", _hdr))
	out_line()
	out_line("#include <stdbool.h>")
	out_line()
	out_tok_enum()
	out_line()
	out_lex_define()
	out_line()
	out_line("#endif")
	out_line("// </lex_header>")
}
function out_lex_cls_events_memb(    _set, _i, _end, _str) {
	lb_vect_make_set(_set, G_actions_vect, 2)

	out_line("// return text input; when done return \"\", never NULL")
	out_line(sprintf("const char * %s(void * usr_arg);", N_LEX_USR_GET_INPUT()))
	out_line("// user events")
	_end = vect_len(_set)
	for(_i = 1; _i <= _end; ++_i) {
		_str = _set[_i]
		if (match(_str, FCALL())) {
			sub(FCALL(), "", _str)
			out_line(sprintf("%s %s(%s * lex);",
				N_TOK_ID(), npref("lex_usr_" _str), N_LEX_STATE()))
		}
	}
	out_line(sprintf("%s %s(%s * lex);",
		N_TOK_ID(), N_LEX_USR_ON_UNKNOWN_CH(), N_LEX_STATE()))
}
function out_lex_init_info(    _set, _i, _end, _str) {
	out_line(sprintf("typedef struct %s {", N_LEX_INIT_INFO()))
	tabs_inc()
	out_line(sprintf("void * usr_arg;   // the argument to %s()",
		N_LEX_USR_GET_INPUT()))
	out_line(sprintf("char * write_buff;   // %s() saves here",
		N_LEX_SAVE_CH()))
	out_line("uint write_buff_len; // includes the '\\0'")
	tabs_dec()
	out_line(sprintf("} %s;", N_LEX_INIT_INFO()))
	out_line()
	
}
function out_lex_define(    _set, _i, _end, _str) {
	out_line("typedef unsigned int uint;")
	out_line(sprintf("typedef struct %s {", N_LEX_STATE()))
	tabs_inc()
	out_line("const char * input;")
	out_line("uint input_pos;")
	out_line("int curr_ch;")
	out_line(sprintf("%s curr_tok;", N_TOK_ID()))
	out_line("uint input_line;")
	out_line("void * usr_arg;")
	out_line("char * write_buff;")
	out_line("uint write_buff_len;")
	out_line("uint write_buff_pos;")
	tabs_dec()
	out_line(sprintf("} %s;", N_LEX_STATE()))
	out_line()
	out_lex_init_info()
	out_line("// <lex_usr_defined>")
	out_lex_cls_events_memb()
	out_line("// </lex_usr_defined>")
	out_line()
	
	out_line("// read the next character, advance the input")
	out_line(sprintf("static inline int %s(%s * lex)",
		N_LEX_READ_CH(), N_LEX_STATE()))
	out_line("{")
	tabs_inc()
	out_line("lex->curr_ch = *lex->input++;")
	out_line("++lex->input_pos;")
	out_line("if (!(*lex->input))")
	tabs_inc()
	out_line(sprintf("lex->input = %s(lex->usr_arg);", N_LEX_USR_GET_INPUT()))
	tabs_dec()
	out_line("return lex->curr_ch;")
	tabs_dec()
	out_line("}")

	out_line()
	out_line("// look at, but do not read, the next character")
	out_line(sprintf("static inline int %s(%s * lex)",
		N_LEX_PEEK_CH(), N_LEX_STATE()))
	out_line("{return *lex->input;}")
	out_line()
	out_line("// call this before writing to the lexer write space")
	out_line(sprintf("static inline void %s(%s * lex)",
		N_LEX_SAVE_BEGIN(), N_LEX_STATE()))
	out_line("{lex->write_buff_pos = 0;}")
	out_line()

	out_line("// call this to write to the lexer write space")
	out_line(sprintf("static inline bool %s(%s * lex)",
		N_LEX_SAVE_CH(), N_LEX_STATE()))
	out_line("{")
	tabs_inc()
	out_line("bool is_saved = (lex->write_buff_pos < lex->write_buff_len);") 
	out_line("if (is_saved)")
	tabs_inc()
	out_line("lex->write_buff[lex->write_buff_pos++] = lex->curr_ch;")
	tabs_dec()
	out_line("return is_saved;")
	tabs_dec()
	out_line("}")
	
	out_line()
	out_line("// call this after you're done writing to the lexer write space")
	out_line(sprintf("static inline void %s(%s * lex)",
		N_LEX_SAVE_END(), N_LEX_STATE()))
	out_line("{lex->write_buff[lex->write_buff_pos] = '\\0';}")
	out_line()
	out_line("// get what you've written")
	out_line(sprintf("static inline char * %s(%s * lex)",
		N_LEX_GET_SAVED(), N_LEX_STATE()))
	out_line("{return lex->write_buff;}")
	out_line()
	out_line("// see how long it is")
	out_line(sprintf("static inline uint %s(%s * lex)",
		N_LEX_GET_SAVED_LEN(), N_LEX_STATE()))
	out_line("{return lex->write_buff_pos;}")
	out_line()
	out_line("// so it's possible for the user to access their argument back")
	out_line(sprintf("static inline void * %s(%s * lex)",
		N_LEX_GET_USR_ARG(), N_LEX_STATE()))
	out_line("{return lex->usr_arg;}")
	out_line()
	out_line("// get the character position on the current input line")
	out_line(sprintf("static inline uint %s(%s * lex)",
		N_LEX_GET_INPUT_POS(), N_LEX_STATE()))
	out_line("{return lex->input_pos;}")
	out_line()
	out_line("// get the number of the current input line")
	out_line(sprintf("static inline uint %s(%s * lex)",
		N_LEX_GET_INPUT_LINE_NO(), N_LEX_STATE()))
	out_line("{return lex->input_line;}")
	out_line()
	out_line("// get the last character the lexer read")
	out_line(sprintf("static inline int %s(%s * lex)",
		N_LEX_GET_CURR_CH(), N_LEX_STATE()))
	out_line("{return lex->curr_ch;}")
	out_line()
	out_line("// get the last token the lexer read")
	out_line(sprintf("static inline %s %s(%s * lex)",
		N_TOK_ID(), N_LEX_GET_CURR_TOK(), N_LEX_STATE()))
	out_line("{return lex->curr_tok;}")
	out_line()
	out_line("// see if tok is the same as the token in the lexer")
	out_line(sprintf("static inline bool %s(%s * lex, %s tok)",
		N_LEX_MATCH(), N_LEX_STATE(), N_TOK_ID()))
	out_line("{return (lex->curr_tok == tok);}")
	out_line()
	
	out_line(sprintf("static inline void %s(%s * lex, %s * init)",
		N_LEX_INIT(), N_LEX_STATE(), N_LEX_INIT_INFO()))
	out_line("{")
	tabs_inc()
	out_line(sprintf("lex->input = %s(init->usr_arg);", N_LEX_USR_GET_INPUT()))
	out_line("lex->input_pos = 0;")
	out_line("lex->curr_ch = -1;")
	out_line(sprintf("lex->curr_tok = %s;", TOK_ERR_ENUM()))
	out_line("lex->input_line = 1;")
	out_line("lex->usr_arg = init->usr_arg;")
	out_line("lex->write_buff = init->write_buff;")
	out_line("lex->write_buff_len = init->write_buff_len;")
	out_line("lex->write_buff_pos = 0;")
	tabs_dec()
	out_line("}")

	out_line()
	out_line("// returns the string representation of tok")
	out_line(sprintf("const char * %s(%s tok);",
		N_LEX_TOK_TO_STR(), N_TOK_ID()))
	out_line()
	out_line("// reads and returns the next token from the input")
	out_line(sprintf("%s %s(%s * lex);",
		N_TOK_ID(), N_LEX_NEXT(), N_LEX_STATE()))
	out_line()
	if (has_keywords()) {
		out_line("// returns the token for the keyword in lex's write buffer, "\
			"or base if not a")
		out_line(sprintf("// keyword; lookup method: %s", get_kw_type()))
		out_line(sprintf("%s;", IS_KW_HEAD()))
	}
}
function out_tok_enum(    _set, _set_const, _set_str, _i, _end, _line_len, _j) {
	lb_vect_make_set(_set, G_symbols_vect, 2)
	lb_vect_copy(_set_const, _set)
	lb_vect_make_set(_set, G_keywords_vect, 2)
	lb_vect_append(_set_const, _set)
	lb_vect_make_set(_set, G_patterns_vect, 2)
	lb_vect_append(_set_const, _set)

	lb_vect_make_set(_set, G_symbols_vect, 1)
	lb_vect_copy(_set_str, _set)
	lb_vect_make_set(_set, G_keywords_vect, 1)
	lb_vect_append(_set_str, _set)
	lb_vect_make_set(_set, G_patterns_vect, 1)
	lb_vect_append(_set_str, _set)
	
	out_line(sprintf("typedef enum %s {", N_TOK_ID()))

	# Print _line_len enum values per line.
	_line_len = 4
	_i = 1
	_end = vect_len(_set_const)
	
	while (_i <= _end) {

		# Print the token value enum constant name.
		for (_j = 0; _j < _line_len && _i+_j <= _end; ++_j) 
			printf("%-20s", sprintf("%s,", _set_const[_i+_j]))
		out_line()

		# Print the token string as a comment below.
		for (_j = 0; _j < _line_len && _i+_j <= _end; ++_j)
			printf("%-20s", sprintf("/* \"%s\" */", _set_str[_i+_j]))
		out_line()

		_i += _j
		
	}
	
	out_line(sprintf("%s," , TOK_ERR_ENUM()))
	out_line(sprintf("/* \"%s\" */", TOK_ERR_STR()))

	out_line(sprintf("} %s;", N_TOK_ID()))
}
# </out_header>

# <out_source>
function out_source() {
	out_line("// <lex_source>")
	out_signature()
	out_line(sprintf("#include \"%s\"", npref("lex.h")))

	if (get_kw_type() != KW_IFS()) {
		out_line("#include <string.h>")
		out_line("#include <stdlib.h>")
	}
	
	out_line()
	out_tok_tbl()
	out_line()
	out_tok_to_str()
	out_line()
	out_all_char_tbl()
	out_line()
	out_keywords()
	out_line("// </lex_source>")
}
# <tok_tbl>
function TOK_ERR_STR() {return "I am Error"}
function TOK_ERR_ENUM() {return (toupper(npref_get()) "TOK_ERROR")}
function out_tok_tbl(    _set, _set_str, _set_const, _i, _end, _line_len, _j) {
	lb_vect_make_set(_set, G_symbols_vect, 1)
	lb_vect_copy(_set_str, _set)
	lb_vect_make_set(_set, G_keywords_vect, 1)
	lb_vect_append(_set_str, _set)
	lb_vect_make_set(_set, G_patterns_vect, 1)
	lb_vect_append(_set_str, _set)

	lb_vect_make_set(_set, G_symbols_vect, 2)
	lb_vect_copy(_set_const, _set)
	lb_vect_make_set(_set, G_keywords_vect, 2)
	lb_vect_append(_set_const, _set)
	lb_vect_make_set(_set, G_patterns_vect, 2)
	lb_vect_append(_set_const, _set)

	
	# Print all tokens in a static string table.
	out_line("static const char * tokens[] = {")

	# Print _line_len tokens per line.
	_line_len = 4
	_i = 1
	_end = vect_len(_set_str)
	while (_i <= _end) {

		# Print the token string representation.
		for (_j = 0; _j < _line_len && _i+_j <= _end; ++_j) 
			printf("%-20s", sprintf("\"%s\",", _set_str[_i+_j]))
		out_line()

		# Print the name of its enum constant as a comment below.
		for (_j = 0; _j < _line_len && _i+_j <= _end; ++_j)
			printf("%-20s", sprintf("/* %s */", _set_const[_i+_j]))		
		out_line()
		
		_i += _j
	}
	
	out_line(sprintf("\"%s\"," , TOK_ERR_STR()))
	out_line(sprintf("/* %s */", TOK_ERR_ENUM()))
	
	out_line("};")

}
# </tok_tbl>
# <lex_tok_to_str>
function out_tok_to_str() {
	out_line(sprintf("const char * %s(%s tok)",
		N_LEX_TOK_TO_STR(), N_TOK_ID()))
	out_line("{")
	tabs_inc()
	out_line("return tokens[tok];")
	tabs_dec()
	out_line("}")
}
# </lex_tok_to_str>
# <char_tbls>
function out_all_char_tbl() {
	out_ch_cls_enum()
	out_line()
	out_char_tbl()
	out_line()
	out_lex_next()
}
function out_ch_cls_enum(    _i, _end, _cls_set, _line_len) {
	lb_vect_make_set(_cls_set, G_char_tbl_vect, 2)

	out_line(sprintf("enum %s {", N_CHAR_CLS()))
	
	_line_len = 4
	_i = 1
	_end = vect_len(_cls_set)
	
	while (_i <= _end) {
	
		for (_j = 0; _j < _line_len && _i+_j <= _end; ++_j) {
			if ((_i+_j) == 1)
				printf("%-20s", sprintf("%s = 1,", _cls_set[_i+_j]))
			else
				printf("%-20s", sprintf("%s,", _cls_set[_i+_j]))
		}
		out_line()
		
		_i += _j
	}
	
	out_line("};")
}
function out_char_tbl(    _i, _end, _ch, _str, _map_ch_cls,
_zero_line_len, _zero_new_line, _j, _ch_out) {
	out_line("#define CHAR_TBL_SZ (0xFF+1)")
	out_line("typedef unsigned char byte;")

	# Print a static constant table for the character classes.
	# Prints at most 16 zeroes, or two char classes along with their values as
	# comments per line.
	out_line("static const byte char_cls_tbl[CHAR_TBL_SZ] = {")

	lb_vect_to_map(_map_ch_cls, G_char_tbl_vect)

	_zero_new_line = 0
	_zero_line_len = 16

	_i = 0
	_end = CHR_TBL_END()
	while (_i < _end) {
		_j = 0
		do {
			_ch = num_to_ch(_i)

			if (" " == _ch)
				_ch = CH_ESC_SPACE()

			_zero_new_line = 0
			if (!(_ch in _map_ch_cls)) {

				if (_ch_out) {
					out_line()
					_ch_out = 0
				}
				
				if (!(_j % _zero_line_len))
					out_tabs()

				printf("0, ")

				if ((_j % _zero_line_len) == (_zero_line_len - 1)) {
					out_line()
					_zero_new_line = 1
				}
				
				++_j
				++_i
			}
		} while (!(_ch in _map_ch_cls) && _i < _end)

		if (_j && !_zero_new_line)
			out_line()
		
		if (!(_i < _end))
			break

		if ("\\" == _ch)
			_str = "\\\\"
		else if (CH_ESC_SPACE() == _ch)
			_str = " "
		else
			_str = _ch
	
		printf("%-35s ",
			sprintf("/* %03d 0x%02X '%s' */ %s,",
				_i, _i, _str, _map_ch_cls[_ch]))
		
		++_ch_out
		if (2 == _ch_out) {
			out_line()
			_ch_out = 0
		}
		
		++_i
	}
		
	out_line("};")
	
	out_line("#define char_cls_get(ch) ((byte)char_cls_tbl[(byte)(ch)])")
}

function out_kw_const() {
	out_line(sprintf("#define KW_LONGEST  %d // longest keyword length",
		kw_longest()))
}
# </char_tbls>
function CHR_TBL_END() {return 128}
# <lex_next>
function out_tree_symb(tree, root, map_tok,    _next_str, _next_ch, _i, _end) {
	# E.g. "=", "==", "=!" becomes
	# if ('=' == next_ch()) {
	#     tok = "="
	#     read_ch()
	#     if ('=' == next_ch()) {
	#         tok = "=="
	#         read_ch()
	#      } else if ('!' == next_ch()) {
	#         tok = "=!"
	#         read_ch()
	#      }
	# }
	
	if (ch_ptree_has(tree, root) || ch_ptree_is_word(tree, root)) {

		if (ch_ptree_is_word(tree, root))
			out_line(sprintf("tok = %s;", map_tok[root]))
			
		_next_str = ch_ptree_get(tree, root)
		_end = length(_next_str)
		for (_i = 1; _i <= _end; ++_i) {
			_next_ch = str_ch_at(_next_str, _i)

			if (_end > 1) {
				# If more than one call to lex_peek_ch() is needed, cache the
				# result into peek_ch.
				
				if (1 == _i)
					out_line(sprintf("peek_ch = %s(lex);", N_LEX_PEEK_CH()))
			
				out_line(sprintf("%s ('%s' == peek_ch)",
					(_i == 1) ? "if" : "else if" ,_next_ch))
			} else {
				# Do not cache for only a single call.
				
				out_line(sprintf("%s ('%s' == %s(lex))",
					(_i == 1) ? "if" : "else if" ,_next_ch, N_LEX_PEEK_CH()))
			}
			
			out_line("{")
			tabs_inc()
			out_line(sprintf("%s(lex);", N_LEX_READ_CH()))
			out_tree_symb(tree, (root _next_ch), map_tok)

			tabs_dec()
			out_line("}")
		}
	}
}
function out_lex_next(    _i, _end, _cls_set, _cls, _act, _map_cls_chr,
_map_symb, _map_act, _tree, _tmp, _dont_go) {

	# Generates lex_next(), which is a big switch statement which switches on
	# the class of the current character. The class values are contiguous, so
	# it's easy for a compiler to turn the switch into a jump table. The class
	# of the character is derived by a quick table lookup, e.g. ch_cls[curr_ch]
	# In each case, either a token is found, a user callback is called, or some
	# custom to the lexer action is performed. E.g.:
	# ...
	# case CH_GT: /* '>' */
	#     tok = TOK_GT;
	#     if (next_ch() == '=')
	#         tok = TOK_GEQ;
	# ...
	# case CH_WORD: // a-z A-Z _
	#     tok = usr_defined_get_kword()
	# ...
	# case CH_NEW_LINE:
	#     ++lex->line_no;
	# ...
	
	lb_vect_make_set(_cls_set, G_char_tbl_vect, 2)
	
	out_line(sprintf("%s %s(%s * lex)",
		N_TOK_ID(), N_LEX_NEXT(), N_LEX_STATE()))
	out_line("{")
	tabs_inc()

	out_line("int peek_ch = 0;")
	out_line(sprintf("%s tok = %s;", N_TOK_ID(), TOK_ERR_ENUM()))
	out_line("while (true)")
	out_line("{")
	tabs_inc()
	
	out_line(sprintf("switch (char_cls_get(%s(lex)))", N_LEX_READ_CH()))
	out_line("{")
	tabs_inc()

	lb_vect_to_map(_map_cls_chr, G_char_tbl_vect, 2, 1)
	lb_vect_to_map(_map_symb, G_symbols_vect)
	lb_vect_to_map(_map_act, G_actions_vect)
	ch_ptree_init(_tree)

	for (_tmp in _map_symb) {
		# Constants are not symbol tokens. I.e. EOI (end of input) can exist in
		# the symbol table, but the character sequence E O I is not a token in
		# the sense in which "==" is for example, so don't put it in the tree
		# with the other tokens.
		
		if (!is_constant(_tmp))
			ch_ptree_insert(_tree, _tmp)
	}

	_end = vect_len(_cls_set)
	for (_i = 1; _i <= _end; ++_i) {
		_cls = _cls_set[_i]
		_dont_go = 0 # <-- stays 0 if a complete token was read

		if (match(_cls, CH_CLS_AUTO_RE()))
			out_line(sprintf("case %s: /* '%s' */", _cls, _map_cls_chr[_cls]))
		else
			out_line(sprintf("case %s:", _cls))
		
		out_line("{")
		tabs_inc()
		
		if (_cls in _map_act) {
			_act = _map_act[_cls]
			if (match(_act, FCALL())) {
				# If the action ends in (), then it's a user defined callback,
				# which has to take lex as an argument.
				
				sub(FCALL(), "(lex)", _act)
				out_line(sprintf("tok = %s;", npref("lex_usr_" _act)))
			} else if (NEXT_CH() == _act) {
				# Immediately jump back to the top of the loop on white space.
				
				_dont_go = 1
				out_line("continue;")
			} else if (NEXT_LINE() == _act) {
				# Count lines.
				
				out_line("++lex->input_line;")
				out_line("lex->input_pos = 0;")
				out_line("continue;")
				_dont_go = 1
			} else if (is_constant(_act)) {
				# Constants are assumed to be meaningful token enums.
				
				out_line(sprintf("tok = %s;", _act))
			} else {
				# Should never happen.
				
				out_line("#error \"unknown action\"")
			}
		} else {
			# Generate if trees for all tokens which begin with the current
			# character class and are longer than a single character. The
			# character class is assumed to represent only a single character.
			
			_tmp = _map_cls_chr[_cls]
			if (length(_tmp) == 1)
				out_tree_symb(_tree, _tmp, _map_symb)
		}

		if (!_dont_go)
			out_line("goto done;")
			
		tabs_dec()
		out_line("} break;")
	}
	out_line("default:")
	out_line("{")
	tabs_inc()
	
	# Called on weird input, e.g. an '@' character in a C file.
	out_line(sprintf("tok = %s(lex);", N_LEX_USR_ON_UNKNOWN_CH()))
	out_line("goto done;")
	tabs_dec()
	out_line("} break;")
		
	tabs_dec()
	out_line("}")
	tabs_dec()
	out_line("}")

	print "done:"
	out_line("return (lex->curr_tok = tok);")
	tabs_dec()
	out_line("}")
}
# </lex_next>
# <keywords>
function kw_longest(    _set, _i, _end, _max, _n) {
	lb_vect_make_set(_set, G_keywords_vect)

	_max = length(_set[1])
	_end = vect_len(_set)
	for (_i = 2; _i <= _end; ++_i) {
		_n = length(_set[_i])
		if (_n > _max)
			_max = _n
	}
	
	return _max
}

function has_keywords() {return vect_len(G_keywords_vect)}
function set_kw_type(str) {_B_kw_type = str}
function get_kw_type() {return _B_kw_type}

function kw_len_bitmap_make(arr, len,    _i, _ch) {

	for (_i = 1; _i <= len; ++_i) {
		
		_ch = str_ch_at(arr[_i], 1)
		_B_kw_len_by_start[_ch] = \
			bw_or(_B_kw_len_by_start[_ch], bw_lshift(1, length(arr[_i])))
	}
}
function kw_len_bitmap_get(ch) {
	if (ch in _B_kw_len_by_start)
		return bw_hex_str(_B_kw_len_by_start[ch], "", 4)
	return ""
}

function out_keywords() {
	if (has_keywords()) {
		out_line("// <lex_keyword_or_base>")

		out_kw_const()
		
		out_line()
		
		if (get_kw_type() == KW_BSEARCH())
			out_kw_bsrch()
		else if (get_kw_type() == KW_IFS())
			out_kw_ifs()

		out_line("// </lex_keyword_or_base>")
	}
}
function IS_KW_HEAD() {
	return sprintf("%s %s(%s * lex, %s base)",
		N_TOK_ID(), N_LEX_KEYWORD_OR_BASE(), N_LEX_STATE(), N_TOK_ID())
}
function out_is_kw_head() {out_line(IS_KW_HEAD())}
function KW_LEN_LIMIT() {return 31}
function KW_LEN_CHECK() {
	return "txt_len <= KW_LONGEST && (vlens & (1 << txt_len))"
}

# <lex_kw_lookup_bsearch>
function out_kw_static_tbls_bsrc(    _set, _sorted, _i, _end, _pad, _map_kw,
_tbl, _start, _len, _ch, _nout) {

	lb_vect_make_set(_set, G_keywords_vect, 1)
	lb_vect_to_map(_map_kw, G_keywords_vect)
	_end = lb_vect_to_array(_sorted, _set)
	
	qsort(_sorted, _end)
	kw_len_bitmap_make(_sorted, _end)
	
	# Output keywords table
	out_line("// sorted; don't jumble up")
	out_line(sprintf("static const char * kws[%d] = {", _end))
	out_tabs()
	_pad = 4
	for (_i = 1; _i <= _end; ++_i) {
		printf("%-15s", sprintf("\"%s\", ", _sorted[_i]))
		if (!(_i % _pad) && _i != _end) {
			out_line()
			out_tabs()
		}
	}
	out_line()
	out_line("};")

	out_line()
	# Output tokens table
	out_line(sprintf("static const %s tks[%d] = {", N_TOK_ID(), _end))
	out_tabs()
	for (_i = 1; _i <= _end; ++_i) {
		printf("%-15s", sprintf("%s, ", _map_kw[_sorted[_i]]))
		if (!(_i % _pad) && _i != _end) {
			out_line()
			out_tabs()
		}
	}
	out_line()
	out_line("};")

	out_line()
	out_line("typedef struct kw_len_data {")
	tabs_inc()
	out_line("unsigned int valid_lengths;")
	out_line("byte start;")
	out_line("byte span;")
	tabs_dec()
	out_line("} kw_len_data;")

	# Find out keyword len info by first character
	# _end is still the length of _sorted
	for (_i = 1; _i <= _end; ++_i)
		++_tbl[str_ch_at(_sorted[_i], 1)]

	out_line()
	# Output the len data per first character
	out_line(sprintf("static const kw_len_data kwlen[CHAR_TBL_SZ] = {", _end))
	out_tabs()

	# Start index of words starting with a particular character in kws
	_start = 0
	# The number of words which start with a particular character
	_len = 0
	# Count of how many empty structs have been output so some formatting exists
	_nout = 0
	_pad = 4
	
	_end = CHR_TBL_END()
	for (_i = 0; _i < _end; ++_i) {
		_ch = num_to_ch(_i) 
		if ((_ch in _tbl)) {
			# Print the struct for a particular character and reset the counter
			# for empty structs
			_len = _tbl[_ch]

			# Ugly 'make sure you don't output two new lines after each other'
			if (_nout % _pad) {
				out_line()
				out_tabs()
			}

			printf("{0x%s, %2d, %2d}, /* '%s' */",
				kw_len_bitmap_get(_ch), _start, _len, _ch)
			out_line()
			out_tabs()
			_start += _len
			_nout = 0
		} else {
			# Print at most _pad empty structs on a line
			printf("{0, 0, 0}, ")
			++_nout
			if ((_i+1 < _end) && !(_nout % _pad)) {
				out_line()
				out_tabs()
			}
		}
	}
	out_line()
	out_line("};")
}
function out_kw_bsrch() {
	out_is_kw_head()
	out_line("{")
	tabs_inc()

	out_kw_static_tbls_bsrc()
	out_line()
	
	out_line(sprintf("%s tok = base;", N_TOK_ID()))
	out_line("const char * txt = lex->write_buff;")
	out_line("byte first = (byte)*txt;")
	out_line("uint vlens = kwlen[first].valid_lengths;")
	out_line("uint txt_len = lex->write_buff_pos;")
	
	# Call bsearch() only if a keyword with length(input) exists and limit the
	# search to the range of keywords with exactly that length.
	out_line()
	out_line(sprintf("if (!(%s))", KW_LEN_CHECK()))
	tabs_inc()
	out_line("return tok;")
	tabs_dec()

	out_line()
	out_line("uint start = kwlen[first].start;")
	out_line("uint span = kwlen[first].span;")
	
	out_line("switch (span)")
	out_line("{")
	tabs_inc()
	out_line("case 2:")
	tabs_inc()
	out_line("if (strcmp(kws[start], txt) == 0)")
	tabs_inc()
	out_line("return tks[start];")
	tabs_dec()
	out_line("++start;")
	tabs_dec()
	out_line("case 1:")
	tabs_inc()
	out_line("if (strcmp(kws[start], txt) == 0)")
	tabs_inc()
	out_line("return tks[start];")
	tabs_dec()
	out_line("return tok;")
	tabs_dec()
	out_line("default:")
	out_line("{")
	tabs_inc()
	out_line("int left = (int)start;")
	out_line("int right = left + (int)span;")
	out_line("int mid, res;")
	out_line("byte second = txt[1];")
	out_line("const char * pkw = NULL;")
	out_line()
	out_line("while (left <= right)")
	out_line("{")
	tabs_inc()
	out_line("mid = left + ((right - left) / 2);")
	out_line("pkw = kws[mid];")
	out_line("if (((res = (pkw[1] - second)) == 0) &&")
	tabs_inc()
	out_line("(res = strcmp(pkw, txt)) == 0)")
	tabs_inc()
	tabs_dec()
	out_line("return tks[mid];")
	tabs_dec()
	out_line("else if (res < 0)")
	tabs_inc()
	out_line("left = mid + 1;")
	tabs_dec()
	out_line("else")
	tabs_inc()
	out_line("right = mid - 1;")
	tabs_dec()
	tabs_dec()
	out_line("}")
	out_line("return tok;")
	tabs_dec()
	out_line("}")
	tabs_dec()
	out_line("}")
	tabs_dec()
	out_line("}")
}
# </lex_kw_lookup_bsearch>

# # <lex_kw_lookup_ifs>
function out_kw_walk(tree, root, map_kw, n,    _next, _ch, _i, _end, _rlen) {

	if (ch_ptree_has(tree, root) || ch_ptree_is_word(tree, root)) {
		
		if ((_rlen = length(root)) > 1) {
			
			_ch = str_ch_at(root, _rlen)
			out_line(sprintf("%s ('%s' == *ch)", (1 == n) ? "if" : "else if",
				_ch))
			out_line("{")
			tabs_inc()
			out_line("++ch;")

			if (ch_ptree_is_word(tree, root))
				out_line(sprintf("tok = %s;", map_kw[root]))
		}
		
		_next = ch_ptree_get(tree, root)
		_end = length(_next)
		for (_i = 1; _i <= _end; ++_i)
			out_kw_walk(tree, (root str_ch_at(_next, _i)), map_kw, _i)
		
		if (_rlen > 1) {
			
			tabs_dec()
			out_line("}")
		}
	}
}

function out_kw_static_tbls_ifs(set_ch,    _set, _sorted, _i, _end, _pad,
_map_kw, _ch, _hex, _nout) {

	lb_vect_make_set(_set, G_keywords_vect, 1)
	lb_vect_to_map(_map_kw, G_keywords_vect)
	_end = lb_vect_to_array(_sorted, _set)
	
	qsort(_sorted, _end)
	kw_len_bitmap_make(_sorted, _end)

	out_line("typedef struct kw_info {")
	tabs_inc()
	out_line("unsigned int valid_lengths;")
	out_line("unsigned int target;")
	tabs_dec()
	out_line("} kw_info;")
	out_line()
	
	out_line("enum {")
	tabs_inc()
	
	_end = eos_size(set_ch)
	out_line(sprintf("CH_%c = 1,", set_ch[1]))
	
	for (_i = 2; _i <= _end; ++_i)
		out_line(sprintf("CH_%c,", set_ch[_i]))
	
	tabs_dec()
	out_line("};")
	out_line()
	
	# Output the len data per first character
	out_line(sprintf("static const kw_info kwinf[CHAR_TBL_SZ] = {", _end))
	out_tabs()

	# Count of how many empty structs have been output so some formatting exists
	_nout = 0
	_pad = 8
	
	_end = CHR_TBL_END()
	for (_i = 0; _i < _end; ++_i) {
		_ch = num_to_ch(_i) 
		if (_hex = kw_len_bitmap_get(_ch)) {
		
			# Ugly 'make sure you don't output two new lines after each other'
			if (_nout % _pad) {
				out_line()
				out_tabs()
			}

			printf("{0x%s, CH_%c}, /* '%s' */", _hex, _ch, _ch)
			out_line()
			out_tabs()
			_nout = 0
		} else {
			# Print at most _pad empty structs on a line
			printf("{0, 0}, ")
			++_nout
			if ((_i+1 < _end) && !(_nout % _pad)) {
				out_line()
				out_tabs()
			}
		}
	}
	out_line()
	out_line("};")
}

function out_kw_ifs(    _tree, _set_kw, _map_kw, _i, _end, _vect, _set_ch,
_ch) {

	# Find out if, and which, keyword the input is by literal if statements for
	# each character.

	lb_vect_make_set(_set_kw, G_keywords_vect, 1)
	lb_vect_to_map(_map_kw, G_keywords_vect)
	ch_ptree_init(_tree)
	
	_end = vect_len(_set_kw)
	for (_i = 1; _i <= _end; ++_i) {
		ch_ptree_insert(_tree, _set_kw[_i])
		vect_push(_vect, str_ch_at(_set_kw[_i], 1))
	}
	lb_vect_make_set(_set_ch, _vect)
	
	out_is_kw_head()
	out_line("{")
	tabs_inc()
	
	out_kw_static_tbls_ifs(_set_ch)
	out_line()
	
	out_line("const char * txt = lex->write_buff;")
	out_line("uint txt_len = lex->write_buff_pos;")
	out_line("const kw_info * pkwi = kwinf+((byte)*txt);")
	out_line("uint vlens = pkwi->valid_lengths;")
	out_line("uint target = pkwi->target;")
	out_line()
	
	out_line(sprintf("if (vlens && (%s))", KW_LEN_CHECK()))
	out_line("{")
	tabs_inc()
	
	out_line("const char * ch = txt+1;")
	out_line(sprintf("%s tok = base;", N_TOK_ID()))
	out_line()
	
	out_line("switch (target)")
	out_line("{")
	tabs_inc()
	
	_end = eos_size(_set_ch)
	# Generate one big if - else if tree for all keywords.
	for (_i = 1; _i <= _end; ++_i) {
		_ch = _set_ch[_i]
		
		out_line(sprintf("case CH_%c:", _ch))
		out_line("{")
		tabs_inc()
		
		out_kw_walk(_tree, _ch, _map_kw, _i)
		
		tabs_dec()
		out_line("} break;")
	}
	
	out_line("default:")
	out_line("{")
	tabs_inc()
	out_line("return base;")
	tabs_dec()
	out_line("} break;")
	
	out_line()
	
	tabs_dec()
	out_line("}")
	out_line("return *ch ? base : tok;")
	tabs_dec()
	out_line("}")
	out_line("return base;")
	tabs_dec()
	out_line("}")
}
# </lex_kw_lookup_ifs>
# </keywords>
# </out_source>

# <misc>
function generate() {
	out_header()
	out_source()
}
function KW_BSEARCH() {return "bsearch"}
function KW_IFS() {return "ifs"}
function check_kw_lookup_type(str) {
	if (str != KW_BSEARCH() && str != KW_IFS()) {
		err_quit(sprintf("Keywords has to be one of: %s, %s",
			KW_BSEARCH(), KW_IFS()))
	}
}
function kw_len_check(    _kw_set) {
	lb_vect_make_set(_kw_set, G_keywords_vect, 1)

	_end = vect_len(_kw_set)
	for (_i = 1; _i <= _end; ++_i) {
		if (length(_kw_set[_i]) > KW_LEN_LIMIT()) {
			# We have a limit because an int bitmap is used to check if a
			# keyword of a certain length exists.
	
			err_quit(sprintf("keyword '%s': length cannot be greater than %d",
				_kw_set[_i], KW_LEN_LIMIT()))
		}
	}
}
function npref(str) {return (npref_get() str)}
function npref_set(str) {_B_npref = str}
function npref_get() {return _B_npref}
function npref_constants_all() {
	npref_constants(G_char_tbl_vect, 2, npref_get())
	npref_constants(G_symbols_vect, 2, npref_get())
	npref_constants(G_keywords_vect, 2, npref_get())
	npref_constants(G_patterns_vect, 2, npref_get())
	npref_constants(G_actions_vect, 1, npref_get())
	npref_constants(G_actions_vect, 2, npref_get())
}

function err_quit(msg) {
	error_quit(msg, SCRIPT_NAME())
}

function on_help() {
print sprintf("%s -- lex-build C back end", SCRIPT_NAME())
print ""
print "Static inline functions are preferred over macros, hence compiling with"
print "optimizations would make a significant difference. The user implements"
print "lex_usr_*()"
print ""
print "Options:"
print sprintf("-vKeywords=%s/%s - specifies the keyword lookup method.",
	KW_BSEARCH(), KW_IFS())
print sprintf("%s - optimized binary search; generally <= work compared to " \
"hashing.", KW_BSEARCH())
print sprintf("%s     - a literal character by character if - else if tree. " \
"Generally linear.", KW_IFS())
print sprintf("Faster than %s, doesn't use stdlib.h and string.h, but more " \
"code. %s", KW_BSEARCH(), KW_BSEARCH())
print "is the default."
print "-vNamePrefix=<string> - prefixes all function and constant names with "\
"<string>."
print "E.g. -vNamePrefix='foo_' will result in foo_lex_usr_get_input()"
print ""
}

function on_version() {
print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
}

function on_begin() {
	lex_lib_is_included()
	
	vect_init(G_char_tbl_vect)
	vect_init(G_symbols_vect)
	vect_init(G_keywords_vect)
	vect_init(G_patterns_vect)
	vect_init(G_actions_vect)
	
	if (!Keywords)
		Keywords = KW_BSEARCH()
	check_kw_lookup_type(Keywords)
	set_kw_type(Keywords)
	
	npref_set(NamePrefix)
}
function on_char_tbl() {save_to(G_char_tbl_vect)}
function on_symbols()  {save_to(G_symbols_vect)}
function on_keywords() {save_to(G_keywords_vect)}
function on_patterns() {save_to(G_patterns_vect)}
function on_actions()  {save_to(G_actions_vect)}
function on_end()      {kw_len_check(); npref_constants_all(); generate()}

# Produce an error if lex_lib.awk is not included
BEGIN {lex_lib_is_included()}
# </misc>
