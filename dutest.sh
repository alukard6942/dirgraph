#!/bin/bash
# Array[0]=1
# Array[1]=2
# Array[2]=3
# Array[4]=5
# Array[5]=6

decleare -A Array

getfirst(){
	echo $1
	Array[$1]=`expr ${Array[$1]} + 1`
}

for file in `ls $PWD`; do
	getfirst `du  -a $file`
done


echo -----------Array-----------

echo ${Array[0]}
echo ${Array[1]}
echo ${Array[2]}
echo ${Array[3]}
echo ${Array[4]}
Array["hello"]=`expr ${Array["hello"]} + 1`
echo ${Array["hello"]}
echo ${Array[0]}


echo ----------- arr loop ------------------
for tmp in ${Array[@]}; do
	echo $tmp
done