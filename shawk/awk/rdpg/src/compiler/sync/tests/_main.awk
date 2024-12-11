function error_quit(msg) {
	print msg > "/dev/stderr"
	exit(1)
}

function main(    _i, _ei, _j, _ej, _nont, _term) {
	sync_init(Sync)

	if (Type) {
		print sync_type()
		exit(0)
	}

	_ei = sync_nont_count()
	for (_i = 1; _i <= _ei; ++_i) {
		_nont = sync_nont(_i)
		printf("%s = ", _nont)
		_ej = sync_term_count(_nont)
		for (_j = 1; _j <= _ej; ++_j) {
			_term = sync_term(_nont, _j)
			printf("%s", _term)
			if (_j < _ej)
				printf(" ")
		}
		print ""
	}
}

BEGIN {
	main()
}
