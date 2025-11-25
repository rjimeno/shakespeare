FROM python:3.9-slim-buster
WORKDIR /app
COPY 100-0-inverted_index.csv .
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY lookup_word.py .
EXPOSE 5000
CMD ["python", "lookup_word.py"]