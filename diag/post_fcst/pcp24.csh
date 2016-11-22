#!/bin/csh
#BSUB -P P64000510
#BSUB -n 1
#BSUB -J post_fhr
#BSUB -o post.out
#BSUB -e post.out
#BSUB -W 1:00
#BSUB -q geyser

set echo

# -------------------------------------------------------------------------
# Uncomment these lines, and comment-out below if you need to manually run
# -------------------------------------------------------------------------

module load ncl
module load nco
module load python
module load all-python-libs

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
set GRAPHICS_RUN_DIR = /glade/scratch/hclin/CONUS/wrfda/postdir/fcst_15_3km/${DATE}/webplot
set LOGS_RUN_DIR = $GRAPHICS_RUN_DIR
setenv WRF_DIR   /glade/scratch/hclin/CONUS/wrfda/expdir/rt/fcst_15_3km
setenv POST_DIR  /glade/scratch/hclin/CONUS/wrfda/postdir/fcst_15_3km

if ( ! -e ${POST_DIR}/${DATE}/fhr_${fhr}/WRFTWO${fhr2}.nc ) then
   echo "Running run_unipost_fcst.csh for fhr=$fhr ..."
   /glade/u/home/hclin/scripts/rt2015/diag/post_fcst/run_unipost_fcst.csh
   set file_to_check = ${POST_DIR}/${DATE}/fhr_${fhr}/post_done
   set unipost_done = false
   while ( $unipost_done == false )
      if ( -e $file_to_check ) then
         set unipost_done = true
      else
         sleep 30
      endif
   end
endif

mkdir -p $GRAPHICS_RUN_DIR

# --------------------------------------------------------------
# Use these if running as part of script suite, as in real-time
# --------------------------------------------------------------

cd $GRAPHICS_RUN_DIR
set logfile = "${LOGS_RUN_DIR}/graphics_log_fhr${fhr}.log"

cp ${PYTHON_SCRIPTS_DIR}/fieldinfo.py       .
cp ${PYTHON_SCRIPTS_DIR}/webplot.py         .
if ( ! -e matplotlibrc ) then
cp ${PYTHON_SCRIPTS_DIR}/fieldinfo.py       .
cp ${PYTHON_SCRIPTS_DIR}/make_webplot.py    .
cp ${PYTHON_SCRIPTS_DIR}/webplot.py         .
cp ${PYTHON_SCRIPTS_DIR}/*.pk               .  # Pre-defined map stuff for different regions
cp ${PYTHON_SCRIPTS_DIR}/matplotlibrc       .
cp ${PYTHON_SCRIPTS_DIR}/ncar.png           .  # Logo on all figures
cp ${PYTHON_SCRIPTS_DIR}/*.rgb              .  # Local color tables
cp ${PYTHON_SCRIPTS_DIR}/rt2015_latlon*.nc  .  # Lat/lon netcdf files
endif

#---------------------------------------------------- 
#       Precipitation/reflectivity products 
#---------------------------------------------------- 

if ( $fhr == 36 ) then
   set start_fhr = `expr $fhr - 23`
   $script_name -d=${DATE} -tr=${start_fhr},${fhr} -f=precip-24hr_summean   -t="24-hr (12Z - 12Z) accumulated precipitation (mm)"
endif

#if ( $fhr > 0 ) then
#   # --- Hourly Precipitation ---
#   #$script_name -d=${DATE} -tr=${fhr},${fhr} -f=precip_mean -c=mslp_mean -b=wind10m_mean -t='1-hr precipitation (fill; in), MSLP (contour; hPa), and 10-m wind (kts)'
#
#   # --- Running accumulation of precipitation ---
#   $script_name -d=${DATE} -tr=${fhr},${fhr} -f=precipacc_mean    -t="${fhr}-hr accumulated precipitation (in)"
#endif

#rsync -av ${GRAPHICS_RUN_DIR}/*_f${fhr3}_CONUS.png nebula.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/conus15km/images/CONUS/hourly/${DATE}

