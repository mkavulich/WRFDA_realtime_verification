#!/bin/csh
#BSUB -J ep2
#BSUB -q caldera
#BSUB -n 1
#BSUB -o job.out
#BSUB -e job.out
#BSUB -W 3:00
#BSUB -P P64000510
##BSUB -P NMMM0016
set echo
#set BIN_DIR = $HOME/bin
#set SCRIPT_DIR = /glade/u/home/hclin/scripts/rt2015
#set EP_EXE_DIR = /glade/p/work/hclin/code_intel/V37/WRFDA_serial/var/build
#set EP_DIR_TOP = /glade/scratch/hclin/CONUS/wrfda/enspert
#set ENS_SIZE = 50
#set ANAL_DATE = 2015051112

#   set EP_DIR = ${EP_DIR_TOP}/${ANAL_DATE}/ep
#   if ( ! -d ${EP_DIR} ) mkdir -p ${EP_DIR}
#   cd ${EP_DIR}

   ln -sf ${EP_EXE_DIR}/gen_be_ep2.exe ./gen_be_ep2.exe
   ./gen_be_ep2.exe ${ANAL_DATE} ${ENS_SIZE} ${EP_DIR} wrfout_d01_${FCST_DATE} 1 >&! log.${ANAL_DATE}

   grep "All Done" log.${ANAL_DATE}
   if ( $status != 0 ) then
      echo "ERROR in $0 : gen_be_ep2.exe failed"
      mail -s "RT2015: ${ANAL_DATE} Error gen_be_ep2inf" "hclin@ucar.edu" < log.${ANAL_DATE}
      exit 1
   else
      touch FINISHED
      \rm -f tmp.e*
      cd ${EP_DIR_TOP}

      #archive ensemble perturbations
      set archive_fname = ep_${ANAL_DATE}_${FCST_DATE}.tar.gz
      tar czvf ${archive_fname} ${ANAL_DATE}/ep/ps.e* \
             ${ANAL_DATE}/ep/u.e* ${ANAL_DATE}/ep/v.e* ${ANAL_DATE}/ep/t.e* ${ANAL_DATE}/ep/q*.e* \
             ${ANAL_DATE}/ep/*.mean ${ANAL_DATE}/ep/*.stdv \
             ${ANAL_DATE}/ep/prior_inf_ic
      set HSI_DIR = ${HSI_BASEDIR}/enspert_inflate
      hsi "cd ${HSI_DIR}; lcd ${EP_DIR_TOP}; put -p ${archive_fname}"
      if { hsi ls ${HSI_DIR}/${archive_fname} >& /dev/null } then
         \rm -f ${ANAL_DATE}/ep/qcloud.* ${ANAL_DATE}/ep/qrain.* ${ANAL_DATE}/ep/qice.* ${ANAL_DATE}/ep/qsnow.* ${ANAL_DATE}/ep/qgraup.*
         \rm -f ${archive_fname}
      endif

      #archive prior P and PB info
      set archive_fname = prior_P_PB_inf_${ANAL_DATE}_${FCST_DATE}.tar.gz
      tar czvfh ${archive_fname} ${ANAL_DATE}/ep/prior_inf_ic_orig ${ANAL_DATE}/ep/prior_inf_ic ${ANAL_DATE}/ep/prior_d01*
      set HSI_DIR = /home/hclin/RT2015/enspert_inflate
      hsi "cd ${HSI_DIR}; lcd ${EP_DIR_TOP}; put -p ${archive_fname}"
      if { hsi ls ${HSI_DIR}/${archive_fname} >& /dev/null } then
         \rm -f ${archive_fname} ${ANAL_DATE}/ep/prior_d01*
      endif
   endif
