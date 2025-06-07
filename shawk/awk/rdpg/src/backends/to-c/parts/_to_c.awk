#!/usr/bin/awk -f

# <to-c>
function SCRIPT_NAME()    {return "rdpg-to-c.awk"}
function SCRIPT_VERSION() {return "2.2.3"}

function print_help_quit() {
print sprintf("-- %s - ir to C translator --", SCRIPT_NAME())
print ""
print "Use: rdpg-comp.awk [options] <grammar> | rdpg-to-c.awk [options]"
print ""
print "Outputs rdpg_parser.c and rdpg_parser.h in the current directory by default."
print "Expects rdpg_usr.h which contains the declarations of all required user types."
print "The Tag option changes the output file names; e.g. rdpg_parser_<tag>.c"
print ""
print "I. Required user types:"
print "1. typedef enum tok_id tok_id; - represents the type of token. No assumptions"
print "are made about the values."
print ""
print "2. typedef struct usr_ctx usr_ctx; - holds the user context, e.g. the lexer."
print "The parser does not care what's in the struct, only passes its address around."
print ""
print "II. Required user callbacks:"
print "1. tok_id tok_next(usr_ctx * usr); - called to get the next token from the"
print "input."
print ""
print "2. void tok_err(usr_ctx * usr, prs_ctx * prs); - called when the current input"
print "token is not what's expected. Print error messages here."
print ""
print "3. tok_id tok_curr(usr_ctx * usr); - returns the current token. Only with"
print "TokHack=1."
print ""
print "III. Exported types:"
print "1. typedef struct prs_ctx {void * ctx;} prs_ctx; - holds the parser state."
print "Opaque to the user. Needed in order to avoid static variables. The user does not"
print "need to initialize it, only declare one and pass it to the parser."
print ""
print "IV. Exported API:"
print "1. bool rdpg_parse(prs_ctx * prs, usr_ctx * usr); - call to parse. Returns"
print "true of no error occurred while parsing, false otherwise."
print ""
print "2. const tok_id * rdpg_expect(prs_ctx * prs, size_t * out_size); - call from"
print "tok_err(). Returns a pointer to an array of tokens which were expected at this"
print "point in the input. Upon return, out_size holds the size of the array."
print ""
print "3. void rdpg_reread_curr_tok(prs_ctx * prs); - reread the current token. Only"
print "with TokHack=1."
print ""
print "Options:"
print "-v Dir=<dir> - output the .c and .h files in <dir>; ./ by default"
print "-v Tag=<str> - use <str> in functions, types, and files; e.g. rdpg_parse_<tag>()"
print "-v TokHack=1 - generate rdpg_reread_curr_tok()"
print "-v TokEnum=<file>   - use bit sets for token lookup, take the enum from <file>"
print "-v EnumParserHelp=1 - print more info about the enum parsing process"
print "-v Help=1    - this screen"
print "-v Version=1 - version info"
exit_success()
}
function print_enum_parser_help_quit() {
print sprintf("-- %s enum parser --", SCRIPT_NAME())
print ""
print enum_help_str()
exit_success()
}
function print_version_quit() {
print sprintf("%s %s", SCRIPT_NAME(), SCRIPT_VERSION())
exit_success()
}

# <options>
function OPT_OUT()      {return "Out"}
function OPT_DIR()      {return "Dir"}
function OPT_TAG()      {return "Tag"}
function OPT_TOK_HACK() {return "TokHack"}
function OPT_TOK_ENUM() {return "TokEnum"}

function opt_tok_hack_set(n) {_B_to_c_opt_tbl[OPT_TOK_HACK()] = n}
function opt_tok_hack()      {return _B_to_c_opt_tbl[OPT_TOK_HACK()]}

function opt_out_set(str) {_B_to_c_opt_tbl[OPT_OUT()] = str}
function opt_out()        {return _B_to_c_opt_tbl[OPT_OUT()]}

function opt_dir_set(str) {_B_to_c_opt_tbl[OPT_DIR()] = str}
function opt_dir()        {return _B_to_c_opt_tbl[OPT_DIR()]}

