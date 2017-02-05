; Extract variables to calculate/plot profiles

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$BIN_DIR/utils_hclin.ncl"

begin
;

system("date")

; for testing           
; dir = "/glade/scratch/wrfrt/realtime_ensemble/ensf/2015040800/wrf_rundir/ens_2/"
; storage = dir
; mem = 2
; init = 2015040800
;EXEC = "/glade/u/home/schwartz/utils/da_advance_time.exe"
; fhr = 48
; st_mem = sprinti("%0.3i",mem)
; st_fhr = sprinti("%0.3i",fhr)

 
; For realtime scripting

;EXEC = getenv("EXE_DIR")+"/da_advance_time.exe"
;mem = getenv("MEM")
;st_mem = sprinti("%0.3i",stringtointeger(mem))
;storage_top = getenv("storage_top")+"/"
; storage = getenv("storage")+"/"
;datename = getenv("valid_time_wrf")
; init = getenv("DATE")
;fhr_min = stringtointeger(getenv("fhr_min"))
;fhr_max = stringtointeger(getenv("fhr_max"))
;inc_fhr = stringtointeger(getenv("inc_fhr"))
;fhrs = ispan(fhr_min,fhr_max,inc_fhr)
;fhr = stringtointeger(getenv("fhr"))
; st_fhr = sprinti("%0.3i",fhr)
; dir = getenv("dir")+"/"
;infile = getenv("infile")
;fname = addfile(infile+".nc","r")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        

init = getenv("ANAL_DATE")
fcst_run_dir = getenv("FCST_RUN_DIR")
domain = getenv("FCST_DOMAINS")
fcst_range1 = 43
fcst_range2 = 48
fcst_freq  = 01
;fhrs = sprinti("%0.3i",ispan(fcst_range1,fcst_range2,fcst_freq))
fhrs = ispan(fcst_range1,fcst_range2,fcst_freq)
storage = "/glade/scratch/hclin/CONUS/wrfda/postdir/soundings/"+init
system("mkdir -p "+storage)
;dir = "/glade/scratch/hclin/CONUS/wrfda/expdir/start2015060812/ob_ascii/hyb_e50_amsua/fcst_15km/"+init
;dir = "/glade/scratch/hclin/CONUS/wrfda/expdir/rt/fcst_15km/"+init
dir = fcst_run_dir+"/"+init

nfhrs = dimsizes(fhrs)

do f = 0,nfhrs - 1

   fhr = fhrs(f)
   st_fhr = sprinti("%0.3i",fhr)

   ;hcl valid_time_wrf = systemfunc(EXEC+" "+init+" "+fhr+" -w")
   valid_date = advance_cymdh(init, fhr)
   valid_time_wrf = format_date_WRF(valid_date)

   ;hcl fpathname = dir+"wrfout_d02_"+valid_time_wrf
   ;hcl fpathname = dir+"/wrfout_d01_"+valid_time_wrf
   fpathname = dir+"/wrfout_d0"+domain+"_"+valid_time_wrf

   fname = addfile(fpathname+".nc","r")

    tc  = wrf_user_getvar(fname,"tc",-1)         ; T in C
    td  = wrf_user_getvar(fname,"td",-1)         ; dew point temperature
    p   = wrf_user_getvar(fname, "pressure",-1)  ; grid point pressure
    z   = wrf_user_getvar(fname, "z",-1)         ; grid point height
    uvm = wrf_user_getvar(fname,"uvmet",-1)      ; umet and vmet averaged to mass points
  					     ; This is a 4D array where
     					     ; uvm(0,:,:,:) is umet, and
					     ; uvm(1,:,:,:) is vmet, and
					     ; This function rotate winds to earth coord.
     wrf_time = chartostring(fname->Times)
  wrf_IC_time = fname@SIMULATION_START_DATE

    ; extract u and v from uvm array, and turn wind into kts
      u   = uvm(0,:,:,:,:)*1.94386 
      v   = uvm(1,:,:,:,:)*1.94386

   lats_model = fname->XLAT(0,:,:)
   lons_model = fname->XLONG(0,:,:)

