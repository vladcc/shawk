// <source>
#include "rdpg_parser.h"

// <decl>
// <prs>
static bool start(prs_ctx * prs);
static bool expr(prs_ctx * prs);
static bool expr_plus(prs_ctx * prs);
static bool expr_star(prs_ctx * prs);
static bool expr_add_sub(prs_ctx * prs);
static bool expr_add_sub_opt(prs_ctx * prs);
static bool add_sub(prs_ctx * prs);
static bool add_sub_star(prs_ctx * prs);
static bool expr_mul_div(prs_ctx * prs);
static bool mul_div(prs_ctx * prs);
static bool mul_div_star(prs_ctx * prs);
static bool expr_expon(prs_ctx * prs);
static bool expon(prs_ctx * prs);
static bool expon_opt(prs_ctx * prs);
static bool expr_base(prs_ctx * prs);
static bool base(prs_ctx * prs);
// </prs>

// <esc>
void on_expr_start(usr_ctx * usr);
void on_expr_end(usr_ctx * usr);
void on_add(usr_ctx * usr);
void on_sub(usr_ctx * usr);
void on_mul(usr_ctx * usr);
void on_div(usr_ctx * usr);
void on_pow(usr_ctx * usr);
void on_neg(usr_ctx * usr);
void on_number(usr_ctx * usr);
// </esc>
// </decl>

// generated by rdpg-comp.awk 2.1.1
// 
// Immediate error detection: 1
// 
// Grammar:
// 
// 1. start : expr_plus EOI
// 
// 2. expr : \on_expr_start expr_add_sub_opt SEMI \on_expr_end
// 
// 3. expr_plus : expr expr_star
// 
// 4. expr_star : expr expr_star
// 5. expr_star : 0
// 
// 6. expr_add_sub : expr_mul_div add_sub_star
// 
// 7. expr_add_sub_opt : expr_add_sub
// 8. expr_add_sub_opt : 0
// 
// 9. add_sub : PLUS expr_mul_div \on_add
// 10. add_sub : MINUS expr_mul_div \on_sub
// 
// 11. add_sub_star : add_sub add_sub_star
// 12. add_sub_star : 0
// 
// 13. expr_mul_div : expr_expon mul_div_star
// 
// 14. mul_div : MUL expr_expon \on_mul
// 15. mul_div : DIV expr_expon \on_div
// 
// 16. mul_div_star : mul_div mul_div_star
// 17. mul_div_star : 0
// 
// 18. expr_expon : expr_base expon_opt
// 
// 19. expon : POW expr_expon \on_pow
// 
// 20. expon_opt : expon
// 21. expon_opt : 0
// 
// 22. expr_base : MINUS base \on_neg
// 23. expr_base : base
// 
// 24. base : NUMBER \on_number
// 25. base : L_PAR expr_add_sub R_PAR
// 

// <internal-types>
#define TOK_ENONE ((tok_id)(-1))

typedef struct set {
	const tok_id * const data;
	const size_t len;
} set;

typedef struct pred_set {
	const set * const s;
} pred_set;

typedef struct exp_set {
	const set * const s;
} exp_set;

typedef struct sync_set {
	const set * const s;
} sync_set;

typedef struct prs_st {
	usr_ctx * usr;
	const exp_set * eset;
	tok_id etok[1];
	tok_id curr_tok;
	bool was_err;
} prs_st;

static inline void prs_st_set(prs_ctx * prs, prs_st * st)
{
	prs->ctx = (void *)st;
}

static inline prs_st * prs_st_get(prs_ctx * prs)
{
	return (prs_st *)(prs->ctx);
}
// </internal-types>

// <exported>
bool rdpg_parse(prs_ctx * prs, usr_ctx * usr)
{
	prs_st pst = {0};
	pst.usr = usr;
	prs_st_set(prs, &pst);
	return start(prs) && !(prs_st_get(prs)->was_err);
}

