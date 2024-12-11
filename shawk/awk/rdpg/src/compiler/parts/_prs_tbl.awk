# <parse-table>
function pt_print() {_pt_print()}

# <private>
function __pt_set(k, v) {_B_pt_data[k] = v}
function __pt_has(k)    {return map_has(_B_pt_data, k)}
function __pt_get(k)    {return map_get(_B_pt_data, k)}

function _pt_add(lhs, term, rule,    _k, _v) {
	_k = (lhs "," term)
	_v = (__pt_has(_k)) ? (__pt_get(_k) "," rule) : rule
	__pt_set(_k, _v)
}
function _pt_get(lhs, term)       {return __pt_get((lhs "," term))}
# </private>
function _pt_err(lhs, term, rstr,    _str) {
	# Given rdpg makes sure the grammar is LL(1) we should never end up here. If
	# it happens, there must be a bug in the some previous grammar check step.
	_str = sprintf("terminal '%s' in lhs '%s' can predict more than one rule", \
		term, lhs)
	_str = (_str sprintf(": %s", rstr))
	error_print(_str)
}

function _pt_init(    _i, _ei, _j, _ej, _lhs, _term, _rnm) {
	# Precondition: predict sets have been calculated.
	_ei = st_rule_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_lhs = st_rule_lhs(_i)
		_rnm = st_rule_name(_i)

		_ej = sets_pred_size(_rnm)
		for (_j = 1; _j <= _ej; ++_j) {
			_term = sets_pred_at(_rnm, _j)
			_pt_add(_lhs, _term, _rnm)
		}
	}
}

function _pt_check(    _i, _ei, _j, _ej, _lhs, _term, _rstr) {
	_ei = st_lhs_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_lhs = st_lhs(_i)
		_ej = st_name_term_count()
		for (_j = 1; _j <= _ej; ++_j) {
			_term = st_name_term(_j)
			_rstr = _pt_get(_lhs, _term)
			if (index(_rstr, ","))
				_pt_err(_lhs, _term, _rstr)
		}
	}
}

function _PT_SEP() {return ";"}
function _pt_print(    _i, _ei, _j, _ej, _lhs) {
	_pt_init()
	_pt_check()

	printf("table %s%s", _PT_SEP(), _PT_SEP())
	_ei = st_name_term_count()
	for (_i = 1; _i <= _ei; ++_i)
		printf("%s%s", st_name_term(_i), _PT_SEP())
	print ""

	_ei = st_lhs_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_lhs = st_lhs(_i)
		printf("table %s%s%s", _PT_SEP(), _lhs, _PT_SEP())
		_ej = st_name_term_count()
		for (_j = 1; _j <= _ej; ++_j)
			printf("%s%s", _pt_get(_lhs, st_name_term(_j)), _PT_SEP())
		print ""
	}
}
# </parse-table>
