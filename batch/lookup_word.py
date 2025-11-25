#!/usr/bin/env python

from flask import Flask, request

app = Flask(__name__)

# TODO: Consult a database instead of a file.
# TODO: Read and return JSON instead of a string.
@app.route('/lookup', methods=['GET'])
def lookup():
    found = False
    word = request.args.get('word')
    if word:
        # Look at the README.md file before changing the file name.
        with open('100-0-inverted_index.csv', 'r') as f:
            for line in f:
                entry_word, pages = line.strip().split(',')
                if entry_word == word:
                    found = True
                    break
        if not found:
            pages = "0" # i.e. word not found in the inverted index.
    else:
        pages = "-1" # i.e. word not found in the arguments.
    return f'{word}: {pages}'

# Temporarily kept for diagnostics.
@app.route('/')
def hello_world():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
    # Obs.: Without debug=True, listens only to localhost.
