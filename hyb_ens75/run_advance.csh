#!/bin/csh -f
#BSUB -J adv
#BSUB -q regular
##BSUB -n 128
#BSUB -n 64
#BSUB -o job.out
#BSUB -e job.out
#BSUB -W 0:10
#BSUB -P P64000510
set echo
echo "Beginning $0"

if ( ! $?PARAMS_SET ) then
   source /glade/u/home/hclin/scripts/rt2015/params.csh
endif

if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif

set DATE = $ANAL_DATE

set WRF_RUN_DIR = ${EXP_DIR_TOP}/advance/${DATE}

set MAX_DOM = 1

set FCST_RANGE  = ${ADVANCE_HOUR}
set LBC_FREQ    = 6
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

set START_DATE = `${EP_EXE_DIR}/da_advance_time.exe $DATE 0 -w`
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
 start_year                          = ${ccyy_s}
 start_month                         = ${mm_s}
 start_day                           = ${dd_s}
 start_hour                          = ${hh_s}
 start_minute                        = ${mi_s}
 start_second                        = 00
 end_year                            = ${ccyy_e}
 end_month                           = ${mm_e}
 end_day                             = ${dd_e}
 end_hour                            = ${hh_e}
 end_minute                          = ${mi_e}
 end_second                          = 00
 interval_seconds                    = 21600,
 input_from_file                     = .true.,
 history_interval                    = 360,
 frames_per_outfile                  = 1,
 restart                             = .false.,
 restart_interval                    = 2881,
 io_form_history                     = 2,
 io_form_restart                     = 102,
 io_form_input                       = 2,
 io_form_boundary                    = 2,
 io_form_auxhist2                    = 2,
 debug_level                         = 0
 diag_print                          = 0
 /
 &dfi_control
 /
 &domains
 time_step                           = ${TIME_STEP},
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
 sst_skin                            = 1,
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
EOF

   if ( ! -e $EXP_DIR_TOP/${DATE}/wrfbdy_d01_${DATE} || \
        ! -e $EXP_DIR_TOP/${DATE}/wrfvar_output_d01_${DATE} ) then
      echo "input files for WRF not found" > FAIL
      exit 1
   endif

   ln -sf ${WRF_SRC_DIR}/main/wrf.exe .
   ln -sf $EXP_DIR_TOP/${DATE}/wrfbdy_d01_${DATE} ./wrfbdy_d01
   ln -sf $EXP_DIR_TOP/${DATE}/wrfvar_output_d01_${DATE} ./wrfinput_d01
   if ( ${MAX_DOM} == 2 ) then
      ln -sf $EXP_DIR_TOP/${DATE}/real/wrfinput_d02 ./wrfinput_d02
   endif
   mpirun.lsf ./wrf.exe

   # check status
   grep "SUCCESS COMPLETE WRF" rsl.out.0000
   if ( $status != 0 ) then
      echo "ERROR in run_advance.csh : wrf.exe failed..." > FAIL
      exit 1
   endif

   mkdir rsl
   mv rsl.out.*   rsl
   mv rsl.error.* rsl

   touch FINISHED

exit 0
