# <prs>
# <parse>
#
# translated by rdpg-to-awk.awk 2.1.1
# generated by rdpg-comp.awk 2.1.1
# 
# Immediate error detection: 1
# 
# Grammar:
# 
# 1. start : parser EOI
# 
# 2. parser : \on_parser comment_star tokens_ sets_ parse_main func__plus
# 
# 3. comment : IR_COMMENT \on_comment
# 
# 4. comment_star : comment comment_star
# 5. comment_star : 0
# 
# 6. tokens_ : tok_lst tok_eoi_
# 
# 7. tok_lst : IR_TOKENS \on_tokens tok_name_plus
# 
# 8. tok_name : NAME \on_tok_name
# 
# 9. tok_name_plus : tok_name tok_name_star
# 
# 10. tok_name_star : tok_name tok_name_star
# 11. tok_name_star : 0
# 
# 12. tok_eoi_ : IR_TOK_EOI NAME \on_tok_eoi
# 
# 13. sets_ : IR_SETS IR_BLOCK_OPEN \on_sets alias__plus set_plus IR_BLOCK_CLOSE
# 
# 14. alias_ : IR_ALIAS \on_set_alias NAME \on_set_alias_defn set_elem_plus
# 
# 15. alias__plus : alias_ alias__star
# 
# 16. alias__star : alias_ alias__star
# 17. alias__star : 0
# 
# 18. set_elem : NAME \on_set_elem
# 
# 19. set_elem_plus : set_elem set_elem_star
# 
# 20. set_elem_star : set_elem set_elem_star
# 21. set_elem_star : 0
# 
# 22. set : \on_set set_type NAME \on_set_name NAME \on_set_alias_name
# 
# 23. set_plus : set set_star
# 
# 24. set_star : set set_star
# 25. set_star : 0
# 
# 26. set_type : IR_PREDICT \on_set_type
# 27. set_type : IR_EXPECT \on_set_type
# 28. set_type : IR_SYNC \on_set_type
# 
# 29. parse_main : IR_FUNC IR_RDPG_PARSE \on_parse_main IR_BLOCK_OPEN IR_RETURN IR_CALL NAME \on_top_name IR_AND IR_WAS_NO_ERR \on_err_var IR_BLOCK_CLOSE \on_parse_main_end
# 
# 30. func_ : IR_FUNC NAME \on_func_start func_code_block \on_func_end
# 
# 31. func__plus : func_ func__star
# 
# 32. func__star : func_ func__star
# 33. func__star : 0
# 
# 34. func_code_block : IR_BLOCK_OPEN comment_star \on_cb_open ir_code_plus IR_BLOCK_CLOSE \on_cb_close
# 
# 35. code_block : IR_BLOCK_OPEN \on_cb_open ir_code_plus IR_BLOCK_CLOSE \on_cb_close
# 
# 36. ir_code : call_expr
# 37. ir_code : return_stmt
# 38. ir_code : loop_stmt
# 39. ir_code : IR_CONTINUE \on_continue
# 40. ir_code : if_stmt
# 
# 41. ir_code_plus : ir_code ir_code_star
# 
# 42. ir_code_star : ir_code ir_code_star
# 43. ir_code_star : 0
# 
# 44. call_expr : IR_CALL \on_call call_name call_arg_opt \on_call_end
# 
# 45. call_name : NAME \on_call_name
# 46. call_name : IR_TOK_IS \on_call_name
# 47. call_name : IR_ESC \on_call_esc NAME \on_call_name
# 48. call_name : IR_TOK_NEXT \on_call_name
# 49. call_name : IR_TOK_MATCH \on_call_name
# 50. call_name : IR_PREDICT \on_call_name
# 51. call_name : IR_EXPECT \on_call_name
# 52. call_name : IR_SYNC \on_call_name
# 
# 53. call_arg : NAME \on_call_arg
# 
# 54. call_arg_opt : call_arg
# 55. call_arg_opt : 0
# 
# 56. return_stmt : IR_RETURN \on_return return_rest \on_return_end
# 
# 57. return_rest : call_expr
# 58. return_rest : IR_TRUE \on_ret_const
# 59. return_rest : IR_FALSE \on_ret_const
# 
# 60. loop_stmt : IR_LOOP \on_loop code_block \on_loop_end
# 
# 61. if_stmt : IR_IF \on_if call_expr code_block \on_if_end else_if_stmt_star else_stmt_opt
# 
# 62. else_if_stmt : IR_ELSE_IF \on_else_if call_expr code_block \on_else_if_end
# 
# 63. else_if_stmt_star : else_if_stmt else_if_stmt_star
# 64. else_if_stmt_star : 0
# 
# 65. else_stmt : IR_ELSE \on_else code_block \on_else_end
# 
# 66. else_stmt_opt : else_stmt
# 67. else_stmt_opt : 0
# 

