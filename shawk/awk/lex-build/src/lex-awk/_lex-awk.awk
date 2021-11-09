#!/usr/bin/awk -f

# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2021-10-18

# Generates a lexer in awk. It determines the next token by branching on the
# character class of the current input character, and then branches on the next
# character value. Patterns, like constants and ids, are handled by user
# callbacks. An interface to distinguish between ids and keywords is provided.

# <script>
function SCRIPT_NAME() {return "lex-awk.awk"}
function SCRIPT_VERSION() {return "1.41"}
# </script>

# <out_signature>
function out_signature() {
	out_line(sprintf("# generated by %s %s", SCRIPT_NAME(), SCRIPT_VERSION()))
}
# </out_signature>

# <out_ch_tbl>
function TOK_ERR() {return "I am Error"}

function ch_esc_esc(ch) {
	if (CH_ESC_SPACE() == ch) ch = " "
	else if ("\\0" == ch)     ch = ""
	else if ("\\" == ch)      ch = "\\\\"
	else if ("\"" == ch)      ch = "\\\""
	return ch
}

function out_const(    _set, _set_const, _set_str, _i, _end, _ch_cls) {
	# Outputs awk 'constants'. E.g. In C you'd have
	# ...
	# enum { TOK_FOO = 0};
	# static const char * toks[] = {"foo"};
	# const char * tok_to_str(int tok) {return toks[tok];}
	# ...
	# In awk this would be
	# ...
	# function TOK_FOO() {return "foo"}
	# ...
	# So, functions instead of enums and tables. Since strings are scalar types
	# in awk, the return value of the function is the actual string
	# representation of the token. Character classes are handled similarly. E.g.
	# ...
	# enum {CH_CLS_FOO = 1, CH_CLS_BAR};
	# ...
	# becomes
	# ...
	# function CH_CLS_FOO() {return 1}
	# function CH_CLS_BAR() {return 2}
	# ...
 
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

	out_line()
	out_line("# the only way to have immutable values; use as constants")

	# Tokens.
	_end = vect_len(_set_const)
	for (_i = 1; _i <= _end; ++_i) {
		out_line(sprintf("function %s() {return \"%s\"}",
			_set_const[_i], ch_esc_esc(_set_str[_i])))
	}
	out_line(sprintf("function %s() {return \"%s\"}",
		toupper(cname("TOK_ERROR")), TOK_ERR()))
	out_line()
	
	lb_vect_make_set(_set, G_char_tbl_vect, 2)

	# Char classes.
	_end = vect_len(_set)
	for (_i = 1; _i <= _end; ++_i) {
		_ch_cls = _set[_i]
		out_line(sprintf("function %s() {return %d}", _ch_cls, _i))
		ch_cls_to_const_map_add(_ch_cls, _i)
	}
}

function out_init_ch_tbl(    _i, _end, _ch, _cls, _split) {
	# Generates the mapping between characters and their classes. E.g.
	# n["a"] = CH_CLS_WORD()
	# n["b"] = CH_CLS_WORD()
	# ...
	# n["0"] = CH_CLS_NUM()
	# n["1"] = CH_CLS_NUM()
	# ...

	out_line(sprintf("%s() {", _fdecl("init_ch_tbl")))
	tabs_inc()

	_end = vect_len(G_char_tbl_vect)
	for (_i = 1; _i <= _end; ++_i) {
		unjoin(_split, G_char_tbl_vect[_i])
		_ch = _split[1]
		_cls = _split[2]
		
		_ch = ch_esc_esc(_ch)
		out_line(sprintf("%s[\"%s\"] = %s()", vname("ch_tbl"), _ch, _cls))
	}
	
	tabs_dec()
	out_line("}")
}
# </out_ch_tbl>

