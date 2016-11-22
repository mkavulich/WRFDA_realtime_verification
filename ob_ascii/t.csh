#!/bin/csh
#set echo
setenv EXPT       ob_ascii
setenv OB_FORMAT  2
#setenv QUEUE      premium
setenv QUEUE      regular
source /glade/u/home/hclin/scripts/rt2015/${EXPT}/params.csh
#setenv ENS_SIZE 0
#setenv TIME_STEP 60
#setenv TIME_STEP_FCST 75

if ( ${#argv} > 0 ) then
   set DATE = $1
   set cc = `echo $DATE | cut -c1-2`
   set yy = `echo $DATE | cut -c3-4`
   set mm = `echo $DATE | cut -c5-6`
   set dd = `echo $DATE | cut -c7-8`
   set hh = `echo $DATE | cut -c9-10`
else
   set cc = `date -u '+%C'`
   set yy = `date -u '+%y'`
   set mm = `date -u '+%m'`
   set dd = `date -u '+%d'`
   set hh = `date -u +%H`  ;  set hh = `expr $hh \+ 0`
   if      ( $hh >= 0  && $hh < 6  ) then
      set hh = '00'
   else if ( $hh >= 6  && $hh < 12 ) then
      set hh = '06'
   else if ( $hh >= 12 && $hh < 18 ) then
      set hh = '12'
   else if ( $hh >= 18 && $hh < 24 ) then
      set hh = '18'
   endif
   set DATE = ${cc}${yy}${mm}${dd}${hh}
endif

set echo
setenv ANAL_DATE $DATE
if ( $hh == 00 ) then
   setenv QUEUE premium
endif

cd ${SCRIPT_DIR}
\rm -f ${SCRIPT_DIR}/job.out
echo "`date` started for ${EXPT} ${DATE}" > ${SCRIPT_DIR}/logdir/started_${DATE}
#mail -s "RT2015: ${DATE} ${EXPT} started" "hclin@ucar.edu" < ${SCRIPT_DIR}/logdir/started_${DATE}

if ( $DATE == $FIRST_DATE ) then
   setenv FG_SOURCE  ensfc_mean
endif

if ( ! -d ${LOG_DIR} ) mkdir -p ${LOG_DIR}

echo "====== $DATE ======"

if ( $OB_FORMAT == "2" ) then
   if ( ! -e ${OB_DIR_TOP}/${DATE}/FINISHED ) then
      echo "`date` Running run_obsproc.csh ......"
      ${SCRIPT_DIR}/run_obsproc.csh >&! ${LOG_DIR}/${DATE}.obsproc

      set obs_done = false
      while ( $obs_done == false )
         if ( -e ${OB_DIR_TOP}/${DATE}/ob_d01.ascii.${DATE} ) then
            set obs_done = true
         endif
         if ( $obs_done == false ) then
            if ( -e ${OB_DIR_TOP}/${DATE}/FAIL ) then
               echo "   `date` Error in run_obsproc.csh ......"
               mail -s "RT2015: ${DATE} ${EXPT} Error obsproc" "hclin@ucar.edu" < ${OB_DIR_TOP}/${DATE}/log.d01.${DATE}
               #exit 1
               setenv OB_FORMAT 1
               set obs_done = true
            else
               sleep 60
            endif
         endif
      end
   endif
endif

if ( $OB_FORMAT == "1" ) then
   set OBSPROC_RUN_DIR = ${OB_DIR_TOP}/${DATE}
   if ( ! -d ${OBSPROC_RUN_DIR} ) mkdir -p ${OBSPROC_RUN_DIR}
   cd ${OBSPROC_RUN_DIR}
   if ( ! -e gfs.t${hh}z.1bamua.tm00.bufr_d ) then
      /usr/bin/wget -np ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${DATE}/gfs.t${hh}z.1bamua.tm00.bufr_d
   endif
   if ( ! -e gfs.t${hh}z.gpsro.tm00.bufr_d ) then
      /usr/bin/wget -np ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${DATE}/gfs.t${hh}z.gpsro.tm00.bufr_d
   endif
   if ( ! -e gfs.t${hh}z.prepbufr.nr ) then
      /usr/bin/wget -np ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${DATE}/gfs.t${hh}z.prepbufr.nr
   endif
endif

cd ${SCRIPT_DIR}
if ( ! -e ${EXP_DIR_TOP}/${DA_METHOD}/${DATE}/FINISHED ) then

   set DA_RUN_DIR = ${EXP_DIR_TOP}/${DA_METHOD}/${DATE}
   if ( ! -d ${DA_RUN_DIR} ) mkdir -p ${DA_RUN_DIR}
   
   set gdate = (`${BIN_DIR}/da_advance_time.exe $DATE 0 -g`)
   set gdatef = (`${BIN_DIR}/da_advance_time.exe $DATE $ADVANCE_HOUR -g`)
   set inpfile = /glade/scratch/wrfrt/realtime_ensemble/wrfdart/output/${DATE}/wrfinput_d01_${gdate[1]}_${gdate[2]}_mean
   set bdyfile = /glade/scratch/wrfrt/realtime_ensemble/wrfdart/output/${DATE}/wrfbdy_d01_${gdatef[1]}_${gdatef[2]}_mean
   set tarfile = /glade/scratch/wrfrt/realtime_ensemble/wrfdart/output/${DATE}/retro.tar

   set done = false
   while ( $done == false )
      if ( -e $inpfile && -e $bdyfile ) then
         set done = true
         cp -p $inpfile $DA_RUN_DIR
         cp -p $bdyfile $DA_RUN_DIR
      else if ( -e $tarfile ) then
         set done = true
         cp -p $tarfile $DA_RUN_DIR
      endif
      if ( $done == false ) sleep 120
   end

   @ num_rerun = 0
   SUBMIT_DA_AGAIN:
   echo "`date` submit run_wrfda.csh ......"
   ${bsub_cmd} -q ${QUEUE} -J "da${mm}${dd}${hh}" < ${SCRIPT_DIR}/run_wrfda.csh >&! ${LOG_DIR}/${DATE}.wrfda

   set da_done = false
   while ( $da_done == false )
      if ( -e $EXP_DIR_TOP/${DA_METHOD}/${DATE}/wrfvar_output_d01_${DATE} ) then
         set da_done = true
         mv ${SCRIPT_DIR}/job.out ${LOG_DIR}/job_wrfda.${DATE}
      endif
      if ( $da_done == false ) then
         if ( -e ${EXP_DIR_TOP}/${DA_METHOD}/${DATE}/FAIL ) then
            if ( $num_rerun < 2 ) then
               \rm -f ${EXP_DIR_TOP}/${DA_METHOD}/${DATE}/FAIL
               @ num_rerun ++
               goto SUBMIT_DA_AGAIN
            else
               echo "   `date` Error in run_wrfda.csh ......"
               mail -s "RT2015: ${DATE} ${EXPT} Error da" "hclin@ucar.edu" < ${SCRIPT_DIR}/logdir/log.${hh}z
               exit 1
            endif
         endif
         sleep 60
      endif
   end
endif

if ( 0 ) then
cd ${SCRIPT_DIR}
set file_to_check = $EXP_DIR_TOP/${DA_METHOD}/advance/${DATE}/FINISHED
if ( ! -e ${file_to_check} ) then
   echo "`date` submit run_advance.csh ......"
   ${bsub_cmd} -q ${QUEUE} -J "adv${mm}${dd}${hh}" < ${SCRIPT_DIR}/run_advance.csh >&! ${LOG_DIR}/${DATE}.advance

   set adv_done = false
   while ( $adv_done == false )
      if ( -e $file_to_check ) then
         set adv_done = true
         mv ${SCRIPT_DIR}/job.out ${LOG_DIR}/job_adv.${DATE}
      endif
      if ( $adv_done == false ) then
         if ( -e ${EXP_DIR_TOP}/${DA_METHOD}/advance/${DATE}/FAIL ) then
            echo "   `date` Error in run_advance.csh ......"
            mail -s "RT2015: ${DATE} ${EXPT} Error advance" "hclin@ucar.edu" < ${SCRIPT_DIR}/logdir/log.${hh}z
            exit 1
         endif
         sleep 60
      endif
   end
endif

if ( -e ${EXP_DIR_TOP}/${DA_METHOD}/advance/${DATE}/FINISHED ) then
   echo "`date` Done rt.csh for ${EXPT} ${DATE}"
   mail -s "RT2015: ${DATE} ${EXPT} Done" "hclin@ucar.edu" < ${EXP_DIR_TOP}/${DA_METHOD}/${DATE}/statistics
endif

#post-processing
echo "`date` running run_diag.csh ......"
${DIAG_SCRIPT_DIR}/run_diag.csh >&! ${SCRIPT_DIR}/logdir/diaglog.${hh}z

echo "`date` running run_post_anal.csh ......"
${DIAG_SCRIPT_DIR}/post_anal/run_post_anal.csh >&! ${SCRIPT_DIR}/logdir/postanlog.${hh}z

if ( $hh == 00 ) then
   #48-hour forecast
   cd ${SCRIPT_DIR}
   set file_to_check = ${FCST_RUN_DIR}/${DATE}/FINISHED
   if ( ! -e ${file_to_check} ) then
      echo "`date` submit run_fcst.csh ......"
      ${bsub_cmd} -q regular -J "fc_${mm}${dd}${hh}" < ${SCRIPT_DIR}/run_fcst.csh >&! ${LOG_DIR}/${DATE}.fcst

      set fc_done = false
      while ( $fc_done == false )
         if ( -e $file_to_check ) then
            set fc_done = true
            mv ${SCRIPT_DIR}/job_fc.out ${LOG_DIR}/job_fc.${DATE}

            # extract model soundings
            ${bsub_cmd} < ${DIAG_SCRIPT_DIR}/run_proc_soundings.csh

            echo "`date` submitting post-processing jobs  ......"
            ${DIAG_SCRIPT_DIR}/post_fcst/submit_make_fcst_plots.csh
         endif
         if ( $fc_done == false ) then
            if ( -e ${FCST_RUN_DIR}/${DATE}/FAIL ) then
               echo "   `date` Error in run_fcst.csh ......"
               mail -s "RT2015: ${DATE} ${EXPT} Error FCST" "hclin@ucar.edu" < ${SCRIPT_DIR}/logdir/log.${hh}z
               exit 1
            endif
            sleep 600
         endif
      end
   endif
endif #end 00z 48h fcst

echo "`date` running archive_obs.csh ......"
${SCRIPT_DIR}/archive_obs.csh   >&! ${SCRIPT_DIR}/logdir/arclog.${hh}z

echo "`date` running archive_wrfda.csh ......"
${SCRIPT_DIR}/archive_wrfda.csh >> ${SCRIPT_DIR}/logdir/arclog.${hh}z

endif
