#include "rdpg_parser.h"
#include "rdpg_parser_foo.h"

#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

// <lexer>
typedef enum tok_id tok_id;

typedef struct lexer {
	const char * fname;
	char * str;
	FILE * fp;
	int line;
	int pos;
	int number;
	tok_id curr;
	tok_id prev;
	bool err;
} lexer;

#define BUFF_SZ 1024

static const char * lex_to_str(tok_id tk)
{
	const char * tok_str[] = {
		"none", "(", ")", "number", "^", "/", "*", "-", "+", ";", "eoi", "err",
	};

	return tok_str[(unsigned)tk];
}

static const char * lex_next_line(lexer * lex)
{
	const char * r = fgets(lex->str, BUFF_SZ, lex->fp);
	if (r)
	{
		++lex->line;
		lex->pos = 0;
	}
	else
	{
		// EOF pos for testing
		++lex->line;
		lex->pos=1;
		*lex->str = '\0';
	}
	return r;
}

static void lex_init(lexer * lex, const char * fname, FILE * fp)
{
	static lexer slx = {0};
	static char buff[BUFF_SZ] = {0};

	*lex = slx;
	lex->fname = fname;
	lex->str = buff;
	lex->fp = fp;
	lex_next_line(lex);
}

static char lex_curr_ch(lexer * lex)
{
	return lex->str[lex->pos];
}
static void lex_adv_ch(lexer * lex)
{
	++lex->pos;
}

static tok_id lex_next(lexer * lex)
{
	tok_id ret = ERR;
	while (true)
	{
		int ch = lex_curr_ch(lex);
		switch (ch)
		{
			case ' ':
			case '\t':
				lex_adv_ch(lex);
				continue;
			case '\n':
				if (lex_next_line(lex))
					continue;
				else
				{
					ret = EOI;
					goto out;
				}
			case '\0': ret = EOI; goto next;
			case '+': ret = PLUS; goto next;
			case '-': ret = MINUS; goto next;
			case '*': ret = MUL; goto next;
			case '/': ret = DIV; goto next;
			case '^': ret = POW; goto next;
			case '(': ret = L_PAR; goto next;
			case ')': ret = R_PAR; goto next;
			case ';': ret = SEMI; goto next;
			default:
			{
				if (isdigit(ch))
				{
					char buff[BUFF_SZ];

					int i = 0;
					do
					{
						buff[i++] = ch;
						lex_adv_ch(lex);
						ch = lex_curr_ch(lex);
					} while (isdigit(ch));

					buff[i] = '\0';
					sscanf(buff, "%d", &(lex->number));

					ret = NUMBER;
					goto out;
				}
				fprintf(stderr, "error: unknown char '%c'\n", ch);
				exit(EXIT_FAILURE);
			}
		}
	}

next:
	lex_adv_ch(lex);
out:
	lex->prev = lex->curr;
	return (lex->curr = ret);
}
// </lexer>

#define MAX_NODES 1024

// <btree>
typedef struct btr_node {
	tok_id type;
	int num;
	struct btr_node * left;
	struct btr_node * right;
} btr_node;

typedef struct btree {
	btr_node * node_pool;
	int node_num;
} btree;

btree * btree_(void)
{
	static btr_node nodes[MAX_NODES] = {0};
	static btree btr = {nodes, 0};
	return &btr;
}

btr_node * btr_node_new(void)
{
	btree * btr = btree_();

	if (MAX_NODES == btr->node_num)
	{
		fprintf(stderr, "%s", "error: no more btree nodes\n");
		exit(EXIT_FAILURE);
	}

	return &(btr->node_pool[btr->node_num++]);
}

void btr_eval_print(btr_node * node)
{
	if (!node)
		return;

	btr_node * left = NULL;
	btr_node * right = NULL;

	if (node->type != NUMBER)
	{
		left = node->left;
		right = node->right;
	}

	if (left)
		putchar('(');
	btr_eval_print(left);
	if (node->type != NUMBER)
		printf("%s", lex_to_str(node->type));
	else
		printf("%d", node->num);
	btr_eval_print(right);
	if (right)
		putchar(')');
}

int int_pow(int base, int expon)
{
	int res = 1;
	for (int i = 0; i < expon; ++i)
		res *= base;
	return res;
}