function opt_tag_set(str) {_B_to_c_opt_tbl[OPT_TAG()] = str}
function opt_tag()        {return _B_to_c_opt_tbl[OPT_TAG()]}

function opt_tok_enum_set(str) {_B_to_c_opt_tbl[OPT_TOK_ENUM()] = str}
function opt_tok_enum()        {return _B_to_c_opt_tbl[OPT_TOK_ENUM()]}
# </options>

function init() {
	if (Help)
		print_help_quit()
	if (Version)
		print_version_quit()

    if (EnumParserHelp)
        print_enum_parser_help_quit()

	opt_tag_set(Tag)
	opt_tok_hack_set(TokHack)
    opt_tok_enum_set(TokEnum)

	if (!Dir)
		Dir = "."
	opt_dir_set(Dir)
	opt_out_set((Dir "/" _postf("rdpg_parser")))
}

# <misc>
function _decl_mark(str) {
	return sprintf("#error \"%s decl should be here\"", str)
}
function _PRS_DECL_MARK() {return _decl_mark("parser")}

function _emit_h(str) {bemit(_B_to_c_hdr_buff, str)}
function _nl_h()      {bnl(_B_to_c_hdr_buff)}
function _flush_h()   {bflush(_B_to_c_hdr_buff)}
function _emit_c(str) {bemit(_B_to_c_src_buff, str)}
function _nl_c()      {bnl(_B_to_c_src_buff)}
function _flush_c() {
	if (_PRS_DECL_MARK() == _B_to_c_src_buff[3]) {
		_B_to_c_src_buff[3] = \
			sprintf("\n// <decl>\n// <prs>\n%s\n// </prs>", _tostr_dcl())
	}

	if (_ESC_DECL_MARK() == _B_to_c_src_buff[4]) {
		_B_to_c_src_buff[4] = \
			sprintf("\n// <esc>\n%s\n// </esc>\n// </decl>\n", _esc_lst())
	}

	bflush(_B_to_c_src_buff)
}

function _V_PRS_ST() {return "prs"}

function _T_USR_CTX() {return _postf("usr_ctx")}
function _T_PRS_CTX() {return _postf("prs_ctx")}
function _T_TOK()     {return _postf("tok_id")}

function _make_fn_defn(fname, is_public, type) {
	if (!type)
		type = "bool"

	if (is_public)
		return sprintf("%s %s(%s * usr)", type, fname, _T_USR_CTX())
	return sprintf("static %s %s(%s * prs)", type, fname, _T_PRS_CTX())
}

function _save_dcl(fname) {
	bemit(_B_to_c_decl_buff, sprintf("%s;", _make_fn_defn(fname)))
}
function _tostr_dcl() {return btostr(_B_to_c_decl_buff)}

function _postf(str,    _pref) {
	_pref = opt_tag()
	return _pref ? (str "_" _pref) : str
}
# </misc>

# <sets>
function _set_alias_save(name, data,    _c) {
	_c = ++_B_sets["alias.count"]
	_B_sets[sprintf("alias.name=%d", _c)] = name
	_B_sets[sprintf("alias.data=%d", _c)] = data
	_B_sets[sprintf("alias=%s", name)] = data
}
function _set_alias_count() {return _B_sets["alias.count"]}
function _set_alias_name_by_num(n) {return _B_sets[sprintf("alias.name=%d", n)]}
function _set_alias_data_by_num(n) {return _B_sets[sprintf("alias.data=%d", n)]}

function _set_save(type, name, alias_name,    _c) {
	_c = ++_B_sets[sprintf("set.count=%s", type)]
	_B_sets[sprintf("set.%s.name=%d", type, _c)] = name
	_B_sets[sprintf("set.%s.aname.s=%s", type, name)] = alias_name
    _B_sets[sprintf("set.%s.aname.t=%s", type, alias_name)]
}
function _set_count(type) {return _B_sets[sprintf("set.count=%s", type)]}
function _set_get_name(type, n) {
	return _B_sets[sprintf("set.%s.name=%d", type, n)]
}
function _set_get_alias_name_by_sname(type, sname) {
	return _B_sets[sprintf("set.%s.aname.s=%s", type, sname)]
}
function _set_is_alias_name_of_type(aname, type) {
    return (sprintf("set.%s.aname.t=%s", type, aname) in _B_sets)
}
# </sets>

