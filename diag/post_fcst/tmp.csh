#!/bin/csh
#setenv ANAL_DATE 2015082400
#set START_DATE = $ANAL_DATE #2015052700
#set END_DATE   = $ANAL_DATE #2015082512
set START_DATE = 2015101300
set END_DATE   = 2015101300
set CYCLE_PERIOD = 24
set DATE = $START_DATE
set BIN_DIR = ${HOME}/bin

while ( $DATE <= $END_DATE )

setenv ANAL_DATE $DATE
set START_FHR  = 0
set FCST_RANGE = 48
set SCRIPT_DIR = ${BASE_DIR}/diag/post_fcst
set SCRIPT_NAME = precip.csh
set fhrs = `seq $START_FHR 1 $FCST_RANGE`
foreach fhr ( $fhrs )
   setenv FHR $fhr
   #bsub -J "post_fhr${fhr}" < ${SCRIPT_DIR}/${SCRIPT_NAME}
   ${SCRIPT_DIR}/${SCRIPT_NAME}
end
#echo "Done submitting for $DATE"
#echo "sleep 90"
#sleep 90
set DATE = `${HOME}/bin/da_advance_time.exe $DATE $CYCLE_PERIOD`

end
