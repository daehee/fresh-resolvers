#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

if [ -z "$1" ]
then
    echo "[ERROR] Provide name of axiom box!"
    exit 0
fi

BOX=$1
WORK_DIR=~/work/resolvers
TIMESTAMP=$(date "+%Y%m%d-%H%M%S")

axiom-exec 'wget -O ~/work/fresh-resolvers.txt https://raw.githubusercontent.com/BBerastegui/fresh-dns-servers/master/resolvers.txt' $BOX

axiom-exec "dnsvalidator -tL ~/work/fresh-resolvers.txt -threads 20 -o ~/work/valid-resolvers_$TIMESTAMP.txt" $BOX
axiom-scp $BOX:~/work/valid-resolvers_$TIMESTAMP.txt $WORK_DIR/valid-resolvers.txt

# strip empty lines and add EOF newline on validr esolvers
# combine with default resolvers and sort unique to new file
cat $WORK_DIR/valid-resolvers.txt | sed '/^$/d' | sed -e '$a\' | cat - $WORK_DIR/default_resolvers.txt | sort -u > $WORK_DIR/master-resolvers.txt.new

# send diff with prev run to slack-cli
#diff --suppress-common-lines -y $WORK_DIR/master-resolvers.txt $WORK_DIR/master-resolvers.txt.new | slack chat send --channel '#general' --pretext 'New resolvers:'

# overwrite master
cp $WORK_DIR/master-resolvers.txt.new $WORK_DIR/master-resolvers.txt

echo "Fresh resolvers updated!"
