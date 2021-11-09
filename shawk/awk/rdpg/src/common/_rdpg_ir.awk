# <rdpg_ir>
# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2021-03-20

# version 1.0
# A generic intermediate representation. If optimization is performed, it's
# performed on this. Then it's fed into a back-end for translation to the target
# language.
function IR_FUNC() {return "func"}
function IR_FUNC_END() {return "func_end"}
function IR_CALL() {return "call"}
function IR_IF() {return "if"}
function IR_ELSE_IF() {return "else_if"}
function IR_ELSE() {return "else"}
function IR_LOOP_START() {return "loop_start"}
function IR_LOOP_END() {return "loop_end"}
function IR_CONTINUE() {return "continue"}
function IR_RETURN() {return "return"}
function IR_GOAL() {return "goal"}
function IR_FAIL() {return "fail"}
function IR_COMMENT() {return "comment"}
function IR_BLOCK_OPEN() {return "block_open"}
function IR_BLOCK_CLOSE() {return "block_close"}
function IR_PASS_THROUGH() {return "@"} # for debugging
function IR_TOK_MATCH() {return "tok_match"}
function IR_TOK_NEXT() {return "tok_next"}
function IR_TOK_ERR() {return "tok_err_exp"}
function IR_TRUE() {return "true"}
function IR_FALSE() {return "false"}
# </rdpg_ir>