if ( domain .eq. 2 ) then
   lats_interp= ndtooned( fname->XLAT(0,0::30,0::30)  )
   lons_interp= ndtooned( fname->XLONG(0,0::30,0::30) )
end if
if ( domain .eq. 1 ) then
   lats_interp= ndtooned( fname->XLAT(0,0::6,0::6)  )
   lons_interp= ndtooned( fname->XLONG(0,0::6,0::6) )
end if
   locs_interp = new( dimsizes(lats_interp),"string",-999999)
   locs_interp = ""

   ndimensions = dimsizes(tc)
   nmodlevs = ndimensions(1)

; Get stations info
; Stations, and their lat/lon locations

 locs_raobs = (/ "DNR - Denver", "DDC - Dodge City", "LBF - North Platte", \
              "GJT - Grand Junction", "RIW - Riverton", "UNR - Rapid City", \
              "ABR - Aberdeen", "BIS - Bismark", "MPX - Minneapolis", \
              "OAX - Omaha", "DVN - Davenport", "TOP - Topeka", \
              "ILX - Lincoln", "ILN - Wilmington", "SGF - Springfield", \
              "BNA - Nashville", "OUN - Norman", "AMA - Amarillo", \
              "ABQ - Albuquerque", "EPZ - El Paso", "MAF - Midland", \
              "DRT - Del Rio", "FWD - Fort Worth", "SHV - Shreveport", \
              "LZK - Little Rock", "LCH - Lake Charles", "STL - Slidell",\
              "BMX - Birmingham", "GRB - Green Bay", "CRP - Corpus Christi", \
              "JAN - Jackson", "TFX - Great Falls", "SLC - Salt Lake City", \
              "FGZ - Flagstaff", "TWC - Tucson", "BRO - Brownsville", \
              "VEF - Las Vegas", "REV - Reno", "LKN - Elko", \
              "GGW - Glasgow", "NKX - San Deigo", "VBG - Vandenberg AFB", \
              "OAK - Oakland", "MFR - Medford", "SLE - Salem", \
              "UIL - Quillayute", "OTX - Spokane", "LMN - Lamont", \
              "INL - International Falls", "DTX - White Lake", "APX - Gaylord", \
              "FFC - Peachtree", "KEY - Key West", "MFL - Miami", \
              "TBW - Tampa", "TLH - Tallahassee", "JAX - Jacksonville" , \ 
              "CHS - Charleston", "MHX - Newport", "GSO - Greensboro" , \
              "RNK - Blacksburg", "IAD - Sterling", "PIT - Pittsburgh" , \
              "APG - Aberdeen", "WAL - Wallops Island", "OKX - Upton", \ 
              "BUF - Buffalo", "ALB - Albany", "CHH - Chatham" , \
              "GYX - Grey", "CAR - Caribou", \
              "MCU - Chihuahua", "WLW - Kelowna", "WMW - Maniwaki", \ 
              "BOI - Boise", "PHX - Phoenix" /)

 lats_raobs = (/   39.75,   37.77,   41.13, \
                39.12,   43.07,   44.07, \
                45.45,   46.77,   44.85, \
                41.32,   41.62,   39.07, \
                40.15,   39.43,   37.23, \
                36.12,   35.25,   35.22, \
                35.05,   31.87,   31.95, \
                29.37,   32.82,   32.45, \
                34.83,   30.13,   30.33, \
                33.17,   44.48,   27.77, \
                32.32,   47.47,   40.78, \
                35.23,   32.23,   25.91, \
                36.05,   39.56,   40.86, \
                48.21,   32.85,   34.75, \
                37.73,   42.36,   44.91, \
                47.95,   47.68,   36.62, \
                48.56,   42.70,   44.91, \
                33.36,   24.55,   25.75, \
                27.70,   30.45,   30.50, \ 
                32.90,   34.78,   36.08, \
                37.20,   38.98,   40.53, \
                39.47,   37.93,   40.87, \
                42.93,   42.69,   41.66, \ 
                43.90,   46.86,          \
                28.67,   49.94,   46.30, \
                43.34,   33.43 /)
                


 lons_raobs = (/ -104.87,  -99.97,  -100.68, \
              -108.52, -108.47,  -103.20, \
               -98.42, -100.75,   -93.57, \
               -96.37,  -90.58,   -95.63, \
               -89.33,  -83.80,   -93.38, \
               -86.68,  -97.47,  -101.72, \
              -106.62, -106.70,  -102.20, \
              -100.92,  -97.28,   -93.83, \
               -92.27,  -93.22,   -89.83, \
               -86.77,  -88.13,   -97.50, \
               -90.08,  -111.38, -111.97, \
              -111.82,  -110.95,  -97.41, \
              -115.18,  -119.80, -115.73, \
              -106.61,  -117.12, -120.56, \
              -122.21,  -122.86, -123.00, \
              -124.55,  -117.63,  -97.48, \
               -93.40,   -83.46,  -84.71, \
               -84.57,   -81.79,  -80.38, \
               -82.40,   -84.30,  -81.70, \ 
               -80.03,   -76.88,  -79.95, \
               -80.41,   -77.46,  -80.22, \
               -76.07,   -75.47,  -72.86, \
               -78.73,   -73.83,  -69.96, \
               -70.25,   -68.01,          \
              -106.02,  -119.40,  -76.01, \
              -116.13,  -112.00  /)
               

 ip_lats = array_append_record(lats_interp,lats_raobs,0)
 ip_lons = array_append_record(lons_interp,lons_raobs,0)
 ip_locs = array_append_record(locs_interp,locs_raobs,0)
 delete(lats_interp) ; No longer needed
 delete(lons_interp) ; No longer needed

 nsta  = dimsizes(ip_locs)

 ip_locs!0 = "stations"
 ip_lats!0 = "stations"
 ip_lons!0 = "stations"

   ip_locs_char = stringtochar(ip_locs)
   char_dims = dimsizes(ip_locs_char)
   nchar_ip = char_dims(1)   ; variable size
   ip_locs_char!0 = "stations"
   ip_locs_char!1 = "nchar_ip"
   nchar_w = 20
   wrf_time_char = stringtochar(wrf_time)
   wrf_times_char  = new((/ndimensions(0),nchar_w/),typeof(wrf_time_char))
   wrf_times_char(0,:) = wrf_time_char
   wrf_times_char!0 = "Time"
   wrf_times_char!1 = "nchar_w"  ; should be 20

