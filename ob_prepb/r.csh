#!/bin/csh
#set echo
setenv EXPT       ob_prepb
setenv OB_FORMAT  1
#setenv QUEUE      premium
setenv QUEUE      regular
echo "Beginning $0"
source ${BASE_DIR}/${EXPT}/params.csh

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
#\rm -f ${SCRIPT_DIR}/job.out
#echo "`date` started for ${EXPT} ${DATE}" > ${SCRIPT_DIR}/logdir/started_${DATE}
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
               exit 1
            endif
            sleep 60
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
   
   set gdate = (`${EP_EXE_DIR}/da_advance_time.exe $DATE 0 -g`)
   set gdatef = (`${EP_EXE_DIR}/da_advance_time.exe $DATE $ADVANCE_HOUR -g`)
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
            echo "   `date` Error in run_wrfda.csh ......"
            mail -s "RT2015: ${DATE} ${EXPT} Error da" "hclin@ucar.edu" < ${SCRIPT_DIR}/logdir/log.${hh}z
            exit 1
         endif
         sleep 60
      endif
   end
endif

cd ${SCRIPT_DIR}
set file_to_check = $EXP_DIR_TOP/${DA_METHOD}/advance/${DATE}/FINISHED
if ( ! -e ${file_to_check} ) then
   echo "`date` submit run_advance.csh ......"
   ${bsub_cmd} -q ${QUEUE} -J "adv${mm}${dd}${hh}" < ${SCRIPT_DIR}/run_advance.csh >&! ${LOG_DIR}/${DATE}.advance

   set fc_done = false
   while ( $fc_done == false )
      if ( -e $file_to_check ) then
         set fc_done = true
         mv ${SCRIPT_DIR}/job.out ${LOG_DIR}/job_adv.${DATE}
      endif
      if ( $fc_done == false ) then
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

