#!/bin/csh
#BSUB -P P64000510
#BSUB -n 1
#BSUB -J post
#BSUB -o post.out
#BSUB -e post.out
#BSUB -W 6:00
#BSUB -q geyser

set echo

# -------------------------------------------------------------------------
# Uncomment these lines, and comment-out below if you need to manually run
# -------------------------------------------------------------------------

module load ncl
module load nco
module load python
module load all-python-libs

#setenv ANAL_DATE 2015082400
#set START_DATE = $ANAL_DATE #2015052700
#set END_DATE   = $ANAL_DATE #2015082512
set START_DATE = 2016020100
set END_DATE   = 2016030800
set CYCLE_PERIOD = 24
set DATE = $START_DATE
set BIN_DIR = ${HOME}/bin

while ( $DATE <= $END_DATE )

setenv ANAL_DATE $DATE
set START_FHR  = 00
set FCST_RANGE = 48
set SCRIPT_DIR = /glade/u/home/hclin/scripts/rt2015/diag/post_fcst
set fhrs = `seq $START_FHR 1 $FCST_RANGE`
foreach fhr ( $fhrs )
   setenv FHR $fhr
if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif
if ( ! $?FHR ) then
   echo "FHR not set"
   exit 1
endif
#set DATE = 2015081800
#set fhr = 2 # 23
set DATE = $ANAL_DATE
set fhr  = ${FHR} # 23
set fhr2 = `printf %02i ${FHR}` # 23
set fhr3 = `printf %03i ${FHR}` # 23

#set PYTHON_SCRIPTS_DIR = /glade/u/home/wrfrt/rt_ensemble/python_scripts
set PYTHON_SCRIPTS_DIR = /glade/u/home/hclin/scripts/rt2015/diag/post_fcst/python_scripts
set script_name  = ./make_webplot.py
set GRAPHICS_RUN_DIR = /glade/scratch/hclin/CONUS/wrfda/postdir/fcst_15km/${DATE}/webplot
set LOGS_RUN_DIR = $GRAPHICS_RUN_DIR
setenv WRF_DIR   /glade/scratch/hclin/CONUS/wrfda/expdir/rt/fcst_15km
setenv POST_DIR  /glade/scratch/hclin/CONUS/wrfda/postdir/fcst_15km

mkdir -p $GRAPHICS_RUN_DIR

# --------------------------------------------------------------
# Use these if running as part of script suite, as in real-time
# --------------------------------------------------------------

cd $GRAPHICS_RUN_DIR
set logfile = "${LOGS_RUN_DIR}/graphics_log_fhr${fhr}.log"

cp ${PYTHON_SCRIPTS_DIR}/webplot.py_d01     ./webplot.py
#if ( ! -e matplotlibrc ) then
cp ${PYTHON_SCRIPTS_DIR}/fieldinfo.py       .
cp ${PYTHON_SCRIPTS_DIR}/make_webplot.py    .
#cp ${PYTHON_SCRIPTS_DIR}/webplot.py         .
cp ${PYTHON_SCRIPTS_DIR}/*.pk               .  # Pre-defined map stuff for different regions
cp ${PYTHON_SCRIPTS_DIR}/matplotlibrc       .
cp ${PYTHON_SCRIPTS_DIR}/ncar.png           .  # Logo on all figures
cp ${PYTHON_SCRIPTS_DIR}/*.rgb              .  # Local color tables
cp ${PYTHON_SCRIPTS_DIR}/rt2015_latlon*.nc  .  # Lat/lon netcdf files
#endif

#---------------------------------------------------- 
#       Precipitation/reflectivity products 
#---------------------------------------------------- 

if ( $fhr > 0 ) then
   # --- Hourly snow ---
#   $script_name -d=${DATE} -tr=${fhr},${fhr} -f=snow_mean -t='1-hr snowfall (in)'

   # --- Running accumulation of snow ---
   $script_name -d=${DATE} -tr=${fhr},${fhr} -f=snowacc_mean  -t="${fhr}-hr accumulated snowfall (in)"
endif

end

rsync -av ${GRAPHICS_RUN_DIR}/snow*CONUS.png nebula.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/conus15km/images/CONUS/hourly/${DATE}

set DATE = `${HOME}/bin/da_advance_time.exe $DATE $CYCLE_PERIOD`

end