const tok_id * rdpg_expect(prs_ctx * prs, size_t * out_len)
{
	prs_st * pst = prs_st_get(prs);
	const set * const st = pst->eset->s;
	if (st)
	{
		*out_len = st->len;
		return st->data;
	}
	else
	{
		*out_len = 1;
		return pst->etok;
	}
}
// </exported>

// <io>
static inline void expect(prs_ctx * prs, const exp_set * eset, const tok_id etok)
{
	prs_st * pst = prs_st_get(prs);
	pst->was_err = true;
	pst->etok[0] = etok;
	pst->eset = eset;
	tok_err(pst->usr, prs);
}

static inline void rdpg_tok_next(prs_ctx * prs)
{
	prs_st * pst = prs_st_get(prs);
	pst->curr_tok = tok_next(pst->usr);
}

static inline bool rdpg_tok_is(prs_ctx * prs, const tok_id tk)
{
	return (tk == prs_st_get(prs)->curr_tok);
}

static inline bool rdpg_tok_match(prs_ctx * prs, const tok_id tk)
{
	bool is_match = rdpg_tok_is(prs, tk);
	if (is_match)
		rdpg_tok_next(prs);
	return is_match;
}
// </io>

// <sets>
static const tok_id set_1_d[4] = {SEMI, MINUS, NUMBER, L_PAR};
static const tok_id set_2_d[3] = {MINUS, NUMBER, L_PAR};
static const tok_id set_3_d[2] = {PLUS, MINUS};
static const tok_id set_4_d[2] = {SEMI, R_PAR};
static const tok_id set_5_d[2] = {MUL, DIV};
static const tok_id set_6_d[4] = {PLUS, MINUS, SEMI, R_PAR};
static const tok_id set_7_d[6] = {MUL, DIV, PLUS, MINUS, SEMI, R_PAR};
static const tok_id set_8_d[2] = {NUMBER, L_PAR};
static const tok_id set_9_d[5] = {SEMI, MINUS, NUMBER, L_PAR, EOI};
static const tok_id set_10_d[4] = {MINUS, NUMBER, L_PAR, SEMI};
static const tok_id set_11_d[7] = {POW, MUL, DIV, PLUS, MINUS, SEMI, R_PAR};
static const tok_id set_12_d[1] = {EOI};
static const tok_id set_13_d[1] = {SEMI};

static const set set_1_ = {set_1_d, 4};
static const set set_2_ = {set_2_d, 3};
static const set set_3_ = {set_3_d, 2};
static const set set_4_ = {set_4_d, 2};
static const set set_5_ = {set_5_d, 2};
static const set set_6_ = {set_6_d, 4};
static const set set_7_ = {set_7_d, 6};
static const set set_8_ = {set_8_d, 2};
static const set set_9_ = {set_9_d, 5};
static const set set_10_ = {set_10_d, 4};
static const set set_11_ = {set_11_d, 7};
static const set set_12_ = {set_12_d, 1};
static const set set_13_ = {set_13_d, 1};

static const set * const set_1 = &set_1_;
static const set * const set_2 = &set_2_;
static const set * const set_3 = &set_3_;
static const set * const set_4 = &set_4_;
static const set * const set_5 = &set_5_;
static const set * const set_6 = &set_6_;
static const set * const set_7 = &set_7_;
static const set * const set_8 = &set_8_;
static const set * const set_9 = &set_9_;
static const set * const set_10 = &set_10_;
static const set * const set_11 = &set_11_;
static const set * const set_12 = &set_12_;
static const set * const set_13 = &set_13_;

