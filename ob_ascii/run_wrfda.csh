#!/bin/csh
#BSUB -J da
#BSUB -q regular
##BSUB -n 128
#BSUB -n 64
#BSUB -o job.out
#BSUB -e job.out
#BSUB -W 0:10
#BSUB -P P64000510
#
set echo
echo "Beginning $0"
module load mkl
module swap intel/12.1.5 intel/13.1.2

if ( ! $?PARAMS_SET ) then
   source ${BASE_DIR}/${EXPT}/params.csh
endif
#set FG_SOURCE = $1
#set FG_SOURCE = ensfc_mean
#set FG_SOURCE = cycle
#set DA_METHOD = hybrid_ens75_amsua
#set JE_FACTOR = 1.33
#set ENS_SIZE = 50
#set DA_METHOD = 3dvar_amsua
#set JE_FACTOR = 1.0
#set ENS_SIZE = 0
#set use_radiance = false
#set use_radiance = true

if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif

set DATE  = $ANAL_DATE

set PREV_DATE = `${EP_EXE_DIR}/da_advance_time.exe ${DATE} -${CYCLE_PERIOD}`
set NEXT_DATE = `${EP_EXE_DIR}/da_advance_time.exe ${DATE}  ${CYCLE_PERIOD}`
set cc = `echo $DATE | cut -c1-2`
set yy = `echo $DATE | cut -c3-4`
set ccyy = `echo $DATE | cut -c1-4`
set   mm = `echo $DATE | cut -c5-6`
set   dd = `echo $DATE | cut -c7-8`
set   hh = `echo $DATE | cut -c9-10`
set   mi = 00 #`echo $DATE | cut -c11-12`
set DATE1 = `${EP_EXE_DIR}/da_advance_time.exe ${DATE} ${TIMEWINDOW1} -f ccyymmddhhnn`
set DATE2 = `${EP_EXE_DIR}/da_advance_time.exe ${DATE} ${TIMEWINDOW2} -f ccyymmddhhnn`
set ccyy1 = `echo $DATE1 | cut -c1-4`
set   mm1 = `echo $DATE1 | cut -c5-6`
set   dd1 = `echo $DATE1 | cut -c7-8`
set   hh1 = `echo $DATE1 | cut -c9-10`
set   mi1 = `echo $DATE1 | cut -c11-12`
set ccyy2 = `echo $DATE2 | cut -c1-4`
set   mm2 = `echo $DATE2 | cut -c5-6`
set   dd2 = `echo $DATE2 | cut -c7-8`
set   hh2 = `echo $DATE2 | cut -c9-10`
set   mi2 = `echo $DATE2 | cut -c11-12`
if ( ${VAR4D} == TRUE ) then
   set ccyy_e = `echo $DATE2 | cut -c1-4`
   set   mm_e = `echo $DATE2 | cut -c5-6`
   set   dd_e = `echo $DATE2 | cut -c7-8`
   set   hh_e = `echo $DATE2 | cut -c9-10`
   set   mi_e = `echo $DATE2 | cut -c11-12`
else
   set ccyy_e = `echo $DATE | cut -c1-4`
   set   mm_e = `echo $DATE | cut -c5-6`
   set   dd_e = `echo $DATE | cut -c7-8`
   set   hh_e = `echo $DATE | cut -c9-10`
   set   mi_e = 00 #`echo $DATE | cut -c11-12`
endif

set DATE_WRF = `${EP_EXE_DIR}/da_advance_time.exe ${DATE} 0 -w`

   set domain_id = 01

   set DA_RUN_DIR = ${EXP_DIR_TOP}/${DA_METHOD}/${DATE}
   if ( ! -d ${DA_RUN_DIR} ) mkdir -p ${DA_RUN_DIR}
   cd ${DA_RUN_DIR}

   rm -f ${DA_RUN_DIR}/rsl.*
   rm -f ${DA_RUN_DIR}/FAIL