# <out_kwds>
function out_kwds(    _set, _i, _end) {
	# Generates the keyword map. E.g.
	# ...
	# n["if"] = 1
	# n["else"] = 1
	# ...
	
	out_line(sprintf("%s() {", _fdecl("init_keywords")))
	tabs_inc()

	lb_vect_make_set(_set, G_keywords_vect, 1)
	
	_end = vect_len(_set)
	for (_i = 1; _i <= _end; ++_i)
		out_line(sprintf("%s[\"%s\"] = 1", vname("keywords_tbl"), _set[_i]))
	
	tabs_dec()
	out_line("}")
}
# </out_kwds>

# <out_input>
function F_PEEK_CH() {return fname("peek_ch")}
function F_READ_CH() {return fname("read_ch")}
function F_USR_ON_UNKNOWN_CH() {return fname("usr_on_unknown_ch")}
function F_USR_GET_LINE() {return fname("usr_get_line")}

function fname(str) {return (npref_get() "lex_" str)}
function fdecl(name) {return sprintf("function %s", fname(name))}
function _fname(str) {return ("_" fname(str))}
function _fdecl(name) {return sprintf("function %s", _fname(name))}

function VAR_ARE_TABLES_INIT() {return vname("are_tables_init")}
function VAR_CH_TBL() {return vname("ch_tbl")}
function VAR_CURR_CH() {return vname("curr_ch")}
function VAR_CURR_CH_CLS_CACHE() {return vname("curr_ch_cls_cache")}
function VAR_CURR_TOK() {return vname("curr_tok")}
function VAR_LINE_NO() {return vname("line_no")}
function VAR_LINE_POS() {return vname("line_pos")}
function VAR_PEEK_CH() {return vname("peek_ch")}
function VAR_PEEKED_CH_CACHE() {return vname("peeked_ch_cache")}
function VAR_SAVED() {return vname("saved")}
function VAR_INPUT_LINE() {return vname("input_line")}
function VAR_KEYWORDS_TBL() {return vname("keywords_tbl")}

function vname(str,    _res) {
	_res = npref_get()
	return _res ? sprintf("_B_%slex_%s", _res, str) : sprintf("_B_lex_%s", str)
}
function cname(str) {return (npref_get() str)}

