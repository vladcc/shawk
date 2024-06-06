# <misc>
function data_or_err() {
	if (NF < 2)
		error_qfpos(sprintf("no data after '%s'", $1))
}

function NULLABLE() {return "?"}
function get_last_ch(str) {return substr(str, length(str))}
function remove_last_ch(str) {return substr(str, 1, length(str)-1)}
function remove_first_field(str) {
	sub("[^[:space:]]+[[:space:]]*", "", str)
	return str
}

function save_raw_definition(rule, defn, _str) {
	_str = _B_plain_defn[rule]
	_str = sprintf("%s%s\n", _str, defn)
	_B_plain_defn[rule] = _str
}
function get_raw_definition(rule) {return _B_plain_defn[rule]}

function null_set_place(rule) {_B_null_set[rule]}
function null_set_has(rule) {return (rule in _B_null_set)}

function is_rule_nullable(rule) {return null_set_has(rule)}

function rule_set_place(rule) {_B_rule_set[rule]}
function rule_set_has(rule) {return (rule in _B_rule_set)}

function rule_line_map_save(rule) {_B_rule_line[rule] = FNR}
function rule_line_map_get(rule) {
	return (rule in _B_rule_line) ? _B_rule_line[rule] : 0
}
function is_a_rule(str){return rule_line_map_get(str)}

function get_current_rule() {return rule_get(rule_get_count())}
function is_terminal(str) {
	return match(str, "^[_[:upper:]][[:upper:][:digit:]_]*$")
}

function RE_NON_TERMINAL() {return "^[_[:lower:]][[:lower:][:digit:]_]*\\??$"}
function is_non_terminal(symb) {
	return match(symb, RE_NON_TERMINAL())
}
function rule_process_name(rule,    _rule) {
	_rule = rule

	if ((get_last_ch(_rule) == NULLABLE())) {
		_rule = remove_last_ch(_rule)
		null_set_place(_rule)
	}
	return _rule
}

function add_defn_to_rule(tree, rule, defn) {
	rdpg_pft_insert(tree, rule, defn)
}
function get_full_path(rule, defn,    _full_path) {
	_full_path = (rule " " defn)
	gsub("[[:space:]]+", RDPG_PFT_SEP(), _full_path)
	return _full_path
}
function get_current_defn() {return defn_get(defn_get_count())}

function syntax_check_rule(rule) {
	if (!is_non_terminal(rule)) {
		error_qfpos(sprintf("bad rule syntax '%s'; has to match '%s'",
			rule, RE_NON_TERMINAL()))
	}
}

function syntax_check_defn(str,    _i, _len, _arr, _tmp) {
	_len = split(str, _arr)
	for (_i = 1; _i <= _len; ++_i) {
		_tmp = _arr[_i]

		if (!is_non_terminal(_tmp) && !is_terminal(_tmp)) {
			error_qfpos(\
				sprintf("bad syntax: '%s' not a terminal or a non-terminal",
				_tmp))
		}
	}

	return str
}
# </misc>