;print(ip_locs_char)
;print(wrf_times_char)

; Do the interpolation
tc_sta  = rcm2points(lats_model,lons_model,tc,ip_lats,ip_lons,2)
td_sta  = rcm2points(lats_model,lons_model,td,ip_lats,ip_lons,2)
p_sta  = rcm2points(lats_model,lons_model,p,ip_lats,ip_lons,2)
z_sta  = rcm2points(lats_model,lons_model,z,ip_lats,ip_lons,2)
u_sta  = rcm2points(lats_model,lons_model,u,ip_lats,ip_lons,2)
v_sta  = rcm2points(lats_model,lons_model,v,ip_lats,ip_lons,2)

;;;;;;;;;;;;;;;;;;;;;;;;;
; Create netcdf file 
;;;;;;;;;;;;;;;;;;;;;;;;;
;hcl print("creating netcdf for "+st_mem+" at "+init+"_f"+st_fhr)
print("creating netcdf for "+init+"_f"+st_fhr)

   ;hcl outname = storage+"sound_mem"+st_mem+"_Fhr_"+st_fhr+".nc"     ; Define name of the netCDF file you're creating
   outname = storage+"/sound_wrfda_Fhr_"+st_fhr+".nc"     ; Define name of the netCDF file you're creating
   system("rm -f "+outname)
   fout = addfile(outname,"c")
   setfileoption(fout,"DefineMode",True)   ; Tell NCL you're defining a netCDF file
  ;fileAtt = True                          ; Define global attributes
  ;fileAtt@creation_date = systemfunc("date")
  ;fileattdef(fout,fname)
  ;fileattdef(fout,fileAtt)

   dimNames = (/"Time", "bottom_top", "stations"/)
   dimSizes = (/  -1  ,  nmodlevs,     nsta     /)
   dimUnlim = (/ True ,   False   ,    False    /)

   filedimdef(fout,dimNames,dimSizes,dimUnlim)

   uwind_Att = 0
   uwind_Att@description = "u wind"
   uwind_Att@units = "kts"

   vwind_Att = 0
   vwind_Att@description = "v wind"
   vwind_Att@units = "kts"

   filevardef(fout, "TEMP_MODLEV",     typeof(tc), dimNames(0:2))
   filevardef(fout, "DEWPOINT_MODLEV", typeof(td), dimNames(0:2))
   filevardef(fout, "PRESSURE_MODLEV", typeof(p),  dimNames(0:2))
   filevardef(fout, "HEIGHT_MODLEV",   typeof(z),  dimNames(0:2))
   filevardef(fout, "U_GRID_MODLEV",   typeof(u),  dimNames(0:2))
   filevardef(fout, "V_GRID_MODLEV",   typeof(v),  dimNames(0:2))

   filevarattdef(fout, "TEMP_MODLEV",     tc)  
   filevarattdef(fout, "DEWPOINT_MODLEV", td) 
   filevarattdef(fout, "PRESSURE_MODLEV", p)
   filevarattdef(fout, "HEIGHT_MODLEV",   z)
   filevarattdef(fout, "U_GRID_MODLEV", uwind_Att) 
   filevarattdef(fout, "V_GRID_MODLEV", uwind_Att) 
 
