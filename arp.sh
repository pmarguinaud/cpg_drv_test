#!/bin/bash
#SBATCH --export=NONE
#SBATCH --job-name=arp
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


for NAM in ARP LACE LTWOTL=F.ARP SPNG SLHD LTWOTL=F.ARP.LSLAG=T LSLPHY LTWOTL=T.ARP.AERO ARP.XFU.CFU
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
" --inplace fort.4
fi

ls -lrt

cat fort.4

# Run the model; use your mpirun


pack=$PACK

/opt/softs/mpiauto/mpiauto --verbose --wrap --wrap-stdeo --nouse-slurm-mpi --prefix-mpirun '/usr/bin/time -f "time=%e"' \
    --nnp $NTASK_FC --nn $NNODE_FC --openmp $NOPMP_FC -- $pack/bin/MASTERODB \
 -- --nnp $NTASK_IO --nn $NNODE_IO --openmp $NOPMP_IO -- $pack/bin/MASTERODB 

diffNODE.001_01 --gpnorms AERO.001 NODE.001_01 $PACK/ref.48t3_gprcp.01.MIMPIIFC1805.2y/NODE.001_01.$NAM


ls -lrt

cd ..

done
