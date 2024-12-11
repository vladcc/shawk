# <rdpg_ir>
# Author: Vladimir Dinev
# vld.dinev@gmail.com
# 2024-06-24

# version 2.0
# A generic intermediate representation. If optimization is performed, it's
# performed on this. Then it's fed into a back-end for translation to the target
# language.
function IR_COMMENT() {return "#"}

function IR_SETS() {return "sets"}

function IR_ALIAS() {return "alias"}
function IR_PREDICT() {return "predict"}
function IR_EXPECT() {return "expect"}
function IR_SYNC() {return "sync"}

function IR_ESC() {return "\\"}
function IR_FUNC() {return "func"}
function IR_CALL() {return "call"}
function IR_RETURN() {return "return"}

function IR_TOKENS() {return "tokens"}

function IR_TRUE() {return "true"}
function IR_FALSE() {return "false"}

function IR_RDPG_PARSE() {return "rdpg_parse"}
function IR_AND() {return "&&"}

function IR_BLOCK_OPEN() {return "{"}
function IR_BLOCK_CLOSE() {return "}"}

function IR_IF() {return "if"}
function IR_ELSE_IF() {return "else_if"}
function IR_ELSE() {return "else"}

function IR_LOOP() {return "loop"}
function IR_CONTINUE() {return "continue"}

function IR_TOK_MATCH() {return "tok_match"}
function IR_TOK_IS() {return "tok_is"}
function IR_TOK_NEXT() {return "tok_next"}
function IR_TOK_CURR() {return "tok_curr"}
function IR_TOK_EOI() {return "tok_eoi"}
function IR_TOK_ERR() {return "tok_err"}
function IR_WAS_NO_ERR() {return "was_no_err"}
# </rdpg_ir>
