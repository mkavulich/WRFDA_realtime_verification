#!/bin/csh
#BSUB -J post
#BSUB -q geyser
#BSUB -n 1
#BSUB -o job.out
#BSUB -e job.out
#BSUB -W 3:00
#BSUB -P P64000510

module load ncl
module load python
module load all-python-libs

echo "Beginning $0"
set START_DATE = 2015091800
set END_DATE   = 2015091800
set CYCLE_PERIOD = 24
set DATE = $START_DATE
while ( $DATE <= $END_DATE )

echo $DATE
setenv ANAL_DATE $DATE
if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif
#set DIAG_RUN_DIR    = /glade/scratch/hclin/CONUS/wrfda/postdir/soundings/${ANAL_DATE}
set extract_sound = True
set convert_sound = True

if ( ! -d ${DIAG_RUN_DIR} ) mkdir -p ${DIAG_RUN_DIR}

if ( $?extract_sound ) then
   #module load ncl
   ncl ${DIAG_SCRIPT_DIR}/skewtlogp.ncl >&! /dev/null
endif

if ( $?convert_sound ) then
   #module load python
   #module load all-python-libs
   ${DIAG_SCRIPT_DIR}/sounding_to_json.py >&! /dev/null
endif

set DATE = `${EP_EXE_DIR}/da_advance_time.exe $DATE $CYCLE_PERIOD`

rsync -av ${DIAG_RUN_DIR}/*js nebula.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/realtimetest/images/sounding/${ANAL_DATE}

end #DATE loop
