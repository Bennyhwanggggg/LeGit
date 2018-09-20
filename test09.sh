#!/bin/sh

# test 9 checks add, commit, branch, rm, commit, checkout, merge conflict, checkout, delete
# check merge conflict and delete branch are working


legit.pl init
seq 1 10 > file1
echo abcdefg > file2
echo line1 > file3
legit.pl add file1 file2
legit.pl commit -m 'commit 1'
legit.pl branch b1
rm file2
perl -pi -e 's/1/114/' file1
legit.pl commit -a -m 'commit 2'
legit.pl checkout b1
ls
perl -pi -e 's/0/55/' file1
legit.pl commit -a -m commit-3
legit.pl checkout master
legit.pl merge b1 -m merge-1
legit.pl branch -d b1
