#!/bin/ksh
#
set -x

#
# 20101227 - changed typeset for post output for new format 
#
# August 2005: Hui-Ya Chuang, NCEP: This script uses 
# NCEP's Unipost to post processes WRF native model 
# output, and uses copygb to horizontally interpolate posted 
# output from native A-E to a regular projection grid. 
#
# July 2006: Meral Demirtas, NCAR/DTC: Added new "copygb" 
# options and revised some parts for clarity. 
#
#--------------------------------------------------------
# This script performs 2 jobs:
#
# 1. Run Unipost
# 2. Run copygb to horizontally interpolate output from 
#    native A-E to a regular projection grid
#--------------------------------------------------------

#--- EDIT HERE --------------------------------------------------------
# TOP_DIR - where you put the UPP build directory
# DOMAINPATH - where do you want me to do my work
# WRFPATH - Where do you have a version of WRF compiled
# *** Datafile is entered below - it may reference these variables
# dyncore - set to the model used 
#----------------------------------------------------------------------
export anal_date="$1"
export DATE=${anal_date}
#export file_type="$2" #fg or an
export file_type="an"
# uncomment below to pass in mpi threads, and uncomment mpi exec below 
# (mpi_unipost.exe)
#export NTHREADS="$3"

#export TOP_DIR=/glade/scratch/hclin/CONUS/wrfda/expdir/start2015060812/ob_ascii/hyb_e50_amsua
#export TOP_DIR=/glade/scratch/hclin/CONUS/wrfda/expdir/start2015112400/hyb_ens75
export TOP_DIR=${DA_RUN_DIR_TOP}
export DOMAINPATH=${TOP_DIR}/${anal_date}
export WRFPATH=/glade/scratch/wrfrt/realtime_ensemble/wrfdart/rundir/WRF_RUN

#MPI unipost
export UNI_POST_HOME=/glade/p/work/romine/rt2012Y/WRF/UPPv2_netcdf4/UPPV2.0_serial
export POSTEXEC=${UNI_POST_HOME}/bin

#Specify Dyn Core (ARW or NMM in upper case)
dyncore="ARW"

if [ $dyncore = "NMM" ]; then
   export tag=NMM
elif [ $dyncore = "ARW" ]; then
   export tag=NCAR
else
    echo "${dyncore} is not supported. Edit script to choose ARW or NMM dyncore."
    exit
fi

#--- EDIT HERE --------------------------------------------------------
# anal_date = Forecast start date
# fhr =  first forecast hour to be post-processed
# lastfhr = last forecast hour to be post-processed
# incrementhr = the incement (in hours) between forecast files
#----------------------------------------------------------------------

if [ ${file_type} = "fg" ]; then
   export filein=fg
   export fhr=06
   export lastfhr=06
   export incrementhr=06
elif [ ${file_type} = "an" ]; then
   export filein=wrfvar_output_d01_${anal_date}
   export fhr=00
   export lastfhr=00
   export incrementhr=00
fi

# cd to working directory
mkdir ${DOMAINPATH}/unipost_${file_type}
cd ${DOMAINPATH}/unipost_${file_type}

# Link Ferrier's microphysic's table and Unipost control file, 
ln -fs ${WRFPATH}/ETAMPNEW_DATA eta_micro_lookup.dat

# Get local copy of parm file
ln -fs ${UNI_POST_HOME}/parm/my_wrf_cntrl.parm wrf_cntrl.parm

