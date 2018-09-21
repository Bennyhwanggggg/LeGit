#!/bin/sh

# test 2 checks add, commit, -a -m commit fail, -a -m commit, status, rm, legit rm, status
# check if rm and commit are working


legit.pl init
echo 123456 > file1
ls
legit.pl add file1
legit.pl commit -a -m commit2
legit.pl status
echo another >> file1 
legit.pl status
echo "file2" >> file2
echo "file3" >> file3
legit.pl commit -a -m commit3
legit.pl add file2 file3
legit.pl status
rm file2
legit.pl status
legit.pl rm file3
legit.pl commit -a -m commit4
legit.pl status
echo new > file4
legit.pl status
legit.pl add file4
legit.pl status
legit.pl rm file4
legit.pl status



