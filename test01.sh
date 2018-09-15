#!/bin/sh

# test 1 checks add, commit, log, add, log, commit, log, show, failed commit, log

test_folder="test1"
if test -e $test_folder
then
	rm -r $test_folder
fi

mkdir $test_folder
cp "legit.pl" "$test_folder/legit.pl"

cd $test_folder

test_file_1="file1"
test_file_2="file2"

# The expected result are retrived from reference implementation using the same commands
expected="expected.txt" 
touch $expected
echo "legit.pl init:\nInitialized empty legit repository in .legit" >> $expected
echo "legit.pl add $test_file_1:" >> $expected
echo "1\n2\n3\n4\n5\n6\n7\n8\n9\n10" >> $expected
echo "legit.pl log:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl commit -m commit 1:\nusage: legit.pl commit [-a] -m commit-message" >> $expected
echo "legit.pl commit -m commit-1:\nCommitted as commit 0" >> $expected
echo "legit.pl log:\n0 commit-1" >> $expected
echo "legit.pl add $test_file_1 $test_file_2:" >> $expected
echo "legit.pl log:\n0 commit-1" >> $expected
echo "legit.pl commit -m commit-2:\nCommitted as commit 1" >> $expected
echo "legit.pl log:\n1 commit-2\n0 commit-1" >> $expected
echo "legit.pl show 4:$test_file_1:\nlegit.pl: error: unknown commit '4'" >> $expected
echo "legit.pl show 4:unknown:\nlegit.pl: error: unknown commit '4'" >> $expected
echo "legit.pl show 0:unknown:\nlegit.pl: error: 'unknown' not found in commit 0" >> $expected
echo "legit.pl show 0:$test_file_1:\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10" >> $expected
echo "legit.pl show 1:$test_file_1:\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10\nnew line" >> $expected
echo "legit commit -m commit-3:\nnothing to commit" >> $expected
echo "legit.pl log:\n1 commit-2\n0 commit-1" >> $expected





result="result.txt"
touch $result

echo "legit.pl init:" >> $result
perl legit.pl init >> $result
seq 1 10 > $test_file_1
echo "legit.pl add $test_file_1:" >> $result
perl legit.pl add $test_file_1 >> $result
cat $test_file_1 >> $result
echo "legit.pl log:" >> $result
perl legit.pl log >> $result
echo "legit.pl commit -m commit 1:" >> $result
perl legit.pl commit -m commit 1 >> $result
echo "legit.pl commit -m commit-1:" >> $result
perl legit.pl commit -m commit-1 >> $result
echo "legit.pl log:" >> $result
perl legit.pl log >> $result
echo line1 > $test_file_2
echo new line >> $test_file_1
echo "legit.pl add $test_file_1 $test_file_2:" >> $result
perl legit.pl add $test_file_1 >> $result
echo "legit.pl log:" >> $result
perl legit.pl log >> $result 
echo "legit.pl commit -m commit-2:" >> $result
perl legit.pl commit -m commit-2 >> $result
echo "legit.pl log:" >> $result
perl legit.pl log >> $result 
echo "legit.pl show 4:$test_file_1:" >> $result
perl legit.pl show 4:$test_file_1 >> $result
echo "legit.pl show 4:unknown:" >> $result
perl legit.pl show 4:unknown >> $result
echo "legit.pl show 0:unknown:" >> $result
perl legit.pl show 0:unknown >> $result
echo "legit.pl show 0:$test_file_1:" >> $result
perl legit.pl show 0:$test_file_1 >> $result
echo "legit.pl show 1:$test_file_1:" >> $result
perl legit.pl show 1:$test_file_1 >> $result
echo "legit commit -m commit-3:" >> $result
perl legit.pl commit -m commit-3 >> $result
echo "legit.pl log:" >> $result
perl legit.pl log >> $result 


if diff $result $expected >/dev/null
then
	echo "pass!"
else
	echo "failed"
	diff $result $expected
fi











