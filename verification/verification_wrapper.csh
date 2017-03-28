#!/bin/csh -f

# Wrapper script for running WRFDA verification package

# Set some initial variables, then source the main "parameters" script

setenv QUEUE   regular
setenv use_standby   false 
setenv EXPT   hvc10_sfc
setenv NOTIFY   false
setenv MAIL_TO   kavulich@ucar.edu
setenv MKBASEDIR   /glade/p/wrf/WORKDIR/wrfda_realtime

if ( ${#argv} > 0 ) then
   setenv END_DATE $1
   set cc = `echo $END_DATE | cut -c1-2`
   set yy = `echo $END_DATE | cut -c3-4`
   set mm = `echo $END_DATE | cut -c5-6`
   set dd = `echo $END_DATE | cut -c7-8`
   set hh = `echo $END_DATE | cut -c9-10`
else
   set cc = `date -u '+%C'`
   set yy = `date -u '+%y'`
   set mm = `date -u '+%m'`
   set dd = `date -u '+%d'`
   set hh = `date -u +%H`  ;  set hh = `expr $hh \+ 0`
   if      ( $hh >    0  && $hh < 6  ) then
      set hh = '00'
   else if ( $hh >    6  && $hh < 12 ) then
      set hh = '06'
   else if ( $hh >    12 && $hh < 18 ) then
      set hh = '12'
   else if ( $hh >    18 && $hh < 24 ) then
      set hh = '18'
   endif
   setenv END_DATE ${cc}${yy}${mm}${dd}${hh}
endif

source params.csh

#Universal settings
setenv WRFVAR_DIR /glade/p/work/kavulich/V39/WRFDA_3DVAR_dmpar_friendly2_gpsref_bugfix #${WRFDA_SRC_DIR}
setenv BUILD_DIR ${WRFVAR_DIR}/var/build
setenv TOOLS_DIR   /glade/p/wrf/WORKDIR/wrfda_realtime/TOOLS
setenv SCRIPTS_DIR   `pwd`
setenv GRAPHICS_DIR   ${TOOLS_DIR}/graphics/ncl


#Create GFS output on WRF grid if it doesn't already exist
setenv WAITING_FOR 0
if (! -d /glade/p/wrf/WORKDIR/wrfda_realtime/verification/GFS/Output/${END_DATE}) then
   ./convert_fcst_to_wrf.pl --start=$cc$yy-$mm-${dd}_${hh}:00:00 --overwrite=yes --gfs=true
   setenv JOBS `bjobs -w | grep REAL_GFS2WRF_48h`
   echo "JOBS is "
   echo "$JOBS"
   while ( "$JOBS" != "" )
      if ($WAITING_FOR > 45) then
         echo "Been waiting too long, something is up!"
         echo "Exiting...."
         exit 1
      endif
      echo "Waiting for jobs converting GFS->WRF to finish; been waiting $WAITING_FOR minutes"
      sleep 60
      setenv JOBS `bjobs -w | grep REAL_GFS2WRF_48h`
      @ WAITING_FOR++
   end
endif

# Settings for ./da_verif_grid.ksh
setenv NUM_EXPT   1
setenv EXP_DIRS   /glade/scratch/hclin/CONUS/wrfda/expdir/rt/fcst_15km/
setenv EXP_NAMES   'REALTIME'
setenv VERIFICATION_FILE_STRING   'wrfout'
setenv EXP_LEGENDS   '(/"WRFDA Realtime System"/)'
setenv VERIFY_PERIOD 1d #Examples: 7d (7 days), 120h (120 hours), etc. Used with da_advance_time.exe
setenv INTERVAL   24
setenv VERIFY_HOUR   48
setenv START_DATE   `${WRFDA_SRC_DIR}/var/build/da_advance_time.exe ${END_DATE} -${VERIFY_PERIOD}`
setenv CONTROL_EXP_DIR   ${MKBASEDIR}/verification/GFS/Output
setenv RUN_DIR /glade/p/wrf/WORKDIR/wrfda_realtime/verification/GFS_verify
setenv VERIFY_ITS_OWN_ANALYSIS false

#./da_verif_grid.ksh

# Settings for ./da_run_suite_verif_obs.ksh (WRFDA run)

#setenv DUMMY true # Dummy run, see how the setup goes first
setenv CLEAN false
setenv DEBUG false
setenv NL_TRACE_USE true

setenv BG ${EXPT} #Where the background is from
setenv INITIAL_DATE ${START_DATE}
setenv FINAL_DATE ${END_DATE}
setenv EXP_DIR `pwd`/obs_verify/${BG}
setenv OB_DIR /glade/scratch/hclin/CONUS/wrfda/obsproc
setenv FILTERED_OBS_DIR /glade/scratch/hclin/CONUS/wrfda/expdir/start2016102512/hyb_ens75
setenv BE_DIR ${FILTERED_OBS_DIR}/${END_DATE}
setenv FC_DIR /glade/scratch/hclin/CONUS/wrfda/expdir/rt/fcst_15km/
setenv WINDOW_START ${TIMEWINDOW1}
setenv WINDOW_END ${TIMEWINDOW2}
setenv NUM_PROCS 8
#setenv RUN_CMD "mpirun -np $NUM_PROCS"
#setenv VERIFICATION_FILE_STRING wrfout

# Here is where you set the appropriate namelist variables that the script will use to run WRFDA
setenv NL_E_WE ${E_WE_d01}
setenv NL_E_SN ${E_SN_d01}
setenv NL_E_VERT ${N_VERT}
setenv NL_DX ${DX_d01}
setenv NL_DY ${DX_d01}
setenv NL_SF_SURFACE_PHYSICS 2
setenv NL_NUM_LAND_CAT ${NUM_LAND_CAT}

./da_run_suite_verif_obs.ksh

# Settings for ./da_run_suite_verif_obs.ksh (GFS run)
setenv CLEAN false
setenv DEBUG false
setenv NL_TRACE_USE true

setenv BG GFS
setenv INITIAL_DATE ${START_DATE}
setenv FINAL_DATE ${END_DATE}
setenv EXP_DIR `pwd`/obs_verify/${BG}
setenv OB_DIR /glade/scratch/hclin/CONUS/wrfda/obsproc
setenv FILTERED_OBS_DIR /glade/scratch/hclin/CONUS/wrfda/expdir/start2016102512/hyb_ens75
setenv BE_DIR ${FILTERED_OBS_DIR}/${END_DATE}
setenv FC_DIR /glade/p/wrf/WORKDIR/wrfda_realtime/verification/${BG}/Output
setenv WINDOW_START ${TIMEWINDOW1}
setenv WINDOW_END ${TIMEWINDOW2}
setenv NUM_PROCS 8
setenv NL_E_WE ${E_WE_d01}
setenv NL_E_SN ${E_SN_d01}
setenv NL_E_VERT ${N_VERT}
setenv NL_DX ${DX_d01}
setenv NL_DY ${DX_d01}
setenv NL_SF_SURFACE_PHYSICS 2
setenv NL_NUM_LAND_CAT ${NUM_LAND_CAT}

./da_run_suite_verif_obs.ksh

# Settings for ./da_run_suite_verif_obs.ksh (NAM run)

setenv CLEAN false
setenv DEBUG false
setenv NL_TRACE_USE true

setenv BG NAM
setenv INITIAL_DATE ${START_DATE}
setenv FINAL_DATE ${END_DATE}
setenv EXP_DIR `pwd`/obs_verify/${BG}
setenv OB_DIR /glade/scratch/hclin/CONUS/wrfda/obsproc
setenv FILTERED_OBS_DIR /glade/scratch/hclin/CONUS/wrfda/expdir/start2016102512/hyb_ens75
setenv BE_DIR ${FILTERED_OBS_DIR}/${END_DATE}
setenv FC_DIR /glade/p/wrf/WORKDIR/wrfda_realtime/verification/${BG}/Output
setenv WINDOW_START ${TIMEWINDOW1}
setenv WINDOW_END ${TIMEWINDOW2}
setenv NUM_PROCS 8
setenv NL_E_WE ${E_WE_d01}
setenv NL_E_SN 285 # ${E_SN_d01} Needed smaller domain to fit NAM boundary conditions
setenv NL_E_VERT ${N_VERT}
setenv NL_DX ${DX_d01}
setenv NL_DY ${DX_d01}
setenv NL_SF_SURFACE_PHYSICS 2
setenv NL_NUM_LAND_CAT ${NUM_LAND_CAT}

./da_run_suite_verif_obs.ksh

# Settings for ./da_run_suite_verif_obs.ksh (MPAS run)

setenv CLEAN false
setenv DEBUG false
setenv NL_TRACE_USE true

setenv BG MPAS
setenv INITIAL_DATE ${START_DATE}
setenv FINAL_DATE ${END_DATE}
setenv EXP_DIR `pwd`/obs_verify/${BG}
setenv OB_DIR /glade/scratch/hclin/CONUS/wrfda/obsproc
setenv FILTERED_OBS_DIR /glade/scratch/hclin/CONUS/wrfda/expdir/start2016102512/hyb_ens75
setenv BE_DIR ${FILTERED_OBS_DIR}/${END_DATE}
setenv FC_DIR /glade/p/wrf/WORKDIR/wrfda_realtime/verification/${BG}/Output
setenv WINDOW_START ${TIMEWINDOW1}
setenv WINDOW_END ${TIMEWINDOW2}
setenv NUM_PROCS 8
setenv NL_E_WE ${E_WE_d01}
setenv NL_E_SN ${E_SN_d01}
setenv NL_E_VERT ${N_VERT}
setenv NL_DX ${DX_d01}
setenv NL_DY ${DX_d01}
setenv NL_SF_SURFACE_PHYSICS 2
setenv NL_NUM_LAND_CAT ${NUM_LAND_CAT}

./da_run_suite_verif_obs.ksh

# Settings for da_verif_obs_plot.ksh

#setenv NUM_EXPT 1
#setenv EXP_NAMES 'WRFDA-REALTIME' #UNDERSCORES NOT ALLOWED, BECAUSE THAT MAKES SENSE
#setenv EXP_LEGENDS '(/"WRFDA REALTIME"/)'
#setenv EXP_DIRS "$EXP_DIR"
setenv NUM_EXPT 4
setenv EXP_NAMES 'WRFDA-REALTIME GFS NAM MPAS'
setenv EXP_LEGENDS '(/"WRFDA REALTIME","GFS","NAM","MPAS"/)'
setenv EXP_DIRS "${MKBASEDIR}/verification/obs_verify/${EXPT} ${MKBASEDIR}/verification/obs_verify/GFS ${MKBASEDIR}/verification/obs_verify/NAM ${MKBASEDIR}/verification/obs_verify/MPAS"
setenv EXP_LINES_COLORS '(/"orange","blue","green","DarkSlateGray","DarkSlateBlue","black"/)'
#setenv NUM_PROCS 4
#setenv WRF_FILE "/kumquat/wrfhelp/DATA/WRFDA/cycling/run/2013122300/wrfout_d01_2013-12-23_00:00:00"
#setenv Verify_Date_Range "12z 23 Dec - 12z 25 Dec, 2015 (${INTERVAL} hour Cycle)"
setenv OBS_TYPES 'synop sound'
setenv NUM_OBS_TYPES 2
setenv PLOT_WKS pdf #"pdf" will save plots in pdf format; "x11" will display the plots and not save them

./da_verif_obs_plot.ksh

