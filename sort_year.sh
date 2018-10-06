#!/bin/sh
PATH=/bin:/usr/bin/:/usr/sbin/; export PATH

if [ $# -lt 1 ] ; then
	echo "$0 Error: Not enough arguments" >&2
	exit 1
fi

#check the number of arguments 
if [ $# -eq 1 ] || [ $# -gt 1 ] ; then 
	
	args=("$@")
	for i in "$@" ; do
		echo $i
		#check if an argument isn't a file.
		if [ ! -e "$i" ] ; then
			echo "$0 Error: \""$i"\" is not a file or a directory" >&2

		#if its a directory, check the files within and move them.
		elif [ -d "$i" ] ; then
			echo "$0 Info: \""$i"\" is a directory, moving internal files"
			#file=("$(find $i -type f)")
			for j in "$i"/* ; do
				echo "$j"

				date=$(stat "$j" | grep Modify | awk '{ print $2 }' | awk -F- '{print $1}')
				echo $date

				#check if there is not a directory for that year
				if [ !  -d $date ] ; then
					echo "$date doesn't exist. creating..."
					mkdir ./$date
				fi
				echo "second loop"
				cp -pr "$j" ./$date
			done;



		else 
			echo $i
			#echo good

			#get the date the file was modified and set the var to it. 
			date=$(stat "$i" | grep Modify | awk '{ print $2 }' | awk -F- '{print $1}')
			echo $date

			#check if there is not a directory for that year
			if [ !  -d $date ] ; then
				echo "$date doesn't exist. creating..."
				mkdir ./$date
			fi
			cp -pr "$i" ./$date
		fi
		#sleep 1
	done
fi

#stat * | grep Modify | awk '{ print $2 }' | awk -F- '{print $1}'

