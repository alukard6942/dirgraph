#!/usr/bin/env bash

POSIXLY_CORRECT=yes

##############################################
#			 Global Variables				##
##############################################

DirCount=0
FileCount=0
rootDir="$PWD"
ignoredFiles="\$a"
nFlag=false
Col=79
MaxLine=0



##############################################
##			counting each category			##
##############################################

# for i in {1..8}; do 
# 	Arr[$i]=0
# done

for i in 0 1 2 3 4 5 6 7 8 ; do
	eval Arr$i=0
done


##############################################
#			 	Functions					##
##############################################


updateCount() {
	#echo $1 , $2
	if   [ $1 -le 100 ] 		; then 	#0 100 B
		Arr0=`expr $Arr0 + 1`
	elif [ $1 -le 1024 ] 		; then 	#1 1KiB
		Arr1=`expr $Arr1 + 1`
	elif [ $1 -le 10240 ]		; then 	#2 10KiB
		Arr2=`expr $Arr2 + 1`
	elif [ $1 -le 102400 ]		; then 	#3 100KiB
		Arr3=`expr $Arr3 + 1`
	elif [ $1 -le 1048576 ]		; then 	#4 1MiB
		Arr4=`expr $Arr4 + 1`
	elif [ $1 -le 10485760 ]	; then 	#5 10MiB
		Arr5=`expr $Arr5 + 1`
	elif [ $1 -le 104857600 ]	; then 	#6 100MiB
		Arr6=`expr $Arr6 + 1`
	elif [ $1 -le 1073741824 ]	; then 	#7 1GiB
		Arr7=`expr $Arr7 + 1`
	else 								#8 >1GiB
		Arr8=`expr $Arr8 + 1`
	fi
}


MainLoop() {
	for file in "$1"/* ; do 
		if ! $(echo `basename "${file}"` | grep -qxe $ignoredFiles ) ; then
			#echo `basename "${file}"` -qxe "$ignoredFiles"
			if [ -d "$file" ]; then
				DirCount=`expr $DirCount + 1`
				MainLoop "$file"
			# elif [ -d "$file" ]; then
			# 	DirCount=`expr $DirCount + 1`
			elif [ -f $file ]; then
				updateCount `du -B 1 "$file"`
				FileCount=`expr $FileCount + 1`
			fi 
		fi
	done
}

drawLine() {
	count=$1
	if [ -t 1 ]; then
		Col=`expr $(tput cols) - 1`
	fi
	Col=`expr $Col - 12`

	if $nFlag && [ $count -gt 0 ]; then
		count=`expr $count \* $Col`
		count=`expr $count / $MaxLine`
	elif [ $count -gt $Col ]; then
		count=$Col
	fi 

	while [ $count -gt 0 ]; do
		echo -n "#"
		count=`expr $count - 1`
	done
}

getMaxLine() {
	for tmp in $Arr0 $Arr1 $Arr2 $Arr3 $Arr4 $Arr5 $Arr6 $Arr7 $Arr8; do
		if [ $tmp -gt $MaxLine ]; then
			MaxLine=$tmp
		fi
	done
}

Usage() {
	echo "Usage:" 
	echo "    $0 [-n] [-i REGEX] [FILE]"
}

##############################################
## 				Get opt 					##
##############################################


while getopts ":ni:" opt; do
  case ${opt} in
    n ) nFlag=true	
		;;
    i ) ignoredFiles=$OPTARG
		;;
    \?) Usage
    	;;
  esac
done
shift $((OPTIND -1))


if [ "$1" != ""  ]; then
	if [ -d "$1" ]; then
		rootDir=$1
	else 
		Usage 
		exit 1
	fi
fi


##############################################
## 					Main 					##
##############################################

MainLoop "$rootDir"


echo "Root directory:" 		"$rootDir"
echo "Directories:"			"$DirCount"
echo "All files:" 			"$FileCount"
echo "File size histogram:"

if $nFlag ; then
	getMaxLine
fi

echo -n "  <100 B  :"; drawLine "$Arr0" ; echo
echo -n "  <1 KiB  :"; drawLine "$Arr1" ; echo
echo -n "  <10 KiB :"; drawLine "$Arr2" ; echo
echo -n "  <100 KiB:"; drawLine "$Arr3" ; echo
echo -n "  <1 MiB  :"; drawLine "$Arr4" ; echo
echo -n "  <10 MiB :"; drawLine "$Arr5" ; echo
echo -n "  <100 MiB:"; drawLine "$Arr6" ; echo
echo -n "  <1 GiB  :"; drawLine "$Arr7" ; echo
echo -n "  >=1 GiB :"; drawLine "$Arr8" ; echo
