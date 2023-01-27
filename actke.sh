#!/bin/bash

for f in \
   arpifs/phys_dmn/actke.F90 \
   arpifs/phys_dmn/acbl89.F90 \
   arpifs/phys_dmn/acturb.F90 \
   arpifs/phys_dmn/acevolet.F90 \
   arpifs/phys_dmn/aclender.F90 \
   arpifs/phys_dmn/hl2fl.F90 \
   arpifs/phys_dmn/fl2hl.F90
do 
  echo "==> $f <=="
  /home/gmap/mrpm/marguina/fxtran-acdc/bin/openacc.pl src/local/$f src/local/openacc/arpifs/phys_dmn/
done


