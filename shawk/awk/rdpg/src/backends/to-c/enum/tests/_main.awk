BEGIN {
    if (TestHelp) {
        print enum_help_str()
        exit
    }

    if (TestParseErr)
        _enum_state_push("foo-bar-baz")
}

{
    eprs = enum_parse_line($0)
    if (ENUM_PARSE_SUCCESS() == eprs) {
        end = enum_count()
        for (i = 1; i <= end; ++i) {
            name = enum_get_name_by_num(i)
            val = enum_get_val_by_name(name)
            print sprintf("%s = %s", name, val)
        }
        exit
    } else if (ENUM_PARSE_ERR() == eprs) {
        exit
    }
}

END {
    if ((ENUM_PARSE_SUCCESS() == eprs) || TestHelp)
        exit 0

    if (eprs != ENUM_PARSE_SUCCESS()) {
        print \
            sprintf("error: enum: parsing ended in unexpected state: %s", \
                enum_parse_last_state()) > "/dev/stderr"
    }
    exit 1
}
