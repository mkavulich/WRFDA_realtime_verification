#!/bin/csh
#BSUB -J arc
#BSUB -q geyser
#BSUB -n 1
#BSUB -o job.out
#BSUB -e job.out
#BSUB -W 06:00
#BSUB -P P64000510

echo "Beginning $0"
set START_DATE = $ANAL_DATE #2015060812
set END_DATE   = $ANAL_DATE #2015082500
set CYCLE_PERIOD = 06
set ADVANCE_HOUR = 06
set DATE = $START_DATE
set BIN_DIR = ${HOME}/bin
#set EXP_DIR_TOP = /glade/scratch/hclin/CONUS/wrfda/expdir/start2015112400/hyb_ens75
#set EXP_DIR_TOP = /glade/scratch/hclin/CONUS/wrfda/expdir/start2016060800/hyb_ens75
#set EXP_DIR_TOP = /glade/scratch/hclin/CONUS/wrfda/expdir/start2016082612/hyb_ens75
set EXP_DIR_TOP = /glade/scratch/hclin/CONUS/wrfda/expdir/start2016102512/hyb_ens75
while ( $DATE <= $END_DATE )

   set gdate = (`${BIN_DIR}/da_advance_time.exe $DATE 0 -g`)
   set gdatef = (`${BIN_DIR}/da_advance_time.exe $DATE $ADVANCE_HOUR -g`)

   cd ${EXP_DIR_TOP}/${DATE}

   set HSI_DIR = /home/hclin/RT2015/hyb_ens75/${DATE}
   hsi "mkdir -p ${HSI_DIR}"

   set archive_fname = wrfda_diags_${DATE}.tar
   tar cvfh ${archive_fname} \
       01_qcstat_* \
       VARBC.in \
       VARBC.out \
       filtered_obs_01 \
       gts_omb_oma_01 \
       namelist.input \
       qcstat_conv_01 \
       rad01_oma_${DATE}.tar.gz \
       rej_obs_conv_01 \
       rsl \
       statistics \
       cost_fn \
       grad_fn \
       jo \
       namelist.input
   if ( -d unipost_an ) then
      tar cvfh ${archive_fname} \
          an_${DATE}.nc \
          unipost_an/WRFPRS00.tm00 \
          unipost_an/WRFTWO00.tm00 \
          unipost_an/griddef.out \
          unipost_an/wrf_cntrl.parm \
          unipost_an/itag
   endif
   if ( -e ${archive_fname} ) gzip ${archive_fname}

   hsi "cd ${HSI_DIR}; lcd ${EXP_DIR_TOP}/${DATE}; put -p ${archive_fname}.gz"
   if { hsi ls ${HSI_DIR}/${archive_fname}.gz >& /dev/null } then
      \rm -f ${archive_fname}.gz
   else
      echo "Error archiving wrfda_diags for ${DATE}"
   endif

   set archive_fname = wrfda_inout_${DATE}.tar.gz
   tar czvfh ${archive_fname} \
       LANDUSE.TBL \
       VARBC.in \
       fg \
       namelist.input \
       parame.in.latbdy \
       parame.in.lowbdy \
       radiance_info/*info \
       wrfbdy_d01_${DATE} \
       wrfvar_output_d01_${DATE}

   hsi "cd ${HSI_DIR}; lcd ${EXP_DIR_TOP}/${DATE}; put -p ${archive_fname}"
   if { hsi ls ${HSI_DIR}/${archive_fname} >& /dev/null } then
      \rm -f ${archive_fname}
   else
      echo "Error archiving for ${DATE}"
   endif

   set DATE = `${HOME}/bin/da_advance_time.exe $DATE $CYCLE_PERIOD`

end #DATE loop