# link coefficients for crtm2 (simulated GOES)
#CRTMDIR=${UNI_POST_HOME}/src/lib/crtm2/coefficients
#ln -fs $CRTMDIR/EmisCoeff/Big_Endian/EmisCoeff.bin           ./
#ln -fs $CRTMDIR/AerosolCoeff/Big_Endian/AerosolCoeff.bin     ./
#ln -fs $CRTMDIR/CloudCoeff/Big_Endian/CloudCoeff.bin         ./
#ln -fs $CRTMDIR/SpcCoeff/Big_Endian/imgr_g12.SpcCoeff.bin    ./
#ln -fs $CRTMDIR/TauCoeff/Big_Endian/imgr_g12.TauCoeff.bin    ./
#ln -fs $CRTMDIR/SpcCoeff/Big_Endian/imgr_g11.SpcCoeff.bin    ./
#ln -fs $CRTMDIR/TauCoeff/Big_Endian/imgr_g11.TauCoeff.bin    ./
#ln -fs $CRTMDIR/SpcCoeff/Big_Endian/amsre_aqua.SpcCoeff.bin  ./
#ln -fs $CRTMDIR/TauCoeff/Big_Endian/amsre_aqua.TauCoeff.bin  ./
#ln -fs $CRTMDIR/SpcCoeff/Big_Endian/tmi_trmm.SpcCoeff.bin    ./
#ln -fs $CRTMDIR/TauCoeff/Big_Endian/tmi_trmm.TauCoeff.bin    ./
#ln -fs $CRTMDIR/SpcCoeff/Big_Endian/ssmi_f15.SpcCoeff.bin    ./
#ln -fs $CRTMDIR/TauCoeff/Big_Endian/ssmi_f15.TauCoeff.bin    ./
#ln -fs $CRTMDIR/SpcCoeff/Big_Endian/ssmis_f20.SpcCoeff.bin   ./
#ln -fs $CRTMDIR/TauCoeff/Big_Endian/ssmis_f20.TauCoeff.bin   ./

#---EDIT HERE --------------------------------------------------------
# tmmark is an variable used as the file extention of the output
#    filename .GrbF is used if this variable is not set
# COMSP is a variable used as the initial string of the output filename
#----------------------------------------------------------------------
export tmmark=tm00
export MP_SHARED_MEMORY=yes
export MP_LABELIO=yes

#######################################################
# 1. Run Unipost
#
# The Unipost is used to read native WRF model 
# output and put out isobaric state fields and derived fields.
#######################################################

export NEWDATE=$anal_date

while [ $fhr -le $lastfhr ] ; do

typeset -Z3 fhr

#NEWDATE=`${POSTEXEC}/ndate.exe +${fhr} $anal_date`

YY=`echo $NEWDATE | cut -c1-4`
MM=`echo $NEWDATE | cut -c5-6`
DD=`echo $NEWDATE | cut -c7-8`
HH=`echo $NEWDATE | cut -c9-10`

echo 'NEWDATE' $NEWDATE
echo 'YY' $YY

#--- EDIT HERE --------------------------------------------------------
# Update domains
# ie. for domain in d01 d02 d03
for domain in d01
do

#--- EDIT HERE --------------------------------------------------------
# Create input file for Unipost 
#   First line is where your wrfout data is
#   Second line is the format
#   Third line is the time for this process file
#   Forth line is a tag identifing the model
#----------------------------------------------------------------------
#../wrfout_${domain}_${YY}-${MM}-${DD}_${HH}:00:00
cat > itag <<EOF
../${filein}
netcdf
${YY}-${MM}-${DD}_${HH}:00:00
${tag}
EOF

#-----------------------------------------------------------------------
#   Run unipost.
#-----------------------------------------------------------------------
rm fort.*

ln -sf wrf_cntrl.parm fort.14
ln -sf griddef.out fort.110

#--- EDIT HERE --------------------------------------------------------
# Uncomment one
#   mpirun for MPI dmpar compile -- UPDATE FOR YOUR SYSTEM!!! ** FOR
#      now there are two environment variables tmmark and COMSP
#   unipost.exe for serial compile
#----------------------------------------------------------------------
# dmpar runs
#  mpirun -np ${NTHREADS} ${POSTEXEC}/mpi_unipost.exe > unipost_${domain}.$fhr.out 2>&1

# Serial run command
  ${POSTEXEC}/unipost.exe > unipost_${domain}.$fhr.out 2>&1

ln -sf WRFPRS*.tm00 prs.grb
ln -sf WRFTWO*.tm00 two.grb
/glade/apps/opt/ncl/6.3.0/intel/12.1.5/bin/ncl_convert2nc prs.grb
/glade/apps/opt/ncl/6.3.0/intel/12.1.5/bin/ncl_convert2nc two.grb
/glade/apps/opt/ncl/6.3.0/intel/12.1.5/bin/ncl  /glade/u/home/hclin/scripts/rt2015/diag/post_anal/extract_wrf.ncl
/glade/apps/opt/ncl/6.3.0/intel/12.1.5/bin/ncl  /glade/u/home/hclin/scripts/rt2015/diag/post_anal/merge2.ncl

