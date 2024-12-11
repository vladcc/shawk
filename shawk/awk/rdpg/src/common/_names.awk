# <names>
function is_terminal(nm) {
	return match(nm, "^[_[:upper:]][[:upper:][:digit:]_]*$")
}
function is_non_term(nm) {
	return match(nm, "^[_[:lower:]][[:lower:][:digit:]_]*$")
}
# </names>
