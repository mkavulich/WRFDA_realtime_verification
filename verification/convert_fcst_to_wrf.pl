#!/usr/bin/perl -w

##################################################################
# Convert GFS forecast onto WRF Grid for WRFDA Verification purposes
# Created by Michael Kavulich, February 2017
# Modification history:
#  March 2017 - Modified to allow for arbitrary forecast hours, including 00h
#             - Modified to run for multiple different forecast dates
##################################################################
#
#
use strict;
use Time::HiRes qw(sleep gettimeofday);
use Time::localtime;
use Time::gmtime;
use Sys::Hostname;
use File::Copy;
use File::Path;
use File::Basename;
use File::Compare;
use IPC::Open2;
use Net::FTP;
use Getopt::Long;

#Set needed variables

 my $Start_time;
 my $tm = localtime;
 $Start_time=sprintf "Begin : %02d:%02d:%02d-%04d/%02d/%02d\n",
      $tm->hour, $tm->min, $tm->sec, $tm->year+1900, $tm->mon+1, $tm->mday;

 my $utm = gmtime; #Get time in UTC

 print "Start time: $Start_time\n";


sub print_help_and_die {
  print "\nUsage : convert_fcst_to_wrf.pl --start=YYYY-MM-DD_hh:mm:ss --end=YYYY-MM-DD_hh:mm:ss --interval=24 --overwrite=yes/[no]\n";
  print "\n                               --run_wps=[true]/false --run_real=[true]/false\n";
  print "\n                               --gfs=[true]/false --nam=[true]/false --mpas=[true]/false\n";
  print "        start:      Start date in full WRF format (YYYY-MM-DD_hh:mm:ss); default is 00z today\n";
  print "        end:        End date in full WRF format (YYYY-MM-DD_hh:mm:ss); default is same as start\n";
  print "        interval:   Interval between forecast start dates in hours; default is 24\n";
  print "        overwrite:  'yes' will overwrite old runs without asking (useful for calls from other scripts)\n";
  print "        run_wps:    'false' will not run WPS (will use old WPS run if it exists)\n";
  print "        run_real:   'false' will not run real.exe\n";
  print "        gfs:        'true' will convert GFS forecasts\n";
  print "        nam:        'true' will convert NAM forecasts\n";
  print "        mpas:       'true' will convert MPAS forecasts\n";
  die "\n";
}

# Basic static inputs
 my $Main_dir = "/glade/p/work/kavulich/V39/";
 my $Script_dir = `pwd`;
 chomp $Script_dir;
 my $WPS_dir="$Main_dir/WPS";
 my $WRF_dir="$Main_dir/WRF_20170329";
 my $WRFDA_dir="/glade/p/work/hclin/code_intel/WRFDA/v39";
 my @WPS_indata_dir;
 my $Convert_GFS="true";
 my $Convert_NAM="true";
 my $Convert_MPAS="true";

# Command-line options
 my $start_date=sprintf "%04d-%02d-%02d_00:00:00",$utm->year+1900,$utm->mon+1,$utm->mday; #Initial time for first GFS forecast; default to 00z today
 my $end_date='';   #Initial time for final GFS forecast
 my $FC_INTERVAL=24;                   #Interval between forecasts  IN HOURS
 my @convert_hours = ( 0, 48 );          #Forecast hours to convert for each individual forecast (not command-line yet)
 my $overwrite = 'no';
 my $run_wps='true';
 my $run_real='true';
 my $run_wrf='false';

# Read command-line input

GetOptions( "start:s" => \$start_date,
            "end:s" => \$end_date,
            "interval:s" => \$FC_INTERVAL,
            "overwrite:s" => \$overwrite,
            "run_wps:s" => \$run_wps,
            "run_real:s" => \$run_real,
            "gfs:s" => \$Convert_GFS,
            "nam:s" => \$Convert_NAM,
            "mpas:s" => \$Convert_MPAS ) or &print_help_and_die;

if ( $end_date eq '') {
   $end_date = $start_date;
}

#If input is YYYYMMDDHH format, convert to WRF format (YYYY-MM-DD_hh:mm:ss)
unless ($start_date=~ /:/) {
   $start_date=sprintf "%04d-%02d-%02d_%02d:00:00",substr($start_date, 0, 4),substr($start_date, 4, 2),substr($start_date, 6, 2),substr($start_date, 8, 2);
}
unless ($end_date=~ /:/) {
   $end_date=sprintf "%04d-%02d-%02d_%02d:00:00",substr($end_date, 0, 4),substr($end_date, 4, 2),substr($end_date, 6, 2),substr($end_date, 8, 2);
}

if ( ( ($run_wps =~ /t/i) and ($run_wps =~ /f/i) ) or not ( ($run_wps =~ /t/i) or ($run_wps =~ /f/i) )) {
   die "INVALID INPUT FOR \$run_wps: $run_wps\n";
}
if ( ( ($run_real =~ /t/i) and ($run_real =~ /f/i) ) or not ( ($run_real =~ /t/i) or ($run_real =~ /f/i) )) {
   die "INVALID INPUT FOR \$run_real: $run_real\n";
}
if ( ( ($run_wrf =~ /t/i) and ($run_wrf =~ /f/i) ) or not ( ($run_wrf =~ /t/i) or ($run_wrf =~ /f/i) )) {
   die "INVALID INPUT FOR \$run_wrf: $run_wrf\n";
}


