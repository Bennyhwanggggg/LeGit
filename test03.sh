#!/bin/sh

# test 3 checks add, commit, rm --forced, status, log, add, commit, status, rm -- cached, status, legit rm
# aim to test if rm --forced and rm -- cahched is working properly and if status is correctly affected by them

legit.pl init 
echo 123456 > test_file1
echo abcdefg > test_file_2
echo line1 > test_file_3
legit.pl add test_file1 test_file_2 test_file_3 
legit.pl commit -m 'commit 1' 
legit.pl rm --force test_file_2 
legit.pl status 
legit.pl log 
echo another >> test_file1
legit.pl add test_file1 test_file_2 test_file_3 
legit.pl add test_file1 test_file_3 
legit.pl commit -m commit02 
legit.pl status 
legit.pl rm --cached test_file_3 
legit.pl status 
legit.pl rm test_file_3 
legit.pl rm --force test_file_3 

