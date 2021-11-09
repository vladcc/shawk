#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// <expr_stack>
typedef struct stack {
	double data[128];
	int top;
} stack;
void stack_init(stack * stk)
{
	memset(stk, 0, sizeof(*stk));
}
void stack_push(stack * stk, int val)
{
	stk->data[stk->top++] = val;
}
int stack_pop(stack * stk)
{
	return stk->data[--stk->top];
}
// </expr_stack>

// <prs_state>
typedef struct prs_state {
	lex_state * lex;
	int error_reported_pos;
	bool stop_compute;
} prs_state;
void prs_init(prs_state * prs, lex_state * lex)
{
	memset(prs, 0, sizeof(*prs));
	prs->lex = lex;
}
void prs_set_stop_compute(prs_state * prs)
{
	prs->stop_compute = true;
}
bool prs_stop_compute(prs_state * prs)
{
	return prs->stop_compute;
}
void prs_set_error_reported(prs_state * prs, int pos)
{
	prs->error_reported_pos = pos;
}
int prs_get_error_reported(prs_state * prs)
{
	return prs->error_reported_pos;
}
// </prs_state>

// <usr_state>
typedef struct usr_state {
	stack * stk;
	bool neg_next;
} usr_state;
void usr_state_init(usr_state * ust, stack * stk)
{
	ust->stk = stk;
	ust->neg_next = false;
}
// </usr_state>

// <eval_functions>
void push_val(prs_state * prs, usr_state * usr)
{
	lex_state * lex = prs->lex;
	
	if (prs_stop_compute(prs))
		return;
		
	double num = lex_get_number(lex);
	if (usr->neg_next)
	{
		num = -num;
		usr->neg_next = false;
	}
	stack_push(usr->stk, num);
}

#define print_arith_(op, a, b, res)\
printf("%.2f " op " %.2f = %.2f\n", a, b, res)
#define print_arith(op) print_arith_(op, a, b, res)

void add(prs_state * prs, usr_state * usr)
{
	if (prs_stop_compute(prs))
		return;
		
	stack * stk = usr->stk;
	double b = stack_pop(stk);
	double a = stack_pop(stk);
	double res = a+b;
	print_arith("+");
	stack_push(stk, res);
}

void subt(prs_state * prs, usr_state * usr)
{
	if (prs_stop_compute(prs))
		return;
		
	stack * stk = usr->stk;
	double b = stack_pop(stk);
	double a = stack_pop(stk);
	double res = a-b;
	print_arith("-");
	stack_push(stk, res);
}

void mult(prs_state * prs, usr_state * usr)
{
	if (prs_stop_compute(prs))
		return;
		
	stack * stk = usr->stk;
	double b = stack_pop(stk);
	double a = stack_pop(stk);
	double res = a*b;
	print_arith("*");
	stack_push(stk, res);
}

void divd(prs_state * prs, usr_state * usr)
{
	if (prs_stop_compute(prs))
		return;
		
	stack * stk = usr->stk;
	double b = stack_pop(stk);
	double a = stack_pop(stk);
	double res = a/b;
	print_arith("/");
	stack_push(stk, res);
}

void power(prs_state * prs, usr_state * usr)
{
	if (prs_stop_compute(prs))
		return;
		
	stack * stk = usr->stk;
	double b = stack_pop(stk);
	double a = stack_pop(stk);
	double res = pow(a, b);
	print_arith("^");
	stack_push(stk, res);
}

void neg(prs_state * prs, usr_state * usr)
{
	if (prs_stop_compute(prs))
		return;
		
	usr->neg_next = true;
}

#define new_line(lex, usr) putchar('\n')
// </eval_functions>

// <error_handling>
bool sync(prs_state * prs, usr_state * usr, token tok)
{
	lex_state * lex = prs->lex;
	
	token next = lex_tok_next(lex);
	while (next != tok && next != EOI)
		next = lex_tok_next(lex);
	
	if (EOI == next)
	{
		printf("error: couldn't synchronize on '%s'\n", lex_tok_to_str(tok));
		return false;
	}
	
	lex_tok_next(lex);
	return (next == tok);
}

void tok_err_exp(prs_state * prs, int count, ...)
{	
	lex_state * lex = prs->lex;
	
	int err_pos = lex_get_line_pos(lex);
	if (prs_get_error_reported(prs) == err_pos)
		return;
		
	prs_set_stop_compute(prs);
	prs_set_error_reported(prs, err_pos);
	
	printf("error: expected ");
	
	va_list alist;
	va_start(alist, count);
	for (int i = 0; i < count; ++i)
		printf("'%s', ", lex_tok_to_str(va_arg(alist, token)));
	va_end(alist);
	
	printf("got '%s' instead\n", lex_tok_to_str(lex_get_token(lex)));
	
	printf("%s\n", lex_get_line(lex));
	for (int i = 0, end = lex_get_line_pos(lex)-1; i < end; ++i)
		printf("%c", ' ');
	printf("%c\n", '^');
}
// </error_handling>

// <parse>
#define tok_next(pprs)    lex_tok_next(pprs->lex)
#define tok_match(pprs, tok)   lex_tok_match(pprs->lex, tok)
// </parse>

bool parse_file(const char * fname)
{
#define BSZ 1023
	static char buff[BSZ+1];
	
	FILE * fp = fopen(fname, "r");
	if (!fp)
	{
		printf("error: fopen(%s, \"r\") failed\n", fname);
		exit(EXIT_FAILURE);
	}
	
	prs_state prs_, * prs = &prs_;
	lex_state lex_, * lex = &lex_;
	stack stk_, * stk = &stk_;
	usr_state ust_, * ust = &ust_;
	
	int i = 0;
	while (fgets(buff, BSZ+1, fp))
	{
		++i;
		
		if ('#' == buff[0] || '\n' == buff[0])
			continue;
			
		prs_init(prs, lex);
		lex_init(lex, buff);
		stack_init(stk);
		usr_state_init(ust, stk);
		
		puts(buff);
		if (!parse(prs, ust))
			printf("error: file '%s', line %d\n", fname, i);
		else
			putchar('\n');
	}
	
	return prs_stop_compute(prs);
#undef BSZ
}

int main(int argc, char * argv[])
{
	if (argc < 2)
	{
		printf("Use: %s <file>\n", argv[0]);
		exit(EXIT_FAILURE);
	}
	
	return parse_file(argv[1]);
}
