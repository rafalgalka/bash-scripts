#!/bin/sh

# sync-sftp - Sync files from current directory to SFTP using lftp

if [ $# -eq 0 ] ; then
  echo "Usage: $0 [-p|--password password] user@host [remotedir]" >&2
  exit 1
fi

ARGS=$(getopt -l 'password' -o 'p:' -- "$@" 2> /dev/null)
eval set -- "$ARGS"

sourcedir=`pwd`
remotedir="/"
exclude="" # todo - add to options

user=
host=
password=

while true
do
    case "$1" in
    --password | -p)
        password="$2"
        shift;;
    --)
        shift
        break
        ;;
    esac
    shift
done

user="$(echo $1 | cut -d@ -f1)"
host="$(echo $1 | cut -d@ -f2)"

if [ ! -z "$2" ]; then
    remotedir=$2
fi

lftp -c "open -u ${user},${password} sftp://${host};
lcd $sourcedir;
cd $remotedir;
mirror --reverse \
       --delete \
       --verbose \
       --ignore-time"
       # todo --exclude-glob local/path"

exit 0
