#!/bin/sh

# test 2 checks add, commit, -a -m commit fail, -a -m commit, status, rm, legit rm, status, add, commit, status 

test_folder="test2"
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