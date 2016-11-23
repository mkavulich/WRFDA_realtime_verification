#!/bin/csh -f
#BSUB -J fc
#BSUB -q regular
#BSUB -n 512
#BSUB -o job_fc.out
#BSUB -e job_fc.out
#BSUB -W 5:00
#BSUB -P P64000510
set echo
echo "Beginning $0"

setenv EXPT ob_ascii
if ( ! $?PARAMS_SET ) then
   source ${BASE_DIR}/${EXPT}/params.csh
endif

if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif
if ( ! $?FCST_DOMAINS ) then
   echo "FCST_DOMAINS not set"
   exit 1
endif
if ( ! $?FCST_RUN_DIR ) then
   echo "FCST_RUN_DIR not set"
   exit 1
endif

if ( ! $?WRF_SRC_DIR ) setenv WRF_SRC_DIR /glade/p/work/wrfrt/rt_ensemble_code/WRFV3.6.1_ncar_ensf
if ( ! $?DA_METHOD )   set DA_METHOD = hyb_e50_amsua

set DATE = $ANAL_DATE
set START_DATE = `${EP_EXE_DIR}/da_advance_time.exe $DATE 0 -w`

set MAX_DOM = ${FCST_DOMAINS}
if ( ${MAX_DOM} == 1 ) then
   set WRF_RUN_DIR = ${FCST_RUN_DIR}/${DATE}
   set OUT_INTERVAL_d01 = 60
else if ( ${MAX_DOM} == 2 ) then
   set WRF_RUN_DIR = ${FCST_RUN_DIR}/${DATE}
   set OUT_INTERVAL_d01 = 60
endif
set WPS_RUN_DIR = ${WPS_RUNDIR_TOP}/${DATE}/wps_rundir
if ( ! -d ${WPS_RUN_DIR} ) then
   set WPS_RUN_DIR = /glade/scratch/hclin/CONUS/gfs_wrfbdy/${DATE}
   if ( ! -e ${WPS_RUN_DIR}/fhr_0/gfs_wrfbdy_d01_${START_DATE} ) then
      echo "Error in run_fcst.csh: gfs_wrfbdy_d01 not available"
      exit 1
   endif
endif
set  DA_RUN_DIR = ${EXP_DIR_TOP}/${DA_METHOD}/${DATE}

set FCST_RANGE  = ${FCST_HOUR}
set LBC_FREQ    = 3
@ LBC_FREQ_SEC = $LBC_FREQ * 3600

if ( ! -d ${WRF_RUN_DIR}} ) mkdir -p ${WRF_RUN_DIR}
cd ${WRF_RUN_DIR}

