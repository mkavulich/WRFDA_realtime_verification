#! /bin/csh
#Purpose: This script handles post-processing
#set echo
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
   set FCST_DIR = fcst_15_3km
else
   set FCST_DIR = fcst_15km
endif
set run_mode = MPI
#set run_mode = serial
setenv DATE            $ANAL_DATE
setenv TOOL_DIR        ${HOME}/bin
#setenv MAX_DOM         2
setenv MAX_DOM         ${FCST_DOMAINS}
setenv FCST_RANGE      ${FHR} #48
setenv START_FHR       ${FHR} #0
setenv LOGS_RUN_DIR    ${BASE_DIR}/ob_ascii/logdir
setenv POST_RUN_DIR    ${RUN_BASEDIR}/postdir/${FCST_DIR}/${DATE}
setenv FCST_RUN_DIR    ${RUN_BASEDIR}/expdir/rt/${FCST_DIR}/${DATE}
setenv wrfdir          /glade/p/work/wrfrt/rt_ensemble_code/WRFV3.6.1_ncar_ensf/run
setenv dir ${FCST_RUN_DIR}
#setenv dir ${FCST_RUN_DIR}/ens_${mem}   # Where the files are located for this member
			               #         (/glade/scratch/wrfrt/realtime/ensf)
set storage_top = ${POST_RUN_DIR}   #  Where to store post-processed files; Passed in from driver.
				    #              (/glade/p/nmmm0001/wrfrt/realtime/ensf)

set POST_QUEUE    = regular
if ( $run_mode == MPI ) then
   set run_cmd       = "mpirun.lsf"
   set UPP_CODE_DIR  = /glade/p/work/wrfrt/rt_ensemble_code/UPPV2.2_ncar_ensf
   set CRTMDIR = ${UPP_CODE_DIR}/src/lib/crtm2/src/fix
else
   set run_cmd       = ""
   set UPP_CODE_DIR  = /glade/p/work/romine/rt2012Y/WRF/UPPv2_netcdf4/UPPV2.0_serial
   set CRTMDIR = ${UPP_CODE_DIR}/src/lib/crtm2/coefficients
endif
set WRF_RAIN_EXEC = /glade/u/home/schwartz/wrf_get_rain_2011_GRIB/get_wrf_rain
set POST_STORAGE  = ${RUN_BASEDIR}/postdir

if ( ! -d ${POST_STORAGE}/precip/${DATE} ) mkdir -p ${POST_STORAGE}/precip/${DATE}

#LI is in Kelvin
set UPP_vars_original  = (  PRES_GDS3_SFC    PRES_GDS3_SPDY   HGT_GDS3_TRO     TMP_GDS3_CTL     \
                            TMP_GDS3_SFC     TMP_GDS3_SPDY    DPT_GDS3_HTGL    PVORT_GDS3_THEL  \
                            LFT_X_GDS3_ISBY  CIN_GDS3_SFC     CIN_GDS3_SPDY    REFD_GDS3_HTGL   REFC_GDS3_EATM \
                            CAPE_GDS3_SFC    CAPE_GDS3_SPDY   HLCY_GDS3_HTGY   HGT_GDS3_ADCL  \
                            5WAVA_GDS3_HTGY  SNOWC_GDS3_HTGY  SNOT_GDS3_HTGY   LRGHR_GDS3_HTGY    PLPL_GDS3_SPDY \
                            USTM_GDS3_HTGY   VSTM_GDS3_HTGY   PRMSL_GDS3_MSL   P_WAT_GDS3_EATM  )
                            
set UPP_vars_renamed   =  (  PBMIN_SFC       PBMIN            TROP_HEIGHT      CLD_TOP_TEMP       \
                             BMIN_SFC        BMIN             DEWPOINT_2M      PVORT_320K         \
                             SFC_LI          SBCINH           MLCINH           REFL_1KM_AGL     REFL_MAX_COL                        \
                             SBCAPE          MLCAPE           SR_HELICITY      LCL_HEIGHT                                          \
                             UBSHR1          VBSHR1           UBSHR6           VBSHR6             PARCEL_LIFT_LEV        \
                             U_COMP_STM      V_COMP_STM       MSLP             PWAT   )
####
set num_UPP_vars = $#UPP_vars_original

@ i = 1
set rename_str = ''
while ( $i <= $num_UPP_vars )
   set rename_str = `echo $rename_str -v ${UPP_vars_original[$i]},{$UPP_vars_renamed[$i]}`
   @ i ++
