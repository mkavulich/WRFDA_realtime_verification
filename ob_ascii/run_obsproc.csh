#!/bin/csh
if ( ! $?PARAMS_SET ) then
   source ${BASE_DIR}/${EXPT}/params.csh
endif

set echo
echo "Beginning $0"
set TIMEWINDOW1 = -3h
set TIMEWINDOW2 = 3h
#set DOMAIN_IDS = ( 01 02 )
set DOMAIN_IDS = ( 01 )

if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif

set DATE = $ANAL_DATE

set cc = `echo $DATE | cut -c1-2`
set yy = `echo $DATE | cut -c3-4`
set ccyy = `echo $DATE | cut -c1-4`
set   mm = `echo $DATE | cut -c5-6`
set   dd = `echo $DATE | cut -c7-8`
set   hh = `echo $DATE | cut -c9-10`

#
set OBSPROC_RUN_DIR = ${OB_DIR_TOP}/${DATE}
if ( ! -d ${OBSPROC_RUN_DIR} ) mkdir -p ${OBSPROC_RUN_DIR}
cd ${OBSPROC_RUN_DIR}

#if ( ${hh} == 06 || ${hh} == 18 ) then
#   scp -p loquat.mmm.ucar.edu:/shared/mmmtmp/mm5rt/data/obs/amsua.${DATE}.bufr ${OBSPROC_RUN_DIR}
#endif
if ( ! -e gfs.t${hh}z.1bamua.tm00.bufr_d ) then
   /usr/bin/wget -np ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${DATE}/gfs.t${hh}z.1bamua.tm00.bufr_d
endif
if ( ! -e gfs.t${hh}z.gpsro.tm00.bufr_d ) then
   /usr/bin/wget -np ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${DATE}/gfs.t${hh}z.gpsro.tm00.bufr_d
endif
if ( ! -e gfs.t${hh}z.prepbufr.nr ) then
   /usr/bin/wget -np ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${DATE}/gfs.t${hh}z.prepbufr.nr
endif

set OBS_DATE1 = `${BIN_DIR}/da_advance_time.exe ${DATE} -3h`
#scp -p loquat.mmm.ucar.edu:/shared/mmmtmp/mm5rt/data/obs/obs.${OBS_DATE1} ${OBSPROC_RUN_DIR}
#scp -p loquat.mmm.ucar.edu:/shared/mmmtmp/mm5rt/data/obs/obs.${DATE}      ${OBSPROC_RUN_DIR}
scp -p nebula.mmm.ucar.edu:/shared/mmmtmp/mm5rt/data/obs/obs.${OBS_DATE1} ${OBSPROC_RUN_DIR}
scp -p nebula.mmm.ucar.edu:/shared/mmmtmp/mm5rt/data/obs/obs.${DATE}      ${OBSPROC_RUN_DIR}

#06z and 18z obs can sometimes be available very late
@ num_wait = 0
check_obs:
set fsize = `ls -l obs.${DATE} |awk '{print $5}'`
if ( $fsize < 2000000 ) then
   if ( $num_wait < 12 ) then #wait for 60min at most
      sleep 300 # wait for 5min
      @ num_wait ++
      goto check_obs
   endif
endif

cp -p obs.${OBS_DATE1} obs.${DATE}.r
cat obs.${DATE} >> obs.${DATE}.r

ln -s -f ${OBSPROC_EXE_DIR}/obserr.txt ./obserr.txt
# marine surface station table for getting elevation info for buoys and ships in the Great Lakes
if ( -e ${OBSPROC_EXE_DIR}/msfc.tbl ) then
   ln -s -f ${OBSPROC_EXE_DIR}/msfc.tbl ./msfc.tbl
