#@ <awklib_bitwise>
#@ Library: bitwise
#@ Description: Bit operations implemented with loops and arithmetic. They work
#@ as if on 32 bit unsigned ints. If a number wider than that is passed to a bit
#@ operations, it is truncated to 32 bits. Conversion procedures can optionally
#@ convert numbers winder than 32 bits. The operations are, of course, slow and
#@ shouldn't be used for much more than the occasional bit pattern.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2022-01-20
#@

# <public>

#
#@ Description: Bitwise and.
#@ Returns: The result of the operation, or -1 if any input is negative.
#
function bw_and(a, b) {
	return _bw_do_bw(a, b, _BW_AND())
}

#
#@ Description: Bitwise or.
#@ Returns: The result of the operation, or -1 if any input is negative.
#
function bw_or(a, b) {
	return _bw_do_bw(a, b, _BW_OR())
}

#
#@ Description: Bitwise xor.
#@ Returns: The result of the operation, or -1 if any input is negative.
#
function bw_xor(a, b) {
	return _bw_do_bw(a, b, _BW_XOR())
}

#
#@ Description: Bitwise not.
#@ Returns: The result of the operation, or -1 if any input is negative.
#
function bw_not(val) {
	return _bw_do_bw(val, _BW_UVAL_MAX(), _BW_XOR())
}

#
#@ Description: Bitwise left shift.
#@ Returns: The result of the operation, or -1 if any input is negative, or
#@ 'bits' is larger than 31.
#
function bw_lshift(val, bits) {
	return _bw_do_bw(val, bits, _BW_LSHIFT())
}

#
#@ Description: Bitwise right shift.
#@ Returns: The result of the operation, or -1 if any input is negative, or
#@ 'bits' is larger than 31.
#
function bw_rshift(val, bits) {
	return _bw_do_bw(val, bits, _BW_RSHIFT())
}

#
#@ Description: Creates a binary string representation of 'num'. 'sep', if
#@ given, separates every four bits. 'limit', if given, is the number of bytes
#@ to process, starting from the least significant one. The default is four.
#@ Returns: The binary string representation of 'num', -1 if 'num' is negative.
#
function bw_bin_str(num, sep, limit,    _str) {
	
	return _bw_base_str(num, sep, limit, _BW_BASE_BIN())
}

#
#@ Description: Creates a hex string representation of 'num'. 'sep', if given,
#@ separates every two hex digits. 'limit', if given, is the number of bytes
#@ to process, starting from the least significant one. The default is four.
#@ Returns: The hex string representation of 'num', -1 if 'num' is negative.
#
function bw_hex_str(num, sep, limit,    _str, _digit) {
	
	return _bw_base_str(num, sep, limit, _BW_BASE_HEX())
}
# </public>

# <private>
function _BW_MAX_BITS() {return 32}
function _BW_MSB() {return _BW_MAX_BITS()-1}
function _BW_UVAL_MAX() {return int(2^_BW_MAX_BITS()-1)}

function _BW_AND() {return 1}
function _BW_OR() {return 2}
function _BW_XOR() {return 3}
function _BW_LSHIFT() {return 4}
function _BW_RSHIFT() {return 5}

function _bw_mask_max(n) {return int(n%(2^_BW_MAX_BITS()))}

function _bw_do_bw(na, nb, op,    _ba, _bb, _bc, _pw, _res) {
	
	if ((op < _BW_AND()) || (op > _BW_RSHIFT()))
		return -1
	
	na = int(na)
	nb = int(nb)
	
	if ((na < 0) || (nb < 0))
		return -1
	
	if (na > _BW_UVAL_MAX())
		na = _bw_mask_max(na)

	if (nb > _BW_UVAL_MAX())
		nb = _bw_mask_max(nb)
	
	_res = -1
	if ((_BW_LSHIFT() == op) || (_BW_RSHIFT() == op)) {
		
		if (nb > _BW_MSB())
			return -1
		
		while (na && nb--)
			na = (_BW_LSHIFT() == op) ? _bw_mask_max(na*2) : int(na/2)
			
		_res = na
	} else {
	
		_pw = 0
		_res = 0
		while (1) {
			
			if (na > 0 || nb > 0) { 
				
				_ba = !!(na % 2)
				_bb = !!(nb % 2)
				
				if (_BW_AND() == op)
					_bc = (_ba && _bb)
				else if (_BW_OR() == op)
					_bc = (_ba || _bb)
				else if (_BW_XOR() == op)
					_bc = (_ba != _bb)

				_res += _bc * 2^_pw
				
				++_pw
				na = int(na/2)
				nb = int(nb/2)
			} else {
				break
			}
		}
	}
	return _res
}

function _BW_BASE_BIN() {return 1}
function _BW_BASE_HEX() {return 2}

function _bw_base_str(num, sep, limit, base,    _mod) {
	
	if (base != _BW_BASE_BIN() && base != _BW_BASE_HEX())
		return -1
	
	if (num < 0)
		return -1
		
	num = int(num)
	
	if (_BW_BASE_BIN() == base) {
		limit = (limit) ? limit * 8 : _BW_MAX_BITS()
		_mod = 4
	} else if (_BW_BASE_HEX() == base) {
		limit = (limit) ? limit * 2 : _BW_MAX_BITS() / 4
		_mod = 2
	}
	
	_str = ""
	while (limit) {
		
		if ((sep != "") && (_str != "") && !(limit % _mod))
			_str = (sep _str)
		
			if (_BW_BASE_BIN() == base) {
				
				_str = ((num % 2) _str)	
				num = int(num/2)
			} else if (_BW_BASE_HEX() == base) {
				
				_digit = num % 16
			
				if (_digit == 10) _digit = "A"
				else if (_digit == 11) _digit = "B"
				else if (_digit == 12) _digit = "C"
				else if (_digit == 13) _digit = "D"
				else if (_digit == 14) _digit = "E"
				else if (_digit == 15) _digit = "F"
				
				_str = (_digit _str)
				num = int(num/16)
			}
		
		--limit
	}
	return _str
}
# </private>

#@ </awklib_bitwise>