static const pred_set pset_start_1 = {set_1};
static const pred_set pset_expr_1 = {set_1};
static const pred_set pset_expr_plus_1 = {set_1};
static const pred_set pset_expr_star_1 = {set_1};
static const pred_set pset_expr_add_sub_1 = {set_2};
static const pred_set pset_expr_add_sub_opt_1 = {set_2};
static const pred_set pset_add_sub_star_1 = {set_3};
static const pred_set pset_add_sub_star_2 = {set_4};
static const pred_set pset_expr_mul_div_1 = {set_2};
static const pred_set pset_mul_div_star_1 = {set_5};
static const pred_set pset_mul_div_star_2 = {set_6};
static const pred_set pset_expr_expon_1 = {set_2};
static const pred_set pset_expon_opt_2 = {set_7};
static const pred_set pset_expr_base_2 = {set_8};

static const exp_set eset_none = {NULL};
static const exp_set eset_start = {set_1};
static const exp_set eset_expr = {set_1};
static const exp_set eset_expr_plus = {set_1};
static const exp_set eset_expr_star = {set_9};
static const exp_set eset_expr_add_sub = {set_2};
static const exp_set eset_expr_add_sub_opt = {set_10};
static const exp_set eset_add_sub = {set_3};
static const exp_set eset_add_sub_star = {set_6};
static const exp_set eset_expr_mul_div = {set_2};
static const exp_set eset_mul_div = {set_5};
static const exp_set eset_mul_div_star = {set_7};
static const exp_set eset_expr_expon = {set_2};
static const exp_set eset_expon_opt = {set_11};
static const exp_set eset_expr_base = {set_2};
static const exp_set eset_base = {set_8};

static const sync_set sset_expr = {set_9};
static const sync_set sset_expr_plus = {set_12};
static const sync_set sset_expr_star = {set_12};
static const sync_set sset_expr_add_sub = {set_4};
static const sync_set sset_expr_add_sub_opt = {set_13};
static const sync_set sset_add_sub = {set_6};
static const sync_set sset_add_sub_star = {set_4};
static const sync_set sset_expr_mul_div = {set_6};
static const sync_set sset_mul_div = {set_7};
static const sync_set sset_mul_div_star = {set_6};
static const sync_set sset_expr_expon = {set_7};
static const sync_set sset_expon = {set_7};
static const sync_set sset_expon_opt = {set_7};
static const sync_set sset_expr_base = {set_11};
static const sync_set sset_base = {set_11};

static bool is_in_set(const tok_id tk, const tok_id * data, size_t len)
{
	switch (len)
	{
		case 7: if (tk == data[6]) return true;
		case 6: if (tk == data[5]) return true;
		case 5: if (tk == data[4]) return true;
		case 4: if (tk == data[3]) return true;
		case 3: if (tk == data[2]) return true;
		case 2: if (tk == data[1]) return true;
		case 1: return (tk == data[0]);
		default: {
			// should not return
			err_crit("is_in_set(): bug in set size");
			break;
		}
	}
	return false;
}

static inline bool predict(prs_ctx * prs, const pred_set pset)
{
	return is_in_set(prs_st_get(prs)->curr_tok, pset.s->data, pset.s->len);
}

static bool sync(prs_ctx * prs, const sync_set sset)
{
	prs_st * pst = prs_st_get(prs);
	while (1)
	{
		if (is_in_set(pst->curr_tok, sset.s->data, sset.s->len))
			return true;
		rdpg_tok_next(prs);
		if (EOI == pst->curr_tok)
			break;
	}
	return false;
}
// </sets>

