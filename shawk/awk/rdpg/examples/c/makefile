CC := gcc
CFLAGS := -Wall

.PHONY: help
help:
	@echo 'make compile'
	@echo 'make run'
	@echo 'make clean'

.PHONY: compile
compile: main.bin main_bitsets.bin

main.bin: main.c rdpg_parser.c
	$(CC) $^ -o $@ $(CFLAGS)

main_bitsets.bin: main.c rdpg_parser_bitsets.c
	$(CC) $^ -o $@ $(CFLAGS)

.PHONY: run
run:
	./main.bin ../input.txt
	./main_bitsets.bin ../input.txt

.PHONY: clean
clean:
	rm -f *.bin
