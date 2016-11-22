#!/bin/csh
#setenv ANAL_DATE 2015081700
set START_FHR  = 0
set FCST_RANGE = 48
set SCRIPT_DIR = ${BASE_DIR}/diag/post_fcst
set SCRIPT_NAME = make_fcst_plots.csh
set fhrs = `seq $START_FHR 1 $FCST_RANGE`
foreach fhr ( $fhrs )
   setenv FHR $fhr
   bsub -J "post_fhr${fhr}" < ${SCRIPT_DIR}/${SCRIPT_NAME}
   sleep 10
end
