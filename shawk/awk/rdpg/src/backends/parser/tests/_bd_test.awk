function bd_on_begin() {
	emit("# <parser>")
}
function bd_on_end() {
	emit("# </parser>")
}

function bd_on_comment(str) {
	bstr_cat(IR_COMMENT())
	if (str)
		bstr_cat((" " str))
	bstr_emit()
}
function bd_on_comments_end() {
	nl()
}

function bd_on_alias(name, data) {
	emit(sprintf("%s %s %s", IR_ALIAS(), name, data))
}

function bd_on_set(type, name, alias_name) {
	emit(sprintf("%s %s %s", type, name, alias_name))
}

function bd_on_sets_begin() {
	emit(IR_SETS())
	bd_on_cb_open()
}
function bd_on_sets_end() {
	bd_on_cb_close()
}

function bd_on_tokens(all_toks) {
	emit(sprintf("%s %s", IR_TOKENS(), all_toks))
}
function bd_on_tok_eoi(name) {
	emit(sprintf("%s %s", IR_TOK_EOI(), name))
}

function bd_on_cb_open() {
	emit(IR_BLOCK_OPEN())
	tinc()
}
function bd_on_cb_close() {
	tdec()
	emit(IR_BLOCK_CLOSE())
}

function bd_on_parse_main(name) {
	emit("# <rdpg_main>")
	emit(sprintf("%s %s", IR_FUNC(), name))
}
function bd_on_parse_main_code() {
	emit("# code here")
}
function bd_on_parse_main_end() {
	emit("# </rdpg_main>")
}

function bd_on_func(name) {
	emit(sprintf("%s %s", IR_FUNC(), name))
}

function bd_on_return(val) {
	bstr_cat("return ")
	if (val)
		bstr_cat(val)
}
function bd_on_return_end() {
	bstr_emit()
}

function bd_on_call(name, arg, is_esc,    _call) {
	_call = sprintf("%s ", IR_CALL())
	if (is_esc)
		_call = (_call sprintf("%s ", IR_ESC()))
	_call = (_call name)
	if (arg)
		_call = (_call sprintf(" %s", arg))
	bstr_cat(_call)
	if (bstr_peek() == _call)
		bstr_emit()
}

function bd_on_and() {
	bstr_cat(sprintf(" %s ", IR_AND()))
}
function bd_on_err_var(name) {
	bstr_cat(name)
}

function bd_on_if() {
	bstr_cat(IR_IF())
}
function bd_on_cond() {
	bstr_cat(" ")
}
function bd_on_cond_end() {
	bstr_emit()
}
function bd_on_else_if() {
	bstr_cat(IR_ELSE_IF())
}
function bd_on_else() {
	emit(IR_ELSE())
}

function bd_on_loop() {
	emit(IR_LOOP())
}
function bd_on_continue() {
	emit(IR_CONTINUE())
}
