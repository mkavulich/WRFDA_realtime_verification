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
if ( ! $?FCST_DOMAINS ) then
   echo "FCST_DOMAINS not set"
   exit 1
endif
if ( ${FCST_DOMAINS} == 2 ) then
   set model = "3-km ARW WRF"
   set FCST_DIR = fcst_15_3km
else
   set model = "15-km ARW WRF"
   set FCST_DIR = fcst_15km
endif
#set DATE = 2015081800
#set fhr = 2 # 23
set DATE = $ANAL_DATE
set fhr  = ${FHR} # 23
set fhr2 = `printf %02i ${FHR}` # 23
set fhr3 = `printf %03i ${FHR}` # 23

#set PYTHON_SCRIPTS_DIR = /glade/u/home/wrfrt/rt_ensemble/python_scripts
set PYTHON_SCRIPTS_DIR = /glade/p/wrf/WORKDIR/wrfda_realtime/diag/post_fcst/python_scripts
set script_name  = ./make_webplot.py
set GRAPHICS_RUN_DIR = ${RUN_BASEDIR}/postdir/${FCST_DIR}/${DATE}/webplot
set LOGS_RUN_DIR = $GRAPHICS_RUN_DIR
setenv WRF_DIR   ${RUN_BASEDIR}/expdir/rt/${FCST_DIR}
setenv POST_DIR  ${RUN_BASEDIR}/postdir/${FCST_DIR}

if ( ! -e ${POST_DIR}/${DATE}/fhr_${fhr}/WRFTWO${fhr2}.nc ) then
   echo "Running run_unipost_fcst.csh for fhr=$fhr ..."
   ${BASE_DIR}/diag/post_fcst/run_unipost_fcst.csh
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

if ( $fhr > 0 ) then
   # --- Hourly Precipitation ---
   $script_name -d=${DATE} -tr=${fhr},${fhr} -f=precip_mean -c=mslp_mean -b=wind10m_mean -t="${model} 1-hr precipitation (fill; in), MSLP (contour; hPa), and 10-m wind (kts)"

   # --- Running accumulation of precipitation ---
   $script_name -d=${DATE} -tr=${fhr},${fhr} -f=precipacc_mean    -t="${model} ${fhr}-hr accumulated precipitation (in)"
endif

#if ( $fhr == 36 ) then
#   # 24h accumulated precipitation to be compared with stage IV analysis
#   set start_fhr = `expr $fhr - 23`
#   $script_name -d=${DATE} -tr=${start_fhr},${fhr} -f=precip-24hr_summean   -t="${model} 24-hr (12Z - 12Z) accumulated precipitation (mm)"
#endif

# ----- Severe weather products ---------
# --- SBCAPE --
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=sbcape_mean      -c=sbcinh_mean  -b=shr06_mean  -t="${model} SBCAPE (fill; J/kg), SBCINH (contour; J/kg), and 0-6 km shear (kts)"

# --- MLCAPE --
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=mlcape_mean      -c=mlcinh_mean  -b=shr06_mean  -t="${model} MLCAPE (fill; J/kg), MLCINH (contour; J/kg), and 0-6 km shear (kts)"

# --- MUCAPE --
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=mucape_mean -b=shr06_mean  -t="${model} MUCAPE (fill; J/kg) and 0-6 km shear (kts)"

# --- Helicity --
$script_name -d=${DATE} -tr=${fhr},${fhr}  -f=srh3_mean     -b=shr06_mean -t="${model} 0-3 km SRH (m2/s2) and 0-6 km shear (kts)"

$script_name -d=${DATE} -tr=${fhr},${fhr}  -f=srh1_mean     -b=shr01_mean -t="${model} 0-1 km SRH (m2/s2) and 0-1 km shear (kts)"

# --- Storm motion --
$script_name -d=${DATE} -tr=${fhr},${fhr}  -f=bunkmag_mean  -b=bunkers_mean -t="${model} Bunkers storm motion (fill/barb; kts)"

# --- LCL/LFC/PWAT/LI
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=pwat_mean    -b=wind10m_mean -t="${model} precipitable water (fill; in) and 10-m wind (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=zlfc_mean                    -t="${model} LFC height (m)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=zlcl_mean                    -t="${model} LCL height (m)"

# ------- Surface fields/PBL height ------------------- #
# -- 2-m T -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=t2_mean -c=mslp_mean -b=wind10m_mean -t="${model} 2-m temperature (fill; F), MSLP (contour; hPa), and 10-m wind (kts)"

# -- 2-m Td -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=td2_mean -c=mslp_mean -b=wind10m_mean -t="${model} 2-m dewpoint (fill; F), MSLP (contour; hPa), and 10-m wind (kts)"

# -- equivalent potential temperature -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=thetae_mean             -t="${model} 2-m equivalent potential temperature (K)"

# -- 10-m wind -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=speed10m_mean           -t="${model} 10-m wind speed (kts)"

# -- MSLP -- #
#  $bsub_command_2min  $script_name -d=${DATE} -tr=${fhr},${fhr}  -c=mslp_mean -b=wind10m_mean             -t="${model} Ensemble mean MSLP (hPa) and 10-m wind (kts)"

# -- PBL height -- #
$script_name -d=${DATE} -tr=${fhr},${fhr}  -f=pblh_mean -c=mlcape_mean -t="${model} PBL height (fill; m) and MLCAPE (contour; J/kg)"

