# <parse>
#
# translated by rdpg-to-awk.awk 2.0.2
# generated by rdpg-comp.awk 2.1.0
# 
# Immediate error detection: 1
# 
# Grammar:
# 
# 1. start : expr_plus EOI
# 
# 2. expr : \on_expr_start expr_add_sub_opt SEMI \on_expr_end
# 
# 3. expr_plus : expr expr_star
# 
# 4. expr_star : expr expr_star
# 5. expr_star : 0
# 
# 6. expr_add_sub : expr_mul_div add_sub_star
# 
# 7. expr_add_sub_opt : expr_add_sub
# 8. expr_add_sub_opt : 0
# 
# 9. add_sub : PLUS expr_mul_div \on_add
# 10. add_sub : MINUS expr_mul_div \on_sub
# 
# 11. add_sub_star : add_sub add_sub_star
# 12. add_sub_star : 0
# 
# 13. expr_mul_div : expr_expon mul_div_star
# 
# 14. mul_div : MUL expr_expon \on_mul
# 15. mul_div : DIV expr_expon \on_div
# 
# 16. mul_div_star : mul_div mul_div_star
# 17. mul_div_star : 0
# 
# 18. expr_expon : expr_base expon_opt
# 
# 19. expon : POW expr_expon \on_pow
# 
# 20. expon_opt : expon
# 21. expon_opt : 0
# 
# 22. expr_base : MINUS base \on_neg
# 23. expr_base : base
# 
# 24. base : NUMBER \on_number
# 25. base : L_PAR expr_add_sub R_PAR
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
	_RDPG_B_str_sym_set_1 = (SEMI() _RDPG_SEP() MINUS() _RDPG_SEP() NUMBER() _RDPG_SEP() L_PAR())
	_RDPG_B_str_sym_set_2 = (MINUS() _RDPG_SEP() NUMBER() _RDPG_SEP() L_PAR())
	_RDPG_B_str_sym_set_3 = (PLUS() _RDPG_SEP() MINUS())
	_RDPG_B_str_sym_set_4 = (SEMI() _RDPG_SEP() R_PAR())
	_RDPG_B_str_sym_set_5 = (MUL() _RDPG_SEP() DIV())
	_RDPG_B_str_sym_set_6 = (PLUS() _RDPG_SEP() MINUS() _RDPG_SEP() SEMI() _RDPG_SEP() R_PAR())
	_RDPG_B_str_sym_set_7 = (MUL() _RDPG_SEP() DIV() _RDPG_SEP() PLUS() _RDPG_SEP() MINUS() _RDPG_SEP() SEMI() _RDPG_SEP() R_PAR())
	_RDPG_B_str_sym_set_8 = (NUMBER() _RDPG_SEP() L_PAR())
	_RDPG_B_str_sym_set_9 = (SEMI() _RDPG_SEP() MINUS() _RDPG_SEP() NUMBER() _RDPG_SEP() L_PAR() _RDPG_SEP() EOI())
	_RDPG_B_str_sym_set_10 = (MINUS() _RDPG_SEP() NUMBER() _RDPG_SEP() L_PAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_11 = (POW() _RDPG_SEP() MUL() _RDPG_SEP() DIV() _RDPG_SEP() PLUS() _RDPG_SEP() MINUS() _RDPG_SEP() SEMI() _RDPG_SEP() R_PAR())
	_RDPG_B_str_sym_set_12 = (EOI())
	_RDPG_B_str_sym_set_13 = (SEMI())

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

	# expect
	_RDPG_expect_sets["start"] = _RDPG_B_str_sym_set_1
	_RDPG_expect_sets["expr"] = _RDPG_B_str_sym_set_1
	_RDPG_expect_sets["expr_plus"] = _RDPG_B_str_sym_set_1
	_RDPG_expect_sets["expr_star"] = _RDPG_B_str_sym_set_9
	_RDPG_expect_sets["expr_add_sub"] = _RDPG_B_str_sym_set_2
	_RDPG_expect_sets["expr_add_sub_opt"] = _RDPG_B_str_sym_set_10
	_RDPG_expect_sets["add_sub"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["add_sub_star"] = _RDPG_B_str_sym_set_6
	_RDPG_expect_sets["expr_mul_div"] = _RDPG_B_str_sym_set_2
	_RDPG_expect_sets["mul_div"] = _RDPG_B_str_sym_set_5
	_RDPG_expect_sets["mul_div_star"] = _RDPG_B_str_sym_set_7
	_RDPG_expect_sets["expr_expon"] = _RDPG_B_str_sym_set_2
	_RDPG_expect_sets["expon_opt"] = _RDPG_B_str_sym_set_11
	_RDPG_expect_sets["expr_base"] = _RDPG_B_str_sym_set_2
	_RDPG_expect_sets["base"] = _RDPG_B_str_sym_set_8
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
	# 1. start : expr_plus EOI

	_rdpg_tok_next()
	if (_rdpg_predict(_RDPG_sym_set_1))
	{
		if (_rdpg_expr_plus())
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
function _rdpg_expr()
{
	# 2. expr : \on_expr_start expr_add_sub_opt SEMI \on_expr_end

	if (_rdpg_predict(_RDPG_sym_set_1))
	{
		on_expr_start()
		if (_rdpg_expr_add_sub_opt())
		{
			if (_rdpg_tok_is(SEMI()))
			{
				on_expr_end()
				_rdpg_tok_next()
				return 1
			}
			else
			{
				_rdpg_expect("tok", SEMI())
			}
		}
	}
	else
	{
		_rdpg_expect("set", "expr")
	}
	return _rdpg_sync(_RDPG_sym_set_9)
}
function _rdpg_expr_plus()
{
	# 3. expr_plus : expr expr_star

	if (_rdpg_predict(_RDPG_sym_set_1))
	{
		if (_rdpg_expr())
		{
			if (_rdpg_expr_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "expr_plus")
	}
	return _rdpg_sync(_RDPG_sym_set_12)
}
function _rdpg_expr_star()
{
	# 4. expr_star : expr expr_star
	# 5. expr_star : 0

	while (1)
	{
		if (_rdpg_predict(_RDPG_sym_set_1))
		{
			if (_rdpg_expr())
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
			_rdpg_expect("set", "expr_star")
		}
		return _rdpg_sync(_RDPG_sym_set_12)
	}
}
function _rdpg_expr_add_sub()
{
	# 6. expr_add_sub : expr_mul_div add_sub_star

	if (_rdpg_predict(_RDPG_sym_set_2))
	{
		if (_rdpg_expr_mul_div())
		{
			if (_rdpg_add_sub_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "expr_add_sub")
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_expr_add_sub_opt()
{
	# 7. expr_add_sub_opt : expr_add_sub
	# 8. expr_add_sub_opt : 0

	if (_rdpg_predict(_RDPG_sym_set_2))
	{
		if (_rdpg_expr_add_sub())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(SEMI()))
	{
		return 1
	}
	else
	{
		_rdpg_expect("set", "expr_add_sub_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_13)
}
function _rdpg_add_sub()
{
	# 9. add_sub : PLUS expr_mul_div \on_add
	# 10. add_sub : MINUS expr_mul_div \on_sub

	if (_rdpg_tok_match(PLUS()))
	{
		if (_rdpg_expr_mul_div())
		{
			on_add()
			return 1
		}
	}
	else if (_rdpg_tok_match(MINUS()))
	{
		if (_rdpg_expr_mul_div())
		{
			on_sub()
			return 1
		}
	}
	else
	{
		_rdpg_expect("set", "add_sub")
	}
	return _rdpg_sync(_RDPG_sym_set_6)
}
function _rdpg_add_sub_star()
{
	# 11. add_sub_star : add_sub add_sub_star
	# 12. add_sub_star : 0

	while (1)
	{
		if (_rdpg_predict(_RDPG_sym_set_3))
		{
			if (_rdpg_add_sub())
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
			_rdpg_expect("set", "add_sub_star")
		}
		return _rdpg_sync(_RDPG_sym_set_4)
	}
}
function _rdpg_expr_mul_div()
{
	# 13. expr_mul_div : expr_expon mul_div_star

	if (_rdpg_predict(_RDPG_sym_set_2))
	{
		if (_rdpg_expr_expon())
		{
			if (_rdpg_mul_div_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "expr_mul_div")
	}
	return _rdpg_sync(_RDPG_sym_set_6)
}
function _rdpg_mul_div()
{
	# 14. mul_div : MUL expr_expon \on_mul
	# 15. mul_div : DIV expr_expon \on_div

	if (_rdpg_tok_match(MUL()))
	{
		if (_rdpg_expr_expon())
		{
			on_mul()
			return 1
		}
	}
	else if (_rdpg_tok_match(DIV()))
	{
		if (_rdpg_expr_expon())
		{
			on_div()
			return 1
		}
	}
	else
	{
		_rdpg_expect("set", "mul_div")
	}
	return _rdpg_sync(_RDPG_sym_set_7)
}
function _rdpg_mul_div_star()
{
	# 16. mul_div_star : mul_div mul_div_star
	# 17. mul_div_star : 0

	while (1)
	{
		if (_rdpg_predict(_RDPG_sym_set_5))
		{
			if (_rdpg_mul_div())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_6))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "mul_div_star")
		}
		return _rdpg_sync(_RDPG_sym_set_6)
	}
}
function _rdpg_expr_expon()
{
	# 18. expr_expon : expr_base expon_opt

	if (_rdpg_predict(_RDPG_sym_set_2))
	{
		if (_rdpg_expr_base())
		{
			if (_rdpg_expon_opt())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "expr_expon")
	}
	return _rdpg_sync(_RDPG_sym_set_7)
}
function _rdpg_expon()
{
	# 19. expon : POW expr_expon \on_pow

	if (_rdpg_tok_match(POW()))
	{
		if (_rdpg_expr_expon())
		{
			on_pow()
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", POW())
	}
	return _rdpg_sync(_RDPG_sym_set_7)
}
function _rdpg_expon_opt()
{
	# 20. expon_opt : expon
	# 21. expon_opt : 0

	if (_rdpg_tok_is(POW()))
	{
		if (_rdpg_expon())
		{
			return 1
		}
	}
	else if (_rdpg_predict(_RDPG_sym_set_7))
	{
		return 1
	}
	else
	{
		_rdpg_expect("set", "expon_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_7)
}
function _rdpg_expr_base()
{
	# 22. expr_base : MINUS base \on_neg
	# 23. expr_base : base

	if (_rdpg_tok_match(MINUS()))
	{
		if (_rdpg_base())
		{
			on_neg()
			return 1
		}
	}
	else if (_rdpg_predict(_RDPG_sym_set_8))
	{
		if (_rdpg_base())
		{
			return 1
		}
	}
	else
	{
		_rdpg_expect("set", "expr_base")
	}
	return _rdpg_sync(_RDPG_sym_set_11)
}
function _rdpg_base()
{
	# 24. base : NUMBER \on_number
	# 25. base : L_PAR expr_add_sub R_PAR

	if (_rdpg_tok_is(NUMBER()))
	{
		on_number()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_match(L_PAR()))
	{
		if (_rdpg_expr_add_sub())
		{
			if (_rdpg_tok_match(R_PAR()))
			{
				return 1
			}
			else
			{
				_rdpg_expect("tok", R_PAR())
			}
		}
	}
	else
	{
		_rdpg_expect("set", "base")
	}
	return _rdpg_sync(_RDPG_sym_set_11)
}
# </rd>
# </parse>
