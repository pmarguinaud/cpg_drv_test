#!/bin/bash

export PATH=/home/gmap/mrpm/marguina/fxtran-acdc/bin:$PATH

for f in \
   arpifs/phys_dmn/actke.F90                \
   arpifs/phys_dmn/acbl89.F90               \
   arpifs/phys_dmn/acturb.F90               \
   arpifs/phys_dmn/acevolet.F90             \
   arpifs/phys_dmn/aclender.F90             \
   arpifs/phys_dmn/hl2fl.F90                \
   arpifs/phys_dmn/fl2hl.F90                \
   arpifs/phys_dmn/dprecips.F90             \
   arpifs/pp_obs/ppwetpoint.F90             \
   arpifs/phys_dmn/acdrag.F90               \
   arpifs/phys_dmn/acpluis.F90              \
   arpifs/phys_dmn/acdnshf.F90              \
   arpifs/phys_radi/radozcmf.F90            \
   arpifs/phys_dmn/suozon.F90               \
   arpifs/adiab/cpphinp.F90                 \
   arpifs/phys_dmn/aplpar_init.F90          \
   arpifs/phys_dmn/actqsat.F90              \
   arpifs/phys_dmn/acsol.F90                \
   arpifs/phys_dmn/acsolw.F90               \
   arpifs/phys_dmn/achmt.F90                \
   arpifs/phys_dmn/acntcls.F90              \
   arpifs/phys_dmn/achmtls.F90              \
   arpifs/phys_dmn/acclph.F90               \
   arpifs/phys_dmn/qngcor.F90               \
   arpifs/phys_dmn/acdrme.F90               \
   arpifs/phys_dmn/acevadcape.F90           \
   arpifs/phys_dmn/accldia.F90              \
   arpifs/phys_dmn/acvisih.F90
do 
  echo "==> $f <=="
  dir=$(dirname $f)
  mkdir -p src/local/ifsaux/openacc/$dir
  openacc.pl \
   --only-if-newer --drhook --dir src/local/ifsaux/openacc/$dir \
   --nocompute ABOR1 \
   src/local/$f 
done