# <tokens>
function _toks_eoi_save(nm) {_B_to_c_tok_eoi = nm}
function _toks_eoi()        {return _B_to_c_tok_eoi}

function _toks_save(str,    _enum_file) {
    _B_to_c_toks_num = split(str, _B_to_c_toks_arr, " ")
    if (_enum_file = opt_tok_enum())
        _toks_enum(_enum_file)
}
function _toks_num()     {return _B_to_c_toks_num}
function _toks_get(n)    {return _B_to_c_toks_arr[n]}

function _toks_mark(nm)   {_B_to_c_toks_enum_set[nm]}
function _toks_is_tok(nm) {return (nm in _B_to_c_toks_enum_set)}

# <tok-enum>
function _toks_enum(fname,    _arr_text, _len, _i, _eprs) {
    _len = _toks_enum_read(fname, _arr_text)
    _toks_enum_parse(fname, _arr_text, _len)
    _toks_enum_mark()
}
function _toks_enum_read(fname, arr_out,    _ret) {
    _ret = read_file(fname, arr_out)
    if (_ret < 0)
        error_quit(sprintf("failed to read enum file %s", fname))
    return _ret
}
function _toks_enum_errq(fname, line, msg) {
    error_print(sprintf("enum: %s:%d", fname, line))
    error_quit(sprintf("enum: %s", msg))
}
function _toks_enum_parse(fname, arr_txt, len,    _i, _eprs) {
    for (_i = 1; _i <= len; ++_i) {
        _eprs = enum_parse_line(arr_txt[_i])
        if (ENUM_PARSE_SUCCESS() == _eprs)
            return
        else if (ENUM_PARSE_ERR() == _eprs)
            break
    }
    if (_eprs != ENUM_PARSE_SUCCESS()) {
        _toks_enum_errq(fname, _i,                          \
            sprintf("parsing ended in unexpected state %s", \
            enum_parse_last_state())                        \
        )
    }
}
function _toks_enum_mark(    _tok_num, _tok, _i) {
    # Not all enums might be tokens, that's allowed.
    # All tokens must be found in the enum.
    _tok_num = _toks_num()
    for (_i = 1; _i <= _tok_num; ++_i) {
        _tok = _toks_get(_i)
        if (!enum_has_name(_tok))
            error_quit(sprintf("token '%s' not in enum", _tok))
        _toks_mark(_tok)
    }
}
# </tok-enum>
# <bit-set>
function _cbset_init(bit_num) {
    delete _B_cbset_on_set
    _B_cbset_bit_num = bit_num
    _cbset_set_byte_num(int(bit_num / 8) + (bit_num % 8 > 0))
}
function _cbset_bit_num() {return _B_cbset_bit_num}

function _cbset_set_byte_num(n) {_B_cbset_byte_num = n}
function _cbset_byte_num()      {return _B_cbset_byte_num}

function _cbset_bit_turn_on(n) {_B_cbset_on_set[n]}
function _cbset_bit_is_on(n) {
    return (n < _B_cbset_bit_num) && (n in _B_cbset_on_set)
}

function _cbset_gen_bytes(arr_name,    _i, _end, _bit, _val, _str) {
    _end = _cbset_byte_num()
    _bit = 0
    for (_i = 1; _i <= _end; ++_i) {
        _val = 0
        _val += _cbset_bit_is_on(_bit++) * 2^0
        _val += _cbset_bit_is_on(_bit++) * 2^1
        _val += _cbset_bit_is_on(_bit++) * 2^2
        _val += _cbset_bit_is_on(_bit++) * 2^3
        _val += _cbset_bit_is_on(_bit++) * 2^4
        _val += _cbset_bit_is_on(_bit++) * 2^5
        _val += _cbset_bit_is_on(_bit++) * 2^6
        _val += _cbset_bit_is_on(_bit++) * 2^7
        _str = (_str  sprintf("0x%02X,", _val))
    }
    return sprintf("const uint8_t %s[%d] = {%s};", arr_name, _end, _str)
}
# </bit-set>
# </tokens>

