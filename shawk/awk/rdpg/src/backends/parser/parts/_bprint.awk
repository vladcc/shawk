# <bprint>
function bemit(buff, str) {buff[++buff[0]] = (tget() str)}
function bnl(buff)        {buff[++buff[0]] = ""}
function btostr(buff,    _i, _end, _str) {
	_end = buff[0]
	for (_i = 1; _i <= _end; ++_i)
		_str = (1 == _i) ? buff[_i] : (_str "\n" buff[_i])
	return _str
}
function bflush(buff,    _out, _i, _end) {
	_out = stdout_get()
	_end = buff[0]
	for (_i = 1; _i <= _end; ++_i)
		print buff[_i] > _out
}

function bstr_cat(str) {_B_bstr_str = (_B_bstr_str str)}
function bstr_extract(    _ret) {
	_ret = _B_bstr_str
	_B_bstr_str = ""
	return _ret
}
function bstr_peek() {return _B_bstr_str}
function bstr_emit() {emit(bstr_extract())}
function bstr_bemit(buff) {bemit(buff, bstr_extract())}
# </bprint>
