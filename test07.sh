#!/bin/sh

# test 7 checks add, commit, branch, rm --forced, checkout, add, commit, ls, checkout, ls, cat, status
# check the behaviour of rm--forced and branching

test_folder="test7"
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
test_file_4="file4"

touch $test_file_1 $test_file_2 $test_file_3 $test_file_4

# The expected result are retrived from reference implementation using the same commands
expected="expected.txt" 
touch $expected
result="result.txt"
touch $result

echo "legit.pl init:\nInitialized empty legit repository in .legit" >> $expected
echo "legit.pl add $test_file_1 $test_file_2 $test_file_3 $test_file_4:" >> $expected
echo "legit.pl commit -m 'commit 1':\nCommitted as commit 0" >> $expected
echo "legit.pl branch b1:" >> $expected
echo "legit.pl rm --force $test_file_4:" >> $expected
echo "legit.pl commit -m 'commit 2':\nCommitted as commit 1" >> $expected
echo "legit.pl checkout b1:\nSwitched to branch 'b1'" >> $expected
echo "expected.txt\n$test_file_1\n$test_file_2\n$test_file_3\n$test_file_4\nlegit.pl\nresult.txt" >> $expected
echo "114\n2\n3\n4\n5\n6\n7\n8\n9\n1140" >> $expected
echo "legit.pl add $test_file_1:" >> $expected
echo "legit.pl commit -a -m commit-3:\nCommitted as commit 2" >> $expected
echo "legit.pl checkout master:\nSwitched to branch 'master'" >> $expected
echo "1\n2\n3\n4\n5\n6\n7\n8\n9\n10" >> $expected



echo "legit.pl init:" >> $result
perl legit.pl init >> $result
seq 1 10 > $test_file_1
echo abcdefg > $test_file_2
echo line1 > $test_file_3
echo one > $test_file_4
echo two >> $test_file_4
echo "legit.pl add $test_file_1 $test_file_2 $test_file_3 $test_file_4:" >> $result
perl legit.pl add $test_file_1 $test_file_2 $test_file_3 $test_file_4 >> $result
echo "legit.pl commit -m 'commit 1':" >> $result
perl legit.pl commit -m 'commit 1' >> $result
echo "legit.pl branch b1:" >> $result
perl legit.pl branch b1 >> $result
echo "legit.pl rm --force $test_file_4:" >> $result
perl legit.pl rm --force $test_file_4 >> $result
echo "legit.pl commit -m 'commit 2':" >> $result
perl legit.pl commit -m 'commit 2' >> $result
echo "legit.pl checkout b1:" >> $result
perl legit.pl checkout b1 >> $result
ls >> $result
perl -pi -e 's/1/114/' $test_file_1
cat $test_file_1 >> $result
echo "legit.pl add $test_file_1:" >> $result
perl legit.pl add $test_file_1 >> $result
echo "legit.pl commit -a -m commit-3:" >> $result
perl legit.pl commit -a -m commit-3 >> $result
echo "legit.pl checkout master:" >> $result
perl legit.pl checkout master >> $result
cat $test_file_1 >> $result


if diff $result $expected >/dev/null
then
	echo "pass!"
else
	echo "failed"
	diff -y $result $expected
fi
