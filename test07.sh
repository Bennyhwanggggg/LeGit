#!/bin/sh

# check the behaviour of rm--forced and branching

legit.pl init
seq 1 10 > file1
echo abcdefg > file2
echo line1 > file3
echo one > file4
echo two >> file4
legit.pl add file1 file2 file3 file4
legit.pl commit -m 'commit 1'
legit.pl branch b1
legit.pl rm --force file4
legit.pl commit -m 'commit 2'
legit.pl checkout b1
ls
perl -pi -e 's/1/114/' file1
cat file1
legit.pl add file1
legit.pl commit -a -m commit-3
legit.pl checkout master
cat file1
legit.pl branch b2
legit.pl branch b3
legit.pl checkout b2
seq 11 19 > file3
legit.pl commit -m commit-4
leigt.pl add file3
legit.pl checkout b3
legit.pl commit -a -m commit-5
legit.pl checkout master
legit.pl log


