FROM ubuntu:22.04

RUN apt-get update && apt-get install -y nasm gcc make

WORKDIR /usr/src/app

COPY . .

RUN make build

EXPOSE 8080

CMD ["make", "run"]