;  setfileoption(fout,"DefineMode",False)
   fout@SIMULATION_START_DATE = stringtochar(wrf_IC_time)

   fout->TEMP_MODLEV     = (/tc_sta/)
   fout->DEWPOINT_MODLEV = (/td_sta/)
   fout->PRESSURE_MODLEV = (/p_sta/)
   fout->HEIGHT_MODLEV   = (/z_sta/)
   fout->U_GRID_MODLEV   = (/u_sta/)
   fout->V_GRID_MODLEV   = (/v_sta/)

  printVarSummary(fout)


;  setfileoption(fout,"DefineMode",True)
   moredimNames = (/ "nchar_ip", "nchar_w"/)  
   moredimSizes = (/ nchar_ip, nchar_w /) 
   moredimUnlim = (/  False, False/)
   filedimdef(fout,moredimNames,moredimSizes,moredimUnlim)
   filevardef(fout, "Times" ,typeof(wrf_times_char),getvardims(wrf_times_char)) 
   filevardef(fout, "stn" ,typeof(ip_locs_char),getvardims(ip_locs_char)) 
   filevardef(fout, "lat" ,typeof(ip_lats),getvardims(ip_lats)) 
   filevardef(fout, "lon" ,typeof(ip_lons),getvardims(ip_lons)) 
   filevarattdef(fout,"Times",wrf_times_char)
   setfileoption(fout,"DefineMode",False)
   fout->stn =  (/ip_locs_char/)
   fout->lat =  (/ip_lats/)
   fout->lon =  (/ip_lons/)
   fout->Times = (/wrf_times_char/)

   delete(ip_lats)
   delete(ip_lons)
   delete(ip_locs)
   delete(wrf_times_char)

end do ; fhr loop

system("date")
;system("touch -f sound_done."+fhr)
end

