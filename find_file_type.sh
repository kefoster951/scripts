#!/bin/sh
PATH=/bin:/usr/bin/:/usr/sbin; export PATH
if [ $# -lt 1 ] ; then
	echo "$0 Usage: $0 expects at least one argument"
	exit 1
fi

#echo $(pwd)
if [ $# -eq 1 ] ; then 
	
	find $(pwd) -name *.$1
	exit 0
elif [ $# -gt 1 ] ; then
	if [ -d $2 ] ; then 


		FILECONT=$(find $2 -name *.$1 | wc -l)

		if [ $FILECONT -eq 0 ] ; then
			echo "$0 Error: there where no $1 files found in $2"
			exit 1
		fi
	
		if [ $# -eq 3 ] ; then
			echo $3/$1
	
			if [ -d $3 ] ; then

				if [ ! -d $3/$1 ] ; then
					echo "Making directory $3/$1"
					mkdir $3/$1;
				fi
				echo "coping files..."
				cp $(find $2 -name *.$1) $3/$1/;
				echo "done"
				read -p "we found $FILECONT .$1 files in $2 and moved them to $3. would you like to remove them from $2? (y/n):" del

				case $del in
					[yY]*)
						read -p "this will permanently delete all $1 files in $2. are you sure you would like to remove them? (y/n)" Conf

						case $Conf in
							[yY]*)
								echo "removing $FILECONT from$2..."
								rm $(find $2 -name *.$1)
								echo "done"
								break
								;;
							[nN]*)
								echo "exiting..."
								break
								;;
							*)
								echo "unknown option"
								echo "exiting..."
								exit 1
								;;
						esac
						break
						;;
					[nN]*)
						echo "exiting..."
						exit 0
						break
						;;
					*)
						echo "unknown option"
						echo "exiting..."
						exit 1
						break
						;;
				esac
				exit 0
			else
				echo "$0 Error: $3 is not a directory"
				exit 1		

			fi
		else
			find $2/ -name "*.$1"
		fi
	else
		echo "$0 Error: $2 is not a directory"
		exit 1
	fi
fi
