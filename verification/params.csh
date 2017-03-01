
if ( ! $?EXPT )  then
   echo "EXPT not set"
   exit 1
endif

setenv PARAMS_SET  yes
setenv bsub_cmd    /ncar/opt/lsf/9.1/linux2.6-glibc2.3-x86_64/bin/bsub

setenv BIN_DIR              $HOME/bin
setenv REGION               CONUS
setenv DA_SYSTEM            RTWRFDA
setenv SEND_TO_WEB          false
setenv HYBRID_OPT           2
setenv BASE_DIR             /glade/scratch/hclin
setenv RT_DIR_TOP           ${BASE_DIR}/${DA_SYSTEM}/${REGION}/${EXPT}
setenv METGRID_DAT_DIR      ${BASE_DIR}/${DA_SYSTEM}/${REGION}/metgrid
setenv UNGRIB_DAT_DIR       ${BASE_DIR}/${DA_SYSTEM}/ungrib
setenv WEB_DIR_TOP          galaxy.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/conus15km/images
setenv EXPT_SCRIPT_DIR      /glade/u/home/hclin/scripts/rtwrfda/${EXPT}
setenv ICBC_SCRIPT_DIR      /glade/u/home/hclin/scripts/rtwrfda/${EXPT} #/icbc
setenv OBSDIAG_SCRIPT_DIR   /glade/u/home/hclin/scripts/rtwrfda/diag/obs
setenv SOUND_SCRIPT_DIR     /glade/u/home/hclin/scripts/rtwrfda/diag/soundings
setenv POSTAN_SCRIPT_DIR    /glade/u/home/hclin/scripts/rtwrfda/diag/post_anal
setenv POSTFC_SCRIPT_DIR    /glade/u/home/hclin/scripts/rtwrfda/diag/post_fcst
setenv FIX_DIR              /glade/u/home/hclin/scripts/rtwrfda/fix
setenv EP_EXE_DIR           /glade/p/work/hclin/code_intel/WRFDA/v38-/var/build
setenv ENSFC_DIR_TOP        /glade/scratch/wrfrt/realtime_ensemble/wrfdart_80M40L #/rundir
setenv OBSPROC_EXE_DIR      /glade/p/work/hclin/code_intel/WRFDA/v39/var/obsproc
setenv WRFDA_SRC_DIR        /glade/p/work/hclin/code_intel/WRFDA/v39
setenv WRF_SRC_DIR          /glade/p/work/hclin/code_intel/WRF/v39
#setenv WRF_SRC_DIR          /glade/p/work/wrfrt/rt_ensemble_code/WRFV3.6.1_ncar_ensf
setenv FIRST_DATE           2017021300 #start date of this cycle
setenv EXP_DIR_TOP          ${RT_DIR_TOP}/rundir/cycle_since_${FIRST_DATE}
setenv LOG_DIR              ${RT_DIR_TOP}/logdir
setenv POST_DIR_TOP         ${RT_DIR_TOP}/postdir
setenv ICBC_DIR_TOP         ${RT_DIR_TOP}/icbcdir
setenv GRAPH_DIR            ${POST_DIR_TOP}/webplot
setenv WPS_RUNDIR_TOP       /glade/scratch/wrfrt/realtime_ensemble/ensf
setenv VARBC_DIR            /glade/scratch/hclin/CONUS/wrfda/expdir/start2016082612/hyb_ens75/2016102400
setenv FCST_DIR_TOP         ${EXP_DIR_TOP}/fcst_15km  #for long fcst
setenv DIAG_DIR_TOP         ${RT_DIR_TOP}/diagdir
#hcl setenv EP_DIR_TOP           ${RT_DIR_TOP}/enspert_inflate
#hcl setenv OB_DIR_TOP           ${RT_DIR_TOP}/obsproc
setenv EP_DIR_TOP           /glade/scratch/hclin/CONUS/wrfda/enspert_inflate
setenv OB_DIR_TOP           /glade/scratch/hclin/CONUS/wrfda/obsproc

setenv FCST_DOMAINS         1  #for long forecast
setenv PROC_DOMAINS         1  #for icbc and DA
setenv ENS_SIZE             0
setenv FCST_HOUR            48
setenv ADVANCE_HOUR         6
setenv TIME_STEP            75
setenv TIME_STEP_FCST       75

#DA settings
setenv OB_FORMAT         2
setenv VAR4D          FALSE
setenv VAR4D_LBC      FALSE
setenv FGAT           FALSE
if ( $FGAT == TRUE ) then
   setenv NUM_FGAT_TIME 7
   setenv WRITE_INPUT   TRUE
else
   setenv NUM_FGAT_TIME 1
   setenv WRITE_INPUT   FALSE
endif
setenv LBC_FREQ_ADV    03 #for advance
setenv LBC_FREQ_FCST   03 #for long fcst
setenv CYCLE_PERIOD    06

if ( ${VAR4D} == TRUE ) then
   setenv TIMEWINDOW1     0h00m
   setenv TIMEWINDOW2     6h00m
else
   setenv TIMEWINDOW1    -1h30m  #-1h30m
   setenv TIMEWINDOW2     1h30m  #1h30m
   #setenv TIMEWINDOW1    -3h00m  #-1h30m
   #setenv TIMEWINDOW2     3h00m  #1h30m
endif

setenv N_VERT           51
setenv E_WE_d01         415
setenv E_SN_d01         325
setenv DX_d01           15000.0
setenv E_WE_d02         1581
setenv E_SN_d02         986
setenv DX_d02           3000.0
setenv I_PARENT_START   70
setenv J_PARENT_START   60
setenv GRID_RATIO       5
setenv TIME_STEP_RATIO  4
#setenv OUT_INTERVAL_d01 

setenv CV_OPTIONS               5
if ( ${CV_OPTIONS} == 3 ) then
    setenv BE_FILE     ${WRFDA_SRC_DIR}/var/run/be.dat.cv3
endif
if ( ${CV_OPTIONS} == 5 ) then
   #setenv BE_FILE     ${FIX_DIR}/be.dat.cyang
   setenv BE_FILE     ${FIX_DIR}/be.dat_interp_lev51
endif
setenv OBSERR_FILE  ${FIX_DIR}/obs_errtable_hclin


setenv FG_SOURCE  cycle
#setenv FG_SOURCE  ensfc_mean
#setenv FG_SOURCE  cold
setenv JE_FACTOR  1.33
#setenv JE_FACTOR  2
setenv use_radiance false

#some domain info needs to be set in run_obsproc.csh
