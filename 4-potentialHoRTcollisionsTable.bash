#!/usr/bin/env bash

# Finalizing Potential Conflicts Table by correlating mapped reads with a fork probability equal or
# higher than 70% with the anottated genome.   

# Starting table file, generated in the step 2-tableStart2.bash.
FILENAME="output/tableStart2.tsv"

# Adapted GFF file, generated in the step 3-gffAdaptor.bash.
GFF_FILENAME="output/gff.tsv"

# Header definition.
HEADER=`head -1 ${1}`
echo -e "${HEADER}\tFeature\t Feature Start (bp)\tFeature End(bp)\tStrand\tID\tDescription\tTranscription Direction (+/-)\tConflicts"

IFS='
'
# Iterating into each line of the starting table, disregarding the header line.
# Sorting alphnumerically according to second column (Chrom). For those lines where the value of the
# field Chrom is the same, we sort numerically according to third column (Mapped Read Start (bp)),
# and so on.
for LINE in `tail -n +2 ${FILENAME} | sort -k2,2 -k3,3n -k4,4n -k6,6n -k7,7n -k8,8n -k10,10`
do
  CHROM=`echo ${LINE} | cut -f2`
  FORK_START=`echo ${LINE} | cut -f7`
  FORK_END=`echo ${LINE} | cut -f8`

  # The variable NEXT_CHROM is used to make short circuits in the code: if the corresponding
  # chromosome in tableStart2.tsv is the same as in the gff.tsv, we continue the ordinary
  # processing. Otherwise, we proceed to the next chromosome.
  NEXT_CHROM="NO"

  # Iterating each mapped reads into the adapted GFF file.
  for GFF_LINE in `tail -n +2 ${GFF_FILENAME} | sort -k1,1 -k3,3n -k4,4n` 
  do
    GFF_CHROM=`echo ${GFF_LINE} | cut -f1`
    if [ "${NEXT_CHROM}" == "YES" ] && [ "${GFF_CHROM}" != "${CHROM}" ]
    then
      break
    fi
    if [ "${GFF_CHROM}" == "${CHROM}" ]
    then
      NEXT_CHROM="YES"
      FEATURE_START=`echo ${GFF_LINE} | cut -f3`  
      if [ "${FEATURE_START}" -gt "${FORK_END}" ]
      then
        continue
      fi
      FEATURE_END=`echo ${GFF_LINE} | cut -f4` 
      if [ "${FEATURE_END}" -lt "${FORK_START}" ]
      then
        continue
      fi
      TRANSCRIPTION_DIRECTION=`echo ${GFF_LINE} | cut -f5`
      if [ "${TRANSCRIPTION_DIRECTION}" == "+" ] 
      then
        echo -e -n "${LINE}\t$(echo ${GFF_LINE} | cut -f2-7 | tr ',' '\t')\t+\t"
      elif [ "${TRANSCRIPTION_DIRECTION}" == "-" ]
      then
        echo -e -n "${LINE}\t$(echo ${GFF_LINE} | cut -f2-7 | tr ',' '\t')\t-\t"
      fi

      # Determining potential conflicts between replication and transcription machineries.  
      FORK_DIRECTION=`echo -e ${LINE} | cut -f10`
      READ_STRAND=`echo -e ${LINE} | cut -f6`
      if [ "${READ_STRAND}" == "fwd" ] && [ "${FORK_DIRECTION}" == "LEFT" ] && [ "${TRANSCRIPTION_DIRECTION}" == "+" ]
      then
        echo "YES"
        continue
      fi
      if [ "${READ_STRAND}" == "rev" ] && [ "${FORK_DIRECTION}" == "RIGHT" ] && [ "${TRANSCRIPTION_DIRECTION}" == "+" ]
      then
        echo "YES"
        continue
      fi
      if [ "${READ_STRAND}" == "fwd" ] && [ "${FORK_DIRECTION}" == "RIGHT" ] && [ "${TRANSCRIPTION_DIRECTION}" == "-" ]
      then
        echo "YES"
        continue
      fi
      if [ "${READ_STRAND}" == "rev" ] && [ "${FORK_DIRECTION}" == "LEFT" ] && [ "${TRANSCRIPTION_DIRECTION}" == "-" ]
      then
        echo "YES"
        continue
      fi
      echo "NO"
    fi
  done
done

exit 0
