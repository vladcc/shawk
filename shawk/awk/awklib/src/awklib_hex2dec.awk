#@ <awklib_hex2dec>
#@ Library: hex2dec
#@ Description: Hex to decimal conversion.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2024-06-11
#@

#
#@ Description: Converts the hex number represented by the string 'hex' to
#@ decimal. Accepts '0x', '0X' as prefixes, 'h', 'H' as suffixes.
#@ Returns: The decimal representation of 'hex'. If 'hex' is not a valid hex
#@ number, 0 is returned.
#
function hex2dec(hex,    _i, _len, _ret) {

	hex = tolower(hex)
	gsub("^0x|h$", "", hex)

	_ret = 0
	if (match(hex, "^[[:xdigit:]]+$")) {
		_len = length(hex)
		for (_i = 1; _i <= _len; ++_i)
			_ret = (_ret * 16) + index("123456789abcdef", substr(hex, _i, 1))
	}
	return _ret
}

#@ </awklib_hex2dec>