end

# Log file for this member
set this_log_file = ${LOGS_RUN_DIR}/post_log.txt
rm -f $this_log_file

####

set fhrs = `seq $START_FHR 1 $FCST_RANGE` # Assumes hourly output--could be more general
foreach fhr ( $fhrs )

   echo "Looking to start POST for fhr = $fhr at `date`" >> $this_log_file

   #set POST_QUEUE = $post_queue_save

   # set some variables based on $fhr with the right number of digits
   set tmp = `expr 100 + $fhr`  ;  set f2 = `echo "$tmp" | cut -c 2-`
   set tmp = `expr 1000 + $fhr` ;  set f3 = `echo "$tmp" | cut -c 2-`

   set this_valid_time = `${TOOL_DIR}/da_advance_time.exe $DATE $fhr`
   set wrf_valid_time  = `${TOOL_DIR}/da_advance_time.exe $this_valid_time 0 -w`

   set ccyy_s = `echo $this_valid_time | cut -c 1-4`
   set mm_s   = `echo $this_valid_time | cut -c 5-6`
   set dd_s   = `echo $this_valid_time | cut -c 7-8`
   set hh_s   = `echo $this_valid_time | cut -c 9-10`

   # Make storage
   setenv storage   ${storage_top}/fhr_${fhr}
   if ( ! -d $storage ) mkdir -p $storage
   cd $storage

   # The file to process
   set wrf_file = ${dir}/wrfout_d0${MAX_DOM}_${wrf_valid_time}
   set rewrite = `basename $wrf_file`
   ln -sf $wrf_file .  # Link might be broken at first, but that's ok.

   # Link Ferrier's microphysics table for UPP
   ln -sf ${wrfdir}/ETAMPNEW_DATA                ./eta_micro_lookup.dat
   ln -sf ${wrfdir}/ETAMPNEW_DATA.expanded_rain  ./hires_micro_lookup.dat

   set UPP_GRIB2          = FALSE
   set SCRIPTS_DIR        = /glade/u/home/wrfrt/rt_ensemble
   set UPP_PARAM_FILE     = ${SCRIPTS_DIR}/wrf_cntrl.ncar_ens_2015.parm
   set UPP_PARAM_FILE_SAT = ${SCRIPTS_DIR}/wrf_cntrl.ncar_ens_2015_sat.parm
   set UPP_CNTRL_FILE     = ${SCRIPTS_DIR}/ncar_postcntrl.xml
   set UPP_CNTRL_FILE_SAT = ${SCRIPTS_DIR}/ncar_postcntrl_sat.xml
   set UPP_AVBLFLDS_FILE  = ${SCRIPTS_DIR}/post_avblflds.xml

   # Param file for UPP, from params file
   if ( $fhr == 0 ) then
      cp     $UPP_PARAM_FILE      ./wrf_cntrl.parm  
      cp     $UPP_CNTRL_FILE      ./postcntrl.xml   # needed for GRIB2 output
   else
      cp     $UPP_PARAM_FILE_SAT  ./wrf_cntrl.parm
      cp     $UPP_CNTRL_FILE_SAT  ./postcntrl.xml   # needed for GRIB2 output
   endif

   cp     $UPP_AVBLFLDS_FILE   ./post_avblflds.xml  # needed for GRIB 2 output

   # CRTM files for UPP
   ln -sf $CRTMDIR/EmisCoeff/Big_Endian/EmisCoeff.bin           ./
   ln -sf $CRTMDIR/AerosolCoeff/Big_Endian/AerosolCoeff.bin     ./
   ln -sf $CRTMDIR/CloudCoeff/Big_Endian/CloudCoeff.bin         ./
   ln -sf $CRTMDIR/SpcCoeff/Big_Endian/imgr_g12.SpcCoeff.bin    ./
   ln -sf $CRTMDIR/SpcCoeff/Big_Endian/imgr_g11.SpcCoeff.bin    ./
   ln -sf $CRTMDIR/SpcCoeff/Big_Endian/amsre_aqua.SpcCoeff.bin  ./
   ln -sf $CRTMDIR/SpcCoeff/Big_Endian/tmi_trmm.SpcCoeff.bin    ./
   ln -sf $CRTMDIR/SpcCoeff/Big_Endian/ssmi_f15.SpcCoeff.bin    ./
   ln -sf $CRTMDIR/SpcCoeff/Big_Endian/ssmis_f20.SpcCoeff.bin   ./
   ln -sf $CRTMDIR/SpcCoeff/Big_Endian/ssmis_f17.SpcCoeff.bin   ./
   ln -fs $CRTMDIR/SpcCoeff/Big_Endian/imgr_mt2.SpcCoeff.bin    ./
   ln -fs $CRTMDIR/SpcCoeff/Big_Endian/imgr_mt1r.SpcCoeff.bin   ./

   if ( $run_mode == MPI ) then
      ln -sf $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmis_f17.TauCoeff.bin   ./
      ln -sf $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_g12.TauCoeff.bin    ./
      ln -sf $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_g11.TauCoeff.bin    ./
      ln -sf $CRTMDIR/TauCoeff/ODPS/Big_Endian/amsre_aqua.TauCoeff.bin  ./
      ln -sf $CRTMDIR/TauCoeff/ODPS/Big_Endian/tmi_trmm.TauCoeff.bin    ./
      ln -sf $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmis_f20.TauCoeff.bin   ./
      ln -sf $CRTMDIR/TauCoeff/ODPS/Big_Endian/ssmi_f15.TauCoeff.bin    ./
      ln -fs $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_mt2.TauCoeff.bin    ./
      ln -fs $CRTMDIR/TauCoeff/ODPS/Big_Endian/imgr_mt1r.TauCoeff.bin   ./
   else
      ln -sf $CRTMDIR/TauCoeff/Big_Endian/ssmis_f17.TauCoeff.bin   ./
      ln -sf $CRTMDIR/TauCoeff/Big_Endian/imgr_g12.TauCoeff.bin    ./
      ln -sf $CRTMDIR/TauCoeff/Big_Endian/imgr_g11.TauCoeff.bin    ./
      ln -sf $CRTMDIR/TauCoeff/Big_Endian/amsre_aqua.TauCoeff.bin  ./
      ln -sf $CRTMDIR/TauCoeff/Big_Endian/tmi_trmm.TauCoeff.bin    ./
      ln -sf $CRTMDIR/TauCoeff/Big_Endian/ssmis_f20.TauCoeff.bin   ./
      ln -sf $CRTMDIR/TauCoeff/Big_Endian/ssmi_f15.TauCoeff.bin    ./
      ln -fs $CRTMDIR/TauCoeff/Big_Endian/imgr_mt2.TauCoeff.bin    ./
      ln -fs $CRTMDIR/TauCoeff/Big_Endian/imgr_mt1r.TauCoeff.bin   ./
   endif

   # UPP code
   ln -sf     ${UPP_CODE_DIR}/bin/unipost.exe .

   # Link some stuff for UPP
   rm -f ./fort.*
   ln -sf ./wrf_cntrl.parm  ./fort.14
   ln -sf ./griddef.out     ./fort.110

   # Next three lines needed for GRIB2 output
   ln -sf ${UPP_CODE_DIR}/src/lib/g2tmpl/params_grib2_tbl_new  .
   cp ${SCRIPTS_DIR}/grib2table .
   cp ${SCRIPTS_DIR}/grib2nc.table .

   # Fill namelist for UPP
   setenv upp_fname  $wrf_file
   if ( $UPP_GRIB2 == TRUE ) then
      #$NAMELIST_TEMPLATE uppg2 $this_valid_time  # Output is ./itag
