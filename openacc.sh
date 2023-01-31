#!/bin/bash

for f in \
   arpifs/phys_dmn/actke.F90      \
   arpifs/phys_dmn/acbl89.F90     \
   arpifs/phys_dmn/acturb.F90     \
   arpifs/phys_dmn/acevolet.F90   \
   arpifs/phys_dmn/aclender.F90   \
   arpifs/phys_dmn/hl2fl.F90      \
   arpifs/phys_dmn/fl2hl.F90      \
   arpifs/phys_dmn/dprecips.F90   \
   arpifs/pp_obs/ppwetpoint.F90   \
   arpifs/phys_dmn/acdrag.F90     \
   arpifs/phys_dmn/acpluis.F90    \
   arpifs/phys_dmn/acdnshf.F90
do 
  echo "==> $f <=="
  dir=$(dirname $f)
  mkdir -p src/local/ifsaux/openacc/$dir
  /home/gmap/mrpm/marguina/fxtran-acdc/bin/openacc.pl src/local/$f src/local/ifsaux/openacc/$dir
done