# <public>
function rdpg_parse()
{
	_rdpg_init_sets()
	return _rdpg_start() && !_RDPG_had_error
}
function rdpg_expect(arr_out,    _len) {
	delete arr_out
	if ("tok" == _RDPG_expect_type)
		arr_out[(_len = 1)] = _RDPG_expect_what
	else if ("set" == _RDPG_expect_type)
		_len = split(_RDPG_expect_sets[_RDPG_expect_what], arr_out, _RDPG_SEP())
	return _len
}
# </public>
# <internal>
function _RDPG_SEP() {return "\034"}
function _rdpg_tok_next() {
	_RDPG_curr_tok = tok_next()
}
function _rdpg_tok_is(tok) {
	return (tok == _RDPG_curr_tok)
}
function _rdpg_tok_match(tok,    _ret) {
	if (_ret = _rdpg_tok_is(tok))
		_rdpg_tok_next()
	return _ret
}
function _rdpg_init_sets(    _i, _len, _arr) {
	# alias
	_RDPG_B_str_sym_set_1 = (IR_COMMENT() _RDPG_SEP() IR_TOKENS())
	_RDPG_B_str_sym_set_2 = (IR_TOKENS() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF())
	_RDPG_B_str_sym_set_3 = (IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC())
	_RDPG_B_str_sym_set_4 = (IR_ALIAS() _RDPG_SEP() IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC())
	_RDPG_B_str_sym_set_5 = (IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF())
	_RDPG_B_str_sym_set_6 = (IR_BLOCK_OPEN() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_7 = (IR_ELSE() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_8 = (IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_9 = (IR_COMMENT() _RDPG_SEP() IR_TOKENS() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF())
	_RDPG_B_str_sym_set_10 = (NAME() _RDPG_SEP() IR_TOK_EOI())
	_RDPG_B_str_sym_set_11 = (NAME() _RDPG_SEP() IR_ALIAS() _RDPG_SEP() IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC())
	_RDPG_B_str_sym_set_12 = (IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_13 = (IR_FUNC() _RDPG_SEP() EOI())
	_RDPG_B_str_sym_set_14 = (IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_IF())
	_RDPG_B_str_sym_set_15 = (NAME() _RDPG_SEP() IR_TOK_IS() _RDPG_SEP() IR_ESC() _RDPG_SEP() IR_TOK_NEXT() _RDPG_SEP() IR_TOK_MATCH() _RDPG_SEP() IR_PREDICT() _RDPG_SEP() IR_EXPECT() _RDPG_SEP() IR_SYNC())
	_RDPG_B_str_sym_set_16 = (NAME() _RDPG_SEP() IR_BLOCK_OPEN() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_17 = (IR_CALL() _RDPG_SEP() IR_TRUE() _RDPG_SEP() IR_FALSE())
	_RDPG_B_str_sym_set_18 = (IR_ELSE_IF() _RDPG_SEP() IR_ELSE() _RDPG_SEP() IR_CONTINUE() _RDPG_SEP() IR_CALL() _RDPG_SEP() IR_RETURN() _RDPG_SEP() IR_LOOP() _RDPG_SEP() IR_IF() _RDPG_SEP() IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_19 = (EOI())
	_RDPG_B_str_sym_set_20 = (IR_SETS())
	_RDPG_B_str_sym_set_21 = (IR_TOK_EOI())
	_RDPG_B_str_sym_set_22 = (IR_FUNC())
	_RDPG_B_str_sym_set_23 = (IR_BLOCK_CLOSE())
	_RDPG_B_str_sym_set_24 = (NAME())

	_len = split(_RDPG_B_str_sym_set_1, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_1[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_2, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_2[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_3, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_3[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_4, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_4[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_5, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_5[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_6, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_6[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_7, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_7[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_8, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_8[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_9, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_9[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_10, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_10[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_11, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_11[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_12, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_12[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_13, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_13[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_14, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_14[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_15, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_15[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_16, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_16[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_17, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_17[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_18, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_18[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_19, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_19[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_20, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_20[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_21, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_21[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_22, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_22[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_23, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_23[_arr[_i]]

	_len = split(_RDPG_B_str_sym_set_24, _arr, _RDPG_SEP())
	for (_i = 1; _i <= _len; ++_i)
		_RDPG_sym_set_24[_arr[_i]]

	# expect
	_RDPG_expect_sets["start"] = _RDPG_B_str_sym_set_1
	_RDPG_expect_sets["parser"] = _RDPG_B_str_sym_set_1
	_RDPG_expect_sets["comment_star"] = _RDPG_B_str_sym_set_9
	_RDPG_expect_sets["tok_name_star"] = _RDPG_B_str_sym_set_10
	_RDPG_expect_sets["alias__star"] = _RDPG_B_str_sym_set_4
	_RDPG_expect_sets["set_elem_star"] = _RDPG_B_str_sym_set_11
	_RDPG_expect_sets["set"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["set_plus"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["set_star"] = _RDPG_B_str_sym_set_12
	_RDPG_expect_sets["set_type"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["func__star"] = _RDPG_B_str_sym_set_13
	_RDPG_expect_sets["ir_code"] = _RDPG_B_str_sym_set_14
	_RDPG_expect_sets["ir_code_plus"] = _RDPG_B_str_sym_set_5
	_RDPG_expect_sets["ir_code_star"] = _RDPG_B_str_sym_set_8
	_RDPG_expect_sets["call_name"] = _RDPG_B_str_sym_set_15
	_RDPG_expect_sets["call_arg_opt"] = _RDPG_B_str_sym_set_16
	_RDPG_expect_sets["return_rest"] = _RDPG_B_str_sym_set_17
	_RDPG_expect_sets["else_if_stmt_star"] = _RDPG_B_str_sym_set_18
	_RDPG_expect_sets["else_stmt_opt"] = _RDPG_B_str_sym_set_7
}
function _rdpg_predict(set) {
	return (_RDPG_curr_tok in set)
}
function _rdpg_sync(set) {
	while (_RDPG_curr_tok) {
		if (_RDPG_curr_tok in set)
			return 1
		if (_rdpg_tok_is(EOI()))
			break
		_rdpg_tok_next()
	}
	return 0
}
function _rdpg_expect(type, what) {
	_RDPG_expect_type = type
	_RDPG_expect_what = what
	_RDPG_had_error = 1
	tok_err()
}
# </internal>
# <rd>
function _rdpg_start()
{
	# 1. start : parser EOI

	_rdpg_tok_next()
	if (_rdpg_predict(_RDPG_sym_set_1))
	{
		if (_rdpg_parser())
		{
			if (_rdpg_tok_match(EOI()))
			{
				return 1
			}
			else
			{
				_rdpg_expect("tok", EOI())
			}
		}
	}
	else
	{
		_rdpg_expect("set", "start")
	}
	return 0
}
function _rdpg_parser()
{
	# 2. parser : \on_parser comment_star tokens_ sets_ parse_main func__plus

	if (_rdpg_predict(_RDPG_sym_set_1))
	{
		on_parser()
		if (_rdpg_comment_star())
		{
			if (_rdpg_tokens_())
			{
				if (_rdpg_sets_())
				{
					if (_rdpg_parse_main())
					{
						if (_rdpg_func__plus())
						{
							return 1
						}
					}
				}
			}
		}
	}
	else
	{
		_rdpg_expect("set", "parser")
	}
	return _rdpg_sync(_RDPG_sym_set_19)
}
function _rdpg_comment()
{
	# 3. comment : IR_COMMENT \on_comment

	if (_rdpg_tok_is(IR_COMMENT()))
	{
		on_comment()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("tok", IR_COMMENT())
	}
	return _rdpg_sync(_RDPG_sym_set_9)
}
function _rdpg_comment_star()
{
	# 4. comment_star : comment comment_star
	# 5. comment_star : 0

	while (1)
	{
		if (_rdpg_tok_is(IR_COMMENT()))
		{
			if (_rdpg_comment())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_2))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "comment_star")
		}
		return _rdpg_sync(_RDPG_sym_set_2)
	}
}
function _rdpg_tokens_()
{
	# 6. tokens_ : tok_lst tok_eoi_

	if (_rdpg_tok_is(IR_TOKENS()))
	{
		if (_rdpg_tok_lst())
		{
			if (_rdpg_tok_eoi_())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_TOKENS())
	}
	return _rdpg_sync(_RDPG_sym_set_20)
}
function _rdpg_tok_lst()
{
	# 7. tok_lst : IR_TOKENS \on_tokens tok_name_plus

	if (_rdpg_tok_is(IR_TOKENS()))
	{
		on_tokens()
		_rdpg_tok_next()
		if (_rdpg_tok_name_plus())
		{
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", IR_TOKENS())
	}
	return _rdpg_sync(_RDPG_sym_set_21)
}
function _rdpg_tok_name()
{
	# 8. tok_name : NAME \on_tok_name

	if (_rdpg_tok_is(NAME()))
	{
		on_tok_name()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_10)
}
function _rdpg_tok_name_plus()
{
	# 9. tok_name_plus : tok_name tok_name_star

	if (_rdpg_tok_is(NAME()))
	{
		if (_rdpg_tok_name())
		{
			if (_rdpg_tok_name_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_21)
}
function _rdpg_tok_name_star()
{
	# 10. tok_name_star : tok_name tok_name_star
	# 11. tok_name_star : 0

	while (1)
	{
		if (_rdpg_tok_is(NAME()))
		{
			if (_rdpg_tok_name())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(IR_TOK_EOI()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "tok_name_star")
		}
		return _rdpg_sync(_RDPG_sym_set_21)
	}
}
function _rdpg_tok_eoi_()
{
	# 12. tok_eoi_ : IR_TOK_EOI NAME \on_tok_eoi

	if (_rdpg_tok_match(IR_TOK_EOI()))
	{
		if (_rdpg_tok_is(NAME()))
		{
			on_tok_eoi()
			_rdpg_tok_next()
			return 1
		}
		else
		{
			_rdpg_expect("tok", NAME())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_TOK_EOI())
	}
	return _rdpg_sync(_RDPG_sym_set_20)
}
function _rdpg_sets_()
{
	# 13. sets_ : IR_SETS IR_BLOCK_OPEN \on_sets alias__plus set_plus IR_BLOCK_CLOSE

	if (_rdpg_tok_match(IR_SETS()))
	{
		if (_rdpg_tok_is(IR_BLOCK_OPEN()))
		{
			on_sets()
			_rdpg_tok_next()
			if (_rdpg_alias__plus())
			{
				if (_rdpg_set_plus())
				{
					if (_rdpg_tok_match(IR_BLOCK_CLOSE()))
					{
						return 1
					}
					else
					{
						_rdpg_expect("tok", IR_BLOCK_CLOSE())
					}
				}
			}
		}
		else
		{
			_rdpg_expect("tok", IR_BLOCK_OPEN())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_SETS())
	}
	return _rdpg_sync(_RDPG_sym_set_22)
}
function _rdpg_alias_()
{
	# 14. alias_ : IR_ALIAS \on_set_alias NAME \on_set_alias_defn set_elem_plus

	if (_rdpg_tok_is(IR_ALIAS()))
	{
		on_set_alias()
		_rdpg_tok_next()
		if (_rdpg_tok_is(NAME()))
		{
			on_set_alias_defn()
			_rdpg_tok_next()
			if (_rdpg_set_elem_plus())
			{
				return 1
			}
		}
		else
		{
			_rdpg_expect("tok", NAME())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_ALIAS())
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_alias__plus()
{
	# 15. alias__plus : alias_ alias__star

	if (_rdpg_tok_is(IR_ALIAS()))
	{
		if (_rdpg_alias_())
		{
			if (_rdpg_alias__star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_ALIAS())
	}
	return _rdpg_sync(_RDPG_sym_set_3)
}
function _rdpg_alias__star()
{
	# 16. alias__star : alias_ alias__star
	# 17. alias__star : 0

	while (1)
	{
		if (_rdpg_tok_is(IR_ALIAS()))
		{
			if (_rdpg_alias_())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_3))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "alias__star")
		}
		return _rdpg_sync(_RDPG_sym_set_3)
	}
}
function _rdpg_set_elem()
{
	# 18. set_elem : NAME \on_set_elem

	if (_rdpg_tok_is(NAME()))
	{
		on_set_elem()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_11)
}
function _rdpg_set_elem_plus()
{
	# 19. set_elem_plus : set_elem set_elem_star

	if (_rdpg_tok_is(NAME()))
	{
		if (_rdpg_set_elem())
		{
			if (_rdpg_set_elem_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_set_elem_star()
{
	# 20. set_elem_star : set_elem set_elem_star
	# 21. set_elem_star : 0

	while (1)
	{
		if (_rdpg_tok_is(NAME()))
		{
			if (_rdpg_set_elem())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_4))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "set_elem_star")
		}
		return _rdpg_sync(_RDPG_sym_set_4)
	}
}
function _rdpg_set()
{
	# 22. set : \on_set set_type NAME \on_set_name NAME \on_set_alias_name

	if (_rdpg_predict(_RDPG_sym_set_3))
	{
		on_set()
		if (_rdpg_set_type())
		{
			if (_rdpg_tok_is(NAME()))
			{
				on_set_name()
				_rdpg_tok_next()
				if (_rdpg_tok_is(NAME()))
				{
					on_set_alias_name()
					_rdpg_tok_next()
					return 1
				}
				else
				{
					_rdpg_expect("tok", NAME())
				}
			}
			else
			{
				_rdpg_expect("tok", NAME())
			}
		}
	}
	else
	{
		_rdpg_expect("set", "set")
	}
	return _rdpg_sync(_RDPG_sym_set_12)
}
function _rdpg_set_plus()
{
	# 23. set_plus : set set_star

	if (_rdpg_predict(_RDPG_sym_set_3))
	{
		if (_rdpg_set())
		{
			if (_rdpg_set_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "set_plus")
	}
	return _rdpg_sync(_RDPG_sym_set_23)
}
function _rdpg_set_star()
{
	# 24. set_star : set set_star
	# 25. set_star : 0

	while (1)
	{
		if (_rdpg_predict(_RDPG_sym_set_3))
		{
			if (_rdpg_set())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "set_star")
		}
		return _rdpg_sync(_RDPG_sym_set_23)
	}
}
function _rdpg_set_type()
{
	# 26. set_type : IR_PREDICT \on_set_type
	# 27. set_type : IR_EXPECT \on_set_type
	# 28. set_type : IR_SYNC \on_set_type

	if (_rdpg_tok_is(IR_PREDICT()))
	{
		on_set_type()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_EXPECT()))
	{
		on_set_type()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_SYNC()))
	{
		on_set_type()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("set", "set_type")
	}
	return _rdpg_sync(_RDPG_sym_set_24)
}
function _rdpg_parse_main()
{
	# 29. parse_main : IR_FUNC IR_RDPG_PARSE \on_parse_main IR_BLOCK_OPEN IR_RETURN IR_CALL NAME \on_top_name IR_AND IR_WAS_NO_ERR \on_err_var IR_BLOCK_CLOSE \on_parse_main_end

	if (_rdpg_tok_match(IR_FUNC()))
	{
		if (_rdpg_tok_is(IR_RDPG_PARSE()))
		{
			on_parse_main()
			_rdpg_tok_next()
			if (_rdpg_tok_match(IR_BLOCK_OPEN()))
			{
				if (_rdpg_tok_match(IR_RETURN()))
				{
					if (_rdpg_tok_match(IR_CALL()))
					{
						if (_rdpg_tok_is(NAME()))
						{
							on_top_name()
							_rdpg_tok_next()
							if (_rdpg_tok_match(IR_AND()))
							{
								if (_rdpg_tok_is(IR_WAS_NO_ERR()))
								{
									on_err_var()
									_rdpg_tok_next()
									if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
									{
										on_parse_main_end()
										_rdpg_tok_next()
										return 1
									}
									else
									{
										_rdpg_expect("tok", IR_BLOCK_CLOSE())
									}
								}
								else
								{
									_rdpg_expect("tok", IR_WAS_NO_ERR())
								}
							}
							else
							{
								_rdpg_expect("tok", IR_AND())
							}
						}
						else
						{
							_rdpg_expect("tok", NAME())
						}
					}
					else
					{
						_rdpg_expect("tok", IR_CALL())
					}
				}
				else
				{
					_rdpg_expect("tok", IR_RETURN())
				}
			}
			else
			{
				_rdpg_expect("tok", IR_BLOCK_OPEN())
			}
		}
		else
		{
			_rdpg_expect("tok", IR_RDPG_PARSE())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_FUNC())
	}
	return _rdpg_sync(_RDPG_sym_set_22)
}
function _rdpg_func_()
{
	# 30. func_ : IR_FUNC NAME \on_func_start func_code_block \on_func_end

	if (_rdpg_tok_match(IR_FUNC()))
	{
		if (_rdpg_tok_is(NAME()))
		{
			on_func_start()
			_rdpg_tok_next()
			if (_rdpg_func_code_block())
			{
				on_func_end()
				return 1
			}
		}
		else
		{
			_rdpg_expect("tok", NAME())
		}
	}
	else
	{
		_rdpg_expect("tok", IR_FUNC())
	}
	return _rdpg_sync(_RDPG_sym_set_13)
}
function _rdpg_func__plus()
{
	# 31. func__plus : func_ func__star

	if (_rdpg_tok_is(IR_FUNC()))
	{
		if (_rdpg_func_())
		{
			if (_rdpg_func__star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_FUNC())
	}
	return _rdpg_sync(_RDPG_sym_set_19)
}
function _rdpg_func__star()
{
	# 32. func__star : func_ func__star
	# 33. func__star : 0

	while (1)
	{
		if (_rdpg_tok_is(IR_FUNC()))
		{
			if (_rdpg_func_())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(EOI()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "func__star")
		}
		return _rdpg_sync(_RDPG_sym_set_19)
	}
}
function _rdpg_func_code_block()
{
	# 34. func_code_block : IR_BLOCK_OPEN comment_star \on_cb_open ir_code_plus IR_BLOCK_CLOSE \on_cb_close

	if (_rdpg_tok_match(IR_BLOCK_OPEN()))
	{
		if (_rdpg_comment_star())
		{
			on_cb_open()
			if (_rdpg_ir_code_plus())
			{
				if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
				{
					on_cb_close()
					_rdpg_tok_next()
					return 1
				}
				else
				{
					_rdpg_expect("tok", IR_BLOCK_CLOSE())
				}
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_BLOCK_OPEN())
	}
	return _rdpg_sync(_RDPG_sym_set_13)
}
function _rdpg_code_block()
{
	# 35. code_block : IR_BLOCK_OPEN \on_cb_open ir_code_plus IR_BLOCK_CLOSE \on_cb_close

	if (_rdpg_tok_is(IR_BLOCK_OPEN()))
	{
		on_cb_open()
		_rdpg_tok_next()
		if (_rdpg_ir_code_plus())
		{
			if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
			{
				on_cb_close()
				_rdpg_tok_next()
				return 1
			}
			else
			{
				_rdpg_expect("tok", IR_BLOCK_CLOSE())
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_BLOCK_OPEN())
	}
	return _rdpg_sync(_RDPG_sym_set_18)
}
function _rdpg_ir_code()
{
	# 36. ir_code : call_expr
	# 37. ir_code : return_stmt
	# 38. ir_code : loop_stmt
	# 39. ir_code : IR_CONTINUE \on_continue
	# 40. ir_code : if_stmt

	if (_rdpg_tok_is(IR_CALL()))
	{
		if (_rdpg_call_expr())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(IR_RETURN()))
	{
		if (_rdpg_return_stmt())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(IR_LOOP()))
	{
		if (_rdpg_loop_stmt())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(IR_CONTINUE()))
	{
		on_continue()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_IF()))
	{
		if (_rdpg_if_stmt())
		{
			return 1
		}
	}
	else
	{
		_rdpg_expect("set", "ir_code")
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_ir_code_plus()
{
	# 41. ir_code_plus : ir_code ir_code_star

	if (_rdpg_predict(_RDPG_sym_set_5))
	{
		if (_rdpg_ir_code())
		{
			if (_rdpg_ir_code_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "ir_code_plus")
	}
	return _rdpg_sync(_RDPG_sym_set_23)
}
function _rdpg_ir_code_star()
{
	# 42. ir_code_star : ir_code ir_code_star
	# 43. ir_code_star : 0

	while (1)
	{
		if (_rdpg_predict(_RDPG_sym_set_5))
		{
			if (_rdpg_ir_code())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(IR_BLOCK_CLOSE()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "ir_code_star")
		}
		return _rdpg_sync(_RDPG_sym_set_23)
	}
}
function _rdpg_call_expr()
{
	# 44. call_expr : IR_CALL \on_call call_name call_arg_opt \on_call_end

	if (_rdpg_tok_is(IR_CALL()))
	{
		on_call()
		_rdpg_tok_next()
		if (_rdpg_call_name())
		{
			if (_rdpg_call_arg_opt())
			{
				on_call_end()
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_CALL())
	}
	return _rdpg_sync(_RDPG_sym_set_6)
}
function _rdpg_call_name()
{
	# 45. call_name : NAME \on_call_name
	# 46. call_name : IR_TOK_IS \on_call_name
	# 47. call_name : IR_ESC \on_call_esc NAME \on_call_name
	# 48. call_name : IR_TOK_NEXT \on_call_name
	# 49. call_name : IR_TOK_MATCH \on_call_name
	# 50. call_name : IR_PREDICT \on_call_name
	# 51. call_name : IR_EXPECT \on_call_name
	# 52. call_name : IR_SYNC \on_call_name

	if (_rdpg_tok_is(NAME()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_TOK_IS()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_ESC()))
	{
		on_call_esc()
		_rdpg_tok_next()
		if (_rdpg_tok_is(NAME()))
		{
			on_call_name()
			_rdpg_tok_next()
			return 1
		}
		else
		{
			_rdpg_expect("tok", NAME())
		}
	}
	else if (_rdpg_tok_is(IR_TOK_NEXT()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_TOK_MATCH()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_PREDICT()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_EXPECT()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_SYNC()))
	{
		on_call_name()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("set", "call_name")
	}
	return _rdpg_sync(_RDPG_sym_set_16)
}
function _rdpg_call_arg()
{
	# 53. call_arg : NAME \on_call_arg

	if (_rdpg_tok_is(NAME()))
	{
		on_call_arg()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("tok", NAME())
	}
	return _rdpg_sync(_RDPG_sym_set_6)
}
function _rdpg_call_arg_opt()
{
	# 54. call_arg_opt : call_arg
	# 55. call_arg_opt : 0

	if (_rdpg_tok_is(NAME()))
	{
		if (_rdpg_call_arg())
		{
			return 1
		}
	}
	else if (_rdpg_predict(_RDPG_sym_set_6))
	{
		return 1
	}
	else
	{
		_rdpg_expect("set", "call_arg_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_6)
}
function _rdpg_return_stmt()
{
	# 56. return_stmt : IR_RETURN \on_return return_rest \on_return_end

	if (_rdpg_tok_is(IR_RETURN()))
	{
		on_return()
		_rdpg_tok_next()
		if (_rdpg_return_rest())
		{
			on_return_end()
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", IR_RETURN())
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_return_rest()
{
	# 57. return_rest : call_expr
	# 58. return_rest : IR_TRUE \on_ret_const
	# 59. return_rest : IR_FALSE \on_ret_const

	if (_rdpg_tok_is(IR_CALL()))
	{
		if (_rdpg_call_expr())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(IR_TRUE()))
	{
		on_ret_const()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(IR_FALSE()))
	{
		on_ret_const()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("set", "return_rest")
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_loop_stmt()
{
	# 60. loop_stmt : IR_LOOP \on_loop code_block \on_loop_end

	if (_rdpg_tok_is(IR_LOOP()))
	{
		on_loop()
		_rdpg_tok_next()
		if (_rdpg_code_block())
		{
			on_loop_end()
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", IR_LOOP())
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_if_stmt()
{
	# 61. if_stmt : IR_IF \on_if call_expr code_block \on_if_end else_if_stmt_star else_stmt_opt

	if (_rdpg_tok_is(IR_IF()))
	{
		on_if()
		_rdpg_tok_next()
		if (_rdpg_call_expr())
		{
			if (_rdpg_code_block())
			{
				on_if_end()
				if (_rdpg_else_if_stmt_star())
				{
					if (_rdpg_else_stmt_opt())
					{
						return 1
					}
				}
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_IF())
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_else_if_stmt()
{
	# 62. else_if_stmt : IR_ELSE_IF \on_else_if call_expr code_block \on_else_if_end

	if (_rdpg_tok_is(IR_ELSE_IF()))
	{
		on_else_if()
		_rdpg_tok_next()
		if (_rdpg_call_expr())
		{
			if (_rdpg_code_block())
			{
				on_else_if_end()
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", IR_ELSE_IF())
	}
	return _rdpg_sync(_RDPG_sym_set_18)
}
function _rdpg_else_if_stmt_star()
{
	# 63. else_if_stmt_star : else_if_stmt else_if_stmt_star
	# 64. else_if_stmt_star : 0

	while (1)
	{
		if (_rdpg_tok_is(IR_ELSE_IF()))
		{
			if (_rdpg_else_if_stmt())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_7))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "else_if_stmt_star")
		}
		return _rdpg_sync(_RDPG_sym_set_7)
	}
}
function _rdpg_else_stmt()
{
	# 65. else_stmt : IR_ELSE \on_else code_block \on_else_end

	if (_rdpg_tok_is(IR_ELSE()))
	{
		on_else()
		_rdpg_tok_next()
		if (_rdpg_code_block())
		{
			on_else_end()
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", IR_ELSE())
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
function _rdpg_else_stmt_opt()
{
	# 66. else_stmt_opt : else_stmt
	# 67. else_stmt_opt : 0

	if (_rdpg_tok_is(IR_ELSE()))
	{
		if (_rdpg_else_stmt())
		{
			return 1
		}
	}
	else if (_rdpg_predict(_RDPG_sym_set_8))
	{
		return 1
	}
	else
	{
		_rdpg_expect("set", "else_stmt_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_8)
}
# </rd>
# </parse>
# <export>
function sync_call() {return _B_prs_sync_call}
# </export>

# <dispatch>
function on_call()           {_prs_do("on_call")}
function on_call_arg()       {_prs_do("on_call_arg")}
function on_call_end()       {_prs_do("on_call_end")}
function on_call_esc()       {_prs_do("on_call_esc")}
function on_call_name()      {_prs_do("on_call_name")}
function on_cb_close()       {_prs_do("on_cb_close")}
function on_cb_open()        {_prs_do("on_cb_open")}
function on_comment()        {_prs_do("on_comment")}
function on_continue()       {_prs_do("on_continue")}
function on_else()           {_prs_do("on_else")}
function on_else_end()       {_prs_do("on_else_end")}
function on_else_if()        {_prs_do("on_else_if")}
function on_else_if_end()    {_prs_do("on_else_if_end")}
function on_err_var()        {_prs_do("on_err_var")}
function on_func_end()       {_prs_do("on_func_end")}
function on_func_start()     {_prs_do("on_func_start")}
function on_if()             {_prs_do("on_if")}
function on_if_end()         {_prs_do("on_if_end")}
function on_loop()           {_prs_do("on_loop")}
function on_loop_end()       {_prs_do("on_loop_end")}
function on_parse_main()     {_prs_do("on_parse_main")}
function on_parse_main_end() {_prs_do("on_parse_main_end")}
function on_parser()         {_prs_do("on_parser")}
function on_ret_const()      {_prs_do("on_ret_const")}
function on_return()         {_prs_do("on_return")}
function on_return_end()     {_prs_do("on_return_end")}
function on_set()            {_prs_do("on_set")}
function on_set_alias()      {_prs_do("on_set_alias")}
function on_set_alias_defn() {_prs_do("on_set_alias_defn")}
function on_set_alias_name() {_prs_do("on_set_alias_name")}
function on_set_elem()       {_prs_do("on_set_elem")}
function on_set_name()       {_prs_do("on_set_name")}
function on_sets()           {_prs_do("on_sets")}
function on_set_type()       {_prs_do("on_set_type")}
function on_tokens()         {_prs_do("on_tokens")}
function on_tok_eoi()        {_prs_do("on_tok_eoi")}
function on_tok_name()       {_prs_do("on_tok_name")}
function on_top_name()       {_prs_do("on_top_name")}

function _prs_do(what) {
	if (parsing_error_happened())          return
	else if ("on_call"           == what) _prs_on_call()
	else if ("on_call_arg"       == what) _prs_on_call_arg()
	else if ("on_call_end"       == what) _prs_on_call_end()
	else if ("on_call_esc"       == what) _prs_on_call_esc()
	else if ("on_call_name"      == what) _prs_on_call_name()
	else if ("on_cb_close"       == what) _prs_on_cb_close()
	else if ("on_cb_open"        == what) _prs_on_cb_open()
	else if ("on_comment"        == what) _prs_on_comment()
	else if ("on_continue"       == what) _prs_on_continue()
	else if ("on_else"           == what) _prs_on_else()
	else if ("on_else_end"       == what) _prs_on_else_end()
	else if ("on_else_if"        == what) _prs_on_else_if()
	else if ("on_else_if_end"    == what) _prs_on_else_if_end()
	else if ("on_err_var"        == what) _prs_on_err_var()
	else if ("on_func_end"       == what) _prs_on_func_end()
	else if ("on_func_start"     == what) _prs_on_func_start()
	else if ("on_if"             == what) _prs_on_if()
	else if ("on_if_end"         == what) _prs_on_if_end()
	else if ("on_loop"           == what) _prs_on_loop()
	else if ("on_loop_end"       == what) _prs_on_loop_end()
	else if ("on_parse_main"     == what) _prs_on_parse_main()
	else if ("on_parse_main_end" == what) _prs_on_parse_main_end()
	else if ("on_parser"         == what) _prs_on_parser()
	else if ("on_ret_const"      == what) _prs_on_ret_const()
	else if ("on_return"         == what) _prs_on_return()
	else if ("on_return_end"     == what) _prs_on_return_end()
	else if ("on_set"            == what) _prs_on_set()
	else if ("on_set_alias"      == what) _prs_on_set_alias()
	else if ("on_set_alias_defn" == what) _prs_on_set_alias_defn()
	else if ("on_set_alias_name" == what) _prs_on_set_alias_name()
	else if ("on_set_elem"       == what) _prs_on_set_elem()
	else if ("on_set_name"       == what) _prs_on_set_name()
	else if ("on_sets"           == what) _prs_on_sets()
	else if ("on_set_type"       == what) _prs_on_set_type()
	else if ("on_tokens"         == what) _prs_on_tokens()
	else if ("on_tok_eoi"        == what) _prs_on_tok_eoi()
	else if ("on_tok_name"       == what) _prs_on_tok_name()
	else if ("on_top_name"       == what) _prs_on_top_name()
	else error_quit(sprintf("parser: unknown action '%s'", what))
}
# </dispatch>

# <stack>
function _prs_stack_push(n)    {_B_prs_stack[++_B_prs_stack_len] = n}
function _prs_stack_pop()      {--_B_prs_stack_len}
function _prs_stack_peek()     {return _B_prs_stack[_B_prs_stack_len]}
# </stack>

# <process>
function _prs_on_parser() {
	ast_root_set(ast_root_node_create())
	_prs_stack_push(ast_root())
}

function _prs_on_comment(    _ecmnt, _top, _type, _str) {
	if (!_B_prs_on_comment_rx)
		_B_prs_on_comment_rx = sprintf("^%s[[:space:]]*", IR_COMMENT())

	_str = lex_get_line()
	lex_next_line()
	sub(_B_prs_on_comment_rx, "", _str)
	_ecmnt = ast_comment_make(_str)

	_top = _prs_stack_peek()
	_type = ast_type_of(_top)
	if (AST_ROOT_NODE() == _type) {
		ast_root_node_push_cmnt(_top, _ecmnt)
	} else if (AST_FNC() == _type) {
		ast_fnc_push_cmnt(_top, _ecmnt)
	} else {
		ast_ent_errq("_prs_on_comment()", _top, _type)
	}
}

function _prs_on_tokens(    _toks) {
	_toks = ast_tokens_make()
	ast_root_node_set_tokens(_prs_stack_peek(), _toks)
	_prs_stack_pop()
	_prs_stack_push(_toks)
}
function _prs_on_tok_name(    _toks, _all, _nm) {
	_toks = _prs_stack_peek()
	_nm = lex_get_name()
	_all = ast_tokens_get_all_tok(_toks)
	_all = (_all) ? (_all " " _nm) : _nm
	ast_tokens_set_all_tok(_toks, _all)
}
function _prs_on_tok_eoi() {
	ast_tokens_set_tok_eoi(_prs_stack_peek(), lex_get_name())
}

function _prs_on_sets(    _sets) {
	_sets = ast_sets_create()
	ast_tokens_set_sets(_prs_stack_peek(), _sets)
	_prs_stack_pop()
	_prs_stack_push(_sets)
}

function _prs_on_set_alias() {
	ast_sets_push_alias(_prs_stack_peek(), ast_alias_make())
}
function _prs_on_set_alias_defn() {
	ast_alias_set_name(ast_sets_last_alias(_prs_stack_peek()), lex_get_name())
}
function _prs_on_set_elem() {
	ast_alias_push_elem(ast_sets_last_alias(_prs_stack_peek()), lex_get_name())
}

function _prs_on_set() {
	ast_sets_push_set(_prs_stack_peek(), ast_set_make())
}
function _prs_on_set_type() {
	ast_set_set_type(ast_sets_last_set(_prs_stack_peek()), lex_get_curr_tok())
}
function _prs_on_set_name() {
	ast_set_set_name(ast_sets_last_set(_prs_stack_peek()), lex_get_name())
}
function _prs_on_set_alias_name() {
	ast_set_set_alias_name(ast_sets_last_set(_prs_stack_peek()), lex_get_name())
}

function _prs_on_parse_main() {
	_prs_stack_push(ast_parse_main_create(lex_get_curr_tok()))
}
function _prs_on_top_name() {
	ast_parse_main_set_top_nont(_prs_stack_peek(), lex_get_name())
}
function _prs_on_err_var() {
	ast_parse_main_set_err_var(_prs_stack_peek(), lex_get_curr_tok())
}
function _prs_on_parse_main_end(    _main) {
	_main = _prs_stack_peek()
	_prs_stack_pop()
	ast_sets_set_parse_main(_prs_stack_peek(), _main)
	_prs_stack_pop()
	_prs_stack_push(_main)
}

function _prs_on_func_start() {
	_prs_stack_push(ast_fnc_create(lex_get_name()))
}
function _prs_on_func_end(    _fnc) {
	_fnc = _prs_stack_peek()
	_prs_stack_pop()
	ast_parse_main_push_fnc(_prs_stack_peek(), _fnc)
}

function _prs_on_cb_open(    _top, _type, _code_lst) {
	_top = _prs_stack_peek()
	_type = ast_type_of(_top)
	if (AST_FNC() == _type) {
		_code_lst = ast_fnc_get_code_lst(_top)
	} else if (AST_CODE_LOOP() == _type) {
		_code_lst = ast_code_loop_get_code_lst(_top)
	} else if (AST_CODE_IF() == _type) {
		_code_lst = ast_code_if_get_code_lst(_top)
	} else if (AST_CODE_ELSE_IF() == _type) {
		_code_lst = ast_code_else_if_get_code_lst(_top)
	} else if (AST_CODE_ELSE() == _type) {
		_code_lst = ast_code_else_get_code_lst(_top)
	} else {
		ast_ent_errq("_prs_on_cb_open()", _top, _type)
	}
	_prs_stack_push(_code_lst)
}
function _prs_on_cb_close() {
	_prs_stack_pop()
}

function _prs_on_call() {
	_prs_stack_push(ast_code_call_make())
}
function _prs_on_call_esc() {
	ast_code_call_set_is_esc(_prs_stack_peek(), 1)
}

function _sync_call_set() {_B_prs_sync_call = 1}
function _prs_on_call_name(    _nm) {
	_nm = lex_get_curr_tok()
	if (NAME() == _nm)
		_nm = lex_get_name()
	if (IR_SYNC() == _nm)
		_sync_call_set()
	ast_code_call_set_fname(_prs_stack_peek(), _nm)
}
function _prs_on_call_arg() {
	ast_code_call_set_arg(_prs_stack_peek(), lex_get_name())
}
function _prs_on_call_end(    _call, _top, _type) {
	_call = _prs_stack_peek()
	_prs_stack_pop()
	_top = _prs_stack_peek()
	_type = ast_type_of(_top)
	if (AST_CODE_RET() == _type) {
		ast_code_ret_set_call(_top, _call)
	} else if (AST_CODE_IF() == _type) {
		ast_code_if_set_cond(_top, _call)
	} else if (AST_CODE_ELSE_IF() == _type) {
		ast_code_else_if_set_cond(_top, _call)
	} else if (AST_CODE_LST() == _type) {
		ast_code_lst_push_code_node(_top, ast_code_node_make(_call))
	} else {
		ast_ent_errq("_prs_on_call_end()", _top, _type)
	}
}

function _prs_on_return() {
	_prs_stack_push(ast_code_ret_make())
}
function _prs_on_ret_const() {
	ast_code_ret_set_const(_prs_stack_peek(), lex_get_curr_tok())
}
function _prs_on_return_end(    _ret) {
	_ret = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_ret))
}

function _prs_on_loop() {
	_prs_stack_push(ast_code_loop_create())
}
function _prs_on_loop_end(    _loop) {
	_loop = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_loop))
}

function _prs_on_continue() {
	ast_code_lst_push_code_node(_prs_stack_peek(), \
		ast_code_node_make(ast_code_continue_make()))
}

function _prs_on_if() {
	_prs_stack_push(ast_code_if_create())
}
function _prs_on_if_end(    _if) {
	_if = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_if))
}

function _prs_on_else_if() {
	_prs_stack_push(ast_code_else_if_create())
}
function _prs_on_else_if_end(    _elif) {
	_elif = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_elif))
}

function _prs_on_else() {
	_prs_stack_push(ast_code_else_create())
}
function _prs_on_else_end(    _else) {
	_else = _prs_stack_peek()
	_prs_stack_pop()
	ast_code_lst_push_code_node(_prs_stack_peek(), ast_code_node_make(_else))
}
# </process>
# </prs>
