Suppose we want to offer a service that lets you determine where a given word is used throughout all of Shakespeare’s works.

From page 20 of the book Site Reliability Engineering.

The command line for running the job once the data is loaded in HDFS will look like the following:

aws s3 cp s3://rjimeno-shakespeare/100-0.txt .

aws s3 cp s3://rjimeno-shakespeare/createInvertedIndex-mapper.py .

aws s3 cp s3://rjimeno-shakespeare/createInvertedIndex-reducer.py .


hadoop fs -mkdir input

hadoop fs -put input/100-0.txt

hadoop fs -rm -r resultsZero


hadoop jar /usr/lib/hadoop/hadoop-streaming.jar -input input -output resultsZero -mapper "python createInvertedIndex-mapper.py" -file createInvertedIndex-mapper.py -reducer "python createInvertedIndex-reducer.py" -file createInvertedIndex-reducer.py

hadoop fs -get resultsZero

cd resultsZero
