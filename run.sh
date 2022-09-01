#!/bin/bash

set -e
set -x

./ics_masterodb

cd /home/gmap/mrpm/marguina/pack/48t3_gprcp.01.MIMPIIFC1805.2y

./ics_masterodb

sbatch aro_aero2.sh
