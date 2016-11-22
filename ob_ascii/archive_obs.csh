#!/bin/csh
#BSUB -J arc
#BSUB -q geyser
#BSUB -n 1
#BSUB -o job.out
#BSUB -e job.out
#BSUB -W 06:00
#BSUB -P P64000510

set echo
echo "Beginning $0"
set START_DATE = $ANAL_DATE #2015052700
set END_DATE   = $ANAL_DATE #2015082512
set CYCLE_PERIOD = 06
set ADVANCE_HOUR = 06
set DATE = $START_DATE
set BIN_DIR = ${HOME}/bin
set EXP_DIR_TOP = /glade/scratch/hclin/CONUS/wrfda/obsproc
while ( $DATE <= $END_DATE )

   set hh = `echo $DATE | cut -c9-10`
   cd ${EXP_DIR_TOP}

   set HSI_DIR = /home/hclin/RT2015/${DATE}
   hsi "mkdir -p ${HSI_DIR}"

   set archive_fname = obs_${DATE}.tar
   tar cvf ${archive_fname} \
       ${DATE}/ob_d01.ascii.${DATE}
   foreach gfsobs ( gfs.t${hh}z.1bamua.tm00.bufr_d gfs.t${hh}z.gpsro.tm00.bufr_d gfs.t${hh}z.prepbufr.nr )
       if ( -e ${DATE}/${gfsobs} ) then
          tar --append --file=${archive_fname} ${DATE}/${gfsobs}
       endif
   end
   hsi "cd ${HSI_DIR}; lcd ${EXP_DIR_TOP}; put -p ${archive_fname}"
   if { hsi ls ${HSI_DIR}/${archive_fname} >& /dev/null } then
      \rm -f ${archive_fname}
   else
      echo "Error archiving obs for ${DATE}"
   endif

   set DATE = `${HOME}/bin/da_advance_time.exe $DATE $CYCLE_PERIOD`

end #DATE loop
