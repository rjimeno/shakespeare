#!/usr/bin/env python3

import sys


def word_index_line_list():
    for i, l in enumerate(sys.stdin):
        ll = l.split()
        #map(str.strip(': '), ll)
        print(f'{i}: {ll}')


if '__main__' == __name__:
    word_index_line_list()
