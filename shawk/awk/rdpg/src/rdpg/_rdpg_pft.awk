# <rdpg_pft>
function RDPG_PFT_SEP() {return "."}

function _rdpg_str_to_pft_str(str, sep,    _arr, _len) {
	_len = split(str, _arr, sep ? sep : RDPG_PFT_SEP())
	return pft_arr_to_pft_str(_arr, _len)
}

function rdpg_pft_insert(tree, rule, defn,    _path) {
	_path = _rdpg_str_to_pft_str((rule " " defn), "[[:space:]]+")
	pft_insert(tree, _path)
	pft_mark(tree, _path)
}
function rdpg_pft_is_endpoint(tree, ind) {
	return pft_is_marked(tree, _rdpg_str_to_pft_str(ind))
}
function rdpg_pft_split(root, out_arr) {
	return split(root, out_arr, RDPG_PFT_SEP())
}
function rdpg_pft_init(tree) {
	pft_init(tree)
}
function rdpg_pft_has(tree, ind) {
	ind = _rdpg_str_to_pft_str(ind)
	return (pft_has(tree, ind) && pft_get(tree, ind))
}
function rdpg_pft_get(tree, ind) {
	return pft_pretty(pft_get(tree, _rdpg_str_to_pft_str(ind)), RDPG_PFT_SEP())
}

function rdpg_pft_cat(a, b) {
	if (!a) return b
	if (!b) return a
	return (a RDPG_PFT_SEP() b)
}
function rdpg_pft_arr_has(arr, len, what) {
	return arr_find(arr, len, what)
}
function rdpg_pft_dbg_print(tree) {
	pft_print_dump(tree)
}
# </rdpg_pft>
