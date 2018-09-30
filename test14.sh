#!/bin/sh

# check subset1 and 2 combined, rm and branch delete


legit.pl init
seq 1 10 > file1
echo abcdefg > file2
legit.pl add file1
legit.pl commit -m commit1
echo line1 > file3
legit.pl add file2 file3
seq 11 30 >> file1
legit.pl commit -a -m commit2
legit.pl branch b1
legit.pl checkout b1
legit.pl add file1 file2 file3
legit.pl commit -m commit3
legit.pl log
legit.pl rm --force file3
legit.pl rm --cached file1
legit.pl status
legit.pl commit -a -m commit4
legit.pl status
legit.pl log
echo newfile4 > file4
legit.pl add file4
legit.pl checkout master
legit.pl branch -d b1
legit.pl commit -m commit5
legit.pl status
legit.pl log
rm file4
legit.pl status
