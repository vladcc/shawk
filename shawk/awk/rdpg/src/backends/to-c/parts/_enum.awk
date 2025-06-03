# <enum>
function ENUM_PARSE_NEXT_LINE() {return 0}
function ENUM_PARSE_SUCCESS()   {return 1}
function ENUM_PARSE_ERR()       {return 2}

function ENUM_STATE_LOOK_FOR_ENUM()           {return "find-enum"}
function ENUM_STATE_LOOK_FOR_LCURLY()         {return "find-{"}
function ENUM_STATE_LOOK_FOR_NAME_OR_RCURLY() {return "find-name-or-}"}
function ENUM_STATE_LOOK_FOR_COMMA()          {return "find-comma"}
function ENUM_STATE_ML_CMNT()                 {return "read-ml-comment"}
function ENUM_STATE_DONE()                    {return "done"}
function ENUM_STATE_ERR()                     {return "error"}

function enum_parse_line(str) {return _enum_parse_line(str)}

function enum_parse_last_state() {return _enum_state_top()}

function enum_count()             {return _enum_count()}
function enum_get_name_by_num(n)  {return _enum_get_name_by_num(n)}
function enum_get_val_by_name(nm) {return _enum_get_val_by_name(nm)}
function enum_has_name(nm)        {return _enum_has_name(nm)}

function enum_help_str() {return _enum_help_str()}

# <private>
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
    _B_enum_name_arr[++_B_enum_name_arr_len] = name
    _B_enum_name_val_tbl[name] = _B_enum_name_arr_len - 1
}
function _enum_count()             {return _B_enum_name_arr_len}
function _enum_get_name_by_num(n)  {return _B_enum_name_arr[n]}
function _enum_get_val_by_name(nm) {return _B_enum_name_val_tbl[nm]+0}
function _enum_has_name(nm)        {return (nm in _B_enum_name_val_tbl)}

function _enum_parse_line(str,    _st) {

    if (!(_st = _enum_state_top())) {
        _enum_state_push(ENUM_STATE_LOOK_FOR_ENUM())
        return _enum_parse_line(str)
    }

    if (ENUM_STATE_DONE() == _st)
        return ENUM_PARSE_SUCCESS()

    if (ENUM_STATE_ERR() == _st) {
        _enum_state_pop()
        return ENUM_PARSE_ERR()
    }

    if (!str)
        return ENUM_PARSE_NEXT_LINE()

    gsub("^[[:space:]]+|[[:space:]]+$", "", str)

    if (_enum_match(str, "^([/][*])")) {
        _enum_state_push(ENUM_STATE_ML_CMNT())
        return _enum_parse_line(_enum_match_suffix())
    }

    if (ENUM_STATE_ML_CMNT() != _st) {
        if (match(str, "^//")) {
            return ENUM_PARSE_NEXT_LINE()
        }
    }

    if (ENUM_STATE_ML_CMNT() == _st) {
        if (_enum_match(str, "[*]/")) {
            _enum_state_pop()
            return _enum_parse_line(_enum_match_suffix())
        }
        return ENUM_PARSE_NEXT_LINE()
    } else if (ENUM_STATE_LOOK_FOR_ENUM() == _st) {
        if (_enum_match(str, "([^[:alpha:]]|^)enum([^[:alpha:]]|$)")) {
            _enum_state_pop()
            _enum_state_push(ENUM_STATE_LOOK_FOR_LCURLY())
            return _enum_parse_line(_enum_match_suffix())
        }
        return ENUM_PARSE_NEXT_LINE()
    } else if (ENUM_STATE_LOOK_FOR_LCURLY() == _st) {
        if (_enum_match(str, "{")) {
            _enum_state_pop()
            _enum_state_push(ENUM_STATE_LOOK_FOR_NAME_OR_RCURLY())
            return _enum_parse_line(_enum_match_suffix())
        }
        return ENUM_PARSE_NEXT_LINE()
    } else if (ENUM_STATE_LOOK_FOR_NAME_OR_RCURLY() == _st) {
        if (_enum_match(str, \
            "^([[:upper:]_][[:upper:]_[:digit:]]*)")) {
            _enum_name_save(_enum_match_text())
            _enum_state_push(ENUM_STATE_LOOK_FOR_COMMA())
            return _enum_parse_line(_enum_match_suffix())
        } else if (match(str, "^}")) {
            _enum_state_pop()
            _enum_state_push(ENUM_STATE_DONE())
            return _enum_parse_line("")
        } else if (str) {
            _enum_state_push(ENUM_STATE_ERR())
            return _enum_parse_line("")
        }
        return ENUM_PARSE_NEXT_LINE()
    } else if (ENUM_STATE_LOOK_FOR_COMMA() == _st) {
        if (_enum_match(str, "^,")) {
            _enum_state_pop()
            return _enum_parse_line(_enum_match_suffix())
        }
        return ENUM_PARSE_NEXT_LINE()
    }

    return ENUM_PARSE_ERR()
}

function _enum_help_str() {
return \
"This enum parser parses C style curly braces enums. It understands single line\n"  \
"comments with '//', multi line comment with '/* ... */', expects enum constant\n"  \
"names consist of only [A-Z]_[0-9], are followed by a comma and are not followed\n" \
"by an assignment. If there are multiple enum {} declarations in the file, it\n"    \
"takes the first one."
}
# </private>
# </enum>
