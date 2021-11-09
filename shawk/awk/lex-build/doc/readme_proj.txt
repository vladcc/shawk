Project structure:

lex-builder/:
makefile      - generates lex_lib and run tests
lb_lib.awk    - the lex builder library. The front end and the back ends use it.
lex-first.awk - the lex builder front end. Prepares the input for the back ends.
lex-c.awk     - back end for C; generates a lexer in C
lex-awk.awk   - back end for awk; generates a lexer in awk
input.lb      - example lex-build input

src/:
The different parts of the lex*.awk scripts are contained here. make puts them
together.

tests/:
run-tests.sh - generates all lexers, runs them, expects the same outputs
test-data/   - test inputs
test-accept/ - expected outputs
c/, awk/     - C and awk tests; work as short examples as well

c-vs-flex/:
makefile      - makes and runs performance tests
big_file.zip  - zipped performance input; ~6mb when unzipped
flex.fl       - lexer description for flex
lex.lb        - lexer description for lex-build
flex*.c       - flex output
lex-*.c, awk/ - C and awk lexers; longer examples

doc/ - the project documentation
