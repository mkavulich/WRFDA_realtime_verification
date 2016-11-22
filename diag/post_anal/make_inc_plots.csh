#!/bin/csh

#set START_DATE = 2015080100
#set END_DATE   = 2015081412
#set CYCLE_PERIOD = 06
#set DATE = $START_DATE
#while ( $DATE <= $END_DATE )

if ( ! $?ANAL_DATE ) then
   echo "ANAL_DATE not set"
   exit 1
endif

if ( ! $?POSTAN_SCRIPT_DIR ) then
   set POSTAN_SCRIPT_DIR = /glade/p/wrf/WORKDIR/wrfda_realtime/diag/post_anal
endif
if ( ! $?DA_RUN_DIR_TOP ) then
   set DA_RUN_DIR_TOP = ${RUN_BASEDIR}/expdir/orig/${EXPT}
endif

 set datea = $ANAL_DATE
 #set datea = 2015081406
 set plotdir    = ${RUN_BASEDIR}/postdir/webplot
 set da_dir     = ${DA_RUN_DIR_TOP}/${datea}

 cd $plotdir
 cp -p ${POSTAN_SCRIPT_DIR}/*.py .
 cp -p ${POSTAN_SCRIPT_DIR}/*.rgb .
 cp -p ${POSTAN_SCRIPT_DIR}/*.csh .
 cp -p ${POSTAN_SCRIPT_DIR}/*.ksh .
 cp -p ${POSTAN_SCRIPT_DIR}/ncar.png .
 cp -p ${POSTAN_SCRIPT_DIR}/matplotlibrc .

 if ( ! -e ${plotdir}/increment_${datea}.nc ) then
    ncdiff -v T2,Q2,U10,V10,U,V,T,QVAPOR,PSFC ${da_dir}/wrfvar_output_d01_${datea} ${da_dir}/fg ${plotdir}/increment_${datea}.nc
 endif

#--------------------------------------------------------------------------------------------------------------#
# Analysis increments
#--------------------------------------------------------------------------------------------------------------#
# Surface variable increments
#python make_webplot2.py -d=${datea} -f=t2inc_mean -b=wind10m-inc_mean -t="increment in 2-m temperature (F; fill) and 10 m wind increment (kts * 10)" -tr=0 -dom=ANLYS
#python make_webplot2.py -d=${datea} -f=q2inc_mean -b=wind10m-inc_mean -t="increment in 2-m mixing ratio (g/kg; fill) and 10 m wind increment (kts * 10)" -tr=0 -dom=ANLYS
python make_webplot2.py -d=${datea} -f=psfcinc_mean -b=windl0-inc_mean -t="analysis increment in surface pressure (mb; fill) and wind (kts) @ Lowest Model Level" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=qvl0inc_mean -b=windl0-inc_mean -t="analysis increment in water vapor MR (g/kg; fill) and wind (kts) @ Lowest Model Level" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=qvl5inc_mean -b=windl5-inc_mean -t="analysis increment in water vapor MR (g/kg; fill) and wind (kts) @ Level 5" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=qvl10inc_mean -b=windl10-inc_mean -t="analysis increment in water vapor MR (g/kg; fill) and wind (kts) @ Level 10" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=templ0inc_mean -b=windl0-inc_mean -t="analysis increment in temperature (C; fill) and wind (kts) @ Lowest Model Level" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=templ5inc_mean -b=windl5-inc_mean -t="analysis increment in temperature (C; fill) and wind (kts) @ Level 5" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=templ10inc_mean -b=windl10-inc_mean -t="analysis increment in temperature (C; fill) and wind (kts) @ Level 10" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=templ15inc_mean -b=windl15-inc_mean -t="analysis increment in temperature (C; fill) and wind (kts) @ Level 15" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=templ20inc_mean -b=windl20-inc_mean -t="analysis increment in temperature (C; fill) and wind (kts) @ Level 20" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=templ25inc_mean -b=windl25-inc_mean -t="analysis increment in temperature (C; fill) and wind (kts) @ Level 25" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=templ30inc_mean -b=windl30-inc_mean -t="analysis increment in temperature (C; fill) and wind (kts) @ Level 30" -tr=0 -dom=ANLYS -al
python make_webplot2.py -d=${datea} -f=templ35inc_mean -b=windl35-inc_mean -t="analysis increment in temperature (C; fill) and wind (kts) @ Level 35" -tr=0 -dom=ANLYS -al

#--------------------------------------------------------------------------------------------------------------#
# Clean up
#--------------------------------------------------------------------------------------------------------------#

 mkdir -p ${plotdir}/${datea}
 set mvlist = `ls *f000_ANLYS.png | egrep -v 'ncar.png'`
 mv $mvlist ${plotdir}/${datea}

 rsync -av ${plotdir}/${datea}/*ANLYS.png galaxy.mmm.ucar.edu:/web/htdocs/wrf/users/wrfda/rt_wrfda/realtimetest/images/CONUS/${datea}

#set DATE = `${HOME}/bin/da_advance_time.exe $DATE $CYCLE_PERIOD`
#
#end #DATE loop

exit
