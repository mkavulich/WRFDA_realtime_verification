#!/bin/csh -f

set echo
# Wrapper script for running WRFDA verification package

# Set some initial variables, then source the main "parameters" script

setenv QUEUE   regular
setenv use_standby   false 
setenv EXPT   hvc10_sfc
setenv NOTIFY   false
setenv MAIL_TO   kavulich@ucar.edu
setenv MKBASEDIR   /glade/p/wrf/WORKDIR/wrfda_realtime

if ( ${#argv} > 0 ) then
   setenv START_DATE $1
   set cc = `echo $START_DATE | cut -c1-2`
   set yy = `echo $START_DATE | cut -c3-4`
   set mm = `echo $START_DATE | cut -c5-6`
   set dd = `echo $START_DATE | cut -c7-8`
   set hh = `echo $START_DATE | cut -c9-10`
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
   setenv START_DATE ${cc}${yy}${mm}${dd}${hh}
endif

source params.csh

# Settings for ./da_verif_grid.ksh
setenv WRFVAR_DIR   ${WRFDA_SRC_DIR}
setenv TOOLS_DIR   /glade/p/wrf/WORKDIR/wrfda_realtime/TOOLS
setenv SCRIPTS_DIR   ${TOOLS_DIR}/scripts
setenv GRAPHICS_DIR   ${TOOLS_DIR}/graphics/ncl
setenv NUM_EXPT   1
setenv EXP_DIRS   ${FCST_DIR_TOP}/${START_DATE}
setenv EXP_NAMES   'REALTIME'
setenv VERIFICATION_FILE_STRING   'wrfinput'
setenv EXP_LEGENDS   '(/"WRFDA Realtime System"/)'
setenv END_DATE   `${WRFDA_SRC_DIR}/var/build/da_advance_time.exe ${START_DATE} 48h`
setenv INTERVAL   24
setenv VERIFY_HOUR   48
setenv CONTROL_EXP_DIR   ${MKBASEDIR}/verification/gfs_forecast

echo "Start date parent:"
echo $START_DATE

./da_verif_grid.ksh



# Settings for ./da_run_suite_verif_obs.ksh

#setenv CLEAN false
#setenv INITIAL_DATE 2017022000
#setenv FINAL_DATE 2013122512
#setenv EXP_DIR `pwd`/${EXPT}
#setenv OB_DIR /kumquat/wrfhelp/DATA/WRFDA/arctic_tutorial_case/ob/
#setenv FILTERED_OBS_DIR ${EXP_DIR_TOP}/2017022200/
#setenv BE_DIR /kumquat/wrfhelp/DATA/WRFDA/arctic_tutorial_case/be/
#setenv FC_DIR /kumquat/wrfhelp/DATA/WRFDA/verification/conv_only/fc
#setenv WINDOW_START ${TIMEWINDOW1}
#setenv WINDOW_END ${TIMEWINDOW2}
#setenv CYCLE_PERIOD 24
#setenv NUM_PROCS 4
#setenv VERIFY_HOUR 6
#setenv RUN_CMD "mpirun -np $NUM_PROCS"
#setenv VERIFICATION_FILE_STRING wrfout

# Here is where you set the appropriate namelist variables that the script will use to run WRFDA
#setenv NL_ANALYSIS_TYPE verify
#setenv NL_E_WE ${E_WE_d01}
#setenv NL_E_SN ${E_SN_d01}
#setenv NL_E_VERT ${N_VERT}
#setenv NL_DX ${DX_d01}
#setenv NL_DY ${DX_d01}
#setenv NL_SF_SURFACE_PHYSICS 2
#setenv NL_NUM_LAND_CAT 24

#./da_run_suite_verif_obs.ksh
# Settings for da_verif_obs_plot.ksh

#setenv START_DATE 2013122312
#setenv END_DATE 2013122512
#setenv RUN_DIR "`pwd`/conv_only/plots"
#setenv NUM_EXPT 1
#setenv EXP_NAMES 'conv_only'
#setenv EXP_LEGENDS '(/"conv_only"/)'
#setenv EXP_DIRS "$EXP_DIR"
#setenv INTERVAL 6
#setenv NUM_PROCS 4
#setenv VERIFY_HOUR 00
#setenv GRAPHICS_DIR /kumquat/wrfhelp/DATA/WRFDA/TOOLS/graphics/ncl
#setenv WRF_FILE "/kumquat/wrfhelp/DATA/WRFDA/cycling/run/2013122300/wrfout_d01_2013-12-23_00:00:00"
#setenv Verify_Date_Range "12z 23 Dec - 12z 25 Dec, 2015 (${INTERVAL} hour Cycle)"
#setenv OBS_TYPES 'synop sound'
#setenv NUM_OBS_TYPES 2
#setenv PLOT_WKS pdf #"pdf" will save plots in pdf format; "x11" will display the plots and not save them

#./da_verif_obs_plot.ksh

