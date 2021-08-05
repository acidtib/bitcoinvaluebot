FROM crystallang/crystal:1.1.1

WORKDIR /app
ADD . /app

RUN shards install

RUN crystal build -s -p --release -o build/jobs app/jobs.cr

CMD ./build/jobs