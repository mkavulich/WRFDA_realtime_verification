#!/bin/csh

if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif

module load nco
module load ncl
module load python
module load all-python-libs

if ( ! $?POSTAN_SCRIPT_DIR ) then
   set POSTAN_SCRIPT_DIR = /glade/p/wrf/WORKDIR/wrfda_realtime/diag/post_anal
endif
if ( ! $?DA_RUN_DIR_TOP ) then
   set DA_RUN_DIR_TOP = ${RUN_BASEDIR}/expdir/orig/${EXPT}
endif

${POSTAN_SCRIPT_DIR}/make_inc_plots.csh
${POSTAN_SCRIPT_DIR}/make_anal_plots.csh
