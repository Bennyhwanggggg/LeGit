#!/bin/sh

# check subset0 check many commits


legit.pl init
seq 1 10 > file1
echo abcdefg > file2
legit.pl add file1
legit.pl commit -m commit1
echo line1 > file3
legit.pl add file2 file3
seq 11 30 >> file1
legit.pl commit -m commit2
legit.pl commit -a -m commit3
seq 10 100 >> file2
legit.pl commit -m commit4
legit.pl commit -a -m commit5
rm file3
legit.pl commit -m commit6
legit.pl status
legit.pl log
echo new > file4
legit.pl add file4
legit.pl commit -m commit7
echo new_2 > file5
echo another >> file4
echo another >> file3
echo another >> file2
legit.pl add file 2
legit.pl commit -m commit8
legit.pl add file5 
legit.pl commit -m commit9
legit.pl show :file3
legit.pl show :file2
legit.pl show :file4
legit.pl show 0:file2
legit.pl show 1:file3
legit.pl show 1:file4
legit.pl commit -a -m commit10
legit.pl log
legit.pl show 8:file1
legit.pl show 9:file1
echo end >> file1
legit.pl commit -a -m commit11
legit.pl log
legit.pl show :file1
legit.pl rm *
legit.pl commit -m commit12
legit.pl status
legit.pl log