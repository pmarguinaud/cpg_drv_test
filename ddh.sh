#!/bin/bash
#SBATCH --export=NONE
#SBATCH --job-name=ddh
#SBATCH --nodes=1
#SBATCH --time=00:05:00
#SBATCH --exclusive
#SBATCH --verbose
#SBATCH --no-requeue

set -x

# Environment variables

ulimit -s unlimited
export OMP_STACKSIZE=4G
export KMP_STACKSIZE=4G
export KMP_MONITOR_STACKSIZE=1G
export DR_HOOK=1
export DR_HOOK_IGNORE_SIGNALS=-1
export DR_HOOK_OPT=prof
export EC_PROFILE_HEAP=0
export EC_MPI_ATEXIT=0

export PATH=$HOME/bin:$HOME/benchmf1709/scripts:$PATH

# Directory where input data is stored

DATA=/scratch/work/marguina/benchmf1709-data

# Change to a temporary directory

export workdir=/scratch/work/marguina

if [ "x$SLURM_JOBID" != "x" ]
then
export TMPDIR=$workdir/tmp/arp.$SLURM_JOBID
else
export TMPDIR=$workdir/tmp/arp.$$
fi

mkdir -p $TMPDIR

cd $TMPDIR


for NAM in ARP 
do

mkdir -p $NAM
cd $NAM


# Choose your test case resolution

#GRID=t1798
#GRID=t0798
 GRID=t0031

# Choose a pack

 PACK=/home/gmap/mrpm/marguina/pack/48t3_cpg_drv+.01.MIMPIIFC1805.2y

# Copy data to $TMPDIR

