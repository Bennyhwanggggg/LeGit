#!/bin/sh

# aim to check if rm --cache and forced are affecting the ability to commit properly

legit.pl init 
echo 123456 > file1
echo abcdefg > file2
echo line1 > file3
legit.pl add file1 file2 file3 
legit.pl commit -m 'commit 1' 
legit.pl rm --cached file2 
legit.pl status 
legit.pl commit -a -m commit2 
legit.pl status 
legit.pl commit -m commit3 
legit.pl log 
legit.pl rm --cached file1 file3 
legit.pl commit -a -m commit4 
legit.pl rm --cached file1 
legit.pl commit -m commit5
legit.pl commit -a -m commit6
echo test >> file3
legit.pl add file3
legit.pl status
legit.pl log
echo abcdefg >> file2
legit.pl add file2
legit.pl commit -m commit7
legit.pl show :file1
legit.pl show :file2
legit.pl show 0:file1



