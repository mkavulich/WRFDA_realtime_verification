#!/bin/csh
#setenv ANAL_DATE 2015082400
#set START_DATE = $ANAL_DATE #2015052700
#set END_DATE   = $ANAL_DATE #2015082512
set START_DATE = 2015092000
set END_DATE   = 2015092000
set CYCLE_PERIOD = 24
set DATE = $START_DATE
set BIN_DIR = ${HOME}/bin

while ( $DATE <= $END_DATE )

setenv ANAL_DATE $DATE
set START_FHR  = 2
set FCST_RANGE = 2
set SCRIPT_DIR = /glade/u/home/hclin/scripts/rt2015/diag/post_fcst
set SCRIPT_NAME = make_fcst_plots.csh
set fhrs = `seq $START_FHR 1 $FCST_RANGE`
foreach fhr ( $fhrs )
   setenv FHR $fhr
   bsub -J "post_fhr${fhr}" < ${SCRIPT_DIR}/${SCRIPT_NAME}
   #sleep 5
   #${SCRIPT_DIR}/${SCRIPT_NAME}
end
echo "Done submitting for $DATE"
#echo "sleep 90"
#sleep 90
set DATE = `${HOME}/bin/da_advance_time.exe $DATE $CYCLE_PERIOD`

end
