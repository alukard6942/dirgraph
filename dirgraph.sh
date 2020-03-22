#!/usr/bin/env bash

DirCount=0
FileCount=0

declare -a ArrayCount

updateCount() {
	#echo $1 , $2
	if   [[ $1 -le 100 ]] 		; then 	#0 100 B
		Array[0]=`expr ${Array[0]} + 1`
	elif [[ $1 -le 1024 ]] 		; then 	#1 1KiB
		Array[1]=`expr ${Array[1]} + 1`
	elif [[ $1 -le 10240 ]]		; then 	#2 10KiB
		Array[2]=`expr ${Array[2]} + 1`
	elif [[ $1 -le 102400 ]]	; then 	#3 100KiB
		Array[3]=`expr ${Array[3]} + 1`
	elif [[ $1 -le 1048576 ]]	; then 	#4 1MiB
		Array[4]=`expr ${Array[4]} + 1`
	elif [[ $1 -le 10485760 ]]	; then 	#5 10MiB
		Array[5]=`expr ${Array[5]} + 1`
	elif [[ $1 -le 104857600 ]]	; then 	#6 100MiB
		Array[6]=`expr ${Array[6]} + 1`
	elif [[ $1 -le 1073741824 ]]; then 	#7 1GiB
		Array[7]=`expr ${Array[7]} + 1`
	else 								#8 >1GiB
		Array[8]=`expr ${Array[8]} + 1`
	fi
}


MainLoop() {
	#echo "$1"
	for file in `ls "$1"`; do  		#### TODO --quoting-style=[something]
		if [ -d "$1/$file" ]; then
			DirCount=`expr $DirCount + 1`
			#echo "d: $file"
			MainLoop "$1/$file"
		else
			updateCount `du -s -B 1 "$1/$file"`
			FileCount=`expr $FileCount + 1`

		fi 
	done
}

drawLine() {
	echo $1
}


rootDir="$PWD"

if [[ "$1" != "" ]] ;then
	rootDir=$1
fi

MainLoop $rootDir
echo "Root directory:" $rootDir
echo "Directories: $DirCount"
echo "All files: $FileCount"
echo "File size histogram:"

echo "<100B" ${ArrayCount[0]}
echo "<100B" ${ArrayCount[1]}
echo "<100B" ${ArrayCount[2]}
echo "<100B" ${ArrayCount[3]}