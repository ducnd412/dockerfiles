    #! /bin/sh

    set -e

    if [ "${S3_ACCESS_KEY_ID}" == "**None**" ]; then
      echo "Warning: You did not set the S3_ACCESS_KEY_ID environment variable."
    fi

    if [ "${S3_SECRET_ACCESS_KEY}" == "**None**" ]; then
      echo "Warning: You did not set the S3_SECRET_ACCESS_KEY environment variable."
    fi

    if [ "${S3_BUCKET}" == "**None**" ]; then
      echo "You need to set the S3_BUCKET environment variable."
      exit 1
    fi

    if [ "${MYSQL_HOST}" == "**None**" ]; then
      echo "You need to set the MYSQL_HOST environment variable."
      exit 1
    fi

    if [ "${MYSQL_USER}" == "**None**" ]; then
      echo "You need to set the MYSQL_USER environment variable."
      exit 1
    fi


    if [ "${MYSQL_DATABASE}" == "**None**" ]; then
      echo "You need to set the MYSQL_DATABASE environment variable or link to a container named MYSQL."
      exit 1
    fi

    MYSQL_HOST_OPTS="-h $MYSQL_HOST -P $MYSQL_PORT -u$MYSQL_USER"
    if [ -n "${MYSQL_PASSWORD}" ]; then
      MYSQL_HOST_OPTS="$MYSQL_HOST_OPTS -p$MYSQL_PASSWORD"
    fi

    if [ "${S3_IAMROLE}" != "true" ]; then
      # env vars needed for aws tools - only if an IAM role is not used
      export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
      export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
      export AWS_DEFAULT_REGION=$S3_REGION
    fi
    echo "Creating dump for ${MYSQL_DATABASE} from ${MYSQL_HOST}..."

    DUMP_FILE="/tmp/dump.sql.gz"
    mysqldump ${MYSQL_HOST_OPTS} ${MYSQLDUMP_OPTIONS} ${MYSQL_DATABASE} | gzip  > $DUMP_FILE

    if [ $? == 0 ]; then
        NOW=$(date +"%Y-%m-%dT%H:%M:%SZ")
        AWS_URL="s3://$S3_BUCKET/$S3_PREFIX/${MYSQL_DATABASE}-$NOW.sql.gz"

        echo "Uploading dump to $AWS_URL"
        cat ${DUMP_FILE} | aws ${AWS_ARGS} s3 cp - ${AWS_URL} || exit 2

        echo "SQL backup uploaded successfully: $AWS_URL"
    else
        >&2 echo "Error creating dump of all databases"
    fi

    echo "SQL backup finished"