\rm -f rsl.* FAIL
#
# link constant files
#
ln -sf ${WRF_SRC_DIR}/run/*_DATA .
#ln -sf ${WRF_SRC_DIR}/run/*_DATA_DBL .
ln -sf ${WRF_SRC_DIR}/run/*_TBL .
ln -sf ${WRF_SRC_DIR}/run/*.TBL .
ln -sf ${WRF_SRC_DIR}/run/*_tbl .
ln -sf ${WRF_SRC_DIR}/run/*_txt .
ln -sf ${WRF_SRC_DIR}/run/ozone* .
ln -sf ${WRF_SRC_DIR}/run/aerosol* .
ln -sf ${WRF_SRC_DIR}/run/tr* .

   set cc = `echo $DATE | cut -c1-2`
   set yy = `echo $DATE | cut -c3-4`
   set mm = `echo $DATE | cut -c5-6`
   set dd = `echo $DATE | cut -c7-8`
   set hh = `echo $DATE | cut -c9-10`

#set START_DATE = `${EP_EXE_DIR}/da_advance_time.exe $DATE 0 -w`
set END_DATE = `${EP_EXE_DIR}/da_advance_time.exe $DATE $FCST_RANGE -w`
set ccyy_s = `echo $START_DATE | cut -c1-4`
set mm_s   = `echo $START_DATE | cut -c6-7`
set dd_s   = `echo $START_DATE | cut -c9-10`
set hh_s   = `echo $START_DATE | cut -c12-13`
set mi_s   = `echo $START_DATE | cut -c15-16`
set ccyy_e = `echo $END_DATE | cut -c1-4`
set mm_e   = `echo $END_DATE | cut -c6-7`
set dd_e   = `echo $END_DATE | cut -c9-10`
set hh_e   = `echo $END_DATE | cut -c12-13`
set mi_e   = `echo $END_DATE | cut -c15-16`
#
# create namelist.input
#
cat >&! namelist.input << EOF
 &time_control
 run_days                            = 0,
 run_hours                           = ${FCST_RANGE}
 run_minutes                         = 0,
 run_seconds                         = 0,
 start_year                          = ${ccyy_s}, ${ccyy_s}
 start_month                         = ${mm_s}, ${mm_s}
 start_day                           = ${dd_s}, ${dd_s}
 start_hour                          = ${hh_s}, ${hh_s}
 start_minute                        = ${mi_s}, ${mi_s}
 start_second                        = 00,   00,   00,  00,  00,  00,
 end_year                            = ${ccyy_e}, ${ccyy_e}
 end_month                           = ${mm_e}, ${mm_e}
 end_day                             = ${dd_e}, ${dd_e}
 end_hour                            = ${hh_e}, ${hh_e}
 end_minute                          = ${mi_e}, ${mi_e}
 end_second                          = 00,   00,   00,  00,  00,  00,
 interval_seconds                    = 10800
 input_from_file                     = .true., .true., .true., .true., .true., .true.
 fine_input_stream                   =    0,     2,     2,      2,      2,      2
 io_form_auxinput2                   = 2 
 history_interval                    = ${OUT_INTERVAL_d01},60,60,60,60,60
 frames_per_outfile                  = 1, 1, 1, 1, 1, 1,
 restart                             = .false.,
 restart_interval                    = 25000,
 io_form_history                     = 2
 io_form_restart                     = 2
 io_form_input                       = 2
 io_form_boundary                    = 2
 debug_level                         = 0
 all_ic_times                        = .false.,
 nwp_diagnostics                     = 1,
 iofields_filename                   = "/glade/u/home/wrfrt/rt_ensemble/io.txt","/glade/u/home/wrfrt/rt_ensemble/io.txt"
 ignore_iofields_warning             = .true.,
 io_form_auxhist11                   = 0,
 auxhist11_outname                   = "precip_d<domain>_<date>.grb",
 auxhist11_interval_m                = 60,60,60
 frames_per_auxhist11                = 1,1,1,
 io_form_auxhist2                    = 0,
 auxhist2_outname                    = "radar_d<domain>.<date>.nc",
 auxhist2_interval                   = 12280,60,
 io_form_auxhist23                   = 2,
 auxhist23_outname                   = "diags_d<domain>.<date>.nc",
 auxhist23_interval                  = ${OUT_INTERVAL_d01},60,
 frames_per_auxhist23                = 1,1,
 bdy_inname                          = "wrfbdy_d<domain>_<date>"
 /
 history_outname                     = "history/wrfout_d<domain>_<date>"

 &domains
 time_step                           = ${TIME_STEP_FCST},
 time_step_fract_num                 = 0,
 time_step_fract_den                 = 1,
 max_dom                             = ${MAX_DOM},
 e_we                                = 415,1581,
 e_sn                                = 325,986,
 num_metgrid_levels                  = 27,
 num_metgrid_soil_levels             = 4,
 dx                                  = 15000.0000,3000.0000,
 dy                                  = 15000.0000,3000.0000,
 grid_id                             = 1,     2,     3,    4,    5,    6,
 parent_id                           = 0,     1,     2,    2,    3,    2,
 i_parent_start                      = 1,70,
 j_parent_start                      = 1,60,
 parent_grid_ratio                   = 1,5,
 parent_time_step_ratio              = 1,4
 feedback                            = 1,
 smooth_option                       = 1
 lagrange_order                      = 2
 interp_type                         = 2
 extrap_type                         = 2
 t_extrap_type                       = 2
 use_surface                         = .true.
 use_levels_below_ground             = .true.
 lowest_lev_from_sfc                 = .false.,
 force_sfc_in_vinterp                = 1
 zap_close_levels                    = 500
 interp_theta                        = .FALSE.
 hypsometric_opt                     = 2
 ! eta_levels                          = 1.0000, 0.9980, 0.9940, 0.9870, 0.9750, 0.9590, 
 !                                       0.9390, 0.9160, 0.8920, 0.8650, 0.8350, 0.8020, 
 !                                       0.7660, 0.7270, 0.6850, 0.6400, 0.5920, 0.5420, 
 !                                       0.4970, 0.4565, 0.4205, 0.3877, 0.3582, 0.3317, 
 !                                       0.3078, 0.2863, 0.2670, 0.2496, 0.2329, 0.2188, 
 !                                       0.2047, 0.1906, 0.1765, 0.1624, 0.1483, 0.1342, 
 !                                       0.1201, 0.1060, 0.0919, 0.0778, 0.0657, 0.0568, 
 !                                       0.0486, 0.0409, 0.0337, 0.0271, 0.0209, 0.0151, 
 !                                       0.0097, 0.0047, 0.0000,

 ! p_top_requested                     = 6500
 ! e_vert = 35, 35, 35, 35, 35, 35
 ! eta_levels                          = 1.00000 , 0.99258 , 0.98275 , 0.96996 , 0.95372 ,
 !                                       0.93357 , 0.90913 , 0.87957 , 0.84531 , 0.80683 ,
 !                                       0.76467 , 0.71940 , 0.67163 , 0.62198 , 0.57108 ,
 !                                       0.51956 , 0.46803 , 0.42030 , 0.37613 , 0.33532 ,
 !                                       0.29764 , 0.26290 , 0.23092 , 0.20152 , 0.17452 ,
 !                                       0.14978 , 0.12714 , 0.10646 , 0.08761 , 0.07045 ,
 !                                       0.05466 , 0.03981 , 0.02580 , 0.01258 , 0.00000

 p_top_requested                     = 5000
 e_vert = 40, 40, 40, 40, 40, 40
 eta_levels                            = 1.00000 , 0.99307 , 0.98348 , 0.97105 , 0.95551 ,
                                         0.93651 , 0.91363 , 0.88644 , 0.85460 , 0.81855 ,
                                         0.77877 , 0.73579 , 0.69016 , 0.64246 , 0.59329 ,
                                         0.54573 , 0.50104 , 0.45908 , 0.41972 , 0.38281 ,
                                         0.34824 , 0.31589 , 0.28563 , 0.25735 , 0.23096 ,
                                         0.20635 , 0.18343 , 0.16209 , 0.14226 , 0.12384 ,
                                         0.10677 , 0.09095 , 0.07633 , 0.06282 , 0.05036 ,
                                         0.03889 , 0.02835 , 0.01868 , 0.00983 , 0.00000
 /

 &physics
 num_land_cat                        = 20
 mp_physics                          = 8,8, 
 ra_lw_physics                       = 4, 4,
 ra_sw_physics                       = 4, 4,
 radt                                = 10,10,
 sf_sfclay_physics                   = 2, 2,
 sf_surface_physics                  = 2, 2,
 bl_pbl_physics                      = 2, 2,
 bldt                                = 0, 0,
 cu_physics                          = 6, 0,
 cudt                                = 5, 0,
 isfflx                              = 1,
 ifsnow                              = 0,
 icloud                              = 1,
 surface_input_source                = 1,
 num_soil_layers                     = 4,
 prec_acc_dt     = 60, 60
 do_radar_ref                        = 1,
 o3input = 2
 aer_opt         = 1
 /
 aer_opt         = 1, 0, 0
 levsiz          = 59
 paerlev         = 29
 alevsiz         = 12
 no_src_types    = 6
 o3_opt          = 1, 0, 0  ! Old?
 months_per_year = 12      ! Old
 maxiens                             = 1,  ! For Grell cumulus only
 maxens                              = 1,
 maxens2                             = 1,
 maxens3                             = 1,
 ensdim                              = 1,

 &stoch
 stoch_force_opt                     = 0,0,0,
 stoch_vertstruc_opt                 = 0, 0, 0, 0, 0, 
 nens                                = 1
 tot_backscat_psi                    = 1.0E-05
 tot_backscat_t                      = 1.0E-06 
 kminforc                            = 1
 lminforc                            = 1
 kminforct                           = 4
 lminforct                           = 4
 /

 &dynamics
 tracer_opt                          = 0, 0,
 w_damping                           = 1,
 diff_opt                            = 1,
 diff_6th_opt                        = 2, 2, 2
 diff_6th_factor                     = 0.12, 0.12, 0.12
 km_opt                              = 4,
 damp_opt                            = 1,
 zdamp                               = 5000.,  5000.,  5000.,
 dampcoef                            = 0.05,   0.01,   0.01,
 non_hydrostatic                     = .true., .true.,
 moist_adv_opt                       = 2, 2,
 scalar_adv_opt                      = 2, 2,
 use_baseparam_fr_nml                = .true.,
 /

 &bdy_control
 spec_bdy_width                      = 5,
 spec_zone                           = 1,
 relax_zone                          = 4,
 specified                           = .true., .false.,
 nested                              = .false.,.true.,
 /

 &namelist_quilt
 nio_tasks_per_group = 8,
 nio_groups = 4,
 /
!nio_tasks_per_group = 5,
!nio_groups = 4,

 &diags
 p_lev_diags                         = 1,
 num_press_levels                    = 12,
 press_levels                        = 100000,92500,85000,70000,60000,50000,40000,30000,25000,20000,15000,10000
 use_tot_or_hyd_p                    = 2,
 extrap_below_grnd                   = 2,
 p_lev_missing                       = 1e10,
 /

 &afwa
 afwa_diag_opt                       = 1,1,
 afwa_ptype_opt                      = 1,1,
 afwa_vil_opt                        = 1,1,
 afwa_radar_opt                      = 1,1,
 afwa_severe_opt                     = 1,1,
 afwa_icing_opt                      = 1,1,
 afwa_vis_opt                        = 1,1,
 afwa_cloud_opt                      = 1,1,
 afwa_therm_opt                      = 1,1,
 afwa_turb_opt                       = 1,1,
 afwa_buoy_opt                       = 1,1,
 afwa_hailcast_opt                   = 1,
 afwa_ptype_ccn_tmp                  = 263.15,
 afwa_ptype_tot_melt                 = 10,
 /
!nio_tasks_per_group = 0,
!nio_groups = 1,
EOF

   if ( ! -e ${DA_RUN_DIR}/wrfvar_output_d01_${DATE} ) then
      echo "input files for WRF not found" > FAIL
      exit 1
   endif

   ln -sf ${WPS_RUN_DIR}/fhr_0/gfs_wrfbdy_d01_${START_DATE}   ./gfs_wrfbdy_d01_${DATE}
   if ( ${MAX_DOM} == 2 ) then
      ln -sf ${WPS_RUN_DIR}/fhr_0/gfs_wrfinput_d02_${START_DATE} ./gfs_wrfinput_d02_${DATE}
   endif
   #cp -p ${WPS_RUN_DIR}/fhr_0/gfs_wrfbdy_d01_${START_DATE}   ./gfs_wrfbdy_d01_${DATE}
   #cp -p ${WPS_RUN_DIR}/fhr_0/gfs_wrfinput_d01_${START_DATE} ./gfs_wrfinput_d01_${DATE}
   #cp -p ${WPS_RUN_DIR}/fhr_0/gfs_wrfinput_d02_${START_DATE} ./gfs_wrfinput_d02_${DATE}

   # update wrfbdy_d01
   set update_bc = true
   if ( ${update_bc} == true ) then
      #make a copy as the file will be over-written
      cp -p gfs_wrfbdy_d01_${DATE} wrfbdy_d01
      cat >! parame.in << EOF_bc
&control_param
 da_file            = '${DA_RUN_DIR}/wrfvar_output_d01_${DATE}'
 wrf_bdy_file       = '${WRF_RUN_DIR}/wrfbdy_d01'
 wrf_input          = '${WRF_RUN_DIR}/gfs_wrfinput_d01_${DATE}'
 domain_id          = 1
 debug              = .false.
 update_lateral_bdy = .true.
 update_low_bdy     = .false.
 keep_snow_wrf      = .false.
 update_lsm         = .false.
 iswater            = 17 /
EOF_bc
      ln -sf ${WRFDA_SRC_DIR}/var/build/da_update_bc.exe .
      time ./da_update_bc.exe >&! log.update_lat_bc_${DATE}
      mv parame.in parame.in.latbdy
      grep "Update_bc completed successfully" log.update_lat_bc_${DATE}
      if ( $status != 0 ) then
         echo "ERROR in run_fcst.csh : update lateral bdy failed..." > FAIL
         exit 1
      endif
   endif

   @ nfile = $FCST_RANGE / $LBC_FREQ + 1
   @ n = 1
   while ( $n <= $nfile )
      @ fcsthour = $LBC_FREQ * ( $n - 1 )
      set wrftime = `${EP_EXE_DIR}/da_advance_time.exe $DATE ${fcsthour} -w`
      #cp -p ${WPS_RUN_DIR}/fhr_${fcsthour}/gfs_wrfbdy_d01_${wrftime} .
      ln -sf ${WPS_RUN_DIR}/fhr_${fcsthour}/gfs_wrfbdy_d01_${wrftime} .
      ln -sf gfs_wrfbdy_d01_${wrftime} wrfbdy_d01_${wrftime}
      @ n = $n + 1
   end

   #ln -sf $EXP_DIR_TOP/${DA_METHOD}/${DATE}/wrfbdy_d01_${DATE} ./wrfbdy_d01
   ln -sf wrfbdy_d01 ./wrfbdy_d01_${START_DATE}
   ln -sf ${DA_RUN_DIR}/wrfvar_output_d01_${DATE} ./wrfinput_d01
   if ( ${MAX_DOM} == 2 ) then
      ln -sf gfs_wrfinput_d02_${DATE} ./wrfinput_d02
   endif

   ln -sf ${WRF_SRC_DIR}/main/wrf.exe .
   mpirun.lsf ./wrf.exe

   # check status
   grep "SUCCESS COMPLETE WRF" rsl.out.0000
   if ( $status != 0 ) then
      echo "ERROR in run_fcst.csh : wrf.exe failed..." > FAIL
      exit 1
   endif

   mkdir rsl
   mv rsl.out.*   rsl
   mv rsl.error.* rsl

   touch FINISHED

exit 0
