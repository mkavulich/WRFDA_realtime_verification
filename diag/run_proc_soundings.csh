#!/bin/csh
#BSUB -P P64000510
#BSUB -n 1
#BSUB -J proc_sound
#BSUB -o sound.out
#BSUB -e sound.out
#BSUB -W 3:00
#BSUB -q geyser

setenv EXPT hyb_ens75
source /glade/u/home/hclin/scripts/rt2015/${EXPT}/params.csh

if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif
set DIAG_SCRIPT_DIR = /glade/u/home/hclin/scripts/rt2015/diag
set DIAG_RUN_DIR    = /glade/scratch/hclin/CONUS/wrfda/postdir/soundings/${ANAL_DATE}
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

rsync -av ${DIAG_RUN_DIR}/*js galaxy.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/conus15km/images/sounding/${ANAL_DATE}

#copied in run_diag.csh
#rsync -av /glade/u/home/sobash/SHARPpy/OBS/${DATE}/*js galaxy.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/conus15km/images/sounding/${DATE}
