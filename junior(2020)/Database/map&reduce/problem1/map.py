#!/usr/bin/env python

import sys

for line in sys.stdin:
    line = line.strip()
    tuple_list = line.split(",") # Splits a string into a list.
                
    if len(tuple_list) == 6: # student file
        deptno = tuple_list[4]
        gpa = tuple_list[5]
                                                
        # deptno = key  student,gpa = value
        print('{0}\t{1}'.format(deptno, 'student,'+gpa))
                                                                        
    else: # dept file
        deptno = tuple_list[0]
        dname = tuple_list[1]
        campus = tuple_list[2]
        
        # deptno = key  dept,dname,campus = value
        print('{0}\t{1}'.format(deptno, 'dept,'+dname+':'+campus))

