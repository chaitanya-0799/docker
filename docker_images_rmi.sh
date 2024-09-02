#! /bin/bash

docker images >> images

num=$(wc -l images | awk '{print $1}')
i=2

while [ i <= $num ]
do 
	name=$(sed -n '$i p' images | awk '{print$1}' )
	echo $name
	i=$((i+1))
done << images

rm images
