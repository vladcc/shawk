# <parse>
#
# translated by rdpg-to-awk.awk 2.0.2
# generated by rdpg-comp.awk 2.0.2
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
