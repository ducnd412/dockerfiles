FROM alpine:latest
LABEL maintainer="Johannes Schickling <schickling.j@gmail.com>"

RUN set -e && \
    apk update && \
    apk add mysql-client && \
    apk add python py-pip && \
    pip install awscli && \
    apk del py-pip && \
    apk add curl && \
    curl -L --insecure https://github.com/odise/go-cron/releases/download/v0.0.6/go-cron-linux.gz | zcat > /usr/local/bin/go-cron && \
    chmod u+x /usr/local/bin/go-cron && \
    apk del curl && \
    rm -rf /var/cache/apk/*

ENV MYSQLDUMP_OPTIONS --quote-names --quick --add-drop-table --add-locks --allow-keywords --disable-keys --extended-insert --single-transaction --create-options --comments --net_buffer_length=16384
ENV MYSQL_DATABASE **None**
ENV MYSQL_HOST **None**
ENV MYSQL_PORT 3306
ENV MYSQL_USER **None**
ENV S3_ACCESS_KEY_ID **None**
ENV S3_SECRET_ACCESS_KEY **None**
ENV S3_BUCKET **None**
ENV S3_REGION us-west-1
ENV S3_ENDPOINT **None**
ENV S3_S3V4 no
ENV S3_PREFIX 'backup'
ENV MULTI_FILES no
ENV SCHEDULE **None**

ADD run.sh run.sh
ADD backup.sh backup.sh
ADD restore.sh restore.sh

CMD ["sh", "run.sh"]
