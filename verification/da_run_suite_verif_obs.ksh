#!/bin/ksh
#########################################################################
# Script: da_run_suite_verif_obs.ksh
#
#########################################################################
if [[ $DEBUG == true ]]; then
   set -x
fi

export NL_ANALYSIS_TYPE=verify
export OB_DIR=$FILTERED_OBS_DIR


export WRFVAR_DIR=${WRFVAR_DIR:-$REL_DIR/WRFDA}
export SCRIPTS_DIR=${SCRIPTS_DIR:-$WRFVAR_DIR/var/scripts}
. ${SCRIPTS_DIR}/da_set_defaults.ksh
export SUITE_DIR=${SUITE_DIR:-$RUN_DIR}

echo "<HTML><HEAD><TITLE>$EXPT</TITLE></HEAD><BODY><H1>$EXPT</H1><PRE>"

echo 'WRFVAR_DIR   <A HREF="file:'$WRFVAR_DIR'">'$WRFVAR_DIR'</a>' $WRFVAR_VN

echo "DUMMY            $DUMMY"
echo "CLEAN            $CLEAN"
echo "NUM_PROCS        $NUM_PROCS"
echo "INITIAL_DATE     $INITIAL_DATE"
echo "FINAL_DATE       $FINAL_DATE"
echo "INTERVAL         $INTERVAL"
echo "BE_DIR           $BE_DIR"
echo "FILTERED_OBS_DIR $FILTERED_OBS_DIR"
echo "EXP_DIR          $EXP_DIR"
echo 
echo $(date) "Start"

export DATE=$INITIAL_DATE

RC=0

while [[ $DATE -le $FINAL_DATE ]] ; do 
   export PREV_DATE=$($BUILD_DIR/da_advance_time.exe $DATE -$INTERVAL 2>/dev/null)
   export YEAR=$(echo $DATE | cut -c1-4)
   export MONTH=$(echo $DATE | cut -c5-6)
   export DAY=$(echo $DATE | cut -c7-8)

   export HOUR=$(echo $DATE | cut -c9-10)

   echo "=========="
   echo $DATE
   echo "=========="

   export ANALYSIS_DATE=${YEAR}-${MONTH}-${DAY}_${HOUR}:00:00
   echo "ANALYSIS_DATE=${ANALYSIS_DATE}"

   export WORK_DIR=${EXP_DIR}/${DATE}
   export RUN_DIR=${WORK_DIR}/wrfda
   mkdir -p $WORK_DIR
   cd $WORK_DIR

   echo "WORK_DIR         $WORK_DIR"
   echo "RUN_DIR          $RUN_DIR"

   export DA_FIRST_GUESS=${FC_DIR}/$DATE/wrfinput_d01
   if [[ ${VERIFY_HOUR} != 0 ]]; then
     export PREVF_DATE=`$BUILD_DIR/da_advance_time.exe $DATE -$VERIFY_HOUR 2>/dev/null`
     export DA_FIRST_GUESS=${FC_DIR}/${PREVF_DATE}/${VERIFICATION_FILE_STRING}_d01_${ANALYSIS_DATE}
   fi
   export DA_ANALYSIS=$RUN_DIR/analysis

   echo "VERIFY_HOUR= ${VERIFY_HOUR}"
   echo "Verify file=${DA_FIRST_GUESS}"
   echo "Verify obs are: $FILTERED_OBS_DIR/$DATE/filtered_obs_01"

      cat > da_run_wrfda_verif_bsub.ksh << EOF
#!/bin/csh
#########################################################################
# Script: da_run_wrfda_verif.csh
#BSUB -P P64000400          # project number (required)
#BSUB -a poe                # select poe
#BSUB -W 30                 # wall clock time (in minutes)
#BSUB -n 16                 # number of MPI tasks
#BSUB -R "span[ptile=16]"   # run "ptile" tasks per node
#BSUB -J WRFDA_verify_$DATE       # job name
#BSUB -oo WRFDA_verify.out  # output filename
#BSUB -eo WRFDA_verify.err  # error filename
#BSUB -q caldera            # queue
#
# Purpose: Run WRFDA in verification mode
#########################################################################

unsetenv MP_PE_AFFINITY
${SCRIPTS_DIR}/da_run_wrfda_verif.ksh >& verify.out

EOF


   export STATUS=`bsub < da_run_wrfda_verif_bsub.ksh`

   export NEXT_DATE=$($BUILD_DIR/da_advance_time.exe $DATE $INTERVAL 2>/dev/null)
   export DATE=$NEXT_DATE
   let CYCLE_NUMBER=$CYCLE_NUMBER+1
done

echo
echo $(date) "Finished"

echo "</PRE></BODY></HTML>"

exit $RC

