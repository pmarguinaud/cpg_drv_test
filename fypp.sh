#!/bin/bash

set -x
set -e

cd fypp

declare -A dir

for f in $(find . -name '*.fypp')
do

  b=$(basename $f .fypp)
  d=$(dirname $f)

  if [ $b = "cpg_macros" ]
  then
    continue
  fi

  if [ $b = "field_definition" ]
  then
    continue
  fi

  /opt/softs/anaconda3/bin/fypp -m os -M arpifs/module -m yaml -m field_config ./$d/$b.fypp ./$d/$b.F90

  if [ ! -f ../src/local/$d/$b.F90 ]
  then
    cp $d/$b.F90 ../src/local/$d/$b.F90
  else
    set +e
    cmp $d/$b.F90 ../src/local/$d/$b.F90
    c=$?
    set -e
    if [ $c -ne 0 ]
    then
      cp $d/$b.F90 ../src/local/$d/$b.F90
    fi
  fi

done