function LEX_NEXT_LINE() {
	return sprintf("split(%s(), %s, \"\")",
		F_USR_GET_LINE(), VAR_INPUT_LINE())
}
function out_lex_io() {
	# Generates the lexer public interface.

	out_line("# read the next character; advance the input")
	out_line(sprintf("%s() {", fdecl("read_ch")))
	tabs_inc()
	out_line(sprintf("# Note: the user defines %s()", F_USR_GET_LINE()))
	out_line()
	out_line(sprintf("%s = %s[%s++]",
		VAR_CURR_CH(), VAR_INPUT_LINE(), VAR_LINE_POS()))
	out_line(sprintf("%s = %s[%s]",
		VAR_PEEK_CH(), VAR_INPUT_LINE(), VAR_LINE_POS()))
	out_line(sprintf("if (%s != \"\")", VAR_PEEK_CH()))
	tabs_inc()
	out_line(sprintf("return %s", VAR_CURR_CH()))
	tabs_dec()
	out_line("else")
	tabs_inc()
	out_line(LEX_NEXT_LINE())
	tabs_dec()
	out_line(sprintf("return %s", VAR_CURR_CH()))
	tabs_dec()
	out_line("}")
	out_line()
	out_line("# return the last read character")
	out_line(sprintf("%s()\n{return %s}", fdecl("curr_ch"), VAR_CURR_CH()))
	out_line()
	out_line("# return the next character, but do not advance the input")
	out_line(sprintf("%s()\n{return %s}", fdecl("peek_ch"), VAR_PEEK_CH()))
	out_line()
	out_line("# return the position in the current line of input")
	out_line(sprintf("%s()\n{return (%s-1)}", fdecl("get_pos"), VAR_LINE_POS()))
	out_line()
	out_line("# return the current line number")
	out_line(sprintf("%s()\n{return %s}",
		fdecl("get_line_no"), vname("line_no")))
	out_line()
	out_line("# return the last read token")
	out_line(sprintf("%s()\n{return %s}", fdecl("curr_tok"), VAR_CURR_TOK()))
	out_line()
	out_line("# see if your token is the same as the one in the lexer")
	out_line(sprintf("%s(str)\n{return (str == %s)}",
		fdecl("match_tok"), VAR_CURR_TOK()))
	out_line()
	out_line("# clear the lexer write space")
	out_line(sprintf("%s()\n{%s = \"\"}", fdecl("save_init"), VAR_SAVED()))
	out_line()
	out_line("# save the last read character")
	out_line(sprintf("%s()\n{%s = (%s %s)}",
		fdecl("save_curr_ch"), VAR_SAVED(), VAR_SAVED(), VAR_CURR_CH()))
	out_line()
	out_line("# return the saved string")
	out_line(sprintf("%s()\n{return %s}", fdecl("get_saved"), VAR_SAVED()))
	out_line()
	out_line("# character classes")
	out_line(sprintf("%s(ch, cls)\n{return (cls == %s[ch])}",
		fdecl("is_ch_cls"), VAR_CH_TBL()))
	out_line()
	out_line(sprintf("%s(cls)\n{return (cls == %s[%s])}",
		fdecl("is_curr_ch_cls"), VAR_CH_TBL(), VAR_CURR_CH()))
	out_line()
	out_line(sprintf("%s(cls)\n{return (cls == %s[%s])}",
		fdecl("is_next_ch_cls"), VAR_CH_TBL(), VAR_PEEK_CH()))
	out_line()
	out_line(sprintf("%s(ch)\n{return %s[ch]}",
		fdecl("get_ch_cls"), VAR_CH_TBL()))
	out_line()
	out_line("# see if what's in the lexer's write space is a keyword")
	out_line(sprintf("%s()\n{return (%s in %s)}",
		fdecl("is_saved_a_keyword"), VAR_SAVED(), VAR_KEYWORDS_TBL()))
}
# </out_input>

