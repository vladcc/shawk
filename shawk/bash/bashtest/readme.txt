bashtest provides asserts, stack traces, optional verbosity. After you source
bashtest.sh, call bt_enter. Before you exit call bt_exit_success. This takes
care to push the test script's current directory on the stack, and remove it on
exit. In this way relative paths keep their meaning during the test run. On any
assert failure bt_exit_failure is eventually called and the directory is popd as
well.
