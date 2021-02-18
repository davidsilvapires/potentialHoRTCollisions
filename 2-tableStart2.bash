#!/usr/bin/env bash

# Chromosome names in the genome used for mapping are different from the ones in the genome used
# for assembly. The correlation is described in the chromosome names in the assembly fastq file and
# were inputed in a table, named chromCorrespondence. Then, chromosome names are substituted in
# the tableStart.tsv file and redirected to tableStart2.tsv.

IFS='
'
for LINE in `cat output/tableStart.tsv`
do
  CHROM=`echo ${LINE} | cut -f2`

  # The output is different if we find the chromosome name in the file. Since we don't want
  # anything being echoed to standard output, grep command has to be quiet ("-q" option). The grep
  # exit value is evaluated through "$?" variable.
  grep -q ${CHROM} script/chromCorrespondence.txt
  if [ "$?" == "0" ]
  then
    NEW_CHROM=`grep ${CHROM} script/chromCorrespondence.txt | cut -f2`
    echo ${LINE} | sed "s/${CHROM}/${NEW_CHROM}/" >> output/tableStart2.tsv
  else
    echo ${LINE} >> output/tableStart2.tsv
  fi
done

exit 0
