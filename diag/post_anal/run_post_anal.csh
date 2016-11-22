#!/bin/csh

if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif

module load nco
module load ncl
module load python
module load all-python-libs

setenv DA_RUN_DIR_TOP /glade/scratch/hclin/CONUS/wrfda/expdir/start2016102512/hyb_ens75

set POSTAN_SCRIPT_DIR = /glade/u/home/hclin/scripts/rt2015/diag/post_anal
${POSTAN_SCRIPT_DIR}/make_inc_plots.csh
${POSTAN_SCRIPT_DIR}/make_anal_plots.csh
