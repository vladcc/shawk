function usr_sync_past_semi(    _tok, _ret) {
    while (1) {
        _tok = tok_curr()
        if (SEMI() == _tok) {
            tok_next()
            _ret = 1
            break
        } else if (EOI() == _tok) {
            _ret = 0
            break
        }
        tok_next()
    }
    rdpg_reread_curr_tok()
    return _ret
}

function pstderr(str) {
    print str > "/dev/stderr"
}

BEGIN {
	if (rdpg_parse())
		exprs_process()
	else
		exit(1)
}