# -- Heatindex -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=heatindex_mean -t="${model} heat index (F)"

# -- Visibility -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=afwavis_mean -b=wind10m_mean -t="${model} visibility (fill; mi) and 10-m wind (kts)"

# ------- Satellite brightness  --------------- #
if ( $fhr > 0 ) then
   # -- Water Vapor -- #
   $script_name -d=${DATE} -tr=${fhr},${fhr} -f=goesch3_mean -t="${model} GOES-E Channel 3 (WV) brightness temperature (C)"

   # -- IR -- #
   $script_name -d=${DATE} -tr=${fhr},${fhr} -f=goesch4_mean -t="${model} GOES-E Channel 4 (IR) brightness temperature (C)"
endif

# ------- Constant pressure level stuff --------------- #
# -- 925 hPa -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=temp925_mean -c=hgt925_mean -b=wind925_mean -t="${model} 925 hPa temperature (fill; C), height (contour; m), and wind (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=td925_mean -c=hgt925_mean -b=wind925_mean -t="${model} 925 hPa dewpoint (fill; C), height (contour; m), and wind (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=speed925_mean -c=hgt925_mean  -b=wind925_mean -t="${model} 925 hPa wind speed (fill; kts), height (contour; m), and barbs (kts)"

# -- 850 hPa -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=temp850_mean -c=hgt850_mean -b=wind850_mean -t="${model} 850 hPa temperature (fill; C), height (contour; m), and wind (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=td850_mean -c=hgt850_mean -b=wind850_mean -t="${model} 850 hPa dewpoint (fill; C), height (contour; m), and wind (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=speed850_mean -c=hgt850_mean -b=wind850_mean -t="${model} 850 hPa wind speed (fill; kts), height (contour; m), and barbs (kts)"

# -- 700 hPa -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=rh700_mean -c=hgt700_mean -b=wind700_mean -t="${model} 700 hPa relative humidity (fill; %), height (contour; m), and wind (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=speed700_mean -c=hgt700_mean -b=wind700_mean -t="${model} 700 hPa wind speed (fill; kts), height (contour; m), and barbs (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=temp700_mean -c=hgt700_mean -b=wind700_mean -t="${model} 700 hPa temperature (fill; C), height (contour; m), and wind (kts)"

# -- 500 hPa -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=avo500_mean -c=hgt500_mean -b=wind500_mean -t="${model} 500 hPa absolute vorticity (fill; x10^5 s-1), height (contour; m), and wind (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=speed500_mean -c=hgt500_mean -b=wind500_mean -t="${model} 500 hPa wind speed (fill; kts), height (contour; m), and barbs (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=temp500_mean -c=hgt500_mean -b=wind500_mean -t="${model} 500 hPa temperature (fill; C), height (contour; m), and wind (kts)"

# -- 300 hPa -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=speed300_mean -c=hgt300_mean -b=wind300_mean -t="${model} 300 hPa wind speed (fill; kts), height (contour; m), and barbs (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=temp300_mean -c=hgt300_mean -b=wind300_mean -t="${model} 300 hPa temperature (fill; C), height (contour; m), and wind (kts)"

# -- 250 hPa -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=speed250_mean -c=hgt250_mean -b=wind250_mean -t="${model} 250 hPa wind speed (fill; kts), height (contour; m), and barbs (kts)"
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=temp250_mean -c=hgt250_mean -b=wind250_mean -t="${model} 250 hPa temperature (fill; C), height (contour; m), and wind (kts)"
 -- 320 K isentrope -- #
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=pvort320k_mean  -t="${model} potential vorticity (x10^6) on the 320 K isentrope"

# --- 1-km AGL level reflectivity --
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=ref1km_mean      -b=wind10m_mean  -t="${model} 1-km AGL reflectivity and 10-m wind (kts)" 

# --- Composite reflectivity --
$script_name -d=${DATE} -tr=${fhr},${fhr} -f=cref_mean  -b=wind10m_mean      -t="${model} Max/Composite reflectivity and 10-m wind (kts)" 

if ( $fhr > 0 ) then
   # --- Hourly snow ---
   $script_name -d=${DATE} -tr=${fhr},${fhr} -f=snow_mean -t="${model} 1-hr snowfall (in)"

   # --- Running accumulation of snow ---
   $script_name -d=${DATE} -tr=${fhr},${fhr} -f=snowacc_mean  -t="${model} ${fhr}-hr accumulated snowfall (in)"
endif

# --- 6-hr rain and snow accumulations -------
# if ( $fhr == 6 || $fhr == 12 || $fhr == 18 || $fhr == 24 || $fhr == 30 || $fhr == 36 || $fhr == 42 || $fhr == 48 ) then
#   set start_fhr = `expr $fhr - 5`
#   $script_name -d=${DATE} -tr=${start_fhr},${fhr} -f=precip_summean   -t="${model} 6-hr accumulated precipitation (in)"            
# endif

# --- 24-hr rain and snow accumulations -------
# if ( $fhr == 24 || $fhr == 48 ) then
#   set start_fhr = `expr $fhr - 23`
#   $script_name -d=${DATE} -tr=${start_fhr},${fhr} -f=precip_summean   -t="${model} 24-hr accumulated precipitation (in)"            
# endif

rsync -av ${GRAPHICS_RUN_DIR}/*_f${fhr3}_CONUS.png galaxy.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/realtimetest/images/CONUS/hourly/${DATE}

