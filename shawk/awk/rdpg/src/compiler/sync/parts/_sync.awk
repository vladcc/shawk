# <sync>
# Sync=0 - turned off
# Sync=1 - default
# Sync="nont_a=TOK1;nont_b=TOK2,TOK3;nont_c=on_sync_nont_c;nont_d=1" - custom
# =1 in custom means default - don't empty the set
# a non-terminal becomes a callback to a bool function

function SYNC_NONE()    {return "snone"}
function SYNC_DEFAULT() {return "sdef"}
function SYNC_CUSTOM()  {return "scustom"}

# Don't empty follow set
function SYNC_NAME_CUSTOM_NOCHAGE()  {return "snc-nochg"}
# Empty follow set and call the callback
function SYNC_NAME_CUSTOM_CALLBACK() {return "snc-calbk"}
# Replace the follow set with the terminal list
function SYNC_NAME_CUSTOM_TERM_LST() {return "snc-tlst"}

function sync_init(str) {
	if ("" == str)
		str = "1"

	if ("0" == str) {
		_sync_set_type(SYNC_NONE())
	} else if ("1" == str) {
		_sync_set_type(SYNC_DEFAULT())
	} else if (index(str, "=")) {
		_sync_set_type(SYNC_CUSTOM())
		_sync_set_str(str)
		_sync_process(str)
	} else {
		_sync_errq("unknown type", str)
	}
}

function sync_process_sets() {
	if (sync_type() == SYNC_DEFAULT())
		return 1

	sets_flw_customize()
	return (sync_type() == SYNC_NONE()) ? 1 : (check_err_conflicts() == 0)
}

function sync_type() {return _B_sync_table["type"]}
function sync_nont_count() {return _B_sync_table["nont.count"]+0}
function sync_nont(n) {return _B_sync_table[sprintf("nont=%s", n)]}
function sync_has_nont(n) {return (sprintf("nont.set=%s", n) in _B_sync_table)}
function sync_nont_cst_type(n) {
    return _B_sync_table[sprintf("nont.cst.type=%s", n)]
}
function sync_nont_cst_callback(n) {
    return _B_sync_table[sprintf("nont.cst.cbk=%s", n)]
}
function sync_term_count(nont) {
	return _B_sync_table[sprintf("term.count=%s", nont)]+0
}
function sync_term(nont, n) {
	return _B_sync_table[sprintf("term=%s.%s", nont, n)]
}
# <private>
function _SYNC_NAME_CUSTOM_DEFAULT() {return "1"}

function _sync_process(str) {
	# expected str: "<nont>=TERM[,TERM][;<nont>=TERM[,TERM]]"
	gsub("[[:space:]]", "", str)
	_sync_split_semi(str)
}
function _sync_split_semi(str,    _arr, _len, _i, _str) {
	_len = split(str, _arr, ";")
	for (_i = 1; _i <= _len; ++_i) {
		_str = _arr[_i]

		if (!_str) {
			_sync_errq(sprintf("field %d empty after split on ';'", _i), \
				_sync_str())
		}

		_sync_split_equals(_str)
	}
}

function _sync_is_term_list(str) {
	return match(str, "^[A-Z_][A-Z_0-9]*(,[A-Z_][A-Z_0-9]*)*$")
}

function _sync_split_equals(str,    _arr, _len, _i, _head, _tail) {
	# expected str:
    # <nont>=TERM[,TERM] <-- sync on these tokens
    # <nont>=1           <-- default sync behavior
    # <nont>=<nont>      <-- call rhs <nont> on lhs <nont> sync

	_len = split(str, _arr, "=")
	if (_len != 2)
		_sync_errq("string does not split in two fields at '='", str)

	_head = _arr[1]
	_tail = _arr[2]

	if (!_head)
		_sync_errq("nothing before '='", str)

	if (!_tail)
		_sync_errq("nothing after '='", str)

	if (!is_non_term(_head))
		_sync_errq(sprintf("'%s' not a non-terminal", _head), str)

	_sync_save_nont(_head)

    if (_SYNC_NAME_CUSTOM_DEFAULT() == _tail) {
        _sync_set_nont_cst_type(SYNC_NAME_CUSTOM_NOCHAGE())
    } else if (is_non_term(_tail)) {
        _sync_set_nont_cst_type(SYNC_NAME_CUSTOM_CALLBACK())
        _sync_set_nont_cst_callback(_tail)
    } else if (_sync_is_term_list(_tail)) {
        _sync_set_nont_cst_type(SYNC_NAME_CUSTOM_TERM_LST())
        _sync_split_comma(_tail)
	} else {
		_sync_errq("bad Sync syntax")
    }
}
function _sync_split_comma(str,    _arr, _len, _i, _nm) {
	# expected str: TERM[,TERM]
	_len = split(str, _arr, ",")
	for (_i = 1; _i <= _len; ++_i) {
		_nm = _arr[_i]

		if (!_nm)
			_sync_errq(sprintf("field %d empty after split on ','", _i), str)

		if (!is_terminal(_nm))
			_sync_errq(sprintf("'%s' not a terminal", _nm), str)

		_sync_save_term(_nm)
	}
}

function _sync_errq(msg, str) {
	msg = sprintf("sync: %s", msg)
	if (str)
		msg = (msg sprintf(":\n%s", str))
	error_quit(msg)
}

function _sync_set_str(str) {_B_sync_table["str"] = str}
function _sync_str()        {return _B_sync_table["str"]}
function _sync_set_type(type) {_B_sync_table["type"] = type}
function _sync_save_nont(nont,    _c, _n, _s) {
	_s = sprintf("nont.set=%s", nont)
	if (!(_s in _B_sync_table))
		_B_sync_table[_s]
	else
		_sync_errq(sprintf("'%s' redefined", nont), _sync_str())

	_c = ++_B_sync_table["nont.count"]
	_n = sprintf("nont=%s", _c)
	_B_sync_table[_n] = nont
}
function _sync_nont_last(    _c, _n) {
	_c = _B_sync_table["nont.count"]
	_n = sprintf("nont=%s", _c)
	return _B_sync_table[_n]
}
function _sync_save_term(term,    _nont, _c, _n, _s) {
	_nont = _sync_nont_last()

	_s = sprintf("term.set.%s=%s", _nont, term)
	if (!(_s in _B_sync_table)) {
		_B_sync_table[_s]
	} else {
		_sync_errq(sprintf("'%s' multiple times in '%s'", term, _nont), \
			_sync_str())
	}

	_n = sprintf("term.count=%s", _nont)
	_c = ++_B_sync_table[_n]
	_n = sprintf("term=%s.%s", _nont, _c)
	_B_sync_table[_n] = term
}
function _sync_set_nont_cst_type(type,    _s) {
    _s = sprintf("nont.cst.type=%s", _sync_nont_last())
    _B_sync_table[_s] = type
}
function _sync_set_nont_cst_callback(fn,    _s) {
    _s = sprintf("nont.cst.cbk=%s", _sync_nont_last())
    _B_sync_table[_s] = fn
}
# </private>
# </sync>