int btr_eval_expr(btr_node * node)
{
	if (!node)
		return 0;

	if (NUMBER == node->type)
		return node->num;

	int a = btr_eval_expr(node->left);
	int b = btr_eval_expr(node->right);
	int res = 0;

	switch (node->type)
	{
		case PLUS: res = a + b; break;
		case MINUS: res = a - b; break;
		case MUL: res = a * b; break;
		case DIV: res = a / b; break;
		case POW: res = int_pow(a, b); break;
		default: break;
	}

	printf("%d %s %d = %d\n", a, lex_to_str(node->type), b, res);
	return res;
}

void btr_eval(btr_node * node)
{
	if (!node)
		return;

	puts("Expr:");
	btr_eval_print(node);
	putchar('\n');
	puts("Eval:");
	int res = btr_eval_expr(node);
	puts("Result:");
	printf("%d\n", res);
	putchar('\n');
}
// </btree>

// <root_lst>
typedef struct root_lst {
	btr_node ** nodes;
	int len;
} root_lst;

root_lst * root_lst_get(void)
{
	static btr_node * pool[MAX_NODES] = {0};
	static root_lst rlst = {pool, 0};
	return &rlst;
}

void root_lst_push(btr_node * node)
{
	root_lst * rlst = root_lst_get();
	if (MAX_NODES == rlst->len)
	{
		fprintf(stderr, "%s", "error: no more btree nodes\n");
		exit(EXIT_FAILURE);
	}
	rlst->nodes[rlst->len++] = node;
}
// </root_lst>

// <stack>
typedef struct stack {
	btr_node ** stk;
	int top;
} stack;

stack * stack_(void)
{
	static btr_node * stk_pool[MAX_NODES];
	static stack stk = {stk_pool, 0};
	return &stk;
}

void stack_reset(void)
{
	stack_()->top = 0;
}

void stack_push(btr_node * node)
{
	stack * stk = stack_();

	if (MAX_NODES == stk->top)
	{
		fprintf(stderr, "%s", "error: no more stack space\n");
		exit(EXIT_FAILURE);
	}

	stk->stk[stk->top++] = node;
}
btr_node * stack_peek(void)
{
	stack * stk = stack_();
	return stk->stk[stk->top-1];
}
void stack_pop(void)
{
	--stack_()->top;
}
// </stack>

// <esc>
static lexer * ctx_lex(usr_ctx * ctx)
{
	return (lexer *)(ctx->ctx);
}

typedef enum act {
	ON_START, ON_END,
	ON_ADD, ON_SUB, ON_MUL, ON_DIV, ON_POW, ON_NEG,
	ON_NUMBER,
} act;

void do_op_bin(tok_id op)
{
	btr_node * node = btr_node_new();
	node->type = op;
	node->right = stack_peek();
	stack_pop();
	node->left = stack_peek();
	stack_pop();
	stack_push(node);
}

void do_act(usr_ctx * usr, act what)
{
	lexer * lex = ctx_lex(usr);
	if (lex->err)
		return;

	switch (what)
	{
		case ON_START: {
			stack_reset();
		} break;
		case ON_END: {
			root_lst_push(stack_peek());
			stack_pop();
		} break;
		case ON_ADD: {
			do_op_bin(PLUS);
		} break;
		case ON_SUB: {
			do_op_bin(MINUS);
		} break;
		case ON_MUL: {
			do_op_bin(MUL);
		} break;
		case ON_DIV: {
			do_op_bin(DIV);
		} break;
		case ON_POW: {
			do_op_bin(POW);
		} break;
		case ON_NEG: {
			btr_node * r = stack_peek();
			stack_pop();
			btr_node * zero = btr_node_new();
			zero->type = NUMBER;
			zero->num = 0;
			stack_push(zero);
			stack_push(r);
			do_act(usr, ON_SUB);
		} break;
		case ON_NUMBER: {
			btr_node * node = btr_node_new();
			node->type = NUMBER;
			node->num = lex->number;
			stack_push(node);
		} break;
		default: {
			fprintf(stderr, "error: do_act(): unknown action %d\n", what);
			exit(EXIT_FAILURE);
		} break;
	}
}

void on_expr_start(usr_ctx * usr) {do_act(usr, ON_START);}
void on_expr_end(usr_ctx * usr) {do_act(usr, ON_END);}
void on_add(usr_ctx * usr) {do_act(usr, ON_ADD);}
void on_sub(usr_ctx * usr) {do_act(usr, ON_SUB);}
void on_mul(usr_ctx * usr) {do_act(usr, ON_MUL);}
void on_div(usr_ctx * usr) {do_act(usr, ON_DIV);}
void on_pow(usr_ctx * usr) {do_act(usr, ON_POW);}
void on_neg(usr_ctx * usr) {do_act(usr, ON_NEG);}
void on_number(usr_ctx * usr) {do_act(usr, ON_NUMBER);}
// </esc>

