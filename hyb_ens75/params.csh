
echo "Beginning $0"
setenv PARAMS_SET  yes
#setenv bsub_cmd    bsub
setenv bsub_cmd    /ncar/opt/lsf/9.1/linux2.6-glibc2.3-x86_64/bin/bsub
setenv BASE_DIR    /glade/p/wrf/WORKDIR/wrfda_realtime
setenv BIN_DIR     ${BASE_DIR}/bin
setenv SCRIPT_DIR  ${BASE_DIR}/${EXPT}
setenv DIAG_SCRIPT_DIR ${BASE_DIR}/diag
setenv FIX_DIR     ${BASE_DIR}/fix
setenv FC_DIR_TOP  /glade/scratch/wrfrt/realtime_ensemble/wrfdart/rundir
setenv FCST_HOUR      48
setenv ADVANCE_HOUR   6
setenv WRFDA_SRC_DIR  ${BASE_DIR}/WRFDA_v38-_orig/
setenv EP_EXE_DIR  ${WRFDA_SRC_DIR}/var/build
#setenv WRF_SRC_DIR    /glade/p/nmmm0001/romine/ncar_ens/WRFV3.6.1
setenv EXE_DIR        ${WRFDA_SRC_DIR}/var/build
setenv OBSPROC_EXE_DIR  ${WRFDA_SRC_DIR}/var/obsproc
setenv WRF_SRC_DIR    /glade/p/work/wrfrt/rt_ensemble_code/WRFV3.6.1_ncar_ensf
setenv EP_DIR_TOP  /glade/scratch/hclin/CONUS/wrfda/enspert_inflate

# RUN DIRS
setenv RUN_BASEDIR    /glade/scratch/kavulich/WRFDA_REALTIME/CONUS/wrfda
setenv DA_RUN_DIR_TOP ${RUN_BASEDIR}/expdir/orig/${EXPT}
setenv OB_DIR_TOP  ${RUN_BASEDIR}/obsproc

setenv EXP_DIR_TOP    ${DA_RUN_DIR_TOP}
setenv LOG_DIR        ${EXP_DIR_TOP}/logdir
setenv AMSU_DIR       /glade/scratch/ampsrt/data/amsu
setenv WPS_RUNDIR_TOP /glade/scratch/wrfrt/realtime_ensemble/ensf
setenv VARBC_DIR      /glade/scratch/kavulich/WRFDA_REALTIME/CONUS/wrfda/expdir/start2016082612/hyb_ens75/2016102400
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
   setenv TIMEWINDOW1    -1h30m  #-3h00m
   setenv TIMEWINDOW2     1h30m  #3h00m
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

setenv FIRST_DATE 2016102512

#setenv FG_SOURCE  cycle
#setenv FG_SOURCE  ensfc_mean
setenv FG_SOURCE  cold
setenv JE_FACTOR  1.33
#setenv JE_FACTOR  2
setenv ENS_SIZE   80
setenv use_radiance true

