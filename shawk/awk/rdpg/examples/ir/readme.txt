example.rdpg is obtained by

rdpg-comp.awk -vExample=1

example.ir by

rdpg-comp.awk example.rdpg

Alternativey:

./rdpg-comp.awk -vExample=1 | ./rdpg-comp.awk /dev/stdin
