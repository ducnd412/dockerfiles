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

if [ "${S3_IAMROLE}" != "true" ]; then
  # env vars needed for aws tools - only if an IAM role is not used
  export AWS_ACCESS_KEY_ID=$S3_ACCESS_KEY_ID
  export AWS_SECRET_ACCESS_KEY=$S3_SECRET_ACCESS_KEY
  export AWS_DEFAULT_REGION=$S3_REGION
fi

MYSQL_HOST_OPTS="-h $MYSQL_HOST -P $MYSQL_PORT -u$MYSQL_USER"
if [ -n "${MYSQL_PASSWORD}" ]; then
  MYSQL_HOST_OPTS="$MYSQL_HOST_OPTS -p$MYSQL_PASSWORD"
fi

echo "Finding latest backup: "
echo $(aws s3 ls s3://$S3_BUCKET/$S3_PREFIX/ | sort | tail -n 10 | awk '{ printf("[ %s ]", $4)}')
if [ ! -z "$1" ] ;then
    RESTORE_S3_PATH=$1
    echo "Select RESTORE_S3_PATH from param: $RESTORE_S3_PATH"
    else if [ "${RESTORE_S3_PATH}" = "**None**" ]; then
        RESTORE_S3_PATH=$(aws s3 ls s3://$S3_BUCKET/$S3_PREFIX/ | sort | tail -n 1 | awk '{ print $4 }')
        echo "Select RESTORE_S3_PATH from latest backup: $RESTORE_S3_PATH"

    fi
fi

S3_PATH=s3://$S3_BUCKET/$S3_PREFIX/${RESTORE_S3_PATH}
echo "Fetching ${S3_PATH} from S3"

aws s3 cp $S3_PATH dump.sql.gz
gzip -d dump.sql.gz
#if [ "${DROP_PUBLIC}" == "yes" ]; then
#	echo "Recreating the public schema"
#	psql $POSTGRES_HOST_OPTS -d $POSTGRES_DATABASE -c "drop schema public cascade; create schema public;"
#fi

echo "Restoring ${LATEST_BACKUP}"

mysql $MYSQL_HOST_OPTS $MYSQL_DATABASE < dump.sql

echo "Restore complete"

