#!/usr/bin/env bash

DirCount=0
FileCount=0

ArrayCount[0]=0
ArrayCount[1]=0
ArrayCount[2]=0
ArrayCount[3]=0
ArrayCount[4]=0
ArrayCount[5]=0
ArrayCount[6]=0
ArrayCount[7]=0
ArrayCount[8]=0

updateCount() {
	#echo $1 , $2
	if   [[ $1 -le 100 ]] 		; then 	#0 100 B
		ArrayCount[0]=`expr ${ArrayCount[0]} + 1`
	elif [[ $1 -le 1024 ]] 		; then 	#1 1KiB
		ArrayCount[1]=`expr ${ArrayCount[1]} + 1`
	elif [[ $1 -le 10240 ]]		; then 	#2 10KiB
		ArrayCount[2]=`expr ${ArrayCount[2]} + 1`
	elif [[ $1 -le 102400 ]]	; then 	#3 100KiB
		ArrayCount[3]=`expr ${ArrayCount[3]} + 1`
	elif [[ $1 -le 1048576 ]]	; then 	#4 1MiB
		ArrayCount[4]=`expr ${ArrayCount[4]} + 1`
	elif [[ $1 -le 10485760 ]]	; then 	#5 10MiB
		ArrayCount[5]=`expr ${ArrayCount[5]} + 1`
	elif [[ $1 -le 104857600 ]]	; then 	#6 100MiB
		ArrayCount[6]=`expr ${ArrayCount[6]} + 1`
	elif [[ $1 -le 1073741824 ]]; then 	#7 1GiB
		ArrayCount[7]=`expr ${ArrayCount[7]} + 1`
	else 								#8 >1GiB
		ArrayCount[8]=`expr ${ArrayCount[8]} + 1`
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
			updateCount `du -B 1 "$1/$file"`
			FileCount=`expr $FileCount + 1`

		fi 
	done
}

drawLine() {
	#echo $1
	count=$1
	if [[ count -gt $(tput cols)-12 ]] ;then
		count=`expr $(tput cols) - 12`
	fi 

	#echo $count $(tput cols)

	while [[ $count -gt 0 ]]; do
		echo -n "#"
		count=`expr $count - 1`
	done
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

echo "  <100 B  :" $(drawLine ${ArrayCount[0]})
echo "  <1 KiB  :" $(drawLine ${ArrayCount[1]})
echo "  <10 KiB :" $(drawLine ${ArrayCount[2]})
echo "  <100 KiB:" $(drawLine ${ArrayCount[3]})
echo "  <1 MiB  :" $(drawLine ${ArrayCount[4]})
echo "  <10 MiB :" $(drawLine ${ArrayCount[5]})
echo "  <100 MiB:" $(drawLine ${ArrayCount[6]})
echo "  <1 GiB  :" $(drawLine ${ArrayCount[7]})
echo "  >=1 GiB :" $(drawLine ${ArrayCount[8]})
