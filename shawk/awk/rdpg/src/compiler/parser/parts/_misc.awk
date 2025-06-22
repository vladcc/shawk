# <misc>
function parsing_error_happened() {return _B_parsing_error_flag}
function parsing_error_set() {_B_parsing_error_flag = 1}

function keep(a, b) {return a || b}
function map_has(map, n) {return (n in map)}
function map_get(map, n) {return map_has(map, n) ? map[n] : ""}
# </misc>
