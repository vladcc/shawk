# <parse>
#
# translated by rdpg-to-awk.awk 2.0.1
# generated by rdpg-comp.awk 2.0.1
# 
# Grammar:
# 
# 1. start : grmr_defn_opt TOK_EOI
# 
# 2. grmr_defn : start_defn lhs_defn_plus
# 
# 3. grmr_defn_opt : grmr_defn
# 4. grmr_defn_opt : 0
# 
# 5. start_defn : START_SYM COLON NONT \on_top_sym nont_mod_opt TERM \on_eoi_term SEMI
# 
# 6. lhs_defn : NONT \on_lhs_start COLON rule bar_rule_star SEMI
# 
# 7. lhs_defn_plus : lhs_defn lhs_defn_star
# 
# 8. lhs_defn_star : lhs_defn lhs_defn_star
# 9. lhs_defn_star : 0
# 
# 10. rule : \on_rule_start esc_star sym_plus
# 
# 11. bar_rule : BAR rule
# 
# 12. bar_rule_star : bar_rule bar_rule_star
# 13. bar_rule_star : 0
# 
# 14. sym : grmr_sym esc_star
# 
# 15. sym_plus : sym sym_star
# 
# 16. sym_star : sym sym_star
# 17. sym_star : 0
# 
# 18. esc : ESC NONT \on_esc
# 
# 19. esc_star : esc esc_star
# 20. esc_star : 0
# 
# 21. grmr_sym : TERM \on_term
# 22. grmr_sym : NONT \on_nont nont_mod_opt
# 
# 23. nont_mod : QMARK \on_qmark
# 24. nont_mod : STAR \on_star
# 25. nont_mod : PLUS \on_plus
# 
# 26. nont_mod_opt : nont_mod
# 27. nont_mod_opt : 0
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
	tok_next()
	_RDPG_curr_tok = tok_curr()
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
	_RDPG_B_str_sym_set_1 = (TOK_EOI() _RDPG_SEP() START_SYM())
	_RDPG_B_str_sym_set_2 = (ESC() _RDPG_SEP() TERM() _RDPG_SEP() NONT())
	_RDPG_B_str_sym_set_3 = (TERM() _RDPG_SEP() NONT())
	_RDPG_B_str_sym_set_4 = (BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_5 = (TERM() _RDPG_SEP() NONT() _RDPG_SEP() BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_6 = (QMARK() _RDPG_SEP() STAR() _RDPG_SEP() PLUS())
	_RDPG_B_str_sym_set_7 = (TERM() _RDPG_SEP() ESC() _RDPG_SEP() NONT() _RDPG_SEP() BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_8 = (START_SYM() _RDPG_SEP() TOK_EOI())
	_RDPG_B_str_sym_set_9 = (NONT() _RDPG_SEP() TOK_EOI())
	_RDPG_B_str_sym_set_10 = (ESC() _RDPG_SEP() TERM() _RDPG_SEP() NONT() _RDPG_SEP() BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_11 = (QMARK() _RDPG_SEP() STAR() _RDPG_SEP() PLUS() _RDPG_SEP() TERM() _RDPG_SEP() ESC() _RDPG_SEP() NONT() _RDPG_SEP() BAR() _RDPG_SEP() SEMI())
	_RDPG_B_str_sym_set_12 = (TOK_EOI())
	_RDPG_B_str_sym_set_13 = (NONT())
	_RDPG_B_str_sym_set_14 = (SEMI())

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

	# expect
	_RDPG_expect_sets["start"] = _RDPG_B_str_sym_set_1
	_RDPG_expect_sets["grmr_defn_opt"] = _RDPG_B_str_sym_set_8
	_RDPG_expect_sets["lhs_defn_star"] = _RDPG_B_str_sym_set_9
	_RDPG_expect_sets["rule"] = _RDPG_B_str_sym_set_2
	_RDPG_expect_sets["bar_rule_star"] = _RDPG_B_str_sym_set_4
	_RDPG_expect_sets["sym"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["sym_plus"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["sym_star"] = _RDPG_B_str_sym_set_5
	_RDPG_expect_sets["esc_star"] = _RDPG_B_str_sym_set_10
	_RDPG_expect_sets["grmr_sym"] = _RDPG_B_str_sym_set_3
	_RDPG_expect_sets["nont_mod"] = _RDPG_B_str_sym_set_6
	_RDPG_expect_sets["nont_mod_opt"] = _RDPG_B_str_sym_set_11
}
function _rdpg_predict(set) {
	return (_RDPG_curr_tok in set)
}
function _rdpg_sync(set) {
	while (_RDPG_curr_tok) {
		if (_RDPG_curr_tok in set)
			return 1
		if (_rdpg_tok_is(TOK_EOI()))
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
	# 1. start : grmr_defn_opt TOK_EOI

	_rdpg_tok_next()
	if (_rdpg_predict(_RDPG_sym_set_1))
	{
		if (_rdpg_grmr_defn_opt())
		{
			if (_rdpg_tok_match(TOK_EOI()))
			{
				return 1
			}
			else
			{
				_rdpg_expect("tok", TOK_EOI())
			}
		}
	}
	else
	{
		_rdpg_expect("set", "start")
	}
	return 0
}
function _rdpg_grmr_defn()
{
	# 2. grmr_defn : start_defn lhs_defn_plus

	if (_rdpg_tok_is(START_SYM()))
	{
		if (_rdpg_start_defn())
		{
			if (_rdpg_lhs_defn_plus())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", START_SYM())
	}
	return _rdpg_sync(_RDPG_sym_set_12)
}
function _rdpg_grmr_defn_opt()
{
	# 3. grmr_defn_opt : grmr_defn
	# 4. grmr_defn_opt : 0

	if (_rdpg_tok_is(START_SYM()))
	{
		if (_rdpg_grmr_defn())
		{
			return 1
		}
	}
	else if (_rdpg_tok_is(TOK_EOI()))
	{
		return 1
	}
	else
	{
		_rdpg_expect("set", "grmr_defn_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_12)
}
function _rdpg_start_defn()
{
	# 5. start_defn : START_SYM COLON NONT \on_top_sym nont_mod_opt TERM \on_eoi_term SEMI

	if (_rdpg_tok_match(START_SYM()))
	{
		if (_rdpg_tok_match(COLON()))
		{
			if (_rdpg_tok_is(NONT()))
			{
				on_top_sym()
				_rdpg_tok_next()
				if (_rdpg_nont_mod_opt())
				{
					if (_rdpg_tok_is(TERM()))
					{
						on_eoi_term()
						_rdpg_tok_next()
						if (_rdpg_tok_match(SEMI()))
						{
							return 1
						}
						else
						{
							_rdpg_expect("tok", SEMI())
						}
					}
					else
					{
						_rdpg_expect("tok", TERM())
					}
				}
			}
			else
			{
				_rdpg_expect("tok", NONT())
			}
		}
		else
		{
			_rdpg_expect("tok", COLON())
		}
	}
	else
	{
		_rdpg_expect("tok", START_SYM())
	}
	return _rdpg_sync(_RDPG_sym_set_13)
}
function _rdpg_lhs_defn()
{
	# 6. lhs_defn : NONT \on_lhs_start COLON rule bar_rule_star SEMI

	if (_rdpg_tok_is(NONT()))
	{
		on_lhs_start()
		_rdpg_tok_next()
		if (_rdpg_tok_match(COLON()))
		{
			if (_rdpg_rule())
			{
				if (_rdpg_bar_rule_star())
				{
					if (_rdpg_tok_match(SEMI()))
					{
						return 1
					}
					else
					{
						_rdpg_expect("tok", SEMI())
					}
				}
			}
		}
		else
		{
			_rdpg_expect("tok", COLON())
		}
	}
	else
	{
		_rdpg_expect("tok", NONT())
	}
	return _rdpg_sync(_RDPG_sym_set_9)
}
function _rdpg_lhs_defn_plus()
{
	# 7. lhs_defn_plus : lhs_defn lhs_defn_star

	if (_rdpg_tok_is(NONT()))
	{
		if (_rdpg_lhs_defn())
		{
			if (_rdpg_lhs_defn_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("tok", NONT())
	}
	return _rdpg_sync(_RDPG_sym_set_12)
}
function _rdpg_lhs_defn_star()
{
	# 8. lhs_defn_star : lhs_defn lhs_defn_star
	# 9. lhs_defn_star : 0

	while (1)
	{
		if (_rdpg_tok_is(NONT()))
		{
			if (_rdpg_lhs_defn())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(TOK_EOI()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "lhs_defn_star")
		}
		return _rdpg_sync(_RDPG_sym_set_12)
	}
}
function _rdpg_rule()
{
	# 10. rule : \on_rule_start esc_star sym_plus

	if (_rdpg_predict(_RDPG_sym_set_2))
	{
		on_rule_start()
		if (_rdpg_esc_star())
		{
			if (_rdpg_sym_plus())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "rule")
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_bar_rule()
{
	# 11. bar_rule : BAR rule

	if (_rdpg_tok_match(BAR()))
	{
		if (_rdpg_rule())
		{
			return 1
		}
	}
	else
	{
		_rdpg_expect("tok", BAR())
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_bar_rule_star()
{
	# 12. bar_rule_star : bar_rule bar_rule_star
	# 13. bar_rule_star : 0

	while (1)
	{
		if (_rdpg_tok_is(BAR()))
		{
			if (_rdpg_bar_rule())
			{
				continue
			}
		}
		else if (_rdpg_tok_is(SEMI()))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "bar_rule_star")
		}
		return _rdpg_sync(_RDPG_sym_set_14)
	}
}
function _rdpg_sym()
{
	# 14. sym : grmr_sym esc_star

	if (_rdpg_predict(_RDPG_sym_set_3))
	{
		if (_rdpg_grmr_sym())
		{
			if (_rdpg_esc_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "sym")
	}
	return _rdpg_sync(_RDPG_sym_set_5)
}
function _rdpg_sym_plus()
{
	# 15. sym_plus : sym sym_star

	if (_rdpg_predict(_RDPG_sym_set_3))
	{
		if (_rdpg_sym())
		{
			if (_rdpg_sym_star())
			{
				return 1
			}
		}
	}
	else
	{
		_rdpg_expect("set", "sym_plus")
	}
	return _rdpg_sync(_RDPG_sym_set_4)
}
function _rdpg_sym_star()
{
	# 16. sym_star : sym sym_star
	# 17. sym_star : 0

	while (1)
	{
		if (_rdpg_predict(_RDPG_sym_set_3))
		{
			if (_rdpg_sym())
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
			_rdpg_expect("set", "sym_star")
		}
		return _rdpg_sync(_RDPG_sym_set_4)
	}
}
function _rdpg_esc()
{
	# 18. esc : ESC NONT \on_esc

	if (_rdpg_tok_match(ESC()))
	{
		if (_rdpg_tok_is(NONT()))
		{
			on_esc()
			_rdpg_tok_next()
			return 1
		}
		else
		{
			_rdpg_expect("tok", NONT())
		}
	}
	else
	{
		_rdpg_expect("tok", ESC())
	}
	return _rdpg_sync(_RDPG_sym_set_10)
}
function _rdpg_esc_star()
{
	# 19. esc_star : esc esc_star
	# 20. esc_star : 0

	while (1)
	{
		if (_rdpg_tok_is(ESC()))
		{
			if (_rdpg_esc())
			{
				continue
			}
		}
		else if (_rdpg_predict(_RDPG_sym_set_5))
		{
			return 1
		}
		else
		{
			_rdpg_expect("set", "esc_star")
		}
		return _rdpg_sync(_RDPG_sym_set_5)
	}
}
function _rdpg_grmr_sym()
{
	# 21. grmr_sym : TERM \on_term
	# 22. grmr_sym : NONT \on_nont nont_mod_opt

	if (_rdpg_tok_is(TERM()))
	{
		on_term()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(NONT()))
	{
		on_nont()
		_rdpg_tok_next()
		if (_rdpg_nont_mod_opt())
		{
			return 1
		}
	}
	else
	{
		_rdpg_expect("set", "grmr_sym")
	}
	return _rdpg_sync(_RDPG_sym_set_10)
}
function _rdpg_nont_mod()
{
	# 23. nont_mod : QMARK \on_qmark
	# 24. nont_mod : STAR \on_star
	# 25. nont_mod : PLUS \on_plus

	if (_rdpg_tok_is(QMARK()))
	{
		on_qmark()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(STAR()))
	{
		on_star()
		_rdpg_tok_next()
		return 1
	}
	else if (_rdpg_tok_is(PLUS()))
	{
		on_plus()
		_rdpg_tok_next()
		return 1
	}
	else
	{
		_rdpg_expect("set", "nont_mod")
	}
	return _rdpg_sync(_RDPG_sym_set_7)
}
function _rdpg_nont_mod_opt()
{
	# 26. nont_mod_opt : nont_mod
	# 27. nont_mod_opt : 0

	if (_rdpg_predict(_RDPG_sym_set_6))
	{
		if (_rdpg_nont_mod())
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
		_rdpg_expect("set", "nont_mod_opt")
	}
	return _rdpg_sync(_RDPG_sym_set_7)
}
# </rd>
# </parse>