cat >! ./itag << EOF
$upp_fname
netcdf
grib2
${ccyy_s}-${mm_s}-${dd_s}_${hh_s}:00:00
NCAR
EOF
   else
      #$NAMELIST_TEMPLATE upp $this_valid_time  # Output is ./itag
cat >! ./itag << EOF
$upp_fname
netcdf
${ccyy_s}-${mm_s}-${dd_s}_${hh_s}:00:00
NCAR
EOF
   endif
   
   # ---------------------------------------------------------------------------------
   # If we've gotten this far, the WRF file is there for this fhr and we can proceed 
   # ---------------------------------------------------------------------------------
   echo "`date +%s`" >> ./start_post_fhr_${fhr}

   # Convert precipitation to GRIB--serial code, which is very fast (~1 second)
   set outname_grib = ./wrfda_15km_${DATE}_f${f3}_1hr_pcp.grb
   $WRF_RAIN_EXEC $rewrite ./tmp # Output is ./tmp (a binary file) and ./rain.grb
   rm -f ./tmp # Not needed
   mv    ./rain.grb $outname_grib
   cp    $outname_grib  ${POST_STORAGE}/precip/${DATE}

   #
   # Now run UPP to get selected 2D fields
   # Need to submit a job
   # When it's done, it will touch ./unipost_done.${fhr}
   #
   set touch_file_started = ./upp_started
   set touch_file_ended   = ./unipost_done.${fhr}
   set fname_submit = ./submit_upp.csh
   @ num_tries_run = 0
   try_again_submit:
      #Build submission file
      rm -f $touch_file_started
      rm -f $touch_file_ended
      rm -f $fname_submit
      cat > $fname_submit << EOF
