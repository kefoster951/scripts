#!/bin/sh

while true; do
	temp=$(sensors |  grep +100 |  awk 'NR ==1{ print $4 }' | sed s/+/""/ | awk -F. '{ print $1}')
	if [ $temp -gt 63 ]; then
		 twmnc -t "Warning: High CPU Temp" -c $(sensors |  grep +100 | sed s/Package/""/ |  awk ' NR==1 { print $3}')

	 fi
	sleep 10
done
