#!/usr/bin/env bash

# Usage:
#    $0 <path to reads with fork probability equal or higher than 70%>
PATH_TO_READS=$1

# Error returned when the number of arguments is different of one.
E_NUMARG=1

# Checking the number of arguments.
if [ $# -ne 1 ]
then
   echo "Usage:"
   echo "   $0 <path to reads with fork probability equal or higher than 70%>"
   exit ${E_NUMARG}
fi

# Setting up the initial directories structure.
mkdir input output

# Making symbolic links for input data.
for READS in ${PATH_TO_READS}
do
   # Removing the first character ">" of the filename.
   ln -s ../${PATH_TO_READS}/${READS} input/${READS:1}
done

# Selecting only the coordinates with a fork probability (2nd and 3rd columns) equal or higher than
# 70% and redirecting it into a new file.
for FILE in `ls input/`
do
   head -n 1 input/${FILE} > input/filtered.${FILE}
   awk '$2>=0.7 || $3>=0.7 {print $0}' <(tail -n +2 input/${FILE}) >> input/filtered.${FILE}
done

exit 0