// <prs>
static bool start(prs_ctx * prs)
{
	// 1. start : expr_plus EOI

	rdpg_tok_next(prs);
	if (predict(prs, pset_start_1))
	{
		if (expr_plus(prs))
		{
			if (rdpg_tok_match(prs, EOI))
			{
				return true;
			}
			else
			{
				expect(prs, &eset_none, EOI);
			}
		}
	}
	else
	{
		expect(prs, &eset_start, TOK_ENONE);
	}
	return false;
}
static bool expr(prs_ctx * prs)
{
	// 2. expr : \on_expr_start expr_add_sub_opt SEMI \on_expr_end

	if (predict(prs, pset_expr_1))
	{
		on_expr_start(prs_st_get(prs)->usr);
		if (expr_add_sub_opt(prs))
		{
			if (rdpg_tok_is(prs, SEMI))
			{
				on_expr_end(prs_st_get(prs)->usr);
				rdpg_tok_next(prs);
				return true;
			}
			else
			{
				expect(prs, &eset_none, SEMI);
			}
		}
	}
	else
	{
		expect(prs, &eset_expr, TOK_ENONE);
	}
	return sync(prs, sset_expr);
}
static bool expr_plus(prs_ctx * prs)
{
	// 3. expr_plus : expr expr_star

	if (predict(prs, pset_expr_plus_1))
	{
		if (expr(prs))
		{
			if (expr_star(prs))
			{
				return true;
			}
		}
	}
	else
	{
		expect(prs, &eset_expr_plus, TOK_ENONE);
	}
	return sync(prs, sset_expr_plus);
}
static bool expr_star(prs_ctx * prs)
{
	// 4. expr_star : expr expr_star
	// 5. expr_star : 0

	while (1)
	{
		if (predict(prs, pset_expr_star_1))
		{
			if (expr(prs))
			{
				continue;
			}
		}
		else if (rdpg_tok_is(prs, EOI))
		{
			return true;
		}
		else
		{
			expect(prs, &eset_expr_star, TOK_ENONE);
		}
		return sync(prs, sset_expr_star);
	}
}
static bool expr_add_sub(prs_ctx * prs)
{
	// 6. expr_add_sub : expr_mul_div add_sub_star

	if (predict(prs, pset_expr_add_sub_1))
	{
		if (expr_mul_div(prs))
		{
			if (add_sub_star(prs))
			{
				return true;
			}
		}
	}
	else
	{
		expect(prs, &eset_expr_add_sub, TOK_ENONE);
	}
	return sync(prs, sset_expr_add_sub);
}
static bool expr_add_sub_opt(prs_ctx * prs)
{
	// 7. expr_add_sub_opt : expr_add_sub
	// 8. expr_add_sub_opt : 0

	if (predict(prs, pset_expr_add_sub_opt_1))
	{
		if (expr_add_sub(prs))
		{
			return true;
		}
	}
	else if (rdpg_tok_is(prs, SEMI))
	{
		return true;
	}
	else
	{
		expect(prs, &eset_expr_add_sub_opt, TOK_ENONE);
	}
	return sync(prs, sset_expr_add_sub_opt);
}
static bool add_sub(prs_ctx * prs)
{
	// 9. add_sub : PLUS expr_mul_div \on_add
	// 10. add_sub : MINUS expr_mul_div \on_sub

	if (rdpg_tok_match(prs, PLUS))
	{
		if (expr_mul_div(prs))
		{
			on_add(prs_st_get(prs)->usr);
			return true;
		}
	}
	else if (rdpg_tok_match(prs, MINUS))
	{
		if (expr_mul_div(prs))
		{
			on_sub(prs_st_get(prs)->usr);
			return true;
		}
	}
	else
	{
		expect(prs, &eset_add_sub, TOK_ENONE);
	}
	return sync(prs, sset_add_sub);
}
static bool add_sub_star(prs_ctx * prs)
{
	// 11. add_sub_star : add_sub add_sub_star
	// 12. add_sub_star : 0

	while (1)
	{
		if (predict(prs, pset_add_sub_star_1))
		{
			if (add_sub(prs))
			{
				continue;
			}
		}
		else if (predict(prs, pset_add_sub_star_2))
		{
			return true;
		}
		else
		{
			expect(prs, &eset_add_sub_star, TOK_ENONE);
		}
		return sync(prs, sset_add_sub_star);
	}
}
static bool expr_mul_div(prs_ctx * prs)
{
	// 13. expr_mul_div : expr_expon mul_div_star

	if (predict(prs, pset_expr_mul_div_1))
	{
		if (expr_expon(prs))
		{
			if (mul_div_star(prs))
			{
				return true;
			}
		}
	}
	else
	{
		expect(prs, &eset_expr_mul_div, TOK_ENONE);
	}
	return sync(prs, sset_expr_mul_div);
}
static bool mul_div(prs_ctx * prs)
{
	// 14. mul_div : MUL expr_expon \on_mul
	// 15. mul_div : DIV expr_expon \on_div

	if (rdpg_tok_match(prs, MUL))
	{
		if (expr_expon(prs))
		{
			on_mul(prs_st_get(prs)->usr);
			return true;
		}
	}
	else if (rdpg_tok_match(prs, DIV))
	{
		if (expr_expon(prs))
		{
			on_div(prs_st_get(prs)->usr);
			return true;
		}
	}
	else
	{
		expect(prs, &eset_mul_div, TOK_ENONE);
	}
	return sync(prs, sset_mul_div);
}
static bool mul_div_star(prs_ctx * prs)
{
	// 16. mul_div_star : mul_div mul_div_star
	// 17. mul_div_star : 0

	while (1)
	{
		if (predict(prs, pset_mul_div_star_1))
		{
			if (mul_div(prs))
			{
				continue;
			}
		}
		else if (predict(prs, pset_mul_div_star_2))
		{
			return true;
		}
		else
		{
			expect(prs, &eset_mul_div_star, TOK_ENONE);
		}
		return sync(prs, sset_mul_div_star);
	}
}
static bool expr_expon(prs_ctx * prs)
{
	// 18. expr_expon : expr_base expon_opt

	if (predict(prs, pset_expr_expon_1))
	{
		if (expr_base(prs))
		{
			if (expon_opt(prs))
			{
				return true;
			}
		}
	}
	else
	{
		expect(prs, &eset_expr_expon, TOK_ENONE);
	}
	return sync(prs, sset_expr_expon);
}
static bool expon(prs_ctx * prs)
{
	// 19. expon : POW expr_expon \on_pow

	if (rdpg_tok_match(prs, POW))
	{
		if (expr_expon(prs))
		{
			on_pow(prs_st_get(prs)->usr);
			return true;
		}
	}
	else
	{
		expect(prs, &eset_none, POW);
	}
	return sync(prs, sset_expon);
}
static bool expon_opt(prs_ctx * prs)
{
	// 20. expon_opt : expon
	// 21. expon_opt : 0

	if (rdpg_tok_is(prs, POW))
	{
		if (expon(prs))
		{
			return true;
		}
	}
	else if (predict(prs, pset_expon_opt_2))
	{
		return true;
	}
	else
	{
		expect(prs, &eset_expon_opt, TOK_ENONE);
	}
	return sync(prs, sset_expon_opt);
}
static bool expr_base(prs_ctx * prs)
{
	// 22. expr_base : MINUS base \on_neg
	// 23. expr_base : base

	if (rdpg_tok_match(prs, MINUS))
	{
		if (base(prs))
		{
			on_neg(prs_st_get(prs)->usr);
			return true;
		}
	}
	else if (predict(prs, pset_expr_base_2))
	{
		if (base(prs))
		{
			return true;
		}
	}
	else
	{
		expect(prs, &eset_expr_base, TOK_ENONE);
	}
	return sync(prs, sset_expr_base);
}
static bool base(prs_ctx * prs)
{
	// 24. base : NUMBER \on_number
	// 25. base : L_PAR expr_add_sub R_PAR

	if (rdpg_tok_is(prs, NUMBER))
	{
		on_number(prs_st_get(prs)->usr);
		rdpg_tok_next(prs);
		return true;
	}
	else if (rdpg_tok_match(prs, L_PAR))
	{
		if (expr_add_sub(prs))
		{
			if (rdpg_tok_match(prs, R_PAR))
			{
				return true;
			}
			else
			{
				expect(prs, &eset_none, R_PAR);
			}
		}
	}
	else
	{
		expect(prs, &eset_base, TOK_ENONE);
	}
	return sync(prs, sset_base);
}
// </prs>
// </source>
