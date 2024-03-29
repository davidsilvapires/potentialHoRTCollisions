# potentialHoRTCollisions

Clues on the dynamics of DNA replication in *Giardia lamblia*

DOI: https://doi.org/10.1242/jcs.260828


## How to execute

In order to execute the whole pipeline to generate the potential HoRT collisions table, change the execution mode of the files and execute them sequentially according to the numerical order presented in the filenames.

```
$> chmod +rx *.bash
$> 0-filterAccordingToForkProbability.bash <path to reads with fork probability equal or higher than 70%>
$> 1-tableStart.bash 0.7 > output/tableStart.tsv
$> 2-tableStart2.bash
$> 3-gffAdaptor.bash <path to GFF file of Giardia intestinalis> <GFF filename>
$> 4-potentialHoRTcollisionsTable.bash > finalTable.tsv
```
