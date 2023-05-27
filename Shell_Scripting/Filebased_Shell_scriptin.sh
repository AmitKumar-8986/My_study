#!/bin/bash
while true; do	
echo -e "1. Make a file \n2. Display content \n3) copy the file \n4) Rename the file \n5) Delete the file \n6)  Exit \nEnter your options : " 
read a
#read -p "Enter a file name : " f
if [[ $a == "1" ]]; then
	read -p "Enter a file name : " f
	if [[ -f $f ]]; then
		echo "File already exist "
	else
		cat > $f
	fi
elif [[ $a == "2" ]]; then
	read -p "Enter a file name : " f
	if [[ ! -f $f ]]; then
		echo "File don't exist "
	else
		cat $f
	fi
elif [[ $a == "3" ]]; then
	read -p "Enter a file name : " f
	if [[ -f $f ]]; then
		if [[ -r $f ]]; then
			read -p "Enter a name of target file name : " m
			if [[ ! -f $m ]]; then
				cp $f $m
				echo "File is successfully copyed"
			else
				echo "Target File already exist"
			fi
		else
			echo "File is not readable "
		fi
	else
		echo " Source file is not found "
	fi
elif [[ $a == "4" ]]; then
	read -p "Enter a file name : " f
        if [[ -f $f ]]; then
                if [[ -r $f ]]; then
                        read -p "Enter a name of target file name : " m
                        if [[ ! -f $m ]]; then
                                mv $f $m
                                echo "File is successfully renamed"
                        else
                                echo "Target File already exist"
                        fi
                else
                        echo "File is not readable "
                fi
        else
                echo " Source file is not found "
        fi
elif [[ $a == "5" ]]; then
	read -p "Enter a file name : " f
        if [[ -f $f ]]; then
		if [[  -w $f ]]; then
			read -p "Do you want to delete it Press:(y/n) " ch
			if [[ $ch == "y" ]]; then
				rm -rf $f
				echo "File is deleted Successfully"
			fi
		else
			echo "file is not writable"
		fi
	else 
		echo "file dosen't exist"
	fi
elif [[ $a == "6" ]]; then
	exit 
fi
done