#Keep track of which forecast(s) we are converting
my @forecasts;
my $NUM_METGRID_LEVELS;
my $NUM_METGRID_SOIL_LEVELS;

if ($Convert_GFS =~ /T/i) {
   push @forecasts, "GFS";
}
if ($Convert_NAM =~ /T/i) {
   push @forecasts, "NAM";
}
if ($Convert_MPAS =~ /T/i) {
   push @forecasts, "MPAS";
}

# Directories
 my $geog_dir="/glade/p/work/wrfhelp/WPS_GEOG/";
# WORKDIR is top-level; individual forecasts will be stored in $WORKDIR/@forecasts/Output/$DATE
 my $WORKDIR="/glade/p/wrf/WORKDIR/wrfda_realtime/verification";

# WRF/WPS parameters
 my $METEM_INTERVAL=21600;   #WPS output interval               IN SECONDS
 my $OUT_INTERVAL=360;       #WRF output interval               IN MINUTES
 my $GRIB_INTERVAL=6;        #WPS GRIB input interval           IN HOURS
                             # I'm so, so sorry about this part ^^^^^^^^^^ 
                             # but it's necessary due to WPS/WRF namelist conventions
 my $RUN_DAYS = 0;           # Don't make this a month or longer or bad things will happen!
 my $RUN_HOURS =6;
 my $RUN_MINUTES = 0;
 my $NUM_DOMAINS = 1; #For NUM_DOMAINS > 1, be sure that the appropriate variables are all set for all domains below!
 my @GEOG_DATA_RES = ( "'modis_30s+30s'", "'modis_30s+30s'" );


# THIS DATA SHOULD TAKE COMMAND-LINE ARGUMENTS IN THE FUTURE!
 my $WRF_DT = 75;
 my @WRF_DX = ( 15000, 3000 );
 my @WEST_EAST_GRID = ( 415, 1581 );
 my @SOUTH_NORTH_GRID = ( 325, 986 );
 my @VERTICAL_GRID = ( 40, 51 );
 my @PARENT_GRID_RATIO = ( 1, 5 );
 my @I_PARENT_START = ( 1, 70 );
 my @J_PARENT_START = ( 1, 60 );
# my $NL_ETA_LEVELS="1.000 0.9880 0.9765 0.9620 0.9440 0.9215 0.8945 0.8587 0.8161 0.7735 0.7309 0.6724 0.6010 0.5358 0.4763 0.4222 0.3730 0.3283 0.2878 0.2512 0.2182 0.1885 0.1619 0.1380 0.1166 0.0977 0.0808 0.0659 0.0528 0.0412 0.0312 0.0224 0.0148 0.0083 0.0026 0.0000";
# my $NL_ETA_LEVELS="1.000000,0.998000,0.996000,0.994000,0.992000,0.990000,0.988100,0.981800,0.974000,0.966000,0.958000,0.952000,0.943400,0.920000,0.880000,0.840000,0.800000,0.760000,0.720000,0.680000,0.640000,0.600000,0.560000,0.520000,0.480000,0.440000,0.400000,0.360000,0.320000,0.280000,0.240000,0.200000,0.160000,0.140000,0.120000,0.100000,0.080000,0.060000,0.040000,0.020000,0.00000";

 # See /glade/scratch/wrfrt/realtime_ensemble/ensf/$DATE/wps_rundir/fhr_0/namelist.wps for source
 my $MAP_PROJ="lambert"; #"lambert", "polar", "mercator"
 my $REF_LAT=39.;    #AKA PHIC AKA CEN_LAT
 my $REF_LON=-101.;     #AKA XLONC AKA CEN_LON
 my $STAND_LON=-101.;
 my $TRUELAT1=32.;
 my $TRUELAT2=46.;
 my $POLE_LAT=90.;
 my $POLE_LON=0.;

# WRF options
 my @PARENT_TIME_STEP_RATIO = ( 1, 4 );
 my @MP_PHYSICS = ( 8, 8 );
 my @RA_LW_PHYSICS = ( 4, 4 );
 my @RA_SW_PHYSICS = ( 4, 4 );
 my $RADT = 10;
 my @SF_SFCLAY_PHYSICS = ( 2, 2);
 my @SF_SURFACE_PHYSICS = ( 2, 2);
 my @BL_PBL_PHYSICS = ( 2, 2);
 my @CU_PHYSICS = ( 6, 0);
 my $P_TOP; #Set later dependent on model
 my $NUM_SOIL_LAYERS = 4;
 my $NUM_LAND_CAT = 20; #'modis_30s+30s' geog data requires NUM_LAND_CAT=20

 my $HYBRID_OPT = 0;
 my $ETAC = 0.2;

 my $realsize = 4; # realsize=8 for REAL*8 or WRFPLUS runs

