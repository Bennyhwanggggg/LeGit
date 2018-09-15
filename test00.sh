#!/bin/sh

# test 0 checks error message and add, commit, commit, commit -a -m

test_folder="test0"
if test -e $test_folder
then
	rm -r $test_folder
fi

mkdir $test_folder
cp "legit.pl" "$test_folder/legit.pl"

cd $test_folder

test_file_1="file1"

# The expected result are retrived from reference implementation using the same commands
expected="expected.txt" 
touch $expected
echo "legit.pl init:\nInitialized empty legit repository in .legit" >> $expected
echo "legit.pl commit:\nusage: legit.pl commit [-a] -m commit-message" >> $expected
echo "legit.pl log:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl show:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl show :a:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl commit -a -m test:\nnothing to commit" >> $expected
echo "legit.pl rm:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl rm --force:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl rm --cached:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl status:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl branch:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl commit -m test:\nnothing to commit" >> $expected
echo "legit.pl branch -d test:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "legit.pl merge:\nlegit.pl: error: your repository does not have any commits yet" >> $expected
echo "12345" >> $expected
echo "legit.pl add $test_file_1:" >> $expected
echo "12345\nabcde" >> $expected
echo "legit.pl commit -m commit1:\nCommitted as commit 0" >> $expected
echo "legit.pl commit -m commit2:\nnothing to commit" >> $expected
echo "legit.pl commit -a -m commit3:\nCommitted as commit 1" >> $expected

result="result.txt"
touch $result

echo "legit.pl init:" >> $result
perl legit.pl init >> $result
echo "legit.pl commit:" >> $result
perl legit.pl commit >> $result
echo "legit.pl log:" >> $result
perl legit.pl log >> $result
echo "legit.pl show:" >> $result
perl legit.pl show >> $result
echo "legit.pl show :a:" >> $result
perl legit.pl show :a >> $result
echo "legit.pl commit -a -m test:" >> $result
perl legit.pl commit -a -m test >> $result
echo "legit.pl rm:" >> $result
perl legit.pl rm >> $result
echo "legit.pl rm --force:" >> $result
perl legit.pl rm --force >> $result
echo "legit.pl rm --cached:" >> $result
perl legit.pl rm --cached >> $result
echo "legit.pl status:" >> $result
perl legit.pl status >> $result
echo "legit.pl branch:" >> $result
perl legit.pl branch >> $result
echo "legit.pl commit -m test:" >> $result
perl legit.pl commit -m test >> $result
echo "legit.pl branch -d test:" >> $result
perl legit.pl branch -d test >> $result
echo "legit.pl merge:" >> $result
perl legit.pl merge >> $result
echo "12345" > $test_file_1
cat $test_file_1 >> $result
echo "legit.pl add $test_file_1:" >> $result
perl legit.pl add $test_file_1 >> $result
echo "abcde" >> $test_file_1
cat $test_file_1 >> $result
echo "legit.pl commit -m commit1:" >> $result
perl legit.pl commit -m commit1 >> $result
echo "another line" >> $test_file_1
echo "legit.pl commit -m commit2:" >> $result
perl legit.pl commit -m commit2 >> $result
echo "legit.pl commit -a -m commit3:" >> $result
perl legit.pl commit -a -m commit3 >> $result


if diff $result $expected >/dev/null
then
	echo "pass!"
else
	echo "failed"
	diff $result $expected
fi