set gdate = (`${EP_EXE_DIR}/da_advance_time.exe $DATE 0 -g`)
set gdatef = (`${EP_EXE_DIR}/da_advance_time.exe $DATE $CYCLE_PERIOD -g`)

#if ( ! -e wrfinput_d${domain_id}_${gdate[1]}_${gdate[2]}_mean || \
#     ! -e wrfbdy_d${domain_id}_${gdatef[1]}_${gdatef[2]}_mean ) then
   if ( -e retro.tar ) then
      #tar xvf /glade/scratch/wrfrt/realtime_ensemble/wrfdart/output/${DATE}/retro.tar
      tar xvf retro.tar
      gzip -d *gz
   endif
#endif

   if ( -e ep ) \rm -f ep
   if ( ! -e ${EP_DIR_TOP}/${PREV_DATE}/ep/FINISHED ) then
      setenv ENS_SIZE 0
   else
      ln -sf ${EP_DIR_TOP}/${PREV_DATE}/ep ./ep
      ${WRFDA_SRC_DIR}/var/build/gen_be_vertloc.exe  ${VERTICAL_GRID_NUMBER}
   endif
#
# link some constant files
#
   ln -sf ${WRFDA_SRC_DIR}/run/LANDUSE.TBL  .
   ln -sf ${OBSERR_FILE} ./obs_errtable
   ln -sf ${BE_FILE}     ./be.dat

   if ( $VAR4D == TRUE ) then
      ln -sf ${WRFDA_SRC_DIR}/run/*TBL .
      ln -sf ${WRFDA_SRC_DIR}/run/*DATA .
      ln -sf ${WRFDA_SRC_DIR}/run/ETAMPNEW_DATA_DBL ETAMPNEW_DATA
      ln -sf ${WRFDA_SRC_DIR}/run/RRTMG_LW_DATA_DBL RRTMG_LW_DATA
      ln -sf ${WRFDA_SRC_DIR}/run/RRTMG_SW_DATA_DBL RRTMG_SW_DATA
      ln -sf ${WRFDA_SRC_DIR}/run/RRTM_DATA_DBL     RRTM_DATA
   endif
#
# link first-guess, observations, background-error
#
   if ( $VAR4D == TRUE ) then
      ln -sf ${BUFR_DATDIR}/asr.gpsro.gdas.${DATE}         ./gpsro01.bufr
      ln -sf ${BUFR_DATDIR}/asr.gpsro.gdas.${NEXT_DATE}    ./gpsro02.bufr
      ln -sf ${BUFR_DATDIR}/asr.prepbufr.gdas.${DATE}      ./ob01.bufr
      ln -sf ${BUFR_DATDIR}/asr.prepbufr.gdas.${NEXT_DATE} ./ob02.bufr
     if ( $use_radiance == true ) then
      ln -sf ${BUFR_DATDIR}/asr.1bamua.gdas.${DATE}        ./amsua01.bufr
      ln -sf ${BUFR_DATDIR}/asr.1bamua.gdas.${NEXT_DATE}   ./amsua02.bufr
      ln -sf ${BUFR_DATDIR}/asr.airsev.gdas.${DATE}        ./airs01.bufr
      ln -sf ${BUFR_DATDIR}/asr.airsev.gdas.${NEXT_DATE}   ./airs02.bufr
      #ln -sf ${BUFR_DATDIR}/asr.1bamub.gdas.${DATE}       ./amsub01.bufr
      #ln -sf ${BUFR_DATDIR}/asr.1bamub.gdas.${NEXT_DATE}  ./amsub02.bufr
      #ln -sf ${BUFR_DATDIR}/asr.1bmhs.gdas.${DATE}        ./mhs01.bufr
      #ln -sf ${BUFR_DATDIR}/asr.1bmhs.gdas.${NEXT_DATE}   ./mhs02.bufr
     endif
   else
      ln -sf ${OB_DIR_TOP}/${DATE}/ob_d${domain_id}.ascii.${DATE}  ./ob.ascii
      ln -sf ${OB_DIR_TOP}/${DATE}/gfs.t${hh}z.gpsro.tm00.bufr_d   ./gpsro.bufr
      ln -sf ${OB_DIR_TOP}/${DATE}/gfs.t${hh}z.prepbufr.nr         ./ob.bufr
      #ln -sf ${BUFR_DATDIR}/asr.gpsro.gdas.${DATE}    ./gpsro.bufr
      #ln -sf ${BUFR_DATDIR}/asr.prepbufr.gdas.${DATE} ./ob.bufr
     if ( $use_radiance == true ) then
      #if ( ${hh} == 00 || ${hh} == 12 ) then
      #   ln -sf ${AMSU_DIR}/amsua.${DATE}.gfs.bufr   ./amsua.bufr
      #else
         ln -sf ${OB_DIR_TOP}/${DATE}/amsua.${DATE}.bufr ./amsua.bufr
         ln -sf ${OB_DIR_TOP}/${DATE}/gfs.t${hh}z.1bamua.tm00.bufr_d ./amsua.bufr
      #endif
      #ln -sf ${BUFR_DATDIR}/asr.1bamua.gdas.${DATE}   ./amsua.bufr
      #ln -sf ${BUFR_DATDIR}/asr.airsev.gdas.${DATE}   ./airs.bufr
      #ln -sf ${BUFR_DATDIR}/asr.1bamub.gdas.${DATE}   ./amsub.bufr
      #ln -sf ${BUFR_DATDIR}/asr.1bmhs.gdas.${DATE}    ./mhs.bufr
     endif
   endif

 if ( $use_radiance == true ) then
   if ( -e radiance_info ) \rm -f radiance_info
   #ln -sf ${WRFDA_SRC_DIR}/var/run/radiance_info ./radiance_info
   ln -sf ${FIX_DIR}/radiance_info ./radiance_info
# link VARBC related file
   set VARBC_PREV_DATE = `${EP_EXE_DIR}/da_advance_time.exe ${DATE} -${CYCLE_PERIOD}`
   #set in params.csh set VARBC_DIR = /nfs/gpfs/PAS0400/osu5183/VARBC

   if ( ! -e ${EXP_DIR_TOP}/${DA_METHOD}/${VARBC_PREV_DATE}/VARBC.out ) then
      if ( ! -e ${VARBC_DIR}/${DATE}/VARBC.out ) then
         if ( -e ${VARBC_DIR}/VARBC.out ) then
            ln -sf ${VARBC_DIR}/VARBC.out ./VARBC.in
         else
            ln -sf ${WRFDA_SRC_DIR}/var/run/VARBC.in ./VARBC.in
         endif
      else
         ln -sf ${VARBC_DIR}/${DATE}/VARBC.out ./VARBC.in
      endif
   else
      ln -sf ${EXP_DIR_TOP}/${DA_METHOD}/${VARBC_PREV_DATE}/VARBC.out ./VARBC.in
   endif
 endif

   if ( ${FG_SOURCE} == 'cold' ) then
      if ( ! -e ${REAL_RUN_DIR}/${DATE}/wrfinput_d${domain_id} ) then
         echo "ERROR in run_wrfda.csh : first guess ${REAL_RUN_DIR}/${DATE}/wrfinput_d${domain_id} not found..." >> ${CSH_DIR}/job_${EXPT}.log
         exit 1
      endif
      ln -sf ${REAL_RUN_DIR}/${DATE}/wrfinput_d${domain_id} fg
   else if ( ${FG_SOURCE} == 'ensfc_mean' ) then
      #set FG_FILE = ${EP_DIR_TOP}/${PREV_DATE}/ep/wrfout_d${domain_id}_${DATE}.mean
      set FG_FILE = ${EP_DIR_TOP}/wrfout_d${domain_id}_${PREV_DATE}_${DATE}.mean
      if ( ! -e ${FG_FILE} ) then
            echo "ERROR in run_wrfda.csh : first guess ${FG_FILE} not found..." > FAIL
            exit 1
      else
         ln -sf ${FG_FILE} fg_orig
         cp -p ${FG_FILE} fg
      endif
   else if ( ${FG_SOURCE} == 'cycle' ) then
      set FG_FILE = ${EXP_DIR_TOP}/${DA_METHOD}/advance/${PREV_DATE}/wrfout_d${domain_id}_${DATE_WRF}
      if ( ! -e ${FG_FILE} ) then
            echo "ERROR in run_wrfda.csh : first guess ${FG_FILE} not found..." > FAIL
            exit 1
      else
         ln -sf ${FG_FILE} fg_orig
         cp -p ${FG_FILE} fg
      endif
   endif

   if ( ${FGAT} == TRUE ) then
      set DATE_WRF = `${EP_EXE_DIR}/da_advance_time.exe ${PREV_DATE} 03 -w`
      ln -sf ${EXP_DIR_TOP}/${PREV_DATE}/wrf/wrfinput_d${domain_id}_${DATE_WRF} fg01
      set DATE_WRF = `${EP_EXE_DIR}/da_advance_time.exe ${PREV_DATE} 04 -w`
      ln -sf ${EXP_DIR_TOP}/${PREV_DATE}/wrf/wrfinput_d${domain_id}_${DATE_WRF} fg02
      set DATE_WRF = `${EP_EXE_DIR}/da_advance_time.exe ${PREV_DATE} 05 -w`
      ln -sf ${EXP_DIR_TOP}/${PREV_DATE}/wrf/wrfinput_d${domain_id}_${DATE_WRF} fg03
      set DATE_WRF = `${EP_EXE_DIR}/da_advance_time.exe ${PREV_DATE} 06 -w`
      ln -sf ${EXP_DIR_TOP}/${PREV_DATE}/wrf/wrfinput_d${domain_id}_${DATE_WRF} fg04
      set DATE_WRF = `${EP_EXE_DIR}/da_advance_time.exe ${PREV_DATE} 07 -w`
      ln -sf ${EXP_DIR_TOP}/${PREV_DATE}/wrf/wrfinput_d${domain_id}_${DATE_WRF} fg05
      set DATE_WRF = `${EP_EXE_DIR}/da_advance_time.exe ${PREV_DATE} 08 -w`
      ln -sf ${EXP_DIR_TOP}/${PREV_DATE}/wrf/wrfinput_d${domain_id}_${DATE_WRF} fg06
      set DATE_WRF = `${EP_EXE_DIR}/da_advance_time.exe ${PREV_DATE} 09 -w`
      ln -sf ${EXP_DIR_TOP}/${PREV_DATE}/wrf/wrfinput_d${domain_id}_${DATE_WRF} fg07
   endif

   if ( ${FG_SOURCE} != 'cold' && -e ${DA_RUN_DIR}/wrfinput_d${domain_id}_${gdate[1]}_${gdate[2]}_mean ) then
      # when not cold-starting, update lower boundary first, before running wrfvar
      if ( $VAR4D == TRUE ) then
         set UPDATE_LATERAL_BDY = .true.
         ln -sf ${REAL_RUN_DIR}/${DATE}/wrfbdy_d${domain_id} ${DA_RUN_DIR}/wrfbdy_d${domain_id}_orig
         cp -p ${REAL_RUN_DIR}/${DATE}/wrfbdy_d${domain_id} ${DA_RUN_DIR}/wrfbdy_d${domain_id}
      else
         set UPDATE_LATERAL_BDY = .false.
      endif
      set UPDATE_LOW_BDY     = .true.
      cd ${DA_RUN_DIR}
      cat >! ${DA_RUN_DIR}/parame.in << EOF
&control_param
 da_file            = '${DA_RUN_DIR}/fg'
 wrf_bdy_file       = '${DA_RUN_DIR}/wrfbdy_d${domain_id}_${gdatef[1]}_${gdatef[2]}_mean'
 wrf_input          = '${DA_RUN_DIR}/wrfinput_d${domain_id}_${gdate[1]}_${gdate[2]}_mean'
 domain_id          = ${domain_id}
 debug              = .false.
 update_lateral_bdy = ${UPDATE_LATERAL_BDY}
 update_low_bdy     = ${UPDATE_LOW_BDY}
 keep_snow_wrf      = .false.
 update_lsm         = .false.
 iswater            = 17 /
EOF
      ln -sf ${WRFDA_SRC_DIR}/var/build/da_update_bc.exe .
      time ./da_update_bc.exe >&! log.update_low_bc_${DATE}
      mv parame.in parame.in.lowbdy
      # check status
      grep "Update_bc completed successfully" log.update_low_bc_${DATE}
      if ( $status != 0 ) then
         echo "ERROR in run_wrfda.csh : update low bc failed..." > FAIL
         exit 1
      #else
      #   echo "`date` Done updating low bdy ${DATE}" >> ${CSH_DIR}/job_${EXPT}.log
      endif
   endif

   if ( $VAR4D == TRUE ) then
      ln -sf fg wrfinput_d01
      if ( ${VAR4D_LBC} == TRUE ) then
         #ln -sf ${REAL_RUN_DIR}/${NEXT_DATE}/wrfinput_d${domain_id} fg02
         cp -p ${REAL_RUN_DIR}/${NEXT_DATE}/wrfinput_d${domain_id} fg02
      endif
      #ln -sf ${REAL_RUN_DIR}/${DATE}/wrfbdy_d${domain_id} wrfbdy_d${domain_id}
   endif
#
# create namelist
#
# es_liquid=true # calculate RH not take into account ice
#
   cat >! namelist.input << EOF1
 &wrfvar1
 print_detail_rad=false,
 print_detail_grad=false,
 print_detail_outerloop=false,
 var4d=.${VAR4D}.,
 var4d_lbc=.${VAR4D_LBC}.,
 var4d_bin = 3600,
 multi_inc=0
 /
 &wrfvar2
 /
 &wrfvar3
 ob_format=${OB_FORMAT}
 OB_FORMAT_GPSRO=1
EOF1
   if ( $FGAT == TRUE ) then
      cat >> namelist.input << EOF2
 num_fgat_time=${NUM_FGAT_TIME}
EOF2
   endif
   cat >> namelist.input << EOF3
 /
 &wrfvar4
 thin_mesh_conv = 28*60.0
 top_km_gpsro   = 12.0,
 bot_km_gpsro   = 2.0,
 USE_SYNOPOBS =  T,
 USE_SHIPSOBS =  T,
 USE_METAROBS =  T,
 USE_SOUNDOBS =  T,
 USE_MTGIRSOBS =  F,
 USE_TAMDAROBS =  F,
 USE_PILOTOBS =  T,
 USE_AIREPOBS =  T,
 USE_GEOAMVOBS =  T,
 USE_POLARAMVOBS =  T,
 USE_BOGUSOBS =  F,
 USE_BUOYOBS =  T,
 USE_PROFILEROBS =  T,
 USE_SATEMOBS =  T,
 USE_GPSZTDOBS =  F,
 USE_GPSPWOBS =  T,
 USE_GPSREFOBS =  T,
 USE_QSCATOBS =  T,
 USE_AIRSRETOBS =  F,
 use_ssmiretrievalobs=F,
EOF3
   if ( $use_radiance == true ) then
      cat >> namelist.input << EOF4
 use_amsuaobs = T,
EOF4
   endif
      cat >> namelist.input << EOF4
 use_amsubobs = F,
 use_mhsobs   = F,
 use_airsobs  = F,
 use_eos_amsuaobs = F,
 USE_OBS_ERRFAC=F,
 /
 &wrfvar5
 MAX_ERROR_T =    5.000000000000000     ,
 MAX_ERROR_UV =   5.000000000000000     ,
 MAX_ERROR_PW =   5.000000000000000     ,
 MAX_ERROR_REF =  5.000000000000000     ,
 MAX_ERROR_Q =    5.000000000000000     ,
 MAX_ERROR_P =    5.000000000000000     ,
 /
 &wrfvar6
 max_ext_its=1,
 ntmax=70,
 eps=0.01,
 orthonorm_gradient=.false.,
 /
 &wrfvar7
 cv_options=${CV_OPTIONS},
 AS1     =  0.050000000000000     ,   1.00000000000000     ,   1.50000000000000     , 27*-1.00000000000000       ,
 AS2     =  0.050000000000000     ,   1.00000000000000     ,   1.50000000000000     , 27*-1.00000000000000       ,
 AS3     =  0.050000000000000     ,   1.00000000000000     ,   1.50000000000000     , 27*-1.00000000000000       ,
 AS4     =  0.050000000000000     ,   1.00000000000000     ,   1.50000000000000     , 27*-1.00000000000000       ,
 AS5     =  0.050000000000000     ,   1.00000000000000     ,   1.50000000000000     , 27*-1.00000000000000       ,
 var_scaling1 = 1.,
 var_scaling2 = 1.,
 var_scaling3 = 1.,
 var_scaling4 = 1.,
 var_scaling5 = 1.,
 len_scaling1 = 1.,
 len_scaling2 = 1.,
 len_scaling3 = 1.,
 len_scaling4 = 1.,
 len_scaling5 = 1.,
 je_factor=${JE_FACTOR}
 /
 &wrfvar8
 /
 &wrfvar9
 trace_use=false,
 /
 &wrfvar10
 /
 &wrfvar11
 calculate_cg_cost_fn=false,
 lat_stats_option=false,
 check_rh=1
 SFC_ASSI_OPTIONS=1,
 /
 &wrfvar12
 /
 &wrfvar13
 /
 &wrfvar14
 rtminit_nsensor=4,
 rtminit_platform=1,1,1,10
 rtminit_satid=15,18,19,2
 rtminit_sensor=3,3,3,3
 thinning_mesh=30*90.0
 thinning=true,
 qc_rad=true,
 write_iv_rad_ascii=false,
 write_oa_rad_ascii=true,
 rtm_option=2,
 only_sea_rad=false,
 use_varbc=.true.
 varbc_factor=1.0,
 varbc_nbgerr=500,
 varbc_nobsmin=100,
 use_crtm_kmatrix=.true.
 use_blacklist_rad=.true.
 crtm_coef_path='${WRFDA_SRC_DIR}/var/run/crtm_coeffs_2.1.3'
 /
 &wrfvar15
 /
 &wrfvar16
 ensdim_alpha=${ENS_SIZE}
 alphacv_method=2
 alpha_corr_scale=200.0
 alpha_vertloc=.true.
 alpha_hydrometeors=.false.
 /
 &wrfvar17
 analysis_type="QC-OBS"
 /
 &wrfvar18
 analysis_date="${ccyy}-${mm}-${dd}_${hh}:00:00.0000",
 /
 &wrfvar19
 /
 &wrfvar20
 /
 &wrfvar21
 time_window_min="${ccyy1}-${mm1}-${dd1}_${hh1}:${mi1}:00.0000",
 /
 &wrfvar22
 time_window_max="${ccyy2}-${mm2}-${dd2}_${hh2}:${mi2}:00.0000",
 /
 &wrfvar23
 /
 &time_control
 start_year                          = ${ccyy}
 start_month                         = ${mm}
 start_day                           = ${dd}
 start_hour                          = ${hh}
 start_minute                        = ${mi}
 start_second                        = 00
 end_year                            = ${ccyy_e}
 end_month                           = ${mm_e}
 end_day                             = ${dd_e}
 end_hour                            = ${hh_e}
 end_minute                          = ${mi_e}
 end_second                          = 00
 /
 &dfi_control
 /
 &domains
 time_step                           = 60,
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = 1,
 s_we                                = 1
 e_we                                = ${WEST_EAST_GRID_NUMBER}
 s_sn                                = 1
 e_sn                                = ${SOUTH_NORTH_GRID_NUMBER}
 s_vert                              = 1
 e_vert                              = ${VERTICAL_GRID_NUMBER}
 dx                                  = ${GRID_DISTANCE}
 dy                                  = ${GRID_DISTANCE}
 grid_id                             = 1,
 parent_id                           = 0,
 i_parent_start                      = 1,
 j_parent_start                      = 1,
 parent_grid_ratio                   = 1,
 parent_time_step_ratio              = 1,
 feedback                            = 0,
 smooth_option                       = 1,
 p_top_requested                     = 5000,
 lagrange_order                      = 2,
 interp_type                         = 2,
 interp_theta                        = .false.,
 hypsometric_opt                     = 2,
 extrap_type                         = 2
 t_extrap_type                       = 2
 use_surface                         = .true.,
 use_levels_below_ground             = .true.,
 lowest_lev_from_sfc                 = .false.,
 force_sfc_in_vinterp                = 1,
 zap_close_levels                    = 500,
 eta_levels                          = 1.00000 , 0.99307 , 0.98348 , 0.97105 , 0.95551 ,
                                       0.93651 , 0.91363 , 0.88644 , 0.85460 , 0.81855 ,
                                       0.77877 , 0.73579 , 0.69016 , 0.64246 , 0.59329 ,
                                       0.54573 , 0.50104 , 0.45908 , 0.41972 , 0.38281 ,
                                       0.34824 , 0.31589 , 0.28563 , 0.25735 , 0.23096 ,
                                       0.20635 , 0.18343 , 0.16209 , 0.14226 , 0.12384 ,
                                       0.10677 , 0.09095 , 0.07633 , 0.06282 , 0.05036 ,
                                       0.03889 , 0.02835 , 0.01868 , 0.00983 , 0.00000
 /
 &physics
 mp_physics                          = 8,
 ra_lw_physics                       = 4,
 ra_sw_physics                       = 4,
 radt                                = 10,
 sf_sfclay_physics                   = 2,
 sf_surface_physics                  = 2,
 bl_pbl_physics                      = 2,
 bldt                                = 0,
 cu_physics                          = 6,
 cudt                                = 5,
 mp_zero_out                         = 2,
 mp_zero_out_thresh                  = 1.e-10,
 isfflx                              = 1,
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 1,
 num_land_cat                        = 20,
 num_soil_layers                     = 4,
 o3input                             = 2,
 aer_opt                             = 1,
 /
 &fdda
 /
 &dynamics
 w_damping                           = 1,
 diff_opt                            = 1,
 km_opt                              = 4,
 damp_opt                            = 1,
 zdamp                               = 5000.,  5000.,  5000.,
 dampcoef                            = 0.05,   0.01,   0.01,
 non_hydrostatic                     = .true., .true.,
 moist_adv_opt                       = 2,     2,
 scalar_adv_opt                      = 2,     2,
 diff_6th_opt                        = 2, 2, 
 diff_6th_factor                     = 0.12, 0.12,
 /
 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true., .false.,
 nested                              = .false.,.true.,
 /
 &grib2
 /
 &namelist_quilt
 nio_tasks_per_group = 2,
 nio_groups = 1,
 /
EOF4

   ln -sf ${WRFDA_SRC_DIR}/var/build/da_wrfvar.exe .
   #mkdir -p trace
   mpirun.lsf ./da_wrfvar.exe  >&! log.${DATE}

   # check status
   grep "WRF-Var completed successfully" rsl.out.0000
   if ( $status != 0 ) then
      echo "ERROR in run_wrfda.csh : da_wrfvar.exe failed..." > FAIL
      exit 1
   #else
   #   echo "`date` Done da_wrfvar.exe ${DATE}" >> ${CSH_DIR}/job_${EXPT}.log
   endif

###########################################################
# convert ASCII radiance inv output to NETCDF format
#---------------------------------------------------

if ( $use_radiance == true ) then
   ls 01_oma* >& /dev/null
   if ( $status == 0 ) then
      mkdir $DATE
      cd $DATE
      ln -sf ../01_oma* .
      cd ..
      cat > namelist.da_rad_diags << EOF
&record1
 nproc = 128
 instid = 'noaa-15-amsua','noaa-18-amsua','noaa-19-amsua','metop-2-amsua'
 file_prefix = '01_oma'
 start_date = '$DATE'
 end_date   = '$DATE'
 cycle_period  = 6
/
EOF
      ${WRFDA_SRC_DIR}/var/build/da_rad_diags.exe
      #$HOME/bin/mcp diags'_*' oma'_*'
      rm -rf $DATE
      rm -f namelist.da_rad_diags da_rad_diags.exe
      tar cvf rad01_oma_${DATE}.tar 01_oma_*.*
      gzip rad01_oma_${DATE}.tar
      rm -f 01_oma_*.*
   endif
endif
#############################################################

   mv  wrfvar_output  wrfvar_output_d${domain_id}_${DATE} 
   rm gts_omb_oma_0?.* unpert_obs*

   foreach file_rej ( `ls rej_obs_conv_01.*` )
      cat ${file_rej} >> rej_obs_conv_01
   end
   foreach file_rej ( `ls rej_obs_conv_02.*` )
      cat ${file_rej} >> rej_obs_conv_02
   end
   if ( ! -d rsl ) mkdir -p rsl
   mv rsl.out.* rsl
   mv rsl.error.* rsl
   rm rej_obs_conv_01.* rej_obs_conv_02.* 
   rm filtered_obs.* #rsl.error.* rsl.out.*

   # update lateral bdy for coarse domain
   if ( ${domain_id} == '01' ) then
      set UPDATE_LATERAL_BDY = .true.
      set UPDATE_LOW_BDY     = .false.
      cd ${DA_RUN_DIR}
      if ( ${VAR4D} == TRUE ) then
         cp -p ${DA_RUN_DIR}/wrfbdy_d${domain_id} ${DA_RUN_DIR}/wrfbdy_d${domain_id}_${DATE}
      else
         cp -p wrfbdy_d${domain_id}_${gdatef[1]}_${gdatef[2]}_mean ${DA_RUN_DIR}/wrfbdy_d${domain_id}_${DATE}
      endif
      cat >! ${DA_RUN_DIR}/parame.in << EOF
&control_param
 var4d_lbc          = .${VAR4D_LBC}.
 da_file            = '${DA_RUN_DIR}/wrfvar_output_d${domain_id}_${DATE}'
 da_file_02         = '${DA_RUN_DIR}/ana02'
 wrf_bdy_file       = '${DA_RUN_DIR}/wrfbdy_d${domain_id}_${DATE}'
 wrf_input          = '${DA_RUN_DIR}/wrfinput_d${domain_id}_${gdate[1]}_${gdate[2]}_mean'
 domain_id          = ${domain_id}
 debug              = .false.
 update_lateral_bdy = ${UPDATE_LATERAL_BDY}
 update_low_bdy     = ${UPDATE_LOW_BDY}
 keep_snow_wrf      = .false.
 update_lsm         = .false.
 iswater            = 17 /
EOF
      ln -sf ${WRFDA_SRC_DIR}/var/build/da_update_bc.exe .
      time ./da_update_bc.exe >&! log.update_lat_bc_${DATE}
      mv parame.in parame.in.latbdy
      # check status
      grep "Update_bc completed successfully" log.update_lat_bc_${DATE}
      if ( $status != 0 ) then
         echo "ERROR in run_wrfda.csh : update lateral bdy failed..." > FAIL
         exit 1
      #else
      #   echo "`date` Done updating lateral bdy ${DATE}" >> ${CSH_DIR}/job_${EXPT}.log
      #   exit 0
      endif
   endif

touch FINISHED

exit 0
