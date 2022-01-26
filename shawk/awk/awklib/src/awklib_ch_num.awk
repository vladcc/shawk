#@ <awklib_ch_num>
#@ Library: ch_num
#@ Description: Translates character to numbers and numbers to
#@ characters for the range 0,127 inclusive, i.e. ASCII if that's your
#@ underlying character set.
#@ Version: 1.1
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2022-01-27
#@

#
#@ Description: Initializes the char/num tables.
#@ Returns: Nothing.
#
function ch_num_init(    _i, _ch) {
	
	for (_i = 0; _i <= 127; ++_i) {
		
		_ch = sprintf("%c", _i)
		
		if (0 == _i) {_ch = "\\0"}        # 0x00
		else if (7 == _i) { _ch = "\\a"}  # 0x07
		else if (8 == _i) { _ch = "\\b"}  # 0x08
		else if (9 == _i) { _ch = "\\t"}  # 0x09
		else if (10 == _i) { _ch = "\\n"} # 0x0A
		else if (11 == _i) { _ch = "\\v"} # 0x0B
		else if (12 == _i) { _ch = "\\f"} # 0x0C
		else if (13 == _i) { _ch = "\\r"} # 0x0D
		else if (27 == _i) { _ch = "\\e"} # 0x1B
		
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