# <ctx>
function _ctx_push(ctx) {_B_to_c_ctx_stack[++_B_to_c_ctx_stack_len] = ctx}
function _ctx_peek()    {return _B_to_c_ctx_stack[_B_to_c_ctx_stack_len]}
function _ctx_pop()     {--_B_to_c_ctx_stack_len}
function _ctx_pop_if(ctx) {
	if (_ctx_peek() == ctx) {
		_ctx_pop()
		return 1
	}
	return 0
}
# </ctx>

# <esc>
function _ESC_DECL_MARK() {return _decl_mark("escape")}

function _esc_save(name) {
	name = sprintf("%s;", _make_fn_defn(name, 1, "void"))
	_B_to_c_esc_lst = (!_B_to_c_esc_lst) ? name : (_B_to_c_esc_lst "\n" name)
}
function _esc_lst() {return _B_to_c_esc_lst}
# </esc>

# <cback>
function _cbk_str(    _str) {
	_str = sprintf("void %s(%s * usr, %s * prs);", _postf("tok_err"), \
		_T_USR_CTX(), _T_PRS_CTX())
	_str = (_str "\n" sprintf("%s %s(%s * usr);", _T_TOK(), \
		_postf("tok_next"), _T_USR_CTX()))

	if (opt_tok_hack()) {
		_str = (_str "\n" sprintf("%s %s(%s * usr);", _T_TOK(), \
		_postf("tok_curr"), _T_USR_CTX()))
	}

	return _str
}
# </cback>

# <internal-code>
function _F_IN_SET() {return "is_in_set"}
function _T_PSET() {return "pred_set"}
function _T_SSET() {return "sync_set"}
function _T_ESET() {return "exp_set"}

