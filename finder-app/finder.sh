#!/bin/sh

###################################################################
# Assignment 1. Juan Gomez (juanecito)
###################################################################

# Check arguments
if [ "$#" -ne 2 ]; then
	echo "Error, missing arguments: $0 <FILESDIR> <SEARCHSTR>"
	exit 1
fi

# First argument path to directory on the filesystem
FILESDIR=$1

# Second argument string to find within files
SEARCHSTR=$2

# Check FILESDIR
if [ ! -d "$FILESDIR" ]; then
	echo "Error, directory $FILESDIR doesn't exist"
	exit 1
fi

NB_FILES_WITH_STR=`find $FILESDIR -type f -print 2>/dev/null | xargs grep $SEARCHSTR | sort -u | wc -l`
NB_MATCHINGS=`find $FILESDIR -type f -exec grep -i $SEARCHSTR {} \; 2> /dev/null | wc -l`

echo "The number of files are $NB_FILES_WITH_STR and the number of matching lines are $NB_MATCHINGS"

exit 0