# <out_lex_next>
# <lex_next>
function out_tree_symb(tree, root,    _next_str, _next_ch, _i, _end, _esc) {

	if (ch_ptree_has(tree, root) || ch_ptree_is_word(tree, root)) {
	
		if (ch_ptree_is_word(tree, root))
			out_line(sprintf("%s = \"%s\"", VAR_CURR_TOK(), ch_esc_esc(root)))
			
		_next_str = ch_ptree_get(tree, root)
		_end = length(_next_str)
		for (_i = 1; _i <= _end; ++_i) {
			_next_ch = str_ch_at(_next_str, _i)
			_esc = ch_esc_esc(_next_ch)

			if (_end > 1) {
				if (1 == _i) {
					out_line(sprintf("%s = %s()",
						VAR_PEEKED_CH_CACHE(), F_PEEK_CH()))
					out_tabs()
				}			
				print sprintf("%s (\"%s\" == %s) {",
					(_i == 1) ? "if" : "else if", _esc,
					VAR_PEEKED_CH_CACHE())
			} else {
				out_line(sprintf("%s (\"%s\" == %s()) {",
					(_i == 1) ? "if" : "else if", _esc, F_PEEK_CH()))
			}
			
			tabs_inc()
			out_line(sprintf("%s()", F_READ_CH()))
			out_tree_symb(tree, (root _next_ch))

			tabs_dec()
			out_str("} ")
		}

		if (_end >= 1)
			out_line()
	}
}
function out_lex_next(    _i, _end, _cls_set, _cls, _act, _map_cls_chr,
_map_symb, _map_act, _tree, _tmp) {
	# Outputs a big if - else if tree. Branches on character class first and on
	# character value second.
	
	lb_vect_make_set(_cls_set, G_char_tbl_vect, 2)

	out_line("# return the next token; constants are inlined for performance")
	out_line(sprintf("%s() {", fdecl("next")))
	tabs_inc()
	out_line(sprintf("%s = \"%s\"", VAR_CURR_TOK(), TOK_ERR()))
	out_line("while (1) {")
	tabs_inc()

	out_line(sprintf("%s = %s[%s()]",
		VAR_CURR_CH_CLS_CACHE(), VAR_CH_TBL(), F_READ_CH()))

	lb_vect_to_map(_map_cls_chr, G_char_tbl_vect, 2, 1)
	lb_vect_to_map(_map_symb, G_symbols_vect)
	lb_vect_to_map(_map_act, G_actions_vect)
	ch_ptree_init(_tree)

	for (_tmp in _map_symb) {
		if (!is_constant(_tmp))
			ch_ptree_insert(_tree, _tmp)
	}
	
	_end = vect_len(_cls_set)
	for (_i = 1; _i <= _end; ++_i) {
		_cls = _cls_set[_i]

		if (1 == _i)
			out_tabs()

		# Note: constants are inlined for performance. E.g.
		# ...
		# function CH_CLS_WORD() {return 1}
		# ...
		# if (CH_CLS_WORD() == curr_ch_cls)
		# ...
		# becomes
		# ...
		# if (1 == curr_ch_cls) # CH_CLS_WORD()
		# ...
		# Same goes for tokens.
		
		print sprintf("%s (%s == %s) { # %s()",
			(1 == _i) ? "if" : "else if",
			ch_cls_to_const_map_get(_cls), VAR_CURR_CH_CLS_CACHE(), _cls)
	
		tabs_inc()
		
		if (_cls in _map_act) {
			_act = _map_act[_cls]
			if (match(_act, FCALL())) {
				# Any action which ends in '()' is assumed to be a callback.
			
				out_line(sprintf("%s = %s", VAR_CURR_TOK(), fname("usr_" _act)))
			} else if (NEXT_CH() == _act) {
				# Back to the top on white space.
				
				out_line("continue")
			} else if (NEXT_LINE() == _act) {
				# Count new lines.
				
				out_line(sprintf("++%s", VAR_LINE_NO()))
				out_line(sprintf("%s = 1", VAR_LINE_POS()))
				out_line("continue")
			} else if (is_constant(_act)) {
				# Constants are assumed to be function.
				
				out_line(sprintf("%s = %s()", VAR_CURR_TOK(), _act))
			} else {
				# Should never happen.
				
				out_line("!!! ERROR: UNKNOWN ACTION !!!")
			}
		} else {
			# Generate if trees for all tokens which begin with the current
			# character class and are longer than a single character. The
			# class is assumed to represent a single character, i.e. not a
			# range.
			
			_tmp = _map_cls_chr[_cls]
			if (length(_tmp) == 1)
				out_tree_symb(_tree, _tmp)
		}

		tabs_dec()
		out_str("} ")
	}
	print "else {"
	tabs_inc()
	out_line(sprintf("%s = %s()", VAR_CURR_TOK(), F_USR_ON_UNKNOWN_CH()))
	tabs_dec()
	out_line("}")
	out_line("break")
	tabs_dec()
	out_line("}")

	out_line(sprintf("return %s", VAR_CURR_TOK()))
	tabs_dec()
	out_line("}")
}
# </lex_next>
# </out_lex_next>

