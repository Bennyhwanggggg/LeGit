#!/bin/sh

# test 6 checks add, commit, rm --cached, branch, rm --cached, checkout, status, add, status, checkout
# check the behaviour of rm -- cached and branching


legit.pl init
echo 123456 > file1
echo abcdefg > file2
echo line1 > file3
legit.pl add file1 file2 file3
legit.pl branch b1
legit.pl commit -m 'commit 1'
legit.pl rm --cached file2
legit.pl status
legit.pl branch b1
legit.pl rm --cached file3
legit.pl checkout b1
legit.pl status
legit.pl add file2
legit.pl status
legit.pl checkout master
echo qwer > file1
legit.pl commit -a -m commit2
legit.pl log
legit.pl status
legit.pl add file2
echo hjkl >> file2
legit.pl status