function _gen_io() {
	_emit_c(sprintf("static inline void expect(%s * prs, const %s * eset, const %s etok)", \
		_T_PRS_CTX(), _T_ESET(), _T_TOK()))
	_emit_c("{")
	tinc()
		_emit_c("prs_st * pst = prs_st_get(prs);")
		_emit_c("pst->was_err = true;")
		_emit_c("pst->etok[0] = etok;")
		_emit_c("pst->eset = eset;")
		_emit_c(sprintf("%s(pst->usr, prs);", _postf("tok_err")))
	tdec()
	_emit_c("}")

	_nl_c()
	_emit_c(sprintf("static inline void rdpg_tok_next(%s * prs)", _T_PRS_CTX()))
	_emit_c("{")
	tinc()
		_emit_c("prs_st * pst = prs_st_get(prs);")
		_emit_c(sprintf("pst->curr_tok = %s(pst->usr);", _postf("tok_next")))
	tdec()
	_emit_c("}")

	_nl_c()
	_emit_c(sprintf("static inline bool rdpg_tok_is(%s * prs, const %s tk)", \
		_T_PRS_CTX(), _T_TOK()))
	_emit_c("{")
	tinc()
		_emit_c("return (tk == prs_st_get(prs)->curr_tok);")
	tdec()
	_emit_c("}")

	_nl_c()
	_emit_c(sprintf("static inline bool rdpg_tok_match(%s * prs, const %s tk)",\
		_T_PRS_CTX(), _T_TOK()))
	_emit_c("{")
	tinc()
		_emit_c("bool is_match = rdpg_tok_is(prs, tk);")
		_emit_c("if (is_match)")
		tinc()
			_emit_c("rdpg_tok_next(prs);")
		tdec()
		_emit_c("return is_match;")
	tdec()
	_emit_c("}")
}
# <gen-sets>
function _gen_set_data_enum(    _i, _end, _n, _arr, _als, _nm, _data, _bits,
_should_gen_map) {
    _bits = enum_count()

    _end = _set_alias_count()
    for (_i = 1; _i <= _end; ++_i) {
        _als = _set_alias_name_by_num(_i)
        _should_gen_map[_als] = (                             \
            _set_is_alias_name_of_type(_als, IR_PREDICT()) || \
            _set_is_alias_name_of_type(_als, IR_SYNC())       \
        )
    }

    for (_i = 1; _i <= _end; ++_i) {
        _als = _set_alias_name_by_num(_i)
        if (!_should_gen_map[_als])
                continue

        _nm = ("bit_" _als)
        _data = _set_alias_data_by_num(_i)

        split(_data, _arr, " ")
        _cbset_init(_bits)
        for (_n in _arr)
            _cbset_bit_turn_on(enum_get_val_by_name(_arr[_n]))
        _emit_c(("static " _cbset_gen_bytes((_nm "_d"))))
    }

    _nl_c()
    for (_i = 1; _i <= _end; ++_i) {
        _als = _set_alias_name_by_num(_i)
        if (!_should_gen_map[_als])
                continue

        _nm = ("bit_" _set_alias_name_by_num(_i))
        _emit_c(sprintf("static const bit_set %s = {%s_d, %d};", _nm, _nm, \
            _bits))
    }
}
function _get_set_data(    _i, _end, _als, _data, _sz, _al_sz_map,
_should_gen_map) {
    _end = _set_alias_count()

    if (opt_tok_enum()) {
        _gen_set_data_enum()
        for (_i = 1; _i <= _end; ++_i) {
            _als = _set_alias_name_by_num(_i)
            _should_gen_map[_als] = \
                _set_is_alias_name_of_type(_als, IR_EXPECT())
        }
        _nl_c()
    } else {
        for (_i = 1; _i <= _end; ++_i)
            _should_gen_map[_set_alias_name_by_num(_i)] = 1
    }

	for (_i = 1; _i <= _end; ++_i) {
		_als = _set_alias_name_by_num(_i)
        if (!_should_gen_map[_als])
            continue
		_data = _set_alias_data_by_num(_i)
		_sz = gsub(" ", ", ", _data)+1
		_al_sz_map[_als] = _sz
		_emit_c(sprintf("static const %s %s_d[%d] = {%s};", _T_TOK(), _als, \
			_sz, _data));
	}

	_nl_c()
	for (_i = 1; _i <= _end; ++_i) {
		_als = _set_alias_name_by_num(_i)
        if (!_should_gen_map[_als])
            continue
		_sz = _al_sz_map[_als]
		_emit_c(sprintf("static const set %s = {%s_d, %d};", _als, _als, _sz))
	}
}
function _gen_set_structs(    _i, _end, _als, _set, _pref, _tp, _nm) {
    _pref = opt_tok_enum() ? "bit_" : ""

    _tp = IR_PREDICT()
    _end = _set_count(_tp)
    for (_i = 1; _i <= _end; ++_i) {
        _set = _set_get_name(_tp, _i)
        _als = (_pref _set_get_alias_name_by_sname(_tp, _set))
        _nm = sprintf("pset_%s", _set)
        _emit_c(sprintf("static const %s %s = {&%s};", _T_PSET(), _nm, _als))
    }

    _nl_c()
    _tp = IR_SYNC()
    _end = _set_count(_tp)
    for (_i = 1; _i <= _end; ++_i) {
        _set = _set_get_name(_tp, _i)
        _als = (_pref _set_get_alias_name_by_sname(_tp, _set))
        _nm = sprintf("sset_%s", _set)
        _emit_c(sprintf("static const %s %s = {&%s};", _T_SSET(), _nm, _als))
    }

	_nl_c()
	_tp = IR_EXPECT()
	_end = _set_count(_tp)
	for (_i = 1; _i <= _end; ++_i) {
		_set = _set_get_name(_tp, _i)
		_als = _set_get_alias_name_by_sname(_tp, _set)
		_nm = sprintf("eset_%s", _set)
		if (1 == _i)
			_emit_c(sprintf("static const %s eset_none = {NULL};", _T_ESET()))
		_emit_c(sprintf("static const %s %s = {&%s};", _T_ESET(), _nm, _als))
	}
}
function _gen_set_fns() {
    if (opt_tok_enum()) {
        _emit_c(sprintf("static bool %s(const %s tk, const uint8_t * bytes, const size_t bits)",\
            _F_IN_SET(), _T_TOK()))
        _emit_c("{")
        tinc()
            _emit_c("size_t bit = (size_t)tk;")
            _emit_c("return (bit < bits) ? (bytes[(bit >> 3)] >> (bit & 7)) & 1 : false;")
        tdec()
        _emit_c("}")
    } else {
        _emit_c(sprintf("static bool %s(const %s tk, const %s * data, size_t len)",\
            _F_IN_SET(), _T_TOK(), _T_TOK()))
        _emit_c("{")
        tinc()
            _emit_c("for (size_t i = 0; i < len; ++i)")
            _emit_c("{")
                tinc()
                    _emit_c("if (data[i] == tk)")
                    tinc()
                        _emit_c("return true;")
                    tdec()
                tdec()
            _emit_c("}")
            _emit_c("return false;")
        tdec()
        _emit_c("}")
    }

	_nl_c()
	_emit_c(sprintf("static inline bool predict(%s * prs, const %s pset)", \
		_T_PRS_CTX(), _T_PSET()))
	_emit_c("{")
	tinc()
		_emit_c(sprintf("return %s(prs_st_get(prs)->curr_tok, pset.s->data, pset.s->len);", \
			_F_IN_SET()))
	tdec()
	_emit_c("}")

	if (sync_call()) {
		_nl_c()
		_emit_c(sprintf("static bool sync(%s * prs, const %s sset)", \
			_T_PRS_CTX(), _T_SSET()))
		_emit_c("{")
		tinc()
			_emit_c("prs_st * pst = prs_st_get(prs);")
			_emit_c("while (1)")
			_emit_c("{")
			tinc()
				_emit_c("if (is_in_set(pst->curr_tok, sset.s->data, sset.s->len))")
				tinc()
					_emit_c("return true;")
				tdec()
				_emit_c("rdpg_tok_next(prs);")
				_emit_c(sprintf("if (%s == pst->curr_tok)", _toks_eoi()))
				tinc()
					_emit_c("break;")
				tdec()
			tdec()
			_emit_c("}")
			_emit_c("return false;")
		tdec()
		_emit_c("}")
	}
}
function _gen_sets() {
    _get_set_data()
	_nl_c()
    _gen_set_structs()
	_nl_c()
    _gen_set_fns()
}
# </gen-sets>
function _gen_internal() {
	_nl_c()
	_emit_c(sprintf("const %s * %s(%s * prs, size_t * out_len)", \
		_T_TOK(), _postf("rdpg_expect"), _T_PRS_CTX()))
	_emit_c("{")
	tinc()
		_emit_c("prs_st * pst = prs_st_get(prs);")
		_emit_c("const set * const st = pst->eset->s;")
		_emit_c("if (st)")
		_emit_c("{")
		tinc()
			_emit_c("*out_len = st->len;")
			_emit_c("return st->data;")
		tdec()
		_emit_c("}")
		_emit_c("else")
		_emit_c("{")
		tinc()
			_emit_c("*out_len = 1;")
			_emit_c("return pst->etok;")
		tdec()
		_emit_c("}")
	tdec()
	_emit_c("}")

	if (opt_tok_hack()) {
		_nl_c()
		_emit_c(sprintf("void %s(%s * prs)", _postf("rdpg_reread_curr_tok"), \
			_T_PRS_CTX()))
		_emit_c("{")
		tinc()
			_emit_c("prs_st * pst = prs_st_get(prs);")
			_emit_c(sprintf("pst->curr_tok = %s(pst->usr);", \
				_postf("tok_curr")))
		tdec()
		_emit_c("}")
	}
	_emit_c("// </exported>")

	_nl_c()
	_emit_c("// <io>")
	_gen_io()
	_emit_c("// </io>")
	_nl_c()
	_emit_c("// <sets>")
	_gen_sets()
	_emit_c("// </sets>")
	_nl_c()
}
# </internal-code>