# Job submission options
 my $NUM_PROCS_WPS = 1;
 my $NUM_PROCS_REAL = 4;
 my $NUM_PROCS = 16; 
 my $JOBQUEUE_WPS = "caldera";
 my $JOBQUEUE_REAL = "caldera";
 my $JOBQUEUE = "caldera";
 my $PROJECT = "P64000400";


############################################
#   Only options above should be edited!   #
############################################

# Check there are no problem values
 if (($NUM_PROCS_WPS > 16) and ($JOBQUEUE_WPS eq "caldera"))
     { die "\nERROR ERROR ERROR\nCaldera queue has a max NUM_PROCS of 16\nYou specified NUM_PROCS_WPS = $NUM_PROCS_WPS\nERROR ERROR ERROR\n\n"};
 if (($NUM_PROCS_REAL > 16) and ($JOBQUEUE_REAL eq "caldera"))
     { die "\nERROR ERROR ERROR\nCaldera queue has a max NUM_PROCS of 16\nYou specified NUM_PROCS_REAL = $NUM_PROCS_REAL\nERROR ERROR ERROR\n\n"};
 if (($NUM_PROCS > 16) and ($JOBQUEUE eq "caldera")) 
     { die "\nERROR ERROR ERROR\nCaldera queue has a max NUM_PROCS of 16\nYou specified NUM_PROCS = $NUM_PROCS\nERROR ERROR ERROR\n\n"};

 foreach my $fcst (@forecasts) {

    if ($fcst eq "GFS") {
       $NUM_METGRID_LEVELS=32;     #GFS Default 32 (27 prior to April 2016)
       $NUM_METGRID_SOIL_LEVELS=4; #GFS Default 4 (2 prior to early 2005)
       $P_TOP = 1000;
    } elsif ($fcst eq "NAM") {
       $NUM_METGRID_LEVELS=40;     #NAM default 40
       $NUM_METGRID_SOIL_LEVELS=4; #NAM Default 4
       $P_TOP = 5000;
       @SOUTH_NORTH_GRID = ( 285, 986 ); #FOR NAM, NEED SMALLER DOMAIN
    } elsif ($fcst eq "MPAS") {
       $NUM_METGRID_LEVELS=56;     #MPAS default ???
       $NUM_METGRID_SOIL_LEVELS=4; #MPAS Default ???
       $P_TOP = 1500;
    } else {
       die "UNKNOWN FCST TYPE: $fcst\n";
    }
    #First $init_date is $start_date
    my $init_date = $start_date;

    my $Run_dir_top="$WORKDIR/$fcst/Run";
    my $Out_dir_top="$WORKDIR/$fcst/Output";

    ! system("mkdir -p $Run_dir_top") or die "Can not create $Run_dir_top: $!\n";
    ! system("mkdir -p $Out_dir_top") or die "Can not create $Out_dir_top: $!\n";

    #Allow running for multiple separate forecasts at once
    while ( &wrf2num($init_date) <= &wrf2num($end_date) ) {

       my $iyear  = substr("$init_date", 0, 4) or die "Invalid date format!\n";
       my $imonth = substr("$init_date", 5, 2);
       my $iday   = substr("$init_date", 8, 2);
       my $ihour  = substr("$init_date", 11, 2);
       my $imin   = substr("$init_date", 14, 2);
       my $isec   = substr("$init_date", 17);
       my $Run_dir="$Run_dir_top/$iyear$imonth$iday$ihour";
       my $Out_dir="$Out_dir_top/$iyear$imonth$iday$ihour";

       # If old data exists, ask to overwrite
       if ((-d $Run_dir) && ($overwrite =~ /N/i)) {
          my $go_on='';
          print "$Run_dir already exists, do you want to risk overwriting old data?\a\n";
          while ($go_on eq "") {
             $go_on = <STDIN>;
             chop($go_on);
             if ($go_on =~ /N/i) {
                die "Choose another value for \$WORKDIR.\n";
             } elsif ($go_on =~ /Y/i) {
             } else {
                print "Invalid input: ".$go_on;
                $go_on='';
             }
          }
       }

       print "Setting up working directory for WPS/real/exe:\n$Run_dir\n\n";
       if ($run_wps =~ /t/i) {
          rmtree("$Run_dir");
       }
       mkdir $Run_dir;


       # Remove old FAIL file if it exists
       unlink "FAIL";

       my $job_feedback = ""; #For getting feedback from bsub
       my $jobid;        #For making sure we submit jobs in the right order

       print "\n==================================================\n\n";
       print "Running WPS/real.exe to convert $fcst forecast to WRF-input format\n";
       print "  $fcst Forecast Start Time : $init_date\n";

       if ($run_wps =~ /t/i) {

          # Get WPS files
          if ($fcst eq "GFS") {
             $WPS_indata_dir[0]="/glade/p/rda/data/ds084.1/$iyear/$iyear$imonth$iday";
          } elsif ($fcst eq "NAM") {
             $WPS_indata_dir[0]="/glade/p/rda/data/ds609.2/3hr_fcst/$iyear";
             $WPS_indata_dir[1]="/glade/p/rda/data/ds609.2/6hr_anal/$iyear";
          } elsif ($fcst eq "MPAS") {
             $WPS_indata_dir[0]="/glade/scratch/mpasrt/us/$iyear$imonth$iday$ihour";
          } else {
             die "UNKNOWN FORECAST TYPE: $fcst\n";
          }
          ! system("cp $WPS_dir/link_grib.csh $WPS_dir/geogrid/src/geogrid.exe $WPS_dir/ungrib/src/ungrib.exe $WPS_dir/metgrid/src/metgrid.exe $Run_dir/") or die "Error copying WPS files: $!\n";

          if ($fcst eq "GFS") {
             copy ("$WPS_dir/ungrib/Variable_Tables/Vtable.GFS","$Run_dir/Vtable");
          } elsif ($fcst eq "NAM") {
             copy ("$WPS_dir/ungrib/Variable_Tables/Vtable.NAM","$Run_dir/Vtable");
          } elsif ($fcst ne "MPAS") { #MPAS needs no Vtable
             die "UNKNOWN FORECAST TYPE: $fcst\n";
          }
       }
       if ( ($run_real =~ /t/i) or ($run_wrf =~ /t/i) ) {
          # Get WRF files; use glob since we need everything
          my @WRF_files = glob("$WRF_dir/run/*");

          foreach my $file (@WRF_files) {
             my $filename=basename($file);
             if ($realsize == 8) {
                my @namesplit = split(/_/,$filename);
                if ($namesplit[-1] =~ "DBL") {
                   $filename = substr($filename, 0, -4);
                   print "Renaming double-precision fix file $file to $filename\n";
                }
                copy("$file","$Run_dir/$filename");
                next;
             }
             if ( (not -e "$Run_dir/$filename") or ($filename =~ ".exe")) { #Always overwrite old executables
                 copy("$file","$Run_dir/$filename");
             }
          }
       }

       chdir "$Run_dir";
       unlink "namelist.wps" if ($run_wps =~ /t/i);
       unlink "namelist.input" if ( ($run_real =~ /t/i) or ($run_wrf =~ /t/i) );
       if ($run_real =~ /t/i) {
          chmod 0755, "real.exe" or die "Couldn't change the permission to real.exe: $!";
       }
       if ($run_wrf =~ /t/i) {
          chmod 0755, "wrf.exe" or die "Couldn't change the permission to wrf.exe: $!";
       }

       foreach my $convert_hour (@convert_hours) {

          my $fcst_date = `$WRFDA_dir/var/build/da_advance_time.exe $init_date $convert_hour -w`; #Advance time to next hour
          chomp($fcst_date);
          my $fyear  = substr("$fcst_date", 0, 4) or die "Invalid forecast date format!\n";
          my $fmonth = substr("$fcst_date", 5, 2);
          my $fday   = substr("$fcst_date", 8, 2);
          my $fhour  = substr("$fcst_date", 11, 2);
          my $fmin   = substr("$fcst_date", 14, 2);
          my $fsec   = substr("$fcst_date", 17);
          print "  $fcst $convert_hour-hour Forecast Time   : $fcst_date\n";

          #Create namelists
          print "Creating namelists\n";

# WPS NAMELIST
          if ($run_wps =~ /t/i) {
          open NL, ">namelist.wps.$convert_hour" or die "Can not open namelist.wps.$convert_hour for writing: $! \n";
             print NL "&share\n";
             print NL "wrf_core = 'ARW',\n";
             print NL " max_dom = $NUM_DOMAINS,\n";
             print NL " start_date = '$fcst_date','$fcst_date',\n";
             print NL " end_date   = '$fcst_date','$fcst_date',\n";
             print NL " interval_seconds = $METEM_INTERVAL\n";
             print NL " io_form_geogrid = 2,\n";
             print NL " debug_level = 0\n";
             print NL "/\n";
             print NL "&geogrid\n";
             print NL " parent_id         =   1,   1,\n";
             print NL " parent_grid_ratio =   $PARENT_GRID_RATIO[0],  $PARENT_GRID_RATIO[1],\n";
             print NL " i_parent_start    =   $I_PARENT_START[0],  $I_PARENT_START[1],\n";
             print NL " j_parent_start    =   $J_PARENT_START[0],  $J_PARENT_START[1],\n";
             print NL " e_we              =  $WEST_EAST_GRID[0], $WEST_EAST_GRID[1],\n";
             print NL " e_sn              =  $SOUTH_NORTH_GRID[0], $SOUTH_NORTH_GRID[1],\n";
             print NL " geog_data_res     = $GEOG_DATA_RES[0], $GEOG_DATA_RES[1],\n";
             print NL " dx = $WRF_DX[0],\n";
             print NL " dy = $WRF_DX[0],\n";
             print NL " map_proj = '$MAP_PROJ',\n";
             print NL " ref_lat   = $REF_LAT,\n";
             print NL " ref_lon   = $REF_LON,\n";
             print NL " truelat1  = $TRUELAT1,\n";
             print NL " truelat2  = $TRUELAT2,\n";
             print NL " stand_lon = $STAND_LON,\n";
             print NL " geog_data_path = '$geog_dir'\n";
             print NL " opt_geogrid_tbl_path = '$WPS_dir/geogrid/'\n";
             print NL "/\n";
             print NL "&ungrib\n";
             print NL " out_format = 'WPS',\n";
             print NL " prefix = 'FILE',\n";
             print NL "/\n";
             print NL "&metgrid\n";
             if ($fcst eq "MPAS") {
                print NL " constants_name = 'mpas:static.nc'\n";
                print NL " fg_name = 'mpas:60-15km_CONUS'\n";
             } else {
                print NL " fg_name = 'FILE'\n";
             }
             print NL " io_form_metgrid = 2, \n";
             print NL " opt_metgrid_tbl_path = '$WPS_dir/metgrid/',\n";
             print NL "/\n";
             close NL;
          }

# WRF NAMELIST
          if ( ($run_real =~ /t/i) or ($run_wrf =~ /t/i) ) {
             open NL, ">namelist.input.$convert_hour" or die "Can not open namelist.input.$convert_hour for writing: $! \n";
             print NL "&time_control\n";
             print NL " run_days                 = $RUN_DAYS,\n";
             print NL " run_hours                = $RUN_HOURS,\n";
             print NL " run_minutes              = $RUN_MINUTES,\n";
             print NL " run_seconds              = 0,\n";
             print NL " start_year               = $fyear,$fyear\n";
             print NL " start_month              = $fmonth,$fmonth\n";
             print NL " start_day                = $fday,$fday\n";
             print NL " start_hour               = $fhour,$fhour\n";
             print NL " start_minute             = $fmin,$fmin\n";
             print NL " start_second             = $fsec,$fsec\n";
             print NL " end_year                 = $fyear,$fyear\n";
             print NL " end_month                = $fmonth,$fmonth\n";
             print NL " end_day                  = $fday,$fday\n";
             print NL " end_hour                 = $fhour,$fhour\n";
             print NL " end_minute               = $fmin,$fmin\n";
             print NL " end_second               = $fsec,$fsec\n";
             print NL " interval_seconds         = $METEM_INTERVAL,\n";
             print NL " history_interval         = $OUT_INTERVAL,$OUT_INTERVAL\n";
             print NL " input_from_file          = .true.,.true.,.true.,\n";
             print NL " frames_per_outfile       = 1,1,\n";
             print NL " restart                  = .false.,\n";
             print NL " restart_interval         = 500000,\n";
             print NL " debug_level              = 0,\n";
#       print NL " nocolons                 = true,\n";
             print NL "/\n";
             print NL "&domains\n";
             print NL " time_step                = $WRF_DT,\n";
             print NL " max_dom                  = $NUM_DOMAINS,\n";
             print NL " parent_time_step_ratio   = $PARENT_TIME_STEP_RATIO[0], $PARENT_TIME_STEP_RATIO[1],\n";
             print NL " e_we                     = $WEST_EAST_GRID[0], $WEST_EAST_GRID[1],\n";
             print NL " e_sn                     = $SOUTH_NORTH_GRID[0], $SOUTH_NORTH_GRID[1],\n";
             print NL " e_vert                   = $VERTICAL_GRID[0], $VERTICAL_GRID[1],\n";
             print NL " dx                       = $WRF_DX[0],$WRF_DX[1],\n";
             print NL " dy                       = $WRF_DX[0],$WRF_DX[1],\n";
#       print NL " eta_levels               = $NL_ETA_LEVELS\n";
             print NL " smooth_option            = 1,\n";
             print NL " p_top_requested          = $P_TOP\n";
             print NL " num_metgrid_levels       = $NUM_METGRID_LEVELS,\n";
             print NL " num_metgrid_soil_levels  = $NUM_METGRID_SOIL_LEVELS,\n";
             print NL " grid_id                  = 1, 2,\n";
             print NL " parent_id                = 0, 1,\n";
             print NL " i_parent_start           = $I_PARENT_START[0],  $I_PARENT_START[1],\n";
             print NL " j_parent_start           = $J_PARENT_START[0],  $J_PARENT_START[1],\n";
             print NL " parent_grid_ratio        = $PARENT_GRID_RATIO[0],  $PARENT_GRID_RATIO[1],\n";
             print NL " parent_time_step_ratio   = $PARENT_GRID_RATIO[0],  $PARENT_GRID_RATIO[1],\n";
             print NL " feedback                 = 1,\n";
             print NL "/\n";
             print NL "&physics\n";
             print NL " mp_physics               = $MP_PHYSICS[0], $MP_PHYSICS[1],\n";
             print NL " ra_lw_physics            = $RA_LW_PHYSICS[0], $RA_LW_PHYSICS[1],\n";
             print NL " ra_sw_physics            = $RA_SW_PHYSICS[0], $RA_SW_PHYSICS[1],\n";
             print NL " radt                     = $RADT, $RADT,\n";
             print NL " sf_sfclay_physics        = $SF_SFCLAY_PHYSICS[0], $SF_SFCLAY_PHYSICS[1],\n";
             print NL " sf_surface_physics       = $SF_SURFACE_PHYSICS[0], $SF_SURFACE_PHYSICS[1],\n";
             print NL " bl_pbl_physics           = $BL_PBL_PHYSICS[0], $BL_PBL_PHYSICS[1],\n";
             print NL " bldt                     = 0,\n";
             print NL " cu_physics               = $CU_PHYSICS[0], $CU_PHYSICS[1],\n";
             print NL " cudt                     = 5,\n";
             print NL " isfflx                   = 1,\n";
             print NL " ifsnow                   = 0,\n";
             print NL " icloud                   = 1,\n";
             print NL " surface_input_source     = 1,\n";
             print NL " num_soil_layers          = $NUM_SOIL_LAYERS,\n";
             print NL " num_land_cat             = $NUM_LAND_CAT,\n";
             print NL " sf_urban_physics         = 0,\n";
             print NL "/\n";
             print NL "&dynamics\n";
             print NL " hybrid_opt               = $HYBRID_OPT,\n";
             print NL " etac                     = $ETAC,\n";
             print NL " w_damping                = 1,\n";
             print NL " diff_opt                 = 1,\n";
             print NL " km_opt                   = 4,\n";
             print NL " diff_6th_opt             = 0,\n";
             print NL " diff_6th_factor          = 0.12,\n";
             print NL " base_temp                = 290.\n";
             print NL " damp_opt                 = 0,\n";
             print NL " zdamp                    = 5000.,\n";
             print NL " dampcoef                 = 0.01,\n";
             print NL " khdif                    = 0,\n";
             print NL " kvdif                    = 0,\n";
             print NL " non_hydrostatic          = .true.,\n";
             print NL " moist_adv_opt            = 1,\n";
             print NL " scalar_adv_opt           = 1,\n";
             print NL "/\n";
             print NL "&bdy_control\n";
             print NL " spec_bdy_width           = 5,\n";
             print NL " spec_zone                = 1,\n";
             print NL " relax_zone               = 4,\n";
             print NL " specified                = .true., .false.,.false.,\n";
             print NL " nested                   = .false., .true., .true.,\n";
             print NL "/\n";
             print NL "&namelist_quilt\n";
             print NL " nio_tasks_per_group      = 0,\n";
             print NL " nio_groups               = 1,\n";
             print NL "/\n";
             close NL;
          }

          #Link WPS input data
          if ($run_wps =~ /f/i) {
             print "NOT running WPS\n";
          } else {
             print "Linking input data\n";

             if ($fcst eq "GFS") {
                symlink sprintf("$WPS_indata_dir[0]/gfs.0p25.$iyear$imonth$iday$ihour.f%03d.grib2", $convert_hour) , "grib_$fyear$fmonth$fday\_$fhour" or die "Cannot symlink ".sprintf("$WPS_indata_dir[0]/gfs.0p25.$iyear$imonth$iday$ihour.f%03d.grib2", $convert_hour)." to grib_$fyear$fmonth$fday\_$fhour: $!\n";
             } elsif ($fcst eq "NAM") {
                my $NAMTAR;
                if ($convert_hour > 0) {
                   $NAMTAR = "$WPS_indata_dir[0]/$iyear$imonth$iday.awip3d.fcst.tar";
                } else {
                   $NAMTAR = "$WPS_indata_dir[1]/$iyear$imonth$iday.awip3d.anl.tar"; # Why would you store the initial output file in a different directory in a different tar file? WHYYYYYY?
                }
                print "Untarring the code from $NAMTAR ...\n";
                ! system("tar", "xf", $NAMTAR) or die "Can not open $NAMTAR: $!\n";
                rename sprintf("$iyear$imonth$iday.nam.t%02dz.awip3d%02d.tm00.grib2", $ihour , $convert_hour) , "grib_$fyear$fmonth$fday\_$fhour" or die "Cannot symlink ".sprintf("$iyear$imonth$iday.nam.t%02dz.awip3d%02d.tm00.grib2", $ihour , $convert_hour)." to grib_$fyear$fmonth$fday\_$fhour: $!\n";
                system("rm -f *tm00.grib2");
             } elsif ($fcst eq "MPAS") {
                symlink sprintf("$WPS_indata_dir[0]/60-15km_CONUS.$fyear-$fmonth-$fday\_%02d.nc", $fhour) , sprintf("60-15km_CONUS.$fyear-$fmonth-$fday\_%02d.nc", $fhour)  or die "Cannot symlink ".sprintf("$WPS_indata_dir[0]/60-15km_CONUS.$fyear-$fmonth-$fday\_%02d.nc", $fhour).": $!\n";
                if (! -e "static.nc") { #only need to do this once
#                   ! system("ncrename -vtheta,theta_gwd $WPS_indata_dir[0]/static.nc static.nc") or die "Problem converting $WPS_indata_dir[0]/static.nc to correct format\n";
                    copy("$WPS_indata_dir[0]/static.nc","static.nc");
                }
             } else {
                die "UNKNOWN FCST TYPE: $fcst\n";
             }

# RUN WPS

             print "Creating WPS job\n";

             open FH, ">run_wps_$convert_hour.csh" or die "Can not open run_wps_$convert_hour.csh for writing: $! \n";
                print FH "#!/bin/csh\n";
                print FH "#\n";
                print FH "# LSF batch script\n";
                print FH "# Automatically generated by $0\n";
                print FH "#BSUB -J WPS_${fcst}2WRF_${convert_hour}h\n";
                print FH "#BSUB -q $JOBQUEUE_WPS\n";
                print FH "#BSUB -n $NUM_PROCS_WPS\n";
                print FH "#BSUB -o run_wps_$convert_hour.output\n";
                print FH "#BSUB -e run_wps_$convert_hour.error\n";
                print FH "#BSUB -W 20"."\n";
                print FH "#BSUB -P $PROJECT\n";
                printf FH "#BSUB -R span[ptile=%d]"."\n", ($NUM_PROCS_WPS < 16 ) ? $NUM_PROCS_WPS : 16;
                print FH "\n"; #End of BSUB commands; add newline for readability
                if ( $JOBQUEUE_WPS =~ "caldera") {
                   print FH "unsetenv MP_PE_AFFINITY\n";  # CISL-recommended kludge *sigh*
                }
                print FH "\\rm namelist.wps\n";
                print FH "ln -sf namelist.wps.$convert_hour namelist.wps\n";
                print FH "if ( ! -e geo_em.d01.nc ) then\n";
                print FH "   mpirun.lsf ./geogrid.exe\n";
                print FH "endif\n";
                print FH "./link_grib.csh grib_*\n";
                unless ($fcst eq "MPAS") {
                   print FH "./ungrib.exe\n";
                }
                print FH "mpirun.lsf ./metgrid.exe\n";
                print FH "if ( (!(-e 'met_em.d01.$fcst_date.nc')) && (!(-e '$Script_dir/FAIL')) ) then\n";
                print FH "   echo 'WPS failure in $Run_dir' > $Script_dir/FAIL\n";
                print FH "endif\n";
             close FH ;

             #Run jobs sequentially so nothing gets overwritten or otherwise out of sorts
             if ($job_feedback eq "") {
                $job_feedback = ` bsub < run_wps_$convert_hour.csh `;
             } else {
                $job_feedback = ` bsub -w "ended($jobid)" < run_wps_$convert_hour.csh `;
             }
             print "$job_feedback\n";
             if ($job_feedback =~ m/.*<(\d+)>/) {
                $jobid = $1;
             } else {
                print "\nJob feedback = $job_feedback\n\n";
                die "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nFailed to submit WPS job for $fcst_date\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
             }
          }

          if ($run_real =~ /f/i) { 
             print "NOT running real.exe\n";
          } else {
             print "Creating real.exe job\n";

             open FH, ">run_real_$convert_hour.csh" or die "Can not open run_real_$convert_hour.csh for writing: $! \n";
             print FH "#!/bin/csh\n";
             print FH "#\n";
             print FH "# LSF batch script\n";
             print FH "# Automatically generated by $0\n";
             print FH "#BSUB -J REAL_${fcst}2WRF_${convert_hour}h\n";
             print FH "#BSUB -q $JOBQUEUE_REAL\n";
             print FH "#BSUB -n $NUM_PROCS_REAL\n";
             print FH "#BSUB -o run_real_$convert_hour.output"."\n";
             print FH "#BSUB -e run_real_$convert_hour.error"."\n";
             print FH "#BSUB -W 10"."\n";
             print FH "#BSUB -P $PROJECT\n";
             printf FH "#BSUB -R span[ptile=%d]"."\n", ($NUM_PROCS_REAL < 16 ) ? $NUM_PROCS_REAL : 16;
             print FH "\n"; #End of BSUB commands; add newline for readability
             if ( $JOBQUEUE_REAL =~ "caldera") {
                print FH "unsetenv MP_PE_AFFINITY\n";  # Include this line to avoid caldera problems. CISL-recommended kludge *sigh*
             }
             print FH "\\rm namelist.input\n";
             print FH "ln -sf namelist.input.$convert_hour namelist.input\n";
             print FH "mpirun.lsf ./real.exe\n";
             print FH "if ( (!(-e 'wrfinput_d01')) && (!(-e '$Script_dir/FAIL')) ) then\n";
             print FH "   echo 'real.exe failure in $Run_dir' > $Script_dir/FAIL\n";
             print FH "endif\n";
             print FH "mkdir -p $Out_dir\n";
             print FH "\\cp $Run_dir/wrfinput_d01 $Out_dir/wrfinput_d01_$fyear-$fmonth-${fday}_$fhour:$fmin:$fsec\n";
             print FH "ln -sf  $Out_dir/wrfinput_d01_$fyear-$fmonth-${fday}_$fhour:$fmin:$fsec $Out_dir/wrfout_d01_$fyear-$fmonth-${fday}_$fhour:$fmin:$fsec\n";
             close FH ;

             if ($job_feedback eq "") {
                $job_feedback = ` bsub < run_real_$convert_hour.csh `;
             } else {
                $job_feedback = ` bsub -w "ended($jobid)" < run_real_$convert_hour.csh `;
             }
             print "$job_feedback\n";
             if ($job_feedback =~ m/.*<(\d+)>/) {
                $jobid = $1;
             } else {
                print "\nJob feedback = $job_feedback\n\n";
                die "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nFailed to submit real.exe job for $fcst_date\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
             }
          }

          if ($run_wrf =~ /f/i) {
             print "NOT running WRF\n";
          } else {
             print "Creating WRF job\n";

             open FH, ">run_wrf.csh" or die "Can not open run_wrf.csh for writing: $! \n";
             print FH "#!/bin/csh\n";
             print FH "#\n";
             print FH "# LSF batch script\n";
             print FH "# Automatically generated by $0\n";
             print FH "#BSUB -J WRF${fyear}${fmonth}${fday}${fhour}${fcst}2WRF\n";
             print FH "#BSUB -q $JOBQUEUE\n";
             print FH "#BSUB -n $NUM_PROCS\n";
             print FH "#BSUB -o run_wrf.output"."\n";
             print FH "#BSUB -e run_wrf.error"."\n";
             print FH "#BSUB -W 60"."\n";
             print FH "#BSUB -P $PROJECT\n";
             printf FH "#BSUB -R span[ptile=%d]"."\n", ($NUM_PROCS < 16 ) ? $NUM_PROCS : 16;
             print FH "\n"; #End of BSUB commands; add newline for readability
             if ( $JOBQUEUE =~ "caldera") {
                print FH "unsetenv MP_PE_AFFINITY\n";  # Include this line to avoid caldera problems. CISL-recommended kludge *sigh*
             }
             print FH "mkdir real_rsl\n";
             print FH "mv rsl* real_rsl/\n";
             print FH "mpirun.lsf ./wrf.exe\n";
             print FH "if ( (!(-e 'wrfout_d01_$fcst_date')) && (!(-e '$Script_dir/FAIL')) ) then\n";
             print FH "   echo 'WRF failure in $Run_dir' > $Script_dir/FAIL\n";
             print FH "endif\n";
             print FH "mkdir -p $Out_dir\n";
             print FH "\\cp $Run_dir/wrfout_d0* $Out_dir/\n";
             close FH ;

             if ( ($run_wps =~ /f/i) and ($run_real =~ /f/i) ) {
                $job_feedback = ` bsub < run_wrf.csh`;
             } else {
                $job_feedback = ` bsub -w "ended($jobid)" < run_wrf.csh`;
             }
             print "$job_feedback\n";
             if ($job_feedback =~ m/.*<(\d+)>/) {
                $jobid = $1;
             } else {
                print "\nJob feedback = $job_feedback\n\n";
                die "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\nFailed to submit WRF job for $fcst_date\n!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n";
             }
          }
       }

    chdir $Script_dir;

    copy($0,"$Out_dir/"); #Keep a copy of this script with these settings for future reference.

    #Advance to next forecast date
    $init_date = `$WRFDA_dir/var/build/da_advance_time.exe $init_date ${FC_INTERVAL}h -w`;
    chomp($init_date);
    }
 }

 print "\nScript finished!\n";
 my $Finish_time;
 $tm = localtime;
 $Finish_time=sprintf "End : %02d:%02d:%02d-%04d/%02d/%02d\n",
      $tm->hour, $tm->min, $tm->sec, $tm->year+1900, $tm->mon+1, $tm->mday;

 print "$Finish_time\n";




