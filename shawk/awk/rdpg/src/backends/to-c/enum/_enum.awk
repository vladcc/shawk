# <enum>
function ENUM_PARSE_GOING() {return 0}
function ENUM_PARSE_DONE()  {return 1}
function ENUM_PARSE_ERR()   {return 2}

function enum_parse_line(str) {return _enum_parse_line(str)}

function enum_get_err_str() {return _enum_get_err_str()}

function enum_count()             {return _enum_count()}
function enum_get_name_by_num(n)  {return _enum_get_name_by_num(n)}
function enum_get_val_by_name(nm) {return _enum_get_val_by_name(nm)}
function enum_has_name(nm)        {return _enum_has_name(nm)}

function enum_help_str() {return _enum_help_str()}

# <private>
function _ENUM_STATE_LOOK_FOR_ENUM()   {return 1}
function _ENUM_STATE_LOOK_FOR_LCURLY() {return 2}
function _ENUM_STATE_LOOK_FOR_NAME()   {return 3}
function _ENUM_STATE_ML_CMNT()         {return 4}
function _ENUM_STATE_DONE()            {return 5}

function _enum_state_push(st) {_B_enum_state_stk[++_B_enum_state_stk_num] = st}
function _enum_state_pop(st)  {--_B_enum_state_stk_num}
function _enum_state_top()    {return _B_enum_state_stk[_B_enum_state_stk_num]}

function _enum_match(str, rx) {
    if (match(str, rx)) {
        _B_enum_match_text = substr(str, RSTART, RLENGTH)
        _B_enum_match_suffix = substr(str, RSTART + RLENGTH)
        return 1
    }
    _B_enum_match_text = ""
    _B_enum_match_suffix = ""
    return 0
}
function _enum_match_text()  {return _B_enum_match_text}
function _enum_match_suffix() {return _B_enum_match_suffix}

function _enum_name_save(name) {
    gsub("[[:space:],]", "", name)
    _B_enum_name_arr[++_B_enum_name_arr_len] = name
    _B_enum_name_val_tbl[name] = _B_enum_name_arr_len - 1
}
function _enum_count()             {return _B_enum_name_arr_len}
function _enum_get_name_by_num(n)  {return _B_enum_name_arr[n]}
function _enum_get_val_by_name(nm) {return _B_enum_name_val_tbl[nm]+0}
function _enum_has_name(nm)        {return (nm in _B_enum_name_val_tbl)}

function _enum_set_err_str(str) {_B_enum_err_str = sprintf("enum: %s", str)}
function _enum_get_err_str()    {return _B_enum_err_str}

function _enum_parse_line(str,    _st) {

    if (!(_st = _enum_state_top())) {
        _enum_state_push(_ENUM_STATE_LOOK_FOR_ENUM())
        return _enum_parse_line(str)
    }

    if (_ENUM_STATE_DONE() == _st)
        return ENUM_PARSE_DONE()

    if (!str)
        return ENUM_PARSE_GOING()

    gsub("^[[:space:]]+|[[:space:]]+$", "", str)

    if (_enum_match(str, "^([/][*])")) {
        _enum_state_push(_ENUM_STATE_ML_CMNT())
        return _enum_parse_line(_enum_match_suffix())
    }

    if (_ENUM_STATE_ML_CMNT() != _st) {
        if (match(str, "^//")) {
            return ENUM_PARSE_GOING()
        }
    }

    if (_ENUM_STATE_ML_CMNT() == _st) {
        if (_enum_match(str, "[*][/]")) {
            _enum_state_pop()
            return _enum_parse_line(_enum_match_suffix())
        }
        return ENUM_PARSE_GOING()
    } else if (_ENUM_STATE_LOOK_FOR_ENUM() == _st) {
        if (_enum_match(str, "enum ")) {
            _enum_state_pop()
            _enum_state_push(_ENUM_STATE_LOOK_FOR_LCURLY())
            return _enum_parse_line(_enum_match_suffix())
        }
        return ENUM_PARSE_GOING()
    } else if (_ENUM_STATE_LOOK_FOR_LCURLY() == _st) {
        if (_enum_match(str, "[{]")) {
            _enum_state_pop()
            _enum_state_push(_ENUM_STATE_LOOK_FOR_NAME())
            return _enum_parse_line(_enum_match_suffix())
        }
        return ENUM_PARSE_GOING()
    } else if (_ENUM_STATE_LOOK_FOR_NAME() == _st) {
        if (_enum_match(str, \
            "^([[:upper:]_][[:upper:]_[:digit:]]*[[:space:]]*,?)")) {
            _enum_name_save(_enum_match_text())
            return _enum_parse_line(_enum_match_suffix())
        }  else if (match(str, "^[}]")) {
            _enum_state_pop()
            _enum_state_push(_ENUM_STATE_DONE())
            return _enum_parse_line("")
        }
        return ENUM_PARSE_GOING()
    }

    _enum_set_err_str(sprintf("unexpected state %d", _st))
    return ENUM_PARSE_ERR()
}

function _enum_help_str() {
return \
"This enum parser parses C style curly braces enums. It understands single line\n" \
"comments with '//', multi line comment with '/* ... */', expects enum constant\n" \
"names consist of only [A-Z]_[0-9] and are not followed by an assignment. If\n" \
"there are multiple enum {} declarations in the file, it takes the first one."
}
# </private>
# </enum>
