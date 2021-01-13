#!/usr/bin/env python
import sys

last_deptno = None
dname = None
location = None
maxgpa = []

for key_value in sys.stdin:
    key_value = key_value.strip()
    deptno, table_value = key_value.split("\t")

    table, value = table_value.split(",")

    if last_deptno == deptno:
        if table == 'student':
            maxgpa.append(float(value))
        else: #dept
            dname, location = value.split(":")
    else:
        if last_deptno and dname and location:
            if sum(maxgpa)/float(len(maxgpa))>3.5:
                print("%s, %.1f, %s"%(dname, max(maxgpa), location))
        dname = None
        location = None
        maxgpa = []

        if table == 'student':
            maxgpa = [float(value)]
        else:
            dname, location = value.split(":")

        last_deptno = deptno

if last_deptno and dname and location:
    if sum(maxgpa)/float(len(maxgpa))>3.5:
        print("%s, %.1f, %s"%(dname, max(maxgpa), location))
