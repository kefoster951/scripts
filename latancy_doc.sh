#!/bin/bash
Version="0.3 Bata"
Author="Kenneth Foster"

help_menu="
usage: $0 -d <IP> -f <INPUT fILE>

-d,	Required option, the destination ip for the connection you want to track
-f,	Required option, this is the input file for the script to read from.  it should contain the output of fw monitor with the flags -T -u.
-v,	show the version and exit
-h, 	show this help menu and exit
"

#Function to confirm that an IP is correctly formated
function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
        echo $stat
    return $stat

}

#Function to calculate the time difference between to timestamps
function time_diff()
{
        local time1=$1
        local time2=$2
        #echo $time1 $time2
        local time1_nano=$(date +%S%N -d $time1)
        local time2_nano=$(date +%S%N -d $time2)
        #echo $time1_nano
        #echo $time2_nano
        echo "scale=5; ($time2_nano - $time1_nano)/1000000" | bc

}

if [ $# -eq 0 ]; then
	echo "$0: Error: No options provided" >&2
	echo "$help_menu"
	exit 1
fi
while getopts ":vhd:f:" opt; do
  	case $opt in
		v)
			echo "version: $Version"
			exit 0
		;;
		d)
			DEST=$OPTARG
			if [ ! $(valid_ip $OPTARG) -eq 0 ]; then 
				echo "$0: -d:$OPTARG is not a valid IP address"	>&2
				exit 1
			fi
   		;;
		f)
			if [ -r $OPTARG  ]; then
				inFile=$OPTARG
			else
				echo "$0: -f: $OPTARG is not a vaild file. make sure the file exists and is readable" >&2
				exit 1
			fi
		;;
		h)
			echo "$help_menu"
		exit 0
		;;
    		\?)
      			echo "Invalid option: -$OPTARG" >&2
      			exit 1
      		;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
      			exit 1
		;;
	esac	
done

#get the first id before the UUID is set, and the time of the first packet.
firstID=( $(sed 'N; s/\(id=[0-9]*\)\n/\1 /g' $inFile | grep -e "\[00000000 - 00000000 00000000 00000000 00000000\].*$DEST" | awk 'NR==1 { print $3" "$15}') )

#use the id of the first packet to get the UUID for the connection
UUID=$(grep -e ${firstID[1]}  test2| awk -F"[" 'NR==2 {print $4; } ' | awk -F] '{print $1}')

#create an array of all the times and id for the packets in the connection
arr=( $(echo " ${firstID[@]}"; grep "$UUID" test2 | awk '{print $3" "$15}') )
arr_count=${#arr[@]}
echo $arr_count
for i in ${!arr[@]}; do
	if [ $(($i % 2 )) -eq 0 ]; then
		if [ ! $i -eq $((arr_count -2)) ]; then
			echo old $i
			echo i is ${arr[$i]}
			id=$((i+1))
			j=$((i+2))
			jid=$((j+1))
	
			echo j is${arr[$j]}
			echo id ${arr[$id]}
			echo jid ${arr[$jid]}
				#if [  ${arr[$id]} = ${arr[$jid]} ]; then
					timeMS=$(time_diff "${arr[$i]}" "${arr[$j]}")
					echo "$timeMS" ms
				#else
					#echo failed
				#fi
			sleep 5
		fi
	fi
	i=$((i+2))
	echo new $i
done

#echo ${firstID[@]}
#echo ${arr[@]} | sed 's/\(id=[0-9]*\)/\1\n/g' | nl
