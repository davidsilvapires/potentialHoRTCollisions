# Adapting GFF file to continue the construction of the Potential Conflicts Table.

# Usage:
#    $0 <path to GFF file of Giardia intestinalis> <GFF filename>
PATH_TO_GFF=$1
GFF_FILENAME=$2

# Error returned when the number of arguments is different of one.
E_NUMARGS=1

# Checking the number of arguments.
if [ $# -ne 2 ]
then
   echo "Usage:"
   echo "   $0 <path to GFF file of Giardia intestinalis> <GFF filename>"
   exit ${E_NUMARGS}
fi

# Making symbolic links for input data files.
ln -s ../${PATH_TO_GFF}/${GFF_FILENAME} input/

# Replacing ";" for tab in column 9.
cut -f9 input/${GFF_FILENAME} | sed 's/;/\t/g' > output/splitColumn9.txt

# Splitting column 9 in several columns to select only the desired data.
cut -f1,3 output/splitColumn9.txt > output/splitColumn9Edited.txt

# Editing ID column of the splitColumn9Edited.txt file.
cut -f1 output/splitColumn9Edited.txt | sed 's/ID=//' > output/ID.txt

# Editing Description column of the splitColumn9Edited.txt file
cut -f2 output/splitColumn9Edited.txt | sed 's/description=//' > output/description.txt

# Removing column 9 and other unwanted columns of the original GFF file.
cut -f1,3-5,7 input/giaLam3.gff > output/editedGff.txt

# Concatenating all file in the following order: editedGff.txt + ID.txt + description.txt.
paste output/editedGff.txt output/ID.txt output/description.txt | grep -P "^.*\tgene\t.*\t.*\t.*\t.*\t.*$" > output/editedGff.tsv

# Adding the header.
cat <(echo -e "Chrom\tFeature\tFeature Start (bp)\tFeature End (bp)\tStrand\tID\tDescription") output/editedGff.tsv > output/gff.tsv
