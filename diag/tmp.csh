#!/bin/csh
set START_DATE = 2015112418
set END_DATE   = 2015112512
set CYCLE_PERIOD = 6
set DATE = $START_DATE
while ( $DATE <= $END_DATE )

#echo $DATE
setenv ANAL_DATE $DATE
if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif
set DIAG_SCRIPT_DIR = /glade/u/home/hclin/scripts/rt2015/diag
set DIAG_RUN_DIR    = /glade/scratch/hclin/CONUS/wrfda/diagdir/rt/${ANAL_DATE}
setenv DA_RUN_DIR_TOP  /glade/scratch/hclin/CONUS/wrfda/expdir/start2015112400/hyb_ens75
set DA_RUN_DIR      = ${DA_RUN_DIR_TOP}/${ANAL_DATE}
#set plot_conv_loc          = True
set proc_gts_omb_oma       = True
set plot_ts_omb_oma        = True
set plot_prf_omb_oma       = True
set plot_ts_omb_oma_levels = True
#set plot_rad_loc           = True
#set plot_rad_ts            = True

if ( ! -d ${DIAG_RUN_DIR} ) mkdir -p ${DIAG_RUN_DIR}

#module load ncl

if ( $?plot_conv_loc ) then
   ncl ${DIAG_SCRIPT_DIR}/plot_ob_ascii_loc.ncl
endif

if ( $?proc_gts_omb_oma ) then
   cd $DIAG_RUN_DIR
   echo ${ANAL_DATE} >&! gts_omb_oma
   \cat ${DA_RUN_DIR}/gts_omb_oma_01 >> gts_omb_oma
   ${DIAG_SCRIPT_DIR}/proc_gts_omb_oma.exe
   rm -f gts_omb_oma
endif

if ( $?plot_prf_omb_oma ) then
   cd $DIAG_RUN_DIR
   foreach obtype ( sound geoamv airep )
      if ( $obtype == sound ) then
         set vartypes = ( u v t q )
      endif
      if ( $obtype == geoamv ) then
         set vartypes = ( u v )
      endif
      if ( $obtype == airep ) then
         set vartypes = ( u v t q )
      endif
      setenv OB_TYPE $obtype
      foreach vartype ( $vartypes )
         setenv VAR_TYPE $vartype
         ncl ${DIAG_SCRIPT_DIR}/plot_prf.ncl
      end
   end
   /usr/bin/montage prf_omb_oma_sound_t.png prf_omb_oma_sound_q.png prf_omb_oma_sound_u.png prf_omb_oma_sound_v.png -tile 2x -geometry '500x500>' prf_omb_oma_sound.png
   #/usr/bin/montage prf_omb_oma_airep_t.png null:                   prf_omb_oma_airep_u.png prf_omb_oma_airep_v.png -tile 2x -geometry '500x500>' prf_omb_oma_airep.png
   /usr/bin/montage prf_omb_oma_airep_t.png prf_omb_oma_airep_q.png prf_omb_oma_airep_u.png prf_omb_oma_airep_v.png -tile 2x -geometry '500x500>' prf_omb_oma_airep.png
   /usr/bin/montage prf_omb_oma_geoamv_u.png prf_omb_oma_geoamv_v.png -tile 2x -geometry '500x500>' prf_omb_oma_geoamv.png
endif

if ( $?plot_ts_omb_oma ) then
   cd $DIAG_RUN_DIR
   foreach obtype ( sound sonde_sfc geoamv airep synop metar gpspw buoy ships profiler pilot gpsref )
      if ( $obtype == sound ) then
         set vartypes = ( u v t q )
      endif
      if ( $obtype == sonde_sfc || $obtype == synop || $obtype == metar || $obtype == buoy || $obtype == ships ) then
         set vartypes = ( u v t p q )
      endif
      if ( $obtype == geoamv || $obtype == profiler || $obtype == pilot ) then
         set vartypes = ( u v )
      endif
      if ( $obtype == airep ) then
         set vartypes = ( u v t q )
      endif
      if ( $obtype == gpspw ) then
         set vartypes = ( pw )
      endif
      if ( $obtype == gpsref ) then
         set vartypes = ( ref )
      endif
      setenv OB_TYPE $obtype
      foreach vartype ( $vartypes )
         setenv VAR_TYPE $vartype
         ncl ${DIAG_SCRIPT_DIR}/plot_ts.ncl
      end
   end
   if ( -e ts_omb_oma_gpspw_pw.png ) mv ts_omb_oma_gpspw_pw.png ts_omb_oma_gpspw.png
   if ( -e ts_omb_oma_gpsref_ref.png ) mv ts_omb_oma_gpsref_ref.png ts_omb_oma_gpsref.png
endif

if ( $?plot_ts_omb_oma_levels ) then
   cd $DIAG_RUN_DIR
   foreach obtype ( sound geoamv airep )
      if ( $obtype == sound ) then
         set vartypes = ( u v t q )
      endif
      if ( $obtype == geoamv ) then
         set vartypes = ( u v )
      endif
      if ( $obtype == airep ) then
         set vartypes = ( u v t q )
      endif
      setenv OB_TYPE $obtype
      foreach vartype ( $vartypes )
         setenv VAR_TYPE $vartype
         ncl ${DIAG_SCRIPT_DIR}/plot_ts_levels.ncl
      end
   end
endif

if ( $?plot_rad_loc ) then
   cd $DIAG_RUN_DIR
   set hh = `echo $ANAL_DATE | cut -c9-10`
   if ( $hh == 06 || $hh == 18 ) then
      set insts = ( metop-2-amsua )
   else
      set insts = ( noaa-15-amsua noaa-18-amsua noaa-19-amsua )
   endif
   foreach inst ( $insts )
      setenv INSTRUMENT $inst
      ncl ${DIAG_SCRIPT_DIR}/plot_rad_loc.ncl
      set file_prefix = rad_coverage_${inst}_ch0006
      /usr/bin/convert -trim -density 150x150 ${file_prefix}.pdf ${file_prefix}.png
      if ( $status == 0 ) \rm -f *.pdf #${file_prefix}.pdf
   end
endif

if ( $?plot_rad_ts ) then
   cd $DIAG_RUN_DIR
   set hh = `echo $ANAL_DATE | cut -c9-10`
   if ( $hh == 06 || $hh == 18 ) then
      set insts = ( metop-2-amsua )
   else
      #set insts = ( noaa-15-amsua noaa-18-amsua noaa-19-amsua )
      set insts = ( noaa-18-amsua noaa-19-amsua )
   endif
   foreach inst ( $insts )
      setenv INSTRUMENT $inst
      ncl ${DIAG_SCRIPT_DIR}/plot_rad_stats.ncl
      set file_prefix = ts_rad_omb_oma_${inst}_ch0006
      /usr/bin/convert -trim -density 150x150 ${file_prefix}.pdf ${file_prefix}.png
      if ( $status == 0 ) \rm -f *.pdf #${file_prefix}.pdf
   end
endif

#rsync -av $DIAG_RUN_DIR/*png nebula.mmm.ucar.edu:/web/htdocs/people/hclin/rt_wrfda/images/CONUS/${ANAL_DATE}
rsync -av $DIAG_RUN_DIR/*png nebula.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/conus15km/images/CONUS/${ANAL_DATE}

#rsync -av /glade/u/home/sobash/SHARPpy/OBS/${ANAL_DATE}/*js nebula.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/conus15km/images/sounding/${ANAL_DATE}

set DATE = `${HOME}/bin/da_advance_time.exe $DATE $CYCLE_PERIOD`

end #DATE loop
