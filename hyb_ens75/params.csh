
setenv PARAMS_SET  yes
setenv bsub_cmd    /ncar/opt/lsf/9.1/linux2.6-glibc2.3-x86_64/bin/bsub
setenv BIN_DIR     $HOME/bin
setenv SCRIPT_DIR  /glade/u/home/hclin/scripts/rt2015/${EXPT}
setenv DIAG_SCRIPT_DIR /glade/u/home/hclin/scripts/rt2015/diag
setenv FIX_DIR     /glade/u/home/hclin/scripts/rt2015/fix
setenv EP_EXE_DIR  /glade/p/work/hclin/code_intel/WRFDA/v38-/var/build
#setenv EP_DIR_TOP  /glade/scratch/hclin/CONUS/wrfda/enspert
setenv EP_DIR_TOP  /glade/scratch/hclin/CONUS/wrfda/enspert_inflate
setenv FC_DIR_TOP  /glade/scratch/wrfrt/realtime_ensemble/wrfdart/rundir
setenv OB_DIR_TOP  /glade/scratch/hclin/CONUS/wrfda/obsproc
setenv ENS_SIZE    50
setenv FCST_HOUR      48
setenv ADVANCE_HOUR   6
#changed20151021 setenv OBSPROC_EXE_DIR  /glade/p/work/hclin/code_intel/V37/WRFDA_serial/var/obsproc
#setenv OBSPROC_EXE_DIR  /glade/p/work/hclin/code_intel/WRFDA/v371+/var/obsproc #starting 2015102118
setenv OBSPROC_EXE_DIR  /glade/p/work/hclin/code_intel/WRFDA/v38-/var/obsproc
#changed20151021 setenv WRFDA_SRC_DIR  /glade/p/work/hclin/code_intel/WRFDA/trunk
#setenv WRFDA_SRC_DIR  /glade/p/work/hclin/code_intel/WRFDA/v371+
setenv WRFDA_SRC_DIR  /glade/p/work/hclin/code_intel/WRFDA/v38-
#setenv WRF_SRC_DIR    /glade/p/nmmm0001/romine/ncar_ens/WRFV3.6.1
#2015072918
setenv WRF_SRC_DIR    /glade/p/work/wrfrt/rt_ensemble_code/WRFV3.6.1_ncar_ensf
setenv RUN_BASEDIR    /glade/scratch/hclin/CONUS/wrfda
#setenv EXP_DIR_TOP    ${RUN_BASEDIR}/expdir/${EXPT}
#setenv EXP_DIR_TOP    ${RUN_BASEDIR}/expdir/start2015060812/${EXPT}
#setenv EXP_DIR_TOP    ${RUN_BASEDIR}/expdir/start2015112400/${EXPT}
#setenv EXP_DIR_TOP    ${RUN_BASEDIR}/expdir/start2016060800/${EXPT}
#setenv EXP_DIR_TOP    ${RUN_BASEDIR}/expdir/start2016082612/${EXPT}
setenv EXP_DIR_TOP    ${RUN_BASEDIR}/expdir/start2016102512/${EXPT}
#setenv EXP_DIR_TOP    ${RUN_BASEDIR}
setenv LOG_DIR        ${EXP_DIR_TOP}/logdir
setenv AMSU_DIR       /glade/scratch/ampsrt/data/amsu
setenv WPS_RUNDIR_TOP /glade/scratch/wrfrt/realtime_ensemble/ensf
#setenv VARBC_DIR      /glade/scratch/hclin/CONUS/wrfda/expdir/ob_ascii/hybrid_ens75_amsua/2015053118
#setenv VARBC_DIR      /glade/scratch/hclin/CONUS/wrfda/expdir/start2015060812/ob_ascii/hyb_e50_amsua/2015112312
#setenv VARBC_DIR      /glade/scratch/hclin/CONUS/wrfda/expdir/start2015112400/hyb_ens75/2016060706
#setenv VARBC_DIR      /glade/scratch/hclin/CONUS/wrfda/expdir/start2016060800/hyb_ens75/2016082112
setenv VARBC_DIR      /glade/scratch/hclin/CONUS/wrfda/expdir/start2016082612/hyb_ens75/2016102400
setenv FCST_RUN_DIR   ${RUN_BASEDIR}/expdir/rt/fcst_15km
setenv FCST_DOMAINS   1
#setenv FCST_RUN_DIR   ${RUN_BASEDIR}/expdir/rt/fcst_15_3km
#setenv FCST_DOMAINS   2
setenv TIME_STEP      60
setenv TIME_STEP_FCST 75

#setenv OB_FORMAT      1

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
setenv LBC_FREQ     06
setenv CYCLE_PERIOD 06

if ( ${VAR4D} == TRUE ) then
   setenv TIMEWINDOW1     0h00m
   setenv TIMEWINDOW2     6h00m
else
   setenv TIMEWINDOW1    -1h30m  #-1h30m
   setenv TIMEWINDOW2     1h30m  #1h30m
   #setenv TIMEWINDOW1    -3h00m  #-1h30m
   #setenv TIMEWINDOW2     3h00m  #1h30m
endif

setenv WEST_EAST_GRID_NUMBER    415
setenv SOUTH_NORTH_GRID_NUMBER  325
setenv VERTICAL_GRID_NUMBER     40
setenv GRID_DISTANCE            15000
setenv CV_OPTIONS               5
if ( ${CV_OPTIONS} == 3 ) then
    setenv BE_FILE     ${WRFDA_SRC_DIR}/var/run/be.dat.cv3
endif
if ( ${CV_OPTIONS} == 5 ) then
   setenv BE_FILE     ${FIX_DIR}/be.dat.cyang
endif
setenv OBSERR_FILE  ${FIX_DIR}/obs_errtable_hclin

#setenv FIRST_DATE 2015051212
#setenv FIRST_DATE 2015060112
#setenv FIRST_DATE 2015060812
#setenv FIRST_DATE 2015112400
#setenv FIRST_DATE 2016060800
#setenv FIRST_DATE 2016082612
setenv FIRST_DATE 2016102512

setenv FG_SOURCE  cycle
#setenv FG_SOURCE  ensfc_mean
#setenv FG_SOURCE  cold
setenv JE_FACTOR  1.33
#setenv JE_FACTOR  2
setenv ENS_SIZE   80
setenv use_radiance true

