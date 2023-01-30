#!/bin/bash

###################################################################
# Assignment 1. Juan Gomez (juanecito)
###################################################################

# Check arguments
if [ "$#" -ne 2 ]; then
	echo "Error, missing arguments: $0 <WRITEFILE> <WRITESTR>"
	exit 1
fi

# First argument path to a file in the filesystem
WRITEFILE=$1

# Second argument string to write
WRITESTR=$2

FILESDIR=$(dirname $WRITEFILE)
FILENAME=$(basename $WRITEFILE)

# Check FILESDIR
if [ ! -d "$FILESDIR" ]; then
	echo "Create directory $FILESDIR"
	mkdir -p $FILESDIR
	RC=$?
	
	if [ "$RC" -ne 0 ]; then
		echo "Error: directory $FILESDIR cannot be created"
		exit 1
	fi
fi

if touch $WRITEFILE; then
	echo "$WRITESTR" > $WRITEFILE
else
	echo "Error: file $WRITEFILE cannot be created"
	exit 1
fi

exit 0

