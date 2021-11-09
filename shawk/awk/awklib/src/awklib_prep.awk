#@ <awklib_prep>
#@ Library: prep
#@ Description: Prepares strings by replacing named arguments.
#@ By default, the argument needs to appear between '{}' and can be any
#@ string. The argument name is matched as a regular expression. I.e.
#@ the default format for the named arguments is the printf string
#@ "[{]%s[}]" which, after being processed by 'sprintf()', is matched as
#@ a regular expression. The '[]' are needed to make sure the '{}' are
#@ matched literally, and the '%s' is the argument name. The '%s' is
#@ replaced by each argument name and the whole expression is replaced,
#@ if matched in the target string, by the argument value.
#@ E.g.:
#@
#@ Given the string:
#@
#@ "{1} quick {color} {ANIMAL} jumps over {1} lazy dog"
#@
#@ and the map:
#@
#@ m["1"] = "the"
#@ m["color"] = "brown"
#@ m["[A-Z]+"] = "fox"
#@
#@ the result is:
#@
#@ "the quick brown fox jumps over the lazy dog"
#@
#@ Note that only the '%s' part of the argument name needs to appear as
#@ an index in the map.
#@ Version: 1.0
##
## Vladimir Dinev
## vld.dinev@gmail.com
## 2021-08-29
#@

# <public>
#@ Description: The argument format as a printf string.
#@ Returns: The default value for the argument format.
#
function PREP_ARG() {return "[{]%s[}]"}

#
#@ Description: Replaces the named arguments in 'str' according to
#@ 'map'. E.g. if 'str' is "{1} {arg}" and 'map' is 'map[1] = "foo"'
#@ 'map["arg"] = "bar"', the result is "foo bar". If 'fmt' is not given,
#@ 'PREP_ARG()' is used. If it is given, it must contain a single '%s',
#@ which shall be replaced by the argument name. The '%s' can be
#@ surrounded by non printf string specifier.
#@ Returns: 'str' after all arguments found in 'map' have been replaced.
#
function prep_str(str, map, fmt) {

	if (!fmt)
		fmt = PREP_ARG()

	return _prep_str(str, map, fmt)
}

#
#@ Description: Indicates how many substitutions were made in the last
#@ call to 'prep_str()'
#@ Returns: The number of substitutions made.
#
function prep_num_of_subs() {return __LB_prep_number_of_substitutions__}
# </public>

function _prep_str(str, map, fmt,    _n, _subs) {
	
	_subs = 0
	for (_n in map)
		_subs += gsub(sprintf(fmt, _n), map[_n], str)
	_prep_set_subs(_subs)
	return str
}

function _prep_set_subs(n) {__LB_prep_number_of_substitutions__ = n}

#@ </awklib_prep>