for f in $DATA/arp/grid/$GRID/* $DATA/arp/code/43oops/data/* 
do
  if [ -f "$f" ]
  then
    \rm -f $(basename $f)
    ln $f .
  fi
done

for f in $PACK/data/*
do
  b=$(basename $f)
  \rm -f $b
  ln -s $f $b
done

rm ICMSHFCSTINIT
ln -s arp/ICMSHFCSTINIT

for f in $DATA/arp/code/43oops/naml/*
do
  cp $f .
  chmod 644 $(basename $f)
done

# Set the number of nodes, tasks, threads for the model

NNODE_FC=1
NTASK_FC=8
NOPMP_FC=4

# Set the number of nodes, tasks, threads for the IO server

NNODE_IO=0
NTASK_IO=32
NOPMP_IO=4

let "NPROC_FC=$NNODE_FC*$NTASK_FC"
let "NPROC_IO=$NNODE_IO*$NTASK_IO"

# Set forecast term; reduce it for debugging

STOP=6

# Modify namelist

xpnam --delta="
&NAMRIP
  CSTOP='h$STOP',
  TSTEP=240,
/
&NAMARG
  CUSTOP=-,
  UTSTEP=-,
/
&NAMCVER
  NVSCH=-,
  NVFE_TYPE=1,
/
&NAMTRAJ
/
&NAMCT0
  LGRIB_API=.FALSE.,
/
&NAETLDIAG
/
&NAMDVISI
/
&NAMSATSIM
/
&NAMPHY0
  GREDDRS=-,
/
&NAMNORGWD
/
&NAMMETHOX
/
&NAMNUDGLH
/
&NAMSPP
/
&NAMFA
  NVGRIB=123,
/
&NAMPERTPAR
/
" --inplace fort.4

xpnam --delta="
&NAMIO_SERV
  NPROC_IO=$NPROC_IO,
/
&NAMPAR0
  NPROC=$NPROC_FC,
  $(square $NPROC_FC)
/
&NAMPAR1
  NSTRIN=$NPROC_FC,
/
" --inplace fort.4

xpnam --delta="
$(cat $PACK/nam/$NAM.nam)
" --inplace fort.4

# Set up grib_api environment

grib_api_prefix=$(ldd $PACK/bin/MASTERODB  | perl -ne ' 
   next unless (m/libeccodes_f90/o); 
   my ($path) = (m/=>\s+(\S+)/o); 
   use File::Basename; 
   print &dirname (&dirname ($path)), "\n" ')
export GRIB_DEFINITION_PATH=$PWD/extra_grib_defs:$grib_api_prefix/share/definitions:$grib_api_prefix/share/eccodes/definitions
export GRIB_SAMPLES_PATH=$grib_api_prefix/ifs_samples/grib1:$grib_api_prefix/share/eccodes/ifs_samples/grib1

# Change NPROMA

if [ 1 -eq 1 ]
then
xpnam --delta="
&NAMDIM
  NPROMA=-4,
/
&NAMCT0
  LALLOPR=.TRUE.,
/
" --inplace fort.4
fi

if [ 1 -eq 1 ]
then
xpnam --delta="
&NAMDDH
  LHDEFZ=.TRUE.,
  LHDHKS=.TRUE.,
  LHDZON=.TRUE.,
  LHDDOP=.TRUE.,
  LHDEFD=.TRUE.,
  NDHKD=30,
  BDEDDH(1,01)=4.,
  BDEDDH(2,01)=1.,
  BDEDDH(3,01)=-085.940,
  BDEDDH(4,01)=0079.990,
  BDEDDH(1,02)=4.,
  BDEDDH(2,02)=1.,
  BDEDDH(3,02)=-156.616,
  BDEDDH(4,02)=0071.322,
  BDEDDH(1,03)=4.,
  BDEDDH(2,03)=1.,
  BDEDDH(3,03)=0026.650,
  BDEDDH(4,03)=0067.370,
  BDEDDH(1,04)=4.,
  BDEDDH(2,04)=1.,
  BDEDDH(3,04)=0014.124,
  BDEDDH(4,04)=0052.167,
  BDEDDH(1,05)=4.,
  BDEDDH(2,05)=1.,
  BDEDDH(3,05)=0004.927,
  BDEDDH(4,05)=0051.971,
  BDEDDH(1,06)=4.,
  BDEDDH(2,06)=1.,
  BDEDDH(3,06)=-001.437,
  BDEDDH(4,06)=0051.145,
  BDEDDH(1,07)=4.,
  BDEDDH(2,07)=1.,
  BDEDDH(3,07)=0002.208,
  BDEDDH(4,07)=0048.713,
  BDEDDH(1,08)=4.,
  BDEDDH(2,08)=1.,
  BDEDDH(3,08)=-000.692,
  BDEDDH(4,08)=0044.832,
  BDEDDH(1,09)=4.,
  BDEDDH(2,09)=1.,
  BDEDDH(3,09)=0004.407,
  BDEDDH(4,09)=0043.858,
  BDEDDH(1,10)=4.,
  BDEDDH(2,10)=1.,
  BDEDDH(3,10)=0001.374,
  BDEDDH(4,10)=0043.575,
  BDEDDH(1,11)=4.,
  BDEDDH(2,11)=1.,
  BDEDDH(3,11)=0000.370,
  BDEDDH(4,11)=0043.128,
  BDEDDH(1,12)=4.,
  BDEDDH(2,12)=1.,
  BDEDDH(3,12)=0015.750,
  BDEDDH(4,12)=0040.590,
  BDEDDH(1,13)=4.,
  BDEDDH(2,13)=1.,
  BDEDDH(3,13)=-097.500,
  BDEDDH(4,13)=0036.617,
  BDEDDH(1,14)=4.,
  BDEDDH(2,14)=1.,
  BDEDDH(3,14)=0002.176,
  BDEDDH(4,14)=0013.477,
  BDEDDH(1,15)=4.,
  BDEDDH(2,15)=1.,
  BDEDDH(3,15)=0166.916,
  BDEDDH(4,15)=-000.521,
  BDEDDH(1,16)=4.,
  BDEDDH(2,16)=1.,
  BDEDDH(3,16)=0147.425,
  BDEDDH(4,16)=-002.006,
  BDEDDH(1,17)=4.,
  BDEDDH(2,17)=1.,
  BDEDDH(3,17)=0130.891,
  BDEDDH(4,17)=-012.425,
  BDEDDH(1,18)=4.,
  BDEDDH(2,18)=1.,
  BDEDDH(3,18)=-005.783,
  BDEDDH(4,18)=041.816,
  BDEDDH(1,19)=4.,
  BDEDDH(2,19)=1.,
  BDEDDH(3,19)=024.65,
  BDEDDH(4,19)=060.183,
  BDEDDH(1,20)=4.,
  BDEDDH(2,20)=1.,
  BDEDDH(3,20)=027.50,
  BDEDDH(4,20)=062.666,
  BDEDDH(1,21)=4.,
  BDEDDH(2,21)=1.,
  BDEDDH(3,21)=025.566,
  BDEDDH(4,21)=066.550,
  LFLEXDIA=.TRUE.,
  LDDH_OMP=.TRUE.,
  LRSLDDH=.FALSE.,
  LRSIDDH=.FALSE.,
  LRHDDDH=.FALSE.,
/
" --inplace fort.4
fi

ls -lrt

cat fort.4

# Run the model; use your mpirun


pack=$PACK
#ack=$HOME/pack/48t3_main.01.MIMPIIFC1805.2ys

/opt/softs/mpiauto/mpiauto --verbose --wrap --wrap-stdeo --nouse-slurm-mpi --prefix-mpirun '/usr/bin/time -f "time=%e"' \
    --nnp $NTASK_FC --nn $NNODE_FC --openmp $NOPMP_FC -- $pack/bin/MASTERODB \
 -- --nnp $NTASK_IO --nn $NNODE_IO --openmp $NOPMP_IO -- $pack/bin/MASTERODB 

diffNODE.001_01 --gpnorms AERO.001 NODE.001_01 $PACK/ref.48t3_gprcp.01.MIMPIIFC1805.2y/NODE.001_01.$NAM


ls -lrt

cd ..

done
