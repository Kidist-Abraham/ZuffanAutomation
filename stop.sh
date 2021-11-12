#!/bin/bash

set -e
while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
   fi

  shift
done

if [[ -z "$file" ]]; then
    echo "Must provide the file." 1>&2
    exit 1
fi


docker stop $file 
