#!/usr/bin/env python
import sys

names = []
const = []
name = "name"

for key_value in sys.stdin:
    key_value = key_value.strip()
    key, values = key_value.split("\t")
    tuple_list = values.split(":")
    price = int(tuple_list[1])
    dist = int(tuple_list[2])
    const.append([price, dist])
    names.append(tuple_list[0])
    continue

for i in range(0, len(names), 1):
    j=0
    for j in range(0, len(names), 1):
        if names[i] != names[j]:
            if const[i][0]>const[j][0] and const[i][1]>const[j][1]:
                break
    if j==len(names)-1:
        print(names[i])

    
