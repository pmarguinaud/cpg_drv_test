#!/bin/bash

set -e
set -x

./ics_masterodb

cd /home/gmap/mrpm/marguina/mitraille/cy48t2/cy48t3_cpg_drv+xfu_named
sbatch aro.sh

