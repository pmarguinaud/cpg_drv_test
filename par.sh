#!/bin/bash
#SBATCH --export=NONE
#SBATCH --job-name=arp
#SBATCH --nodes=1
#SBATCH --time=00:15:00
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


#for K in 0 1 2
for K in 0 1 2
do

mkdir -p $K
cd $K


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

for f in $DATA/arp/code/43oops/naml/*
do
  cp $f .
  chmod 644 $(basename $f)
done

# Set the number of nodes, tasks, threads for the model

NNODE_FC=1
#NTASK_FC=2
#NOPMP_FC=2
NTASK_FC=1
NOPMP_FC=1

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
! CSTOP='h$STOP',
  CSTOP='t2',
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
  NVGRIB=0,
/
&NAMDPRECIPS
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
&NAMPERTPAR
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
  NPROMA=-1784,
/
" --inplace fort.4
fi

xpnam --delta="
$(cat $PACK/nam/APLPAR_NEW.nam)
" --inplace fort.4

xpnam --delta="
&NAMPHY
  LAPL_ARPEGE=.TRUE.
/
" --inplace fort.4


ls -lrt

cat fort.4

# Run the model; use your mpirun

unset INPART
unset PERSISTENT
unset PARALLEL

pack=$PACK

BIN=$pack/bin/MASTERODB

\rm -f lparallelmethod.txt

if [ "x$K" = "x0" ]
then
  export INPART=0
  export PERSISTENT=0
  export PARALLEL=0
elif [ "x$K" = "x1" ]
then
  export INPART=1
  export PERSISTENT=1
  export PARALLEL=1
elif [ "x$K" = "x2" ]
then
  export INPART=1
  export PERSISTENT=1
  export PARALLEL=1
  export LPARALLELMETHOD_VERBOSE=1
  cat -> lparallelmethod.txt << EOF
OpenMPSingleColumn APL_ARPEGE_DPRECIPS_PARALLEL:0
OpenMPSingleColumn APL_ARPEGE_INIT_PARALLEL:0
OpenMPSingleColumn APL_ARPEGE_INIT_PARALLEL:1
OpenMPSingleColumn APL_ARPEGE_INIT_PARALLEL:2
OpenMPSingleColumn APL_ARPEGE_INIT_PARALLEL:3
OpenMPSingleColumn APL_ARPEGE_INIT_PARALLEL:4
OpenMPSingleColumn APL_ARPEGE_INIT_PARALLEL:5
OpenMPSingleColumn APL_ARPEGE_INIT_PARALLEL:6
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ACCLPH
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ACDRAG
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ACDRME
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ACEVADCAPE
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ACHMT
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ACHMTLS
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ACSOL
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ACTQSAT
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ACVISIH
OpenMPSingleColumn APL_ARPEGE_PARALLEL:APLPAR_INIT
OpenMPSingleColumn APL_ARPEGE_PARALLEL:CPPHINP
OpenMPSingleColumn APL_ARPEGE_PARALLEL:DIFTQ
OpenMPSingleColumn APL_ARPEGE_PARALLEL:EDR
OpenMPSingleColumn APL_ARPEGE_PARALLEL:FRSOPT
OpenMPSingleColumn APL_ARPEGE_PARALLEL:PLSM
OpenMPSingleColumn APL_ARPEGE_PARALLEL:PPWETPOINT
OpenMPSingleColumn APL_ARPEGE_PARALLEL:QNGCOR
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ZBAY_QRCONV
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ZDE2MR
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ZDPHIV
OpenMPSingleColumn APL_ARPEGE_PARALLEL:ZRDG_LCVQ
OpenMPSingleColumn APL_ARPEGE_SHALLOW_CONVECTION_AND_TURBULENCE_PARALLEL:1
OpenMPSingleColumn MF_PHYS_BAYRAD_PARALLEL:BAYRAD
OpenMPSingleColumn MF_PHYS_FPL_PART1_PARALLEL:0
OpenMPSingleColumn MF_PHYS_FPL_PART2_PARALLEL:0
OpenMPSingleColumn MF_PHYS_MOCON_PARALLEL:PPWETPOINT
OpenMPSingleColumn MF_PHYS_PRECIPS_PARALLEL:EDR
OpenMPSingleColumn MF_PHYS_SAVE_PHSURF_PART1_PARALLEL:0
OpenMPSingleColumn MF_PHYS_SAVE_PHSURF_PART2_PARALLEL:0
EOF

cat lparallelmethod.txt

fi


if [ 1 -eq 1 ]
then
#xport MPIAUTOCONFIG=mpiauto.DDT.conf
#xport MPIAUTOCONFIG=mpiauto.VALGRIND.conf

#xport FOR_ALLOCATE_INIT=NAN

/opt/softs/mpiauto/mpiauto --verbose --wrap --wrap-stdeo --nouse-slurm-mpi --prefix-mpirun '/usr/bin/time -f "time=%e"' \
    --nnp $NTASK_FC --nn $NNODE_FC --openmp $NOPMP_FC -- $BIN \
 -- --nnp $NTASK_IO --nn $NNODE_IO --openmp $NOPMP_IO -- $BIN 
else

export OMP_NUM_THREADS=1
gdb $BIN

fi




ls -lrt

cd ..

done


diffNODE.001_01 --gpnorms '*' 0/NODE.001_01 1/NODE.001_01
diffNODE.001_01 --gpnorms '*' 1/NODE.001_01 2/NODE.001_01

pwd > /home/gmap/mrpm/marguina/pack/48t3_cpg_drv+.01.MIMPIIFC1805.2y/pwd.txt 