# <events>
function bd_on_begin() {
	_emit_h(sprintf("#ifndef %s_H", toupper(_postf("RDPG_PARSER"))))
	_emit_h(sprintf("#define %s_H", toupper(_postf("RDPG_PARSER"))))
	_emit_h(sprintf("#include \"%s.h\"", _postf("rdpg_usr")))
	_nl_h()
	_emit_h("#include <stddef.h>")
	_emit_h("#include <stdbool.h>")
	_nl_h()
	_emit_h(sprintf("typedef enum %s %s;", _T_TOK(), _T_TOK()))
	_emit_h(sprintf("typedef struct %s %s;", _T_USR_CTX(), _T_USR_CTX()))
	_nl_h()
	_emit_h(sprintf("typedef struct %s {", _T_PRS_CTX()))
	tinc()
		_emit_h("void * ctx;")
	tdec()
	_emit_h(sprintf("} %s;", _T_PRS_CTX()))
	_nl_h()
	_emit_h(sprintf("bool %s(%s * prs, %s * usr);", _postf("rdpg_parse"), \
		_T_PRS_CTX(), _T_USR_CTX()))
	_emit_h(sprintf("const %s * %s(%s * prs, size_t * out_size);", _T_TOK(), \
		_postf("rdpg_expect"), _T_PRS_CTX()))

	if (opt_tok_hack()) {
		_emit_h(sprintf("void %s(%s * prs);", _postf("rdpg_reread_curr_tok"), \
			_T_PRS_CTX()))
	}

	_emit_h("\n// <usr-callbacks>")
	_emit_h(_cbk_str())
	_emit_h("// </usr-callbacks>")
	_emit_h("#endif")

	_emit_c(sprintf("#include \"%s.h\"",  _postf("rdpg_parser")))
    _emit_c("#include <stdint.h>")
	_emit_c(_PRS_DECL_MARK())
	_emit_c(_ESC_DECL_MARK())
}
function bd_on_end(    _new, _old) {
	_new = opt_out()
	if (_new) {
		_old = stdout_get()
		stdout_set((_new ".h"))
	}

	emit("// <header>")
	_flush_h()
	emit("// </header>")

	if (_new)
		stdout_set((_new ".c"))

	emit("// <source>")
	_flush_c()
	emit("// </prs>")
	emit("// </source>")

	if (_new)
		stdout_set(_old)
}
function bd_on_comment(str) {
	_emit_c(sprintf("// %s", str))
}
function bd_on_comments_end() {
	_nl_c()
}
function bd_on_alias(name, data) {
	_set_alias_save(name, data)
}
function bd_on_set(type, name, alias_name) {
	_set_save(type, name, alias_name)
}
function bd_on_sets_begin() {

}
function bd_on_sets_end() {

}
function bd_on_tokens(all_toks) {
    _toks_save(all_toks)
}
function bd_on_tok_eoi(name) {
	_toks_eoi_save(name)
}
function bd_on_cb_open() {
	_emit_c("{")
	tinc()
}
function bd_on_cb_close() {
	tdec()
	_emit_c("}")
}
function bd_on_parse_main(name,    _tset) {
	_ctx_push(IR_RDPG_PARSE())
	_emit_c("// <internal-types>")
	_emit_c(sprintf("#define TOK_ENONE ((%s)(-1))", _T_TOK()))

    _nl_c()
	_emit_c("typedef struct set {")
	tinc()
		_emit_c(sprintf("const %s * const data;", _T_TOK()))
		_emit_c("const size_t len;")
	tdec()
	_emit_c("} set;")

    _tset = "set"
    if (opt_tok_enum()) {
        _nl_c()
        _emit_c("typedef struct bit_set {")
        tinc()
            _emit_c("const uint8_t * const data;")
            _emit_c("const size_t len;")
        tdec()
        _emit_c("} bit_set;")
        _tset = "bit_set"
    }

    _nl_c()
    _emit_c(sprintf("typedef struct %s {", _T_PSET()))
    tinc()
        _emit_c(sprintf("const %s * const s;", _tset))
    tdec()
    _emit_c(sprintf("} %s;", _T_PSET()))

    _nl_c()
    _emit_c(sprintf("typedef struct %s {", _T_SSET()))
    tinc()
        _emit_c(sprintf("const %s * const s;", _tset))
    tdec()
    _emit_c(sprintf("} %s;", _T_SSET()))

	_nl_c()
	_emit_c(sprintf("typedef struct %s {", _T_ESET()))
	tinc()
		_emit_c("const set * const s;")
	tdec()
	_emit_c(sprintf("} %s;", _T_ESET()))

	_nl_c()
	_emit_c("typedef struct prs_st {")
	tinc()
		_emit_c(sprintf("%s * usr;", _T_USR_CTX()))
		_emit_c("const exp_set * eset;")
		_emit_c(sprintf("%s etok[1];", _T_TOK()))
		_emit_c(sprintf("%s curr_tok;", _T_TOK()))
		_emit_c("bool was_err;")
	tdec()
	_emit_c("} prs_st;")
	_nl_c()
	_emit_c(sprintf("static inline void prs_st_set(%s * prs, prs_st * st)",
		_T_PRS_CTX()))
	_emit_c("{")
	tinc()
		_emit_c("prs->ctx = (void *)st;")
	tdec()
	_emit_c("}")

	_nl_c()
	_emit_c(sprintf("static inline prs_st * prs_st_get(%s * prs)", \
		_T_PRS_CTX()))
	_emit_c("{")
	tinc()
		_emit_c("return (prs_st *)(prs->ctx);")
	tdec()
	_emit_c("}")
	_emit_c("// </internal-types>")
	_nl_c()
	_emit_c("// <exported>")
	_emit_c(sprintf("bool %s(%s * prs, %s * usr)", \
		_postf("rdpg_parse"), _T_PRS_CTX(), _T_USR_CTX()))
}
function bd_on_parse_main_code() {
	_emit_c("prs_st pst = {0};")
	_emit_c("pst.usr = usr;")
	_emit_c("prs_st_set(prs, &pst);")
}
function bd_on_parse_main_end() {
	_gen_internal()
	_emit_c("// <prs>")
}
function bd_on_func(name) {
	_save_dcl(name)
	_emit_c(_make_fn_defn(name))
}
function bd_on_return(val) {
	bstr_cat("return ")
	if (IR_TRUE() == val)
		bstr_cat("true")
	else if (IR_FALSE() == val)
		bstr_cat("false")
}
function bd_on_return_end() {
	bstr_cat(";")
	_emit_c(bstr_extract())
}
function bd_on_call(name, arg, is_esc,    _call, _act_name) {
	if (arg) {
		if (IR_TOK_IS() == name) {
			_call = sprintf("rdpg_tok_is(prs, %s)", arg)
		} else if (IR_TOK_MATCH() == name) {
			_call = sprintf("rdpg_tok_match(prs, %s)", arg)
		} else if (IR_PREDICT() == name) {
			_call = sprintf("%s(prs, pset_%s)", name, arg)
		} else if (IR_SYNC() == name) {
			_call = sprintf("%s(prs, sset_%s)", name, arg)
		} else if (IR_EXPECT() == name) {
			arg = is_terminal(arg) ? ("&eset_none, " arg) \
				: ("&eset_" arg ", TOK_ENONE")
			_call = sprintf("%s(prs, %s)", name, arg)
		}
	} else if (IR_TOK_NEXT() == name) {
		_call = "rdpg_tok_next(prs)"
	} else if (is_esc) {
		if (is_esc)
			_esc_save(name)
		_call = sprintf("%s(prs_st_get(prs)->usr)", name)
	} else {
		# internal call to a nont
		arg = _V_PRS_ST()
		if (_ctx_pop_if(IR_RDPG_PARSE()))
			arg = ("prs")
		_call = sprintf("%s(%s)", name, arg)
	}

	bstr_cat(_call)
	if (bstr_peek() == _call) {
		bstr_cat(";")
		_emit_c(bstr_extract())
	}
}
function bd_on_and() {
	bstr_cat(" && ")
}
function bd_on_err_var(name) {
	bstr_cat(sprintf("!(prs_st_get(prs)->was_err)"))
}
function bd_on_if() {
	bstr_cat("if ")
}
function bd_on_cond() {
	bstr_cat("(")
}
function bd_on_cond_end() {
	bstr_cat(")")
	_emit_c(bstr_extract())
}
function bd_on_else_if() {
	bstr_cat("else if ")
}
function bd_on_else() {
	_emit_c("else")
}
function bd_on_loop() {
	_emit_c("while (1)")
}
function bd_on_continue() {
	_emit_c("continue;")
}
# </events>
# </to-c>
