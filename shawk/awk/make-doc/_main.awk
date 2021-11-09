#!/usr/bin/awk -f

{G_src[++G_src_len] = $0}

END {
	G_doc_len = awd_make_doc(G_doc, G_src, G_src_len)
	for (i = 1; i <= G_doc_len; ++i)
		print G_doc[i]
}