endif
#
set DATE1 = `${BIN_DIR}/da_advance_time.exe ${DATE} ${TIMEWINDOW1} -f ccyymmddhhnn`
set DATE2 = `${BIN_DIR}/da_advance_time.exe ${DATE} ${TIMEWINDOW2} -f ccyymmddhhnn`
#
set ccyy1 = `echo $DATE1 | cut -c1-4`
set   mm1 = `echo $DATE1 | cut -c5-6`
set   dd1 = `echo $DATE1 | cut -c7-8`
set   hh1 = `echo $DATE1 | cut -c9-10`
set   mi1 = `echo $DATE1 | cut -c11-12`
set ccyy2 = `echo $DATE2 | cut -c1-4`
set   mm2 = `echo $DATE2 | cut -c5-6`
set   dd2 = `echo $DATE2 | cut -c7-8`
set   hh2 = `echo $DATE2 | cut -c9-10`
set   mi2 = `echo $DATE2 | cut -c11-12`
#
foreach domain_id ( ${DOMAIN_IDS} )

   set mapproj = 1
   set stand_lon = -101.0
   set truelat1 = 32.0
   set truelat2 = 46.0
   set clat = 39.0
   set clon = -101.0
   if ( ${domain_id} == '01' ) then
      set xdim = 415
      set ydim = 325
      set dx   = 15.0
   else if ( ${domain_id} == '02' ) then
      set xdim = 1581
      set ydim = 986
      set dx   = 3.0
   endif

cat >! namelist.obsproc << EOF
&record1
 obs_gts_filename = 'obs.${DATE}.r',
 fg_format        = 'WRF',
 obs_err_filename = 'obserr.txt',
 GTS_FROM_MMM_ARCHIVE = .true.
/
&record2
 time_window_min  = '${ccyy1}-${mm1}-${dd1}_${hh1}:${mi1}:00',
 time_analysis    = '${cc}${yy}-${mm}-${dd}_${hh}:00:00',
 time_window_max  = '${ccyy2}-${mm2}-${dd2}_${hh2}:${mi2}:00',
/
&record3
 max_number_of_obs        = 300000,
 fatal_if_exceed_max_obs  = .TRUE.,
/
&record4
 qc_test_vert_consistency = .TRUE.,
 qc_test_convective_adj   = .TRUE.,
 qc_test_above_lid        = .TRUE.,
 remove_above_lid         = .false.,
 domain_check_h           = .true.,
 Thining_SATOB            = .true.,
 Thining_SSMI             = .true.,
 Thining_QSCAT            = .true.,
 CALC_PSFC_FROM_QNH       = .true.
/
&record5
 print_gts_read           = .false.,
 print_gpspw_read         = .false.,
 print_recoverp           = .false.,
 print_duplicate_loc      = .false.,
 print_duplicate_time     = .false.,
 print_recoverh           = .false.,
 print_qc_vert            = .false.,
 print_qc_conv            = .false.,
 print_qc_lid             = .false.,
 print_uncomplete         = .false.,
/
&record6
 ptop =   5000.,
 ps0  = 100000.,
 ts0  =    290.,
 tlp  =     50.,
 pis0 = 20000.0,
 tis0 = 200.0
/
&record7
 IPROJ =  ${mapproj},
 PHIC  =  ${clat},
 XLONC =  ${clon},
 TRUELAT1= ${truelat1},
 TRUELAT2= ${truelat2},
 MOAD_CEN_LAT = ${clat},
 STANDARD_LON = ${stand_lon},
/
&record8
 IDD    =   1,
 MAXNES =   2,
 NESTJX =  ${xdim},  ${xdim},
 NESTIX =  ${ydim},  ${ydim},
 DIS    =  ${dx},  ${dx},
 NUMC   =    1,    1,
 NESTJ  =    1,    1,
 NESTI  =    1,    1,
/
&record9
/
EOF
#
   \rm -f FAIL
   ln -s -f ${OBSPROC_EXE_DIR}/obsproc.exe ./obsproc.exe
   time ./obsproc.exe >&! ${OBSPROC_RUN_DIR}/log.d${domain_id}.${DATE}

   if ( ! -e ${OBSPROC_RUN_DIR}/obs_gts_${cc}${yy}-${mm}-${dd}_${hh}:00:00.3DVAR ) then
      echo "*** obs_gts.3dvar is missing. check log.d${domain_id}.${DATE} in ${OBSPROC_RUN_DIR} ***" > FAIL
      exit 1
   else
      mv obs_gts_${cc}${yy}-${mm}-${dd}_${hh}:00:00.3DVAR ob_d${domain_id}.ascii.${DATE}
      touch FINISHED
   endif

end  # end of domain_id loop

exit 0