// <callbacks>
void err_crit(const char * msg)
{
	fprintf(stderr, "error: critical: %s\n", msg);
	exit(EXIT_FAILURE);
}
void tok_err(usr_ctx * usr, prs_ctx * prs)
{
	lexer * lex = ctx_lex(usr);

	lex->err = true;

	fprintf(stderr, "file %s, line %d, pos %d: unexpected '%s'",
		lex->fname, lex->line, lex->pos, lex_to_str(lex->curr));

	tok_id prev = lex->prev;
	if (prev != NONE)
		fprintf(stderr, " after '%s'", lex_to_str(prev));
	fprintf(stderr, "%s", "\n");

	fprintf(stderr, "%s", lex->str);
	int end = lex->pos-1, ch = 0;
	for (int i = 0; i < end; ++i)
	{
		ch = lex->str[i];
		fprintf(stderr, "%c", isspace(ch) ? ch : ' ');
	}

	if (*lex->str)
		fprintf(stderr, "%c\n", '^');

	size_t exp_size = 0;
	const tok_id * exp = rdpg_expect(prs, &exp_size);

	if (1 == exp_size)
		fprintf(stderr, "expected: '%s'", lex_to_str(exp[0]));
	else if (exp_size > 1)
	{
		fprintf(stderr, "%s", "expected one of:");
		for (size_t i = 0; i < exp_size; ++i)
			fprintf(stderr, " '%s'", lex_to_str(exp[i]));
	}
	fprintf(stderr, "%c\n", '\n');
}
tok_id tok_next(usr_ctx * usr)
{
	return lex_next((lexer *)(usr->ctx));
}
// </callbacks>

#ifdef COMPILE_FOO
// <foo>
static lexer * ctx_lex_foo(usr_ctx_foo * ctx)
{
	return (lexer *)(ctx->ctx);
}

void err_crit_foo(const char * msg)
{
	err_crit(msg);
}
void tok_err_foo(usr_ctx_foo * usr, prs_ctx_foo * prs)
{
	lexer * lex = ctx_lex_foo(usr);

	lex->err = true;

	fprintf(stderr, "file %s, line %d, pos %d: unexpected '%s'",
		lex->fname, lex->line, lex->pos, lex_to_str(lex->curr));

	tok_id_foo prev = lex->prev;
	if (prev != NONE_FOO)
		fprintf(stderr, " after '%s'", lex_to_str(prev));
	fprintf(stderr, "%s", "\n");

	fprintf(stderr, "%s", lex->str);
	int end = lex->pos-1, ch = 0;
	for (int i = 0; i < end; ++i)
	{
		ch = lex->str[i];
		fprintf(stderr, "%c", isspace(ch) ? ch : ' ');
	}
	fprintf(stderr, "%c\n", '^');

	size_t exp_size = 0;
	const tok_id_foo * exp = rdpg_expect_foo(prs, &exp_size);

	if (1 == exp_size)
		fprintf(stderr, "expected: %s", lex_to_str(exp[0]));
	else if (exp_size > 1)
	{
		fprintf(stderr, "%s", "expected one of:");
		for (size_t i = 0; i < exp_size; ++i)
			fprintf(stderr, " %s", lex_to_str(exp[i]));
	}
	fprintf(stderr, "%c", '\n');
}
tok_id_foo tok_next_foo(usr_ctx_foo * usr)
{
	// hack
	return (tok_id_foo)lex_next((lexer *)(usr->ctx));
}
// </foo>
#endif

void exprs_process(void)
{
	root_lst * rlst = root_lst_get();
	for (int i = 0; i < rlst->len; ++i)
		btr_eval(rlst->nodes[i]);
}

int main(int argc, char * argv[])
{
	lexer lex_, * lex = &lex_;
	const char * fname = argv[1];

	FILE * fp = fopen(fname, "r");
	if (!fp)
	{
		fprintf(stderr, "fopen(): %s: %s\n", fname, strerror(errno));
		exit(EXIT_FAILURE);
	}

	lex_init(lex, fname, fp);
	usr_ctx usr = {(void *)lex};
	prs_ctx prs = {0};

	int res = EXIT_FAILURE;
	if (rdpg_parse(&prs, &usr))
	{
		exprs_process();
		res = EXIT_SUCCESS;
	}

	fclose(fp);
	return res;
}
