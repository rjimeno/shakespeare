
For the TL;DR, jump to the command at the bottom of this file. If you want to understand that command more throughly, keep reading.

Currently, this service relies on a file named invertedIndex.csv. That file is produced by batch-processing. Currently, that is implemented as a two scripts operating in a data pipeline.

Those two scripts represent map-reduce jobs as follows:

The first script reads a source file and splits it in left and right pairs of values, which we will call Word and Pointer, one per pair per line of output. The Word on each line is a word appearing in the source file. The Pointer is line number where Word appears in the source file.

Note that one word may appear more than once in the same line of an input file. So, the same pair of Word, Pointer line may appear more than once in the output. Similarly, one word may appear more than once in different  lines of an input file. So, the same Word may appear in more than one lines of output, but their corresponding Pointer values will be different on each line.

Effectively, the first script maps each word in the source file to the line number where it appears (in the source file).

The second script reads lines of Word and Pointer pairs and outputs lines of Key, Numbers paris where the Key on each line is a unique Word from the input, and Numbers is a list of all the Pointers that paired with the Word. Currently, the second script assumes the input is sorted; otherwise the output is not necessarily correct.

Note that each word in the source file appears exactly once in the output of the second script. Since the word that is Key, may appear more than once in the same line of an input file, then Numbers list may contain the same Pointer more than once. 

Effectively, the second script reduces one or more lines of input into a single line of output where the Key value represents a unique value of Word and the Numbers list contains all the Pointer values that paired with Word.

For efficiency, the two scripts may have some pre or post processing, or even for validation purposes. With some additional "guard rails", the process describe above can be done with multiple scripts running in parallel to maximize throughput and minimize latency.

The simplest way (not necessarily the most efficient) to exercise the map-reduce job described above is with the following pipeline that reads an input file and produces an output file as follows:

`./createInvertedIndex-mapper.py < works/100-0.txt | sort | ./createInvertedIndex-reducer.py > 100-0-invert_index.csv`