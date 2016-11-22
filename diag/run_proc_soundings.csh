#!/bin/csh
#BSUB -P P64000510
#BSUB -n 1
#BSUB -J proc_sound
#BSUB -o sound.out
#BSUB -e sound.out
#BSUB -W 3:00
#BSUB -q geyser

echo "Beginning $0"
if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif
#set DIAG_RUN_DIR    = /glade/scratch/hclin/CONUS/wrfda/postdir/soundings/${ANAL_DATE}
set extract_sound = True
set convert_sound = True

if ( ! -d ${DIAG_RUN_DIR} ) mkdir -p ${DIAG_RUN_DIR}

if ( $?extract_sound ) then
   module load ncl
   ncl ${DIAG_SCRIPT_DIR}/skewtlogp.ncl
endif

if ( $?convert_sound ) then
   module load python
   module load all-python-libs
   ${DIAG_SCRIPT_DIR}/sounding_to_json.py
endif

rsync -av ${DIAG_RUN_DIR}/*js galaxy.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/realtimetest/images/sounding/${ANAL_DATE}

