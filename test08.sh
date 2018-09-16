#!/bin/sh

# test 7 checks add, commit, branch, checkout, add, commit, checkout, log, merge, log
test_folder="test8"
if test -e $test_folder
then
	rm -r $test_folder
fi

mkdir $test_folder
cp "legit.pl" "$test_folder/legit.pl"

cd $test_folder

test_file_1="file1"
test_file_2="file2"
test_file_3="file3"


# The expected result are retrived from reference implementation using the same commands
expected="expected.txt" 
touch $expected
result="result.txt"
touch $result

echo "legit.pl init:\nInitialized empty legit repository in .legit" >> $expected
echo "legit.pl add $test_file_1 $test_file_2:" >> $expected
echo "legit.pl commit -m 'commit 1':\nCommitted as commit 0" >> $expected
echo "legit.pl branch b1:" >> $expected
echo "legit.pl checkout b1:\nSwitched to branch 'b1'" >> $expected
echo "expected.txt\n$test_file_1\n$test_file_2\n$test_file_3\nlegit.pl\nresult.txt" >> $expected
echo "legit.pl add $test_file_3:" >> $expected
echo "legit.pl commit -m commit-2:\nCommitted as commit 1" >> $expected
echo "legit.pl checkout master:\nSwitched to branch 'master'" >> $expected
echo "expected.txt\n$test_file_1\n$test_file_2\nlegit.pl\nresult.txt" >> $expected
echo "legit.pl log:\n0 commit 1" >> $expected
echo "legit.pl merge b1 -m merge-b1-master:\nCommitted as commit 1" >> $expected


echo "legit.pl init:" >> $result
perl legit.pl init >> $result
seq 1 10 > $test_file_1
echo abcdefg > $test_file_2
echo line1 > $test_file_3
echo "legit.pl add $test_file_1 $test_file_2:" >> $result
perl legit.pl add $test_file_1 $test_file_2 >> $result
echo "legit.pl commit -m 'commit 1':" >> $result
perl legit.pl commit -m 'commit 1' >> $result
echo "legit.pl branch b1:" >> $result
perl legit.pl branch b1 >> $result
echo "legit.pl checkout b1:" >> $result
perl legit.pl checkout b1 >> $result
ls >> $result
perl -pi -e 's/1/114/' $test_file_1
echo "legit.pl add $test_file_3:" >> $result
perl legit.pl add $test_file_3 >> $result
echo "legit.pl commit -m commit-2:" >> $result
perl legit.pl commit -m commit-2 >> $result
echo "legit.pl checkout master:" >> $result
perl legit.pl checkout master >> $result
ls >> $result
echo "legit.pl log:" >> $result
perl legit.pl log >> $result
echo "legit.pl merge b1 -m merge-b1-master:" >> $result
perl legit.pl merge b1 -m merge-b1-master >> $result



if diff $result $expected >/dev/null
then
	echo "pass!"
else
	echo "failed"
	diff -y $result $expected
fi
