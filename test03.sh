#!/bin/sh

# test 1 checks add, commit, log, add, log, commit, log, show, failed commit, log

test_folder="test3"
if test -e $test_folder
then
	rm -r $test_folder
fi

mkdir $test_folder
cp "legit.pl" "$test_folder/legit.pl"

cd $test_folder

test_file_1="file1"
test_file_2="file2"
test_file_3="file3"