# SUBROUTINES

 sub getgribfiles {

    my ($date, $fcst_end, $smonth, $fcst) = @_;

    while ( &wrf2num($date) <= &wrf2num($fcst_end) ) {
       my $gribyear  = substr("$date", 0, 4);
       my $gribmonth = substr("$date", 5, 2);
       my $gribday   = substr("$date", 8, 2);
       my $gribhour  = substr("$date", 11, 2);

       my @grib_file;

       if ($fcst eq "GFS") {
          @grib_file = glob("$WPS_indata_dir[0]/fnl_$gribyear$gribmonth$gribday\_$gribhour*grib*");
       } elsif ($fcst eq "NAM") {
          @grib_file = glob("$WPS_indata_dir[0]/$gribyear$gribmonth$gribday.nam.t${gribhour}*");
       } else {
          die "\nBAD DATA TYPE SPECIFIED\n";
       }

       symlink $grib_file[0], "grib_$gribyear$gribmonth$gribday\_$gribhour" or die "Cannot symlink $_ to local directory: $!\n";

       $date = `$Script_dir/da_advance_time.exe $date ${GRIB_INTERVAL}h -w`;
       chomp ($date);
    }
 }

#Need a subroutine to convert WRF-format dates to numbers for comparison
 sub wrf2num {
    my ($wrf_date) = @_;
    $wrf_date =~ s/\D//g;
    return $wrf_date;
 }

 sub current_jobs {
    my $bjobs = `bjobs`;
    my $jobnum = () = $bjobs =~ /\d\d:\d\d\n/gi; #This line is complicated; it counts the number of matches for time-like patterns at the end of the line
                                                 #see http://stackoverflow.com/questions/1849329
    return $jobnum;
 }

 sub watch_progress { # When waiting for jobs to finish, let's display some info

}

