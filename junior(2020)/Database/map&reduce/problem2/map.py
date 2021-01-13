#!/usr/bin/env python
import sys

content = []
key = "key"

for line in sys.stdin:
    line = line.strip()
    tuple_list = line.split(",")

    if len(tuple_list) == 3:
        content.append(tuple_list[0]+":"+tuple_list[1]+":"+tuple_list[2])
    continue

for c in content:
    if len(c)>3:
        print('{0}\t{1}'.format(key, c))
