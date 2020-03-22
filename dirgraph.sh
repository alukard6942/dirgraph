#!/usr/bin/env bash

POSIXLY_CORRECT=yes

##############################################
#			 Global Variables				##
##############################################

DirCount=0
FileCount=0
rootDir="$PWD"
ignoredFiles=""
nFlag=false
Col=79
MaxLine=0



##############################################
##			counting each category			##
##############################################

for i in {1..8}; do 
	CountArray[$i]=0
done


##############################################
#			 	Functions					##
##############################################


updateCount() {
	#echo $1 , $2
	if   [[ $1 -le 100 ]] 		; then 	#0 100 B
		CountArray[0]=`expr ${CountArray[0]} + 1`
	elif [[ $1 -le 1024 ]] 		; then 	#1 1KiB
		CountArray[1]=`expr ${CountArray[1]} + 1`
	elif [[ $1 -le 10240 ]]		; then 	#2 10KiB
		CountArray[2]=`expr ${CountArray[2]} + 1`
	elif [[ $1 -le 102400 ]]	; then 	#3 100KiB
		CountArray[3]=`expr ${CountArray[3]} + 1`
	elif [[ $1 -le 1048576 ]]	; then 	#4 1MiB
		CountArray[4]=`expr ${CountArray[4]} + 1`
	elif [[ $1 -le 10485760 ]]	; then 	#5 10MiB
		CountArray[5]=`expr ${CountArray[5]} + 1`
	elif [[ $1 -le 104857600 ]]	; then 	#6 100MiB
		CountArray[6]=`expr ${CountArray[6]} + 1`
	elif [[ $1 -le 1073741824 ]]; then 	#7 1GiB
		CountArray[7]=`expr ${CountArray[7]} + 1`
	else 								#8 >1GiB
		CountArray[8]=`expr ${CountArray[8]} + 1`
	fi
}


MainLoop() {
	#echo "$1"
	for file in `ls "$1"`; do  		#### TODO --quoting-style=[something]
		if [ -d "$1/$file" ]; then
			DirCount=`expr $DirCount + 1`
			MainLoop "$1/$file"
		else
			updateCount `du -B 1 "$1/$file"`
			FileCount=`expr $FileCount + 1`
		fi 
	done
}

drawLine() {
	count=$1
	Col=`expr $(tput cols) - 13`
	if [[ nFlag ]]; then
		count=`expr $count \* $Col`
		count=`expr $count / $MaxLine`
	elif [[ count -gt $Col ]]; then
		count=$Col
	fi 

	while [[ $count -gt 0 ]]; do
		echo -n "#"
		count=`expr $count - 1`
	done
}

getMaxLine() {
	for tmp in ${CountArray[@]}; do
		if [[ $tmp -gt $MaxLine ]]; then
			MaxLine=$tmp
		fi
	done
}

##############################################
## 				Get opt 					##
##############################################


while getopts ":ni:" opt; do
  case ${opt} in
    n ) nFlag=true
		shift
		;;
    i ) echo i ;shift
		;;
    \?) echo "Usage: $0 [-n] [directory]"; exit 1
    	;;
  esac
done



if [[ "$1" != "" ]]; then
	rootDir=$1
fi


##############################################
## 					Main 					##
##############################################

MainLoop $rootDir

if [[ "a " =~ ^[]$ ]] 
	then
  	echo hello
fi

echo "Root directory:" 		$rootDir
echo "Directories:"			$DirCount
echo "All files:" 			$FileCount
echo "File size histogram:"

if [[ $nFlag ]]; then
	MaxLine= getMaxLine
fi


echo "  <100 B  :" $(drawLine ${CountArray[0]})
echo "  <1 KiB  :" $(drawLine ${CountArray[1]})
echo "  <10 KiB :" $(drawLine ${CountArray[2]})
echo "  <100 KiB:" $(drawLine ${CountArray[3]})
echo "  <1 MiB  :" $(drawLine ${CountArray[4]})
echo "  <10 MiB :" $(drawLine ${CountArray[5]})
echo "  <100 MiB:" $(drawLine ${CountArray[6]})
echo "  <1 GiB  :" $(drawLine ${CountArray[7]})
echo "  >=1 GiB :" $(drawLine ${CountArray[8]})
