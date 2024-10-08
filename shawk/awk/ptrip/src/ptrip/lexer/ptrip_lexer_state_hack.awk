# <lex_state_hack>
#
# !!!HACK!!!
# This section uses internal knowledge of the lexer implementation in order to
# save its current state so it can be restored later. This is done so '#include'
# directives can be parsed in a depth-first manner and a complete map of the
# info file jungle can be obtained. It is a dirty hack. It works with the lexer
#
# generated by lex-awk.awk 1.7.2
#
# The above line should be used to check if the version of the generated lexer
# matches. The 'state' of the lexer is defined as all variables which get
# initialized in lex_init().
#
function _LEX_STATE_HACK_SEP() {return "\034"}
function lex_state_hack_push_state() {
	_B_lex_state_hack_stack[++_B_lex_state_hack_stack_pos] = \
		(\
		_B_lex_line_str                        _LEX_STATE_HACK_SEP()  \
		_B_lex_curr_ch                         _LEX_STATE_HACK_SEP()  \
		_B_lex_curr_ch_cls_cache               _LEX_STATE_HACK_SEP()  \
		_B_lex_curr_tok                        _LEX_STATE_HACK_SEP()  \
		_B_lex_line_no                         _LEX_STATE_HACK_SEP()  \
		_B_lex_line_pos                        _LEX_STATE_HACK_SEP()  \
		_B_lex_peek_ch                         _LEX_STATE_HACK_SEP()  \
		_B_lex_peeked_ch_cache                 _LEX_STATE_HACK_SEP()  \
		_B_lex_saved                           _LEX_STATE_HACK_SEP()  \
		)
}
function lex_state_hack_pop_state(    _arr) {
	split(_B_lex_state_hack_stack[_B_lex_state_hack_stack_pos--], _arr,
		_LEX_STATE_HACK_SEP())

	_B_lex_line_str                 =  _arr[1]
	split(_B_lex_line_str, _B_lex_input_line, "")
	_B_lex_curr_ch                  =  _arr[2]
	_B_lex_curr_ch_cls_cache        =  _arr[3]
	_B_lex_curr_tok                 =  _arr[4]
	_B_lex_line_no                  =  _arr[5]
	_B_lex_line_pos                 =  _arr[6]
	_B_lex_peek_ch                  =  _arr[7]
	_B_lex_peeked_ch_cache          =  _arr[8]
	_B_lex_saved                    =  _arr[9]
}
function lex_usr_new_line_hack() {
	return TOK_NEW_LINE()
}
# </lex_state_hack>