# <out_init>
function out_init() {	
	out_line("# call this first")
	out_line(sprintf("%s() {", fdecl("init")))
	tabs_inc()
	out_line("# '_B' variables are 'bound' to the lexer, i.e. 'private'")
	out_line(sprintf("if (!%s) {", VAR_ARE_TABLES_INIT()))
	tabs_inc()
	out_line(sprintf("%s()", _fname("init_ch_tbl")))
	out_line(sprintf("%s()", _fname("init_keywords")))
	out_line(sprintf("%s = 1", VAR_ARE_TABLES_INIT()))
	tabs_dec()
	out_line("}")
	out_line(sprintf("%s = \"\"", VAR_CURR_CH()))
	out_line(sprintf("%s = \"\"", VAR_CURR_CH_CLS_CACHE()))
	out_line(sprintf("%s = \"%s\"", VAR_CURR_TOK(), TOK_ERR()))
	out_line(sprintf("%s = 1", VAR_LINE_NO()))
	out_line(sprintf("%s = 1", VAR_LINE_POS()))
	out_line(sprintf("%s = \"\"", VAR_PEEK_CH()))
	out_line(sprintf("%s = \"\"", VAR_PEEKED_CH_CACHE()))
	out_line(sprintf("%s = \"\"", VAR_SAVED()))
	out_line(LEX_NEXT_LINE())
	tabs_dec()
	out_line("}")
}
# </out_init>

# <misc>
function out_public() {
	out_line("# <lex_constants>")
	out_const()
	out_line("# </lex_constants>")
	out_line()
	out_lex_io()
	out_line()
	out_init()
	out_line()
	out_lex_next()
}
function out_private() {
	out_line("# initialize the lexer tables")
	out_kwds()
	out_init_ch_tbl()
}
function out_info(    _i, _end, _set, _str) {
print "# <lex_usr_defined>"
print "# The user implements the following:"
print sprintf("# %s()", F_USR_GET_LINE())
print sprintf("# %s()", F_USR_ON_UNKNOWN_CH())

	lb_vect_make_set(_set, G_actions_vect, 2)
	_end = vect_len(_set)
	for (_i = 1; _i <= _end; ++_i) {
		_str = _set[_i]
		if (match(_str, FCALL()))
			print sprintf("# %s", fname("usr_" _str))
	}

print "# </lex_usr_defined>"
}
function generate() {
	out_line("# <lex_awk>")
	out_signature()
	out_line()
	out_info()
	out_line()
	out_line("# <lex_public>")
	out_public()
	out_line("# </lex_public>")
	out_line()
	out_line("# <lex_private>")
	out_private()
	out_line("# </lex_private>")
	out_line("# </lex_awk>")
}
function err_quit(msg) {
	error_quit(msg, SCRIPT_NAME())
}

function ch_cls_to_const_map_add(ch_cls, const) {
	_B_ch_cls_const_map[ch_cls] = const
}
function ch_cls_to_const_map_get(ch_cls) {
	return _B_ch_cls_const_map[ch_cls]
}
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

function on_help() {
print sprintf("%s -- lex-build awk back end", SCRIPT_NAME())
print ""
print "Classifies characters by table lookup rather than regex. "\
"lex_usr_*() are"
print "implemented by the user; lex_usr_get_line() returns the next line of "\
"input"
print "to the lexer. '\\n' may need to be appended if new lines are meaningful."
print ""
print "Options:"
print "-vNamePrefix=<string> - prefixes all function and constant names with "\
"<string>."
print "E.g. -vNamePrefix='foo_' will result in foo_lex_usr_get_line()"
}

function on_version() {
print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
}

function on_begin() {
	vect_init(G_char_tbl_vect)
	vect_init(G_symbols_vect)
	vect_init(G_keywords_vect)
	vect_init(G_patterns_vect)
	vect_init(G_actions_vect)
	npref_set(NamePrefix)
}
function on_char_tbl() {save_to(G_char_tbl_vect)}
function on_symbols()  {save_to(G_symbols_vect)}
function on_keywords() {save_to(G_keywords_vect)}
function on_patterns() {save_to(G_patterns_vect)}
function on_actions()  {save_to(G_actions_vect)}
function on_end()      {npref_constants_all(); generate()}

# Produce an error if lex_lib.awk is not included
BEGIN {lex_lib_is_included()}
# </misc>
