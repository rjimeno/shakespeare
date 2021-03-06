#!/usr/bin/env python2

import sys
import re

def mapper(file_handle):
    counter = 0
    #  d = {}
    for line in file_handle:
        counter += 1
        line.strip().lower()
        words = re.split(
            '[,.!?:;"()<>\[\]#$=\-/\s]+',
            line.strip().lower()
        )
        for w in words:
            if 0 == len(w):
                continue
            print '{0} {1}'.format(w, counter)
    return  #  d

if '__main__' == __name__:
    if 1 <= len(sys.argv[1:]):  # One or more arguments.
        for file_name in sys.argv[1:]:
            with open(file_name, 'r') as file_handle:
                mapper(file_handle)
    else:
        mapper(sys.stdin)

