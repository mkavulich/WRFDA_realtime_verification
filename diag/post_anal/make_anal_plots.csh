#!/bin/csh

#set START_DATE = 2015080600
#set END_DATE   = 2015081018
#set CYCLE_PERIOD = 06
#set DATE = $START_DATE
#while ( $DATE <= $END_DATE )

if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif

if ( ! $?POSTAN_SCRIPT_DIR ) then
    set POSTAN_SCRIPT_DIR = /glade/u/home/hclin/scripts/rt2015/diag/post_anal
endif
if ( ! $?DA_RUN_DIR_TOP ) then
   #set DA_RUN_DIR_TOP = /glade/scratch/hclin/CONUS/wrfda/expdir/start2015112400/hyb_ens75
   set DA_RUN_DIR_TOP = /glade/scratch/hclin/CONUS/wrfda/expdir/start2016102512/hyb_ens75
endif

  set datea = $ANAL_DATE
  set plotdir = /glade/scratch/hclin/CONUS/wrfda/postdir/webplot
  set an_file = ${plotdir}/an_${datea}_all.nc

  cd $plotdir
  cp -p ${POSTAN_SCRIPT_DIR}/*.py .
  cp -p ${POSTAN_SCRIPT_DIR}/*.rgb .
  cp -p ${POSTAN_SCRIPT_DIR}/*.csh .
  cp -p ${POSTAN_SCRIPT_DIR}/*.ksh .
  #cp -p ${POSTAN_SCRIPT_DIR}/*.ncl .
  cp -p ${POSTAN_SCRIPT_DIR}/ncar.png .
  cp -p ${POSTAN_SCRIPT_DIR}/matplotlibrc .

  if ( ! -e ${an_file} ) then
     ${POSTAN_SCRIPT_DIR}/run_unipost_anal.ksh ${datea}
  endif

  ncdump -h ${an_file} |grep UNLIMITED
  if ( $status != 0 ) then
     ncrename -O -d Time,ntime ${an_file}
     ncecat -O -h ${an_file} ${an_file}
     ncrename -O -d record,Time ${an_file}
  endif

#ncrename -O -d Time,ntime an_2015081712_all.nc
#ncecat -O -h an_2015081712_all.nc an_2015081712_all.nc
#ncrename -O -d record,Time an_2015081712_all.nc


#--------------------------------------------------------------------------------------------------------------#
# Surface plots
#--------------------------------------------------------------------------------------------------------------#
# temperature analysis
python make_webplot.py -d=${datea} -f=templ0_mean -c=mslp_mean -b=windl0_mean -t="MSLP (mb), temperature (F; fill), and winds (kts) @ Lowest Model Level" -tr=0 -dom=ANLYS
#python make_webplot.py -d=${datea} -f=t2_mean -c=mslp_mean -b=windl0_mean -t="2-m ensemble mean temperature analysis (F; fill), mean MSLP (mb), and 10 m mean winds (kts)" -tr=0 -dom=ANLYS
#python make_webplot.py -d=${datea} -f=t2_var -c=t2_mean -b=windl0_mean -t="2-m temperature analysis spread (F; fill), 2-m mean temperature (F), and 10 m mean winds (kts)" -tr=0 -dom=ANLYS
#
# dewpoint analysis
#python make_webplot.py -d=${datea} -f=td2_mean -c=mslp_mean -b=windl0_mean -t="2-m ensemble mean dewpoint analysis (F; fill), mean MSLP (mb), and 10 m mean winds (kts)" -tr=0 -dom=ANLYS
#python make_webplot.py -d=${datea} -f=td2_var -c=td2_mean -b=windl0_mean -t="2-m dewpoint analysis spread (F; fill), 2-m mean dewpoint (F), and 10 m mean winds (kts)" -tr=0 -dom=ANLYS
#
# Other surface variable fields
python make_webplot.py -d=${datea} -f=refl_mean -b=windl0_mean -t="Reflectivity (dBZ; fill), and winds (kts) @ Lowest Model Level" -tr=0 -dom=ANLYS
python make_webplot.py -d=${datea} -f=pwat_mean -c=mslp_mean -b=windl0_mean -t="Precipitable water (in; fill), MSLP (mb), and winds (kts) @ Lowest Model Level" -tr=0 -dom=ANLYS
#--------------------------------------------------------------------------------------------------------------#
# Pressure level plots
#--------------------------------------------------------------------------------------------------------------#
# 300 mb plots
python make_webplot.py -d=${datea} -f=temp300_mean -c=hgt300_mean -b=wind300_mean -t"300 mb temperature (C; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
python make_webplot.py -d=${datea} -f=iso300_mean -c=hgt300_mean -b=wind300_mean -t"300 mb wind speed (kts; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
# 500 mb plots
python make_webplot.py -d=${datea} -f=temp500_mean -c=hgt500_mean -b=wind500_mean -t"500 mb temperature (C; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
python make_webplot.py -d=${datea} -f=avo500_mean -c=hgt500_mean -b=wind500_mean -t"500 mb absolute vorticity (x 10^5 s-1; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
python make_webplot.py -d=${datea} -f=iso500_mean -c=hgt500_mean -b=wind500_mean -t"500 mb wind speed (kts; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
# 700 mb plots
python make_webplot.py -d=${datea} -f=temp700_mean -c=hgt700_mean -b=wind700_mean -t"700 mb temperature (C; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
#python make_webplot.py -d=${datea} -f=td700_mean -c=hgt700_mean -b=wind700_mean -t"700 mb dewpoint (C; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
python make_webplot.py -d=${datea} -f=iso700_mean -c=hgt700_mean -b=wind700_mean -t"700 mb wind speed (kts; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
# 850 mb plots
python make_webplot.py -d=${datea} -f=temp850_mean -c=hgt850_mean -b=wind850_mean -t"850 mb temperature (C; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
#python make_webplot.py -d=${datea} -f=td850_mean -c=hgt850_mean -b=wind850_mean -t"850 mb dewpoint (C; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS
python make_webplot.py -d=${datea} -f=iso850_mean -c=hgt850_mean -b=wind850_mean -t"850 mb wind speed (kts; fill), geopotential height, and winds (kts)" -tr=0 -dom=ANLYS

#--------------------------------------------------------------------------------------------------------------#
# Clean up
#--------------------------------------------------------------------------------------------------------------#

 mkdir -p ${plotdir}/${datea}
 set mvlist = `ls *f000_ANLYS.png | egrep -v 'ncar.png'`
 mv $mvlist ${plotdir}/${datea}

 rsync -av ${plotdir}/${datea}/*ANLYS.png galaxy.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/conus15km/images/CONUS/${datea}

#set DATE = `${HOME}/bin/da_advance_time.exe $DATE $CYCLE_PERIOD`
#
#end #DATE loop

exit