#!/bin/csh
#BSUB -P P64000510
#BSUB -n 16                   # number of total (MPI) tasks
##BSUB -R span[ptile=8]       # run a max of 8 tasks per node
#BSUB -J upp_fhr${fhr}
#BSUB -o post.out
#BSUB -e post.out
#BSUB -W 0:15
##BSUB -q regular
#BSUB -q ${POST_QUEUE}
##BSUB -x

# LSF stuff in command line for real submission
# Remove above backslashes to submit this script

cd $storage
rm -f $touch_file_started
echo "`date +%s`" > $touch_file_started

setenv tmmark             grb
setenv MP_SHARED_MEMORY   yes
setenv MP_LABELIO         yes

$run_cmd ./unipost.exe >&! log_unipost

if ( \$status == 0 ) touch -f $touch_file_ended

#hcl exit # Delete for manual rerun

# If you need to manually re-run, uncomment above exit

set outfile_post_grb = ./WRFTWO${f2}.grb   # From UPP step, need to use relative paths for ncl_convert2nc
set outfile_post_cdf = ./WRFTWO${f2}.nc    # Output of UPP in netCDF format after conversion

if ( $UPP_GRIB2 != TRUE ) then

   if ( ! -e ./WRFTWO${f2}.grb ) then
      echo "./WRFTWO${f2}.grb not found, exit"
      exit 1
   endif

   ncl_convert2nc \$outfile_post_grb   # Convert WRF-Post to netCDF, output is \$outfile_post_cdf

   ncecat   -O -h \$outfile_post_cdf   \$outfile_post_cdf # Add a record variable, default name is "record"
   ncrename -O -d record,Time          \$outfile_post_cdf # Change name of "record" to "Time"

   #Rename the variables
   ncrename -O $rename_str \$outfile_post_cdf \$outfile_post_cdf

   # cleanup attributes for all variables
   ncatted -O -a parameter_table_version,,d,, \$outfile_post_cdf
   ncatted -O -a parameter_number,,d,, \$outfile_post_cdf
   ncatted -O -a model,,d,, \$outfile_post_cdf
   ncatted -O -a gds_grid_type,,d,, \$outfile_post_cdf
   ncatted -O -a center,,d,, \$outfile_post_cdf
   ncatted -O -a level_indicator,,d,, \$outfile_post_cdf
   #  fix the shear variable attributes
   ncatted -O -a units,UBSHR1,o,c,"meter second-1" \$outfile_post_cdf
   ncatted -O -a units,VBSHR1,o,c,"meter second-1" \$outfile_post_cdf
   ncatted -O -a units,UBSHR6,o,c,"meter second-1" \$outfile_post_cdf
   ncatted -O -a units,VBSHR6,o,c,"meter second-1" \$outfile_post_cdf
   ncatted -O -a long_name,UBSHR1,o,c,"U Wind Component 0-1 km Shear" \$outfile_post_cdf
   ncatted -O -a long_name,VBSHR1,o,c,"V Wind Component 0-1 km Shear" \$outfile_post_cdf
   ncatted -O -a long_name,UBSHR6,o,c,"U Wind Component 0-6 km Shear" \$outfile_post_cdf
   ncatted -O -a long_name,VBSHR6,o,c,"V Wind Component 0-6 km Shear" \$outfile_post_cdf
else # GRIB2 = TRUE
   wgrib2 \${outfile_post_grb} -nc_table grib2nc.table -netcdf \${outfile_post_cdf}
endif

touch -f ${storage}/post_done
EOF

      # --------------------------------------
      # Now submit the script we just created
      # --------------------------------------

      chmod 755 $fname_submit
      if ( $run_mode == MPI ) then
         set pp = `bsub < $fname_submit`   # Submit job
      else
         $fname_submit
      endif

end # loop over fhrs

exit 0
