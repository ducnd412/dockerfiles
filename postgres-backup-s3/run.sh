#! /bin/sh

set -e

if [ "${S3_S3V4}" = "yes" ]; then
    aws configure set default.s3.signature_version s3v4
fi

if [ "${SCHEDULE}" = "**None**" ]; then
  echo "Set SCHEDULE=ONE to run backup one time or using crontab param"
  echo "run : backup.sh to backup"
  echo "run : restore.sh to restore"
  echo "waiting for execute sell"
  sh  -c "tail -f /dev/null"
else if [ "${SCHEDULE}" = "ONE" ]; then
  sh backup.sh
else
  exec go-cron "$SCHEDULE" /bin/sh backup.sh
fi
fi
