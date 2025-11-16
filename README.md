Source: https://learning.oreilly.com/library/view/site-reliability-engineering/9781491929117/ch02.html#:-:text=Shakespeare%3A%20A%20Sample,as%20the%20key.

Shakespeare: A Sample Service

To provide a model of how a service would hypothetically be deployed in the
Google production environment, let’s look at an example service that interacts
with multiple Google technologies. Suppose we want to offer a service that lets
you determine where a given word is used throughout all of Shakespeare’s works.

We can divide this system into two parts:

A batch component that reads all of Shakespeare’s texts, creates an index, and
writes the index into a Bigtable. This job need only run once, or perhaps very
infrequently (as you never know if a new text might be discovered!).

An application frontend that handles end-user requests. This job is always up,
as users in all time zones will want to search in Shakespeare’s books.

The batch component is a MapReduce comprising three phases.

The mapping phase reads Shakespeare’s texts and splits them into individual
words. This is faster if performed in parallel by multiple workers.

The shuffle phase sorts the tuples by word.

In the reduce phase, a tuple of (word, list of locations) is created.

Each tuple is written to a row in a Bigtable, using the word as the key.

