#@ <awklib_ch_num>
#@ Library: ch_num
#@ Description: Translates character to numbers and numbers to
#@ characters for the range 0,127 inclusive, i.e. ASCII if that's your
#@ underlying character set.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-30
#@

#
#@ Description: Initializes the char/num tables.
#@ Returns: Nothing.
#
function ch_num_init(    _i, _ch) {
	
	for (_i = 0; _i <= 127; ++_i) {
		
		_ch = sprintf("%c", _i)
		
		if (0x00 == _i) {_ch = "\\0"}
		else if (0x07 == _i) { _ch = "\\a"}
		else if (0x08 == _i) { _ch = "\\b"}
		else if (0x09 == _i) { _ch = "\\t"}
		else if (0x0A == _i) { _ch = "\\n"}
		else if (0x0B == _i) { _ch = "\\v"}
		else if (0x0C == _i) { _ch = "\\f"}
		else if (0x0D == _i) { _ch = "\\r"}
		else if (0x1B == _i) { _ch = "\\e"}
		
		__LB_ch_num_ch_to_num__[_ch] = _i
		__LB_ch_num_num_to_ch__[_i] = _ch
	}
}

#
#@ Description: Translates the character 'ch' to a number.
#@ Returns: The number representation of 'ch'.
#
function ch_to_num(ch) {return (__LB_ch_num_ch_to_num__[ch]+0)}

#
#@ Description: Translates the number 'num' to a character.
#@ Returns: The character representation of 'num'.
#
function num_to_ch(num) {return (__LB_ch_num_num_to_ch__[num] "")}
#@ </awklib_ch_num>
