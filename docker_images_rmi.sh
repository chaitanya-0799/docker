#!/bin/bash

docker images > delete

# Count the number of lines in the 'delete' file

num=$(wc -l < delete)

# Start from the second line to skip the header
i=2

# Loop through all images and remove them

while [ $i -le $num ]; do
    
    # Get the image name and tag from the 'delete' file
    
    name=$(sed -n "${i}p" delete | awk '{print $1}')
    tag=$(sed -n "${i}p" delete | awk '{print $2}')

    # Remove the Docker image
    
    docker rmi "$name:$tag"

    # Increment the line counter
    
    i=$((i+1))
done

# Clean up by removing the temporary 'delete' file
rm -f delete
