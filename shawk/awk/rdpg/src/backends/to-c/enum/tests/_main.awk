function exit_failure() {_B_was_error=1; exit 1}
function exit_success() {exit 0}
function was_error() {return _B_was_error}

function parse_ok_set() {_B_was_parse_ok = 1}
function parse_was_ok() {return _B_was_parse_ok}

BEGIN {
    if (TestHelp) {
        print enum_help_str()
        parse_ok_set()
        exit_success()
    }

    if (TestParseErr)
        _enum_state_push(1000)
}

{
    eprs = enum_parse_line($0)
    if (ENUM_PARSE_DONE() == eprs) {
        end = enum_count()
        for (i = 1; i <= end; ++i) {
            name = enum_get_name_by_num(i)
            val = enum_get_val_by_name(name)
            print sprintf("%s = %s", name, val)
        }
        parse_ok_set()
        exit_success()
    } else if (ENUM_PARSE_ERR() == eprs) {
        exit_failure()
    }
}

END {
    if (was_error()) {
        print sprintf("error: %s", enum_get_err_str()) > "/dev/stderr"
    } else if (!parse_was_ok()) {
        print "error: parsing did not finish successfully" > "/dev/stderr"
        exit_failure()
    }
}
