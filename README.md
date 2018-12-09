Suppose we want to offer a service that lets you determine where a given word is used throughout all of Shakespeare’s works.

From page 20 of the book Site Reliability Engineering.


The command line for running the job once the data is loaded in HDFS will look like the following:

hadoop jar /usr/lib/hadoop/hadoop-streaming-2.7.1-amzn-1.jar -input 100-0.txt -output resultsZero -mapper createInvertedIndex-mapper.py  -reducer createInvertedIndex-reducer.py

