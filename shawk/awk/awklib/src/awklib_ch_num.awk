#@ <awklib_ch_num>
#@ Library: ch_num
#@ Description: Translates character to numbers and numbers to characters in the
#@ range 0 to 127 inclusive.
#@ Version: 1.1.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2024-06-11
#@

#
#@ Description: Initializes the char/num tables.
#@ Returns: Nothing.
#
function ch_num_init(    _i, _ch) {

	for (_i = 0; _i <= 127; ++_i) {

		_ch = sprintf("%c", _i)

		if (0 == _i) {_ch = "\\0"}           # 0x00
		else if (7 == _i) { _ch = "\\a"}     # 0x07
		else if (8 == _i) { _ch = "\\b"}     # 0x08
		else if (9 == _i) { _ch = "\\t"}     # 0x09
		else if (10 == _i) { _ch = "\\n"}    # 0x0A
		else if (11 == _i) { _ch = "\\v"}    # 0x0B
		else if (12 == _i) { _ch = "\\f"}    # 0x0C
		else if (13 == _i) { _ch = "\\r"}    # 0x0D
		else if (27 == _i) { _ch = "\\e"}    # 0x1B

		_AWKLIB_ch_num__ch_to_num[_ch] = _i
		_AWKLIB_ch_num__num_to_ch[_i] = _ch
	}
}

#
#@ Description: Maps the character 'ch' to a number.
#@ Returns: The number representation of 'ch' if 'ch' is in range, -1 if not.
#
function ch_to_num(ch) {
	return (ch in _AWKLIB_ch_num__ch_to_num) ? \
		(_AWKLIB_ch_num__ch_to_num[ch]+0) : -1
}

#
#@ Description: Maps the number 'num' to a character.
#@ Returns: The character representation of 'num' if num is in range, "" if not.
#
function num_to_ch(num) {
	return (num in _AWKLIB_ch_num__num_to_ch) ? \
		(_AWKLIB_ch_num__num_to_ch[num] "") : ""
}
#@ </awklib_ch_num>