exit #hcl

# debugger runs - enter your debugger and hour of error
#if [[ ${fhr} -eq 15 ]]; then
#  mpirun -np 1 -dbg=pgdbg ${POSTEXEC}/unipost.exe > unipost_${domain}.$fhr.out 2>&1
#else
#  mpirun -np 1 ${POSTEXEC}/unipost.exe > unipost_${domain}.$fhr.out 2>&1
#fi

#
# This prefix was given in the wrf_cntl.parm file
mv WRFPRS$fhr.${tmmark} WRFPRS_${domain}.${fhr}

#
#----------------------------------------------------------------------
#   End of unipost job
#----------------------------------------------------------------------

ls -l WRFPRS_${domain}.${fhr}
err1=$?

if test "$err1" -ne 0
then

echo 'UNIPOST FAILED, EXITTING'
exit

fi

if [ $dyncore = "NMM" ]; then

#######################################################################
# 2. Run copygb
# 
# Copygb interpolates Unipost output from its native 
# grid to a regular projection grid. The package copygb 
# is used to horizontally interpolate from one domain 
# to another, it is necessary to run this step for wrf-nmm 
# (but not for wrf-arw) because wrf-nmm's computational 
# domain is on rotated Arakawa-E grid
#
# Copygb can be run in 3 ways as explained below. 
# Uncomment the preferable one.
#
#----------------------------------------------------------------------
#
# Option 1: 
# Copygb is run with a pre-defined AWIPS grid 
# (variable $gridno, see below) Specify the grid to 
# interpolate the forecast onto. To use standard AWIPS grids 
# (list in  http://wwwt.emc.ncep.noaa.gov/mmb/namgrids/ or 
# or http://www.nco.ncep.noaa.gov/pmb/docs/on388/tableb.html),
# set the number of the grid in variable gridno below.
# To use a user defined grid, see explanation above copygb command.
#
# export gridno=212
#
#${POSTEXEC}/copygb.exe -xg${gridno} WRFPRS_${domain}.${fhr} wrfprs_${domain}.${fhr}
#
#----------------------------------------------------------------------
#
#  Option 2: 
#  Copygb ingests a kgds definition on the command line.
#${POSTEXEC}/copygb.exe -xg"255 3 109 91 37748 -77613 8 -71000 10379 9900 0 64 42000 42000" WRFPRS_${domain}.${fhr} wrfprs_${domain}.${fhr}
#
#----------------------------------------------------------------------
#
#  Option 3: 
#  Copygb can ingests contents of files too. For example:
#     copygb_gridnav.txt or copygb_hwrf.txt through variable $nav.
# 
#  Option -3.1:
#    To run for "Lambert Comformal map projection" uncomment the following line
#
 read nav < 'copygb_gridnav.txt'
#
#  Option -3.2:
#    To run for "lat-lon" uncomment the following line 
#
#read nav < 'copygb_hwrf.txt'
#
export nav
#
${POSTEXEC}/copygb.exe -xg"${nav}" WRFPRS_${domain}.${fhr} wrfprs_${domain}.${fhr}
#
# (For more info on "copygb" see WRF-NMM User's Guide, Chapter-7.)
#----------------------------------------------------------------------

# Check to see whether "copygb" created the requested file.

ls -l wrfprs_${domain}.${fhr}
err1=$?

if test "$err1" -ne 0
then

echo 'copygb FAILED, EXITTING'
exit

fi

#----------------------------------------------------------------------
#   End of copygb job
#----------------------------------------------------------------------

elif [ $dyncore = "ARW" ]; then
    ln -s WRFPRS_${domain}.${fhr} wrfprs_${domain}.${fhr}
fi

done

let "fhr=fhr+$incrementhr"

NEWDATE=`${POSTEXEC}/ndate.exe +${fhr} $anal_date`

done

date
echo "End of Output Job"
exit
