#!/usr/bin/env python2

import sys
import re

def reducer(file_handle):
    previous_word = None
    for row in file_handle:
        word_line = row.strip().split(' ')
        if 2 != len(word_line):
            continue
        current_word, line = word_line
        if previous_word and previous_word != current_word:
            sorted_integers = sorted(lines)
            sorted_strings = [str(x) for x in sorted_integers]
            lines_as_string = ' '.join(sorted_strings)
            print '{} {}'.format(previous_word, lines_as_string)
            previous_word = current_word
            lines.append(int(line))
        else:
            previous_word = current_word
            lines = [int(line)]

if '__main__' == __name__:
    if 1 <= len(sys.argv[1:]):  # One or more arguments.
        for file_name in sys.argv[1:]:
            with open(file_name, 'r') as file_handle:
                reducer(file_handle)
    else:
        reducer(sys.stdin)