#!/bin/sh

# test 8 checks add, commit, branch, checkout, add, commit, checkout, log, merge, log
# check if branch, merge and log are working as intended

legit.pl init
seq 1 10 > file1
echo abcdefg > file2
echo line1 > file3
legit.pl add file1 file2
legit.pl commit -m 'commit 1'
legit.pl branch b1
legit.pl checkout b1
ls
perl -pi -e 's/1/114/' file1
legit.pl add file3
legit.pl commit -m commit-2
legit.pl checkout master
ls
legit.pl log
legit.pl merge b1 -m merge-b1-master

