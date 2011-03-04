#!/bin/sh
# Copyright (c) 2011, Membase, Inc.
# All rights reserved.
cd `dirname $0`
mkdir logs > /dev/null 2>&1

# Initialize distributed erlang on the system (i.e. epmd)
if [ -z "$DONT_START_EPMD" ]; then
  erl -noshell -setcookie nocookie -sname init -run init stop 2>&1 > /dev/null
fi

./mkcouch n_0 9500

exec erl \
    +A 16 \
    -pa `find . -type d -name ebin | grep -v mochiweb` \
    -pa `find ../couchdb/build/lib/couchdb/erlang/lib -type d -name ebin` \
    -setcookie nocookie \
    -run ns_bootstrap \
    -couch_ini couch/n_0_conf.ini \
    -ns_server error_logger_mf_dir '"logs"' \
    -ns_server error_logger_mf_maxbytes 10485760 \
    -ns_server error_logger_mf_maxfiles 10 \
    -ns_server dont_suppress_stderr_logger true \
    -kernel inet_dist_listen_min 21100 inet_dist_listen_max 21199 \
    -- "$@"
