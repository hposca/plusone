FROM python:3.6.4-alpine3.7


# Production version
# RUN apk update && \
#     apk add --upgrade python3-dev mariadb-dev build-base && \
#     pip install --upgrade pip && \
#     pip install -r /app/requirements.txt && \
#     apk del python3-dev mariadb-dev build-base && \
#     apk add mariadb-client-libs

# Development version
RUN apk update \
    && apk add --upgrade \
      build-base \
      mariadb-client-libs \
      mariadb-dev \
      mysql-client \
      python3-dev

COPY requirements.txt /app/

RUN pip install -r /app/requirements.txt

EXPOSE 5000

WORKDIR /app/

ENV FLASK_APP=main.py

CMD ["flask", "run", "--host=0.0.0.0"]
