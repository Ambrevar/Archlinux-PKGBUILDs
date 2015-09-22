#!/bin/sh

FIMS_ROOT=/usr/lib/fims

if [ $# -eq 0 ]; then
	cat<<EOF
Usage: ${0##*/} SCRIPT

Run SCRIPT in $FIMS_ROOT.
This wrapper prevents name clashes with other system binaries.
EOF
	exit
fi

script="$1"
shift
"$FIMS_ROOT/$script" "$@"

