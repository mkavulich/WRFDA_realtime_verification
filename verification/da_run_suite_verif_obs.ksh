#!/bin/ksh
#########################################################################
# Script: da_run_suite_verif_obs.ksh
#
#########################################################################
if [[ $DEBUG == true ]]; then
   set -x
fi

export NL_ANALYSIS_TYPE=VERIFY
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

if [[ ! -e "$BUILD_DIR/da_advance_time.exe" ]] ; then
   echo ""
   echo "ERROR ERROR ERROR"
   echo "$BUILD_DIR/da_advance_time.exe DOES NOT EXIST!"
   echo "CHECK YOUR \$WRFVAR_DIR and \$BUILD_DIR SETTINGS!"
   exit 4
fi

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

   if [[ -e $WORK_DIR/FAIL_VERIFY ]] ; then
      echo "Overwriting previous failed run for $DATE"
      \rm -f $WORK_DIR/FAIL_VERIFY
   fi
   if [[ -e $WORK_DIR/SUCCESS_VERIFY ]] ; then
      echo "Run completed previously for $DATE, skipping..."
   else

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

      if [[ $NUM_PROCS -gt 1 ]]; then
         cat > da_run_wrfda_verif_bsub.ksh << EOF
#!/bin/csh
#########################################################################
# Script: da_run_wrfda_verif.csh
#BSUB -P P64000400          # project number (required)
#BSUB -a poe                # select poe
#BSUB -W 30                 # wall clock time (in minutes)
#BSUB -n $NUM_PROCS                 # number of MPI tasks
#BSUB -R "span[ptile=$NUM_PROCS]"   # run "ptile" tasks per node
#BSUB -J WRFDA_verify_$DATE       # job name
#BSUB -oo WRFDA_verify.out  # output filename
#BSUB -eo WRFDA_verify.err  # error filename
#BSUB -q caldera            # queue
#
# Purpose: Run WRFDA in verification mode
#########################################################################

unsetenv MP_PE_AFFINITY

# Keep environment variables so the script can be run later
setenv DEBUG $DEBUG
setenv SCRIPTS_DIR $SCRIPTS_DIR
setenv CYCLING $CYCLING
setenv CYCLE_NUMBER $CYCLE_NUMBER
setenv RUN_DIR $RUN_DIR
setenv BUILD_DIR $BUILD_DIR
setenv DATE $DATE
setenv WINDOW_START $WINDOW_START
setenv WINDOW_END $WINDOW_END
setenv START_DATE $START_DATE
setenv END_DATE $END_DATE
setenv DA_FIRST_GUESS $DA_FIRST_GUESS
setenv OB_DIR $OB_DIR
setenv BE_DIR $BE_DIR
setenv FC_DIR $FC_DIR
setenv WRFVAR_DIR $WRFVAR_DIR
setenv DA_FIRST_GUESS $DA_FIRST_GUESS
setenv FILTERED_OBS_DIR $FILTERED_OBS_DIR

setenv NL_TRACE_USE $NL_TRACE_USE
setenv NL_ANALYSIS_TYPE $NL_ANALYSIS_TYPE
setenv NL_E_WE $NL_E_WE
setenv NL_E_SN $NL_E_SN
setenv NL_E_VERT $NL_E_VERT
setenv NL_DX $NL_DX
setenv NL_DY $NL_DY
setenv NL_SF_SURFACE_PHYSICS $NL_SF_SURFACE_PHYSICS
setenv NL_NUM_LAND_CAT $NL_NUM_LAND_CAT

${SCRIPTS_DIR}/da_run_wrfda_verif.ksh >& verify.out

EOF
      export STATUS=`bsub < da_run_wrfda_verif_bsub.ksh`
      else
         ${SCRIPTS_DIR}/da_run_wrfda_verif.ksh 2>&1 | tee verify.out
      fi
   fi

   export NEXT_DATE=$($BUILD_DIR/da_advance_time.exe $DATE $INTERVAL 2>/dev/null)
   export DATE=$NEXT_DATE
   let CYCLE_NUMBER=$CYCLE_NUMBER+1
done

echo
echo $(date) "Finished"

echo "</PRE></BODY></HTML>"

exit $RC

