#!/usr/bin/env bash

# This script should be run redirecting its standard output to a file named tableStart.tsv located
# at output directory.

# Insert desired fork probability.
if [ $# -ne 1 ]
then
   echo "Usage: `basename $0` <FORK_PROBABILITY>"
   echo "Please, redirect standard output to output/tableStart.tsv"
   exit 1
fi

# Starting to build Potential Conflicts Table by extracting data from BrdU incorporated reads
# with a fork probability equal or higher than 70%.

# Function to compare two numbers. If the first number is greater than the second one, it returns
# the value 1; 0, otherwise (boolean values).
numCompare() {
   awk -v n1="$1" -v n2="$2" 'BEGIN {printf (n1>=n2?"1":"0")}'
}

# Header definition.
HEADER=`echo "Read Name\tChrom\tMapped Read Start (bp)\tMapped Read End (bp)\tMapped Read Size (bp)\tStrand\tFork Start (bp)\tFork End (bp)\tFork Size (bp)\tFork direction (+/-)"`
echo -e ${HEADER}

for FILE in `ls input/filtered.*`
do

  # Read coordinates extraction: Read Name (f1), Mapped Chromosome (f2), Mapped Read Start (f3) and
  # End (f4), Calculating Mapped read size (f4-f3), Strand (f5).
  READ_COORDINATES=`awk '{if(NR==1) print $0}' ${FILE} | cut -d' ' -f1-5 | awk -v OFS='\t' '{ print $1, $2, $3, $4, $4 - $3, $5 }'`
  
  START=""
  FORK_DIRECTION=""
  PREVIOUS_COORDINATE=""

  # Each line of the Potential Conflicts Table is a read, so the loop iterates among every read
  # file, removing the first identification line. The goal here is to add to the table the coordinates of
  # leftward and rightward moving forks with a fork probability equal or higher than 70%.
  IFS='
  '
  # First, consider only the second column, of a leftward moving fork.
  for LINE in `tail -n +2 ${FILE}`; do
    COORDINATE=`echo ${LINE} | cut -f1`
    LEFT=`echo ${LINE} | cut -f2`
    if [ `numCompare ${LEFT} $1` -eq 1 ]; then
      if [ -z ${START} ]
      then
        START=${COORDINATE}
      fi
      FORK_DIRECTION="LEFT"
      PREVIOUS_COORDINATE=${COORDINATE}
      continue
    else
      if [ ! -z ${START} ]
      then
        END=${PREVIOUS_COORDINATE}
        let "DIFF = END - START"
        echo -e "${READ_COORDINATES}\t${START}\t${END}\t${DIFF}\t${FORK_DIRECTION}"
        START=""
        FORK_DIRECTION=""
      fi
    fi
  done
  
  # Dealing with the last line.
  if [ ! -z ${START} ]
  then
    END=${PREVIOUS_COORDINATE}
    let "DIFF = END - START"
    echo -e "${READ_COORDINATES}\t${START}\t${END}\t${DIFF}\t${FORK_DIRECTION}"
  fi
  
  
  START=""
  FORK_DIRECTION=""
  PREVIOUS_COORDINATE=""

  # Then, consider only the third column, of a rightward moving fork.
  for LINE in `tail -n +2 ${FILE}`; do
    COORDINATE=`echo ${LINE} | cut -f1`
    RIGHT=`echo ${LINE} | cut -f3`
    if [ `numCompare ${RIGHT} $1` -eq 1 ]; then
      if [ -z ${START} ]
      then
        START=${COORDINATE}
      fi
      FORK_DIRECTION="RIGHT"
      PREVIOUS_COORDINATE=${COORDINATE}
      continue
    else
      if [ ! -z ${START} ]
      then
        END=${PREVIOUS_COORDINATE}
        let "DIFF = END - START"
        echo -e "${READ_COORDINATES}\t${START}\t${END}\t${DIFF}\t${FORK_DIRECTION}"
        START=""
        FORK_DIRECTION=""
      fi
    fi
  done

  # Dealing with the last line.
  if [ ! -z ${START} ]
  then
    END=${PREVIOUS_COORDINATE}
    let "DIFF = END - START"
    echo -e "${READ_COORDINATES}\t${START}\t${END}\t${DIFF}\t${FORK_DIRECTION}"
  fi

done

exit 0
