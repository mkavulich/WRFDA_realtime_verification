#!/bin/csh
#BSUB -J ep
#BSUB -q caldera
#BSUB -n 1
#BSUB -o job.out
#BSUB -e job.out
#BSUB -W 3:00
#BSUB -P P64000510

#source /glade/u/home/hclin/scripts/rt2015/params.csh

set echo
setenv bsub_cmd    /ncar/opt/lsf/9.1/linux2.6-glibc2.3-x86_64/bin/bsub
setenv BIN_DIR     $HOME/bin
setenv SCRIPT_DIR  /glade/u/home/hclin/scripts/rt2015
#setenv EP_EXE_DIR  /glade/p/work/hclin/code_intel/WRFDA/trunk_serial/var/build
#setenv EP_EXE_DIR  /glade/p/work/hclin/code_intel/WRFDA/v371+/var/build #starting 2015102118
setenv EP_EXE_DIR  /glade/p/work/hclin/code_intel/WRFDA/v38-/var/build
setenv EP_DIR_TOP  /glade/scratch/hclin/CONUS/wrfda/enspert_inflate
#setenv FC_DIR_TOP  /glade/scratch/wrfrt/realtime_ensemble/wrfdart/rundir
setenv FC_DIR_TOP  /glade/scratch/wrfrt/realtime_ensemble/wrfdart_80M40L/rundir
setenv ENS_SIZE    80
setenv ADVANCE_HOUR   6
#setenv ANAL_DATE   2015051112

   if ( $#argv > 0 ) then
      setenv ANAL_DATE $1
   else
      set date_yyyymmdd = `date -u +%Y%m%d`
      set hh            = `date -u +%H`  ;  set hh = `expr $hh \+ 0`
      if      ( $hh >= 0  && $hh < 6  ) then
         set hh = '00'
      else if ( $hh >= 6  && $hh < 12 ) then
         set hh = '06'
      else if ( $hh >= 12 && $hh < 18 ) then
         set hh = '12'
      else if ( $hh >= 18 && $hh < 24 ) then
         set hh = '18'
      endif
      setenv ANAL_DATE ${date_yyyymmdd}${hh}
   endif

   setenv FCST_DATE `${BIN_DIR}/da_advance_time.exe ${ANAL_DATE} ${ADVANCE_HOUR}`

   set done = false
   while ( $done == false )
      if ( -e ${FC_DIR_TOP}/cycle_finished_${ANAL_DATE} ) then
         set done = true
      endif
      if ( $done == false ) sleep 300
   end

   setenv EP_DIR ${EP_DIR_TOP}/${ANAL_DATE}/ep
   if ( ! -d ${EP_DIR} ) mkdir -p ${EP_DIR}
   cd ${EP_DIR}

   #cp -p ${FC_DIR_TOP}/Inflation_input/prior_inf_ic_old_mean_d01 prior_inf_ic
   set INFLATION_FILE = ${FC_DIR_TOP}/../output/${ANAL_DATE}/Inflation_input/prior_inf_ic_old_mean_d01
   ln -sf ${INFLATION_FILE} prior_inf_ic_source
   cp -p ${INFLATION_FILE} prior_inf_ic_orig
   /glade/apps/opt/nco/4.4.2/gnu/4.8.2/bin/ncap2 -s 'U=float(U)' -s 'V=float(V)' \
      -s 'T=float(T)' -s 'QVAPOR=float(QVAPOR)' -s 'PSFC=float(PSFC)' \
      -s 'QCLOUD=float(QCLOUD)' -s 'QRAIN=float(QRAIN)' -s 'QICE=float(QICE)' \
      -s 'QSNOW=float(QSNOW)' -s 'QGRAUP=float(QGRAUP)' prior_inf_ic_orig prior_inf_ic

   @ ie = 1
   while ( $ie <= $ENS_SIZE )
      set cmem = `printf %03i $ie`
      set FC_DIR = ${FC_DIR_TOP}/advance_temp${ie}
      if ( ! -e wrfout_d01_${FCST_DATE}.e${cmem} ) then
         #cp -p ${FC_DIR}/wrfinput_d01 wrfout_d01_${FCST_DATE}.e${cmem}
         ln -sf ${FC_DIR}/wrfinput_d01 wrfout_d01_${FCST_DATE}.e${cmem}
         # keep P and PB
         /glade/apps/opt/nco/4.4.2/gnu/4.8.2/bin/ncks -O -v P,PB wrfout_d01_${FCST_DATE}.e${cmem} prior_d01_P_PB_${ANAL_DATE}_${FCST_DATE}.e${cmem}
      endif
      @ ie = $ie + 1
   end

   #${EP_EXE_DIR}/gen_be_ep2.exe ${ANAL_DATE} ${ENS_SIZE} ${EP_DIR} wrfout_d01_${FCST_DATE} 1
   ${bsub_cmd} -q caldera -n 1 -J "${ANAL_DATE}_epinf" < ${SCRIPT_DIR}/run_ep2_inflate.csh

   /glade/apps/opt/nco/4.4.2/gnu/4.8.2/bin/ncea -O wrfout_d01_${FCST_DATE}.* ${EP_DIR_TOP}/wrfout_d01_${ANAL_DATE}_${FCST_DATE}.mean

   set HSI_DIR = /home/hclin/RT2015/ensfcst_mean
   hsi "cd ${HSI_DIR}; lcd ${EP_DIR_TOP}; put -p wrfout_d01_${ANAL_DATE}_${FCST_DATE}.mean"
   if { hsi ls ${HSI_DIR}/wrfout_d01_${ANAL_DATE}_${FCST_DATE}.mean >& /dev/null } then
      \rm -f ${EP_DIR_TOP}/wrfout_d01_${ANAL_DATE}_${FCST_DATE}.mean
   endif

exit 0
