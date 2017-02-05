;
; Author: Hui-Chuan Lin   MMM/NCAR
;
; Purpose: plot the distribution of observations contained in obsproc output
;          i.e. WRF-Var ob input (ob.ascii).
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$BIN_DIR/advance_cymdh.ncl"

;***********************************************************************
; user-defined settings
;***********************************************************************
;start_date = "2015072718"
;end_date = "2015072718"
start_date = getenv("ANAL_DATE")
end_date   = getenv("ANAL_DATE")
cycle_period = 06
data_dir_top = getenv("DA_RUN_DIR_TOP")

;obfiles = "/fs/lustre/hclin/nc4_south/var3d_rad_glb_freez/2008080200/var/filtered_obs_01"
;fgfile = "/glade/scratch/hclin/CONUS/wrfda/expdir/start2015060812/ob_ascii/hyb_e50_amsua/2015060900/fg"
fgfile = "$data_dir_top/$start_date/fg"
out_type = "pdf"
;ob_format = 1
ob_format = 2
;data_dir_top = "/glade/scratch/hclin/CONUS/wrfda/expdir/start2015060812/ob_ascii/hyb_e50_amsua"
;data_dir_top = "/glade/scratch/hclin/CONUS/wrfda/expdir/start2015112400/hyb_ens75"
;plot_dir_top = "/glade/scratch/hclin/CONUS/wrfda/diagdir/rt"
;plotname = "./obsloc"+date
;limit_domain = True
limit_domain = False
lat_bound = -30.0
plot_overlay = True
;plot_overlay = False
color_synop = 135 ;5
color_metar = 170 ;15
color_aws   = 165
color_ship  = 25
color_buoy  = 35
color_satem = 45
color_satob = 60
color_satob_modis = 55
color_satob_avhrr = 40
color_satob_polar = 55
color_gpspw = 115 ;65
color_sound = 185 ;75 ;"red"  ;75
color_airep = 85
color_pilot = 85
color_profl = 105
color_qscat = 115
color_bogus = 125
color_airsr = 135
color_gpsrf = 145 ;"navy"  ;145
proc_synop = True
proc_metar = True
proc_aws   = True
proc_ship  = True
proc_buoy  = True
proc_satem = True
proc_satob = True
proc_satob_modis = True
proc_satob_avhrr = True
proc_satob_polar = True
proc_gpspw = True
proc_sound = True
proc_airep = True
proc_pilot = True
proc_profl = True
proc_qscat = True
proc_bogus = True
proc_airsr = True
proc_gpsrf = True
;proc_synop = False
;proc_metar = False
;proc_aws   = False
;proc_ship  = False
;proc_buoy  = False
;proc_satem = False
;proc_satob = False
;proc_satob_modis = False
;proc_satob_avhrr = False
;proc_satob_polar = False
;proc_gpspw = False
;proc_sound = False
;proc_airep = False
;proc_pilot = False
;proc_profl = False
;proc_qscat = False
;proc_bogus = False
;proc_airsr = False
;proc_gpsrf = False
;***********************************************************************
; end of user-defined settings
;***********************************************************************

dates  = get_dates_ccyymmddhh(start_date, end_date, cycle_period)
ndate = dimsizes(dates)

colormap = "BkBlAqGrYeOrReViWh200"

if ( isfilepresent(fgfile) ) then
   wrf_file=addfile(fgfile+".nc","r")
   if ( wrf_file@MAP_PROJ .eq. 1 ) then
      mapproj = "LambertConformal"
      truelat1 = wrf_file@TRUELAT1
      truelat2 = wrf_file@TRUELAT2
      clon     = wrf_file@STAND_LON
   end if
   if ( wrf_file@MAP_PROJ .eq. 2 ) then
      mapproj = "Stereographic"
      truelat1 = wrf_file@TRUELAT1
      truelat2 = wrf_file@TRUELAT2
      ;clon     = wrf_file@CEN_LON
      clon     = wrf_file@STAND_LON
      clat     = wrf_file@CEN_LAT
   end if
   if ( wrf_file@MAP_PROJ .eq. 3 ) then
      mapproj = "Mercator"
   end if
   dsizes = getfiledimsizes(wrf_file)
   nx = dsizes(2)
   ny = dsizes(3)
   xlat=wrf_file->XLAT
   xlon=wrf_file->XLONG
   lat_ll  = xlat(0,0,0)
   lat_ur  = xlat(0,ny-1,nx-1)
   lon_ll  = xlon(0,0,0)
   lon_ur  = xlon(0,ny-1,nx-1)
else
   print("Error: no first guess found for retrieving mapping info")
   exit
end if

undef("setmpres")
function setmpres(title:string, str1:string, str2:string)
begin
   mpres                         = True
   mpres@gsnPaperOrientation     = "portrait"
   mpres@gsnMaximize             = False            ; Maximize plot in frame.
   mpres@gsnDraw                 = False
   mpres@gsnFrame                = False            ; Don't advance the frame

   mpres@mpProjection            = mapproj          ; choose projection
   if ( mapproj .eq. "LambertConformal" ) then
      mpres@mpLambertParallel1F     = truelat1      ; two parallels
      mpres@mpLambertParallel2F     = truelat2
      mpres@mpLambertMeridianF      = clon          ; central meridian
   end if
   if ( mapproj .eq. "Stereographic" ) then
      mpres@mpCenterLatF         = clat
      mpres@mpCenterLonF         = clon
   end if
   mpres@mpLimitMode             = "Corners"
   mpres@mpLeftCornerLatF        = lat_ll
   mpres@mpLeftCornerLonF        = lon_ll
   mpres@mpRightCornerLatF       = lat_ur
   mpres@mpRightCornerLonF       = lon_ur

   mpres@pmTickMarkDisplayMode   = "Always"
   mpres@tmYROn                  = False
   mpres@tmXTOn                  = False
   mpres@tmXTMajorLengthF        = 0
   mpres@tmYLMajorLengthF        = 0
   mpres@tmXBMajorLengthF        = 0
   mpres@tmYRMajorLengthF        = 0
   mpres@tmXBLabelFontHeightF    = 0.010
   mpres@tmYLLabelFontHeightF    = 0.010
   mpres@mpOutlineBoundarySets   = "GeophysicalAndUSStates" ; state boundaries
   mpres@mpFillOn = False
   ;mpres@mpFillOn = True
   mpres@mpLandFillColor = "gray"
   mpres@tfDoNDCOverlay          = True

   mpres@mpUSStateLineColor = "black"
   mpres@mpNationalLineColor = "black"
   mpres@mpGeophysicalLineColor  = "black"
   ; mpres@mpGridAndLimbOn         = True
    mpres@mpGridAndLimbOn         = False
   mpres@mpGridLineDashPattern   = 2
   mpres@mpGridLineDashSegLenF   = 0.06            ; default 0.15

   mpres@mpDataBaseVersion       = "MediumRes"

   ; gsn resources:
   mpres@gsnStringFontHeightF    = 0.015
   mpres@gsnLeftString           = str1         ; add left string
   mpres@gsnRightString          = str2         ; add right string

   ; Title resources:
   mpres@tiMainString            = title
   mpres@tiMainOffsetYF          = 0.0             ; Move the title down.
   mpres@tiMainFontHeightF       = 0.015

   return(mpres)
end

begin  ; main script

do idate = 0, ndate-1
   print("Processing "+dates(idate)+"...")
   date_wrf=format_date_WRF(dates(idate))
   obfile_ascii = data_dir_top+"/"+dates(idate)+"/filtered_obs_01"
   plot_dir = plot_dir_top+"/"+dates(idate)
system("mkdir -p "+plot_dir)
   if ( plot_overlay ) then
      plotname = plot_dir+"/obs_locations"
   else
      plotname = plot_dir+"/obsloc"
   end if
   system("rm -f "+plotname+"tmp")
   ;system("sed -n '/^FM/,$p' "+obfiles(idate)+" > "+plotname+"tmp")
   system("sed -n '/^FM/,$p' "+obfile_ascii+" > "+plotname+"tmp")
   obfile = plotname+"tmp"
   data  = asciiread(obfile, -1, "string")    ; -1 means read all rows.
   cdata = stringtochar(data)
   nline = dimsizes(cdata(:,0))
   hdrstr12 = new(nline,"string")
   hdrstr12(:) = chartostring(cdata(:,0:11))
   hdrstr = new(nline,"string")
   hdrstr(:) = chartostring(cdata(:,0:5))
   stinfo = new(nline,"string")
   stinfo(:) = chartostring(cdata(:,155:159))
   olat = new(nline,"float")
   olat(:) = tofloat(chartostring(cdata(:,83:91)))
   olon = new(nline,"float")
   olon(:) = tofloat(chartostring(cdata(:,106:114)))
   nsynop = 0
   nmetar = 0
   naws   = 0
   nship  = 0
   nbuoy  = 0
   nbogus = 0
   nsound = 0
   nairep = 0
   npilot = 0
   nsatem = 0
   nsatob = 0
   nsatob_modis = 0
   nsatob_avhrr = 0
   nsatob_polar = 0
   ngpspw = 0
   ngpsrf = 0
   nqscat = 0
   nprofl = 0
   nairsr = 0

if ( .not. limit_domain ) then
   isynop = ind(hdrstr.eq."FM-12 ")
   imetar = ind(hdrstr12.eq."FM-15 METAR ".or.hdrstr12.eq."FM-16 SPECI ")
   iaws   = ind(hdrstr12.eq."FM-16 AWSSFC")
   iship  = ind(hdrstr.eq."FM-13 ")
   ibuoy  = ind(hdrstr.eq."FM-18 ".or.hdrstr.eq."FM-19 ")
   ibogus = ind(hdrstr.eq."FM-135")
   isound = ind(hdrstr.eq."FM-35 ".or.hdrstr.eq."FM-36 ")
   iairep = ind(hdrstr.eq."FM-42 ".or.hdrstr.eq."FM-97 ".or.hdrstr.eq."FM-96 ")
   ipilot = ind(hdrstr.eq."FM-32 ")
   isatem = ind(hdrstr.eq."FM-86 ")
   ;isatob = ind(hdrstr.eq."FM-88 ")
   if ( ob_format .eq. 1 ) then
      isatob = ind((hdrstr12.eq."FM-88 SATOB ".and. \
                    abs(olat).lt.60.0))
      isatob_polar = ind((hdrstr12.eq."FM-88 SATOB ".and. \
                          abs(olat).ge.60.0))
   end if
   if ( ob_format .eq. 2 ) then
      isatob = ind((hdrstr12.eq."FM-88 SATOB ".and. \
                    stinfo.ne."AVHRR"))
      isatob_modis = ind(hdrstr12.eq."FM-88 MODIS ")
      isatob_avhrr = ind((hdrstr12.eq."FM-88 SATOB ".and. \
                      stinfo.eq."AVHRR"))
   end if
   igpspw = ind(hdrstr.eq."FM-111")
   igpsrf = ind(hdrstr.eq."FM-116")
   iqscat = ind(hdrstr.eq."FM-281")
   iprofl = ind(hdrstr.eq."FM-132")
   iairsr = ind(hdrstr.eq."FM-133")
else
   isynop = ind((hdrstr.eq."FM-12 ".and.olat.lt.lat_bound))
   imetar = ind((hdrstr12.eq."FM-15 METAR ".or.hdrstr12.eq."FM-16 SPECI ").and.olat.lt.lat_bound)
   iaws   = ind((hdrstr12.eq."FM-16 AWSSFC").and.olat.lt.lat_bound)
   iship  = ind((hdrstr.eq."FM-13 ").and.olat.lt.lat_bound)
   ibuoy  = ind((hdrstr.eq."FM-18 ".or.hdrstr.eq."FM-19 ").and.olat.lt.lat_bound)
   ibogus = ind((hdrstr.eq."FM-135").and.olat.lt.lat_bound)
   isound = ind((hdrstr.eq."FM-35 ".or.hdrstr.eq."FM-36 ").and.olat.lt.lat_bound)
   iairep = ind((hdrstr.eq."FM-42 ".or.hdrstr.eq."FM-97 ".or.hdrstr.eq."FM-96 ").and.olat.lt.lat_bound)
   ipilot = ind((hdrstr.eq."FM-32 ").and.olat.lt.lat_bound)
   isatem = ind((hdrstr.eq."FM-86 ").and.olat.lt.lat_bound)
   ;isatob = ind((hdrstr.eq."FM-88 ")
   isatob = ind(((hdrstr12.eq."FM-88 SATOB ".and. \
                 stinfo.ne."AVHRR")).and.olat.lt.lat_bound)
   ;isatob_p = ind((hdrstr12.eq."FM-88 MODIS ".or. \
   ;               (hdrstr12.eq."FM-88 SATOB ".and. \
   ;                stinfo.eq."AVHRR")).and.olat.lt.lat_bound)
   isatob_modis = ind(hdrstr12.eq."FM-88 MODIS ".and.olat.lt.lat_bound)
   isatob_avhrr = ind((hdrstr12.eq."FM-88 SATOB ".and. \
                     stinfo.eq."AVHRR").and.olat.lt.lat_bound)
   igpspw = ind((hdrstr.eq."FM-111").and.olat.lt.lat_bound)
   igpsrf = ind((hdrstr.eq."FM-116").and.olat.lt.lat_bound)
   iqscat = ind((hdrstr.eq."FM-281").and.olat.lt.lat_bound)
   iprofl = ind((hdrstr.eq."FM-132").and.olat.lt.lat_bound)
   iairsr = ind((hdrstr.eq."FM-133").and.olat.lt.lat_bound)
end if

   ; find out the number of each observation type
   nsynop = num(.not.ismissing(isynop))
   nmetar = num(.not.ismissing(imetar))
   naws   = num(.not.ismissing(iaws))
   nship  = num(.not.ismissing(iship))
   nbuoy  = num(.not.ismissing(ibuoy))
   nbogus = num(.not.ismissing(ibogus))
   nsound = num(.not.ismissing(isound))
   nairep = num(.not.ismissing(iairep))
   npilot = num(.not.ismissing(ipilot))
   nsatem = num(.not.ismissing(isatem))
   nsatob = num(.not.ismissing(isatob))
   if ( ob_format .eq. 2 ) then
      nsatob_modis = num(.not.ismissing(isatob_modis))
      nsatob_avhrr = num(.not.ismissing(isatob_avhrr))
   end if
   if ( ob_format .eq. 1 ) then
      nsatob_polar = num(.not.ismissing(isatob_polar))
   end if
   ngpspw = num(.not.ismissing(igpspw))
   ngpsrf = num(.not.ismissing(igpsrf))
   nqscat = num(.not.ismissing(iqscat))
   nprofl = num(.not.ismissing(iprofl))
   nairsr = num(.not.ismissing(iairsr))

   ntype = 0
   if ( proc_synop .and. nsynop .gt. 0 ) then
      synop_lat = new(nsynop, float)
      synop_lon = new(nsynop, float)
      synop_lat = stringtofloat(charactertostring(cdata(isynop,80:91)))
      synop_lon = stringtofloat(charactertostring(cdata(isynop,103:114)))
      ntype = ntype + 1
      typeinfo1 = (/ "synop "+sprinti("%6.0i", nsynop) /)
      color1 = (/ color_synop /)
   end if
   if ( proc_metar .and. nmetar .gt. 0 ) then
      metar_lat = new(nmetar, float)
      metar_lon = new(nmetar, float)
      metar_lat = stringtofloat(charactertostring(cdata(imetar,80:91)))
      metar_lon = stringtofloat(charactertostring(cdata(imetar,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "metar "+sprinti("%6.0i", nmetar) /)
         color1 = (/ color_metar /)
      else
         typeinfo2 = (/ "metar "+sprinti("%6.0i", nmetar) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_metar /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_aws .and. naws .gt. 0 ) then
      aws_lat = new(naws, float)
      aws_lon = new(naws, float)
      aws_lat = stringtofloat(charactertostring(cdata(iaws,80:91)))
      aws_lon = stringtofloat(charactertostring(cdata(iaws,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "aws   "+sprinti("%6.0i", naws) /)
         color1 = (/ color_aws /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "aws   "+sprinti("%6.0i", naws) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_aws /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_ship .and. nship .gt. 0 ) then
      ship_lat  = new(nship,  float)
      ship_lon  = new(nship,  float)
      ship_lat  = stringtofloat(charactertostring(cdata(iship,80:91)))
      ship_lon  = stringtofloat(charactertostring(cdata(iship,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "ship  "+sprinti("%6.0i", nship) /)
         color1 = (/ color_ship /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "ship  "+sprinti("%6.0i", nship) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_ship /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_buoy .and. nbuoy .gt. 0 ) then
      buoy_lat  = new(nbuoy,  float)
      buoy_lon  = new(nbuoy,  float)
      buoy_lat  = stringtofloat(charactertostring(cdata(ibuoy,80:91)))
      buoy_lon  = stringtofloat(charactertostring(cdata(ibuoy,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "buoy  "+sprinti("%6.0i", nbuoy) /)
         color1 = (/ color_buoy /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "buoy  "+sprinti("%6.0i", nbuoy) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_buoy /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_bogus .and. nbogus .gt. 0 ) then
      bogus_lat = new(nbogus, float)
      bogus_lon = new(nbogus, float)
      bogus_lat = stringtofloat(charactertostring(cdata(ibogus,80:91)))
      bogus_lon = stringtofloat(charactertostring(cdata(ibogus,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "bogus "+sprinti("%6.0i", nbogus) /)
         color1 = (/ color_bogus /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "bogus "+sprinti("%6.0i", nbogus) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_bogus /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_sound .and. nsound .gt. 0 ) then
      sound_lat = new(nsound, float)
      sound_lon = new(nsound, float)
      sound_lat = stringtofloat(charactertostring(cdata(isound,80:91)))
      sound_lon = stringtofloat(charactertostring(cdata(isound,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "sound "+sprinti("%6.0i", nsound) /)
         color1 = (/ color_sound /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "sound "+sprinti("%6.0i", nsound) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_sound /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_airep .and. nairep .gt. 0 ) then
      airep_lat = new(nairep, float)
      airep_lon = new(nairep, float)
      airep_lat = stringtofloat(charactertostring(cdata(iairep,80:91)))
      airep_lon = stringtofloat(charactertostring(cdata(iairep,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "airep "+sprinti("%6.0i", nairep) /)
         color1 = (/ color_airep /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "airep "+sprinti("%6.0i", nairep) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_airep /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_pilot .and. npilot .gt. 0 ) then
      pilot_lat = new(npilot, float)
      pilot_lon = new(npilot, float)
      pilot_lat = stringtofloat(charactertostring(cdata(ipilot,80:91)))
      pilot_lon = stringtofloat(charactertostring(cdata(ipilot,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "pilot "+sprinti("%6.0i", npilot) /)
         color1 = (/ color_pilot /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "pilot "+sprinti("%6.0i", npilot) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_pilot /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_satem .and. nsatem .gt. 0 ) then
      satem_lat = new(nsatem, float)
      satem_lon = new(nsatem, float)
      satem_lat = stringtofloat(charactertostring(cdata(isatem,80:91)))
      satem_lon = stringtofloat(charactertostring(cdata(isatem,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "satem "+sprinti("%6.0i", nsatem) /)
         color1 = (/ color_satem /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "satem "+sprinti("%6.0i", nsatem) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_satem /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_satob .and. nsatob .gt. 0 ) then
      satob_lat = new(nsatob, float)
      satob_lon = new(nsatob, float)
      satob_lat = stringtofloat(charactertostring(cdata(isatob,80:91)))
      satob_lon = stringtofloat(charactertostring(cdata(isatob,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "satob "+sprinti("%6.0i", nsatob) /)
         color1 = (/ color_satob /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "satob "+sprinti("%6.0i", nsatob) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_satob /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( ob_format .eq. 2 ) then
      if ( proc_satob_modis .and. nsatob_modis .gt. 0 ) then
         satob_modis_lat = new(nsatob_modis, float)
         satob_modis_lon = new(nsatob_modis, float)
         satob_modis_lat = stringtofloat(charactertostring(cdata(isatob_modis,80:91)))
         satob_modis_lon = stringtofloat(charactertostring(cdata(isatob_modis,103:114)))
         ntype = ntype + 1
         if ( ntype .eq. 1 ) then
            typeinfo1 = (/ "satob_modis "+sprinti("%6.0i", nsatob_modis) /)
            color1 = (/ color_satob_modis /)
         else
            if ( ntype .gt. 2 ) then
               delete(typeinfo)
               delete(colors)
            end if
            typeinfo2 = (/ "satob_modis "+sprinti("%6.0i", nsatob_modis) /)
            typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
            delete(typeinfo1)
            typeinfo1 = typeinfo
            color2 = (/ color_satob_modis /)
            colors = array_append_record (color1, color2, 0)
            delete(color1)
            color1 = colors
         end if
      end if
      if ( proc_satob_avhrr .and. nsatob_avhrr .gt. 0 ) then
         satob_avhrr_lat = new(nsatob_avhrr, float)
         satob_avhrr_lon = new(nsatob_avhrr, float)
         satob_avhrr_lat = stringtofloat(charactertostring(cdata(isatob_avhrr,80:91)))
         satob_avhrr_lon = stringtofloat(charactertostring(cdata(isatob_avhrr,103:114)))
         ntype = ntype + 1
         if ( ntype .eq. 1 ) then
            typeinfo1 = (/ "satob_avhrr "+sprinti("%6.0i", nsatob_avhrr) /)
            color1 = (/ color_satob_avhrr /)
         else
            if ( ntype .gt. 2 ) then
               delete(typeinfo)
               delete(colors)
            end if
            typeinfo2 = (/ "satob_avhrr "+sprinti("%6.0i", nsatob_avhrr) /)
            typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
            delete(typeinfo1)
            typeinfo1 = typeinfo
            color2 = (/ color_satob_avhrr /)
            colors = array_append_record (color1, color2, 0)
            delete(color1)
            color1 = colors
         end if
      end if
   end if
   if ( ob_format .eq. 1 ) then
      if ( proc_satob_polar .and. nsatob_polar .gt. 0 ) then
         satob_polar_lat = new(nsatob_polar, float)
         satob_polar_lon = new(nsatob_polar, float)
         satob_polar_lat = stringtofloat(charactertostring(cdata(isatob_polar,80:91)))
         satob_polar_lon = stringtofloat(charactertostring(cdata(isatob_polar,103:114)))
         ntype = ntype + 1
         if ( ntype .eq. 1 ) then
            typeinfo1 = (/ "satob_polar "+sprinti("%6.0i", nsatob_polar) /)
            color1 = (/ color_satab_polar /)
         else
            if ( ntype .gt. 2 ) then
               delete(typeinfo)
               delete(colors)
            end if
            typeinfo2 = (/ "satob_polar "+sprinti("%6.0i", nsatob_polar) /)
            typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
            delete(typeinfo1)
            typeinfo1 = typeinfo
            color2 = (/ color_satob_polar /)
            colors = array_append_record (color1, color2, 0)
            delete(color1)
            color1 = colors
         end if
      end if
   end if
   if ( proc_gpspw .and. ngpspw .gt. 0 ) then
      gpspw_lat = new(ngpspw, float)
      gpspw_lon = new(ngpspw, float)
      gpspw_lat = stringtofloat(charactertostring(cdata(igpspw,80:91)))
      gpspw_lon = stringtofloat(charactertostring(cdata(igpspw,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "gpspw "+sprinti("%6.0i", ngpspw) /)
         color1 = (/ color_gpspw /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "gpspw "+sprinti("%6.0i", ngpspw) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_gpspw /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_gpsrf .and. ngpsrf .gt. 0 ) then
      gpsrf_lat = new(ngpsrf, float)
      gpsrf_lon = new(ngpsrf, float)
      gpsrf_lat = stringtofloat(charactertostring(cdata(igpsrf,80:91)))
      gpsrf_lon = stringtofloat(charactertostring(cdata(igpsrf,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "gpsrf "+sprinti("%6.0i", ngpsrf) /)
         color1 = (/ color_gpsrf /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "gpsrf "+sprinti("%6.0i", ngpsrf) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_gpsrf /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_qscat .and. nqscat .gt. 0 ) then
      qscat_lat = new(nqscat, float)
      qscat_lon = new(nqscat, float)
      qscat_lat = stringtofloat(charactertostring(cdata(iqscat,80:91)))
      qscat_lon = stringtofloat(charactertostring(cdata(iqscat,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "qscat "+sprinti("%6.0i", nqscat) /)
         color1 = (/ color_qscat /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "qscat "+sprinti("%6.0i", nqscat) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_qscat /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_profl .and. nprofl .gt. 0 ) then
      profl_lat = new(nprofl, float)
      profl_lon = new(nprofl, float)
      profl_lat = stringtofloat(charactertostring(cdata(iprofl,80:91)))
      profl_lon = stringtofloat(charactertostring(cdata(iprofl,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "profl "+sprinti("%6.0i", nprofl) /)
         color1 = (/ color_profl /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "profl "+sprinti("%6.0i", nprofl) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_profl /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if
   if ( proc_airsr .and. nairsr .gt. 0 ) then
      airsr_lat = new(nairsr, float)
      airsr_lon = new(nairsr, float)
      airsr_lat = stringtofloat(charactertostring(cdata(iairsr,80:91)))
      airsr_lon = stringtofloat(charactertostring(cdata(iairsr,103:114)))
      ntype = ntype + 1
      if ( ntype .eq. 1 ) then
         typeinfo1 = (/ "airsr "+sprinti("%6.0i", nairsr) /)
         color1 = (/ color_airsr /)
      else
         if ( ntype .gt. 2 ) then
            delete(typeinfo)
            delete(colors)
         end if
         typeinfo2 = (/ "airsr "+sprinti("%6.0i", nairsr) /)
         typeinfo = array_append_record (typeinfo1, typeinfo2, 0)
         delete(typeinfo1)
         typeinfo1 = typeinfo
         color2 = (/ color_airsr /)
         colors = array_append_record (color1, color2, 0)
         delete(color1)
         color1 = colors
      end if
   end if

   dummy = new(20,"graphic")
   markersized = 0.005
   markersizem1 = max((/0.001, markersized - 0.001 /))
   markersizem2 = max((/0.001, markersized - 0.002 /))
   markersizem3 = max((/0.001, markersized - 0.003 /))
   markersizem4 = max((/0.001, markersized - 0.004 /))
   markersizem5 = max((/0.001, markersized - 0.005 /))
   markersizem6 = max((/0.001, markersized - 0.006 /))
   wks = gsn_open_wks(out_type, plotname)
   gsn_define_colormap(wks,colormap)
   nc1 = NhlNewColor(wks,.8,.8,.8)  ; add light gray to colormap
   gsres = True
   if ( plot_overlay ) then
      mpres = setmpres(dates(idate),"","")
      map = gsn_csm_map(wks,mpres)
   end if
   if ( proc_synop .and. nsynop .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("SYNOP",dates(idate),nsynop+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_synop
      else
         gsres@gsMarkerColor  = color_synop
      end if
      gsres@gsMarkerIndex = 10 ;16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(0) = gsn_add_polymarker(wks,map,synop_lon(:),synop_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_metar .and. nmetar .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("METAR",dates(idate),nmetar+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_metar
      else
         gsres@gsMarkerColor  = color_metar
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersizem2          ; default 0.007
      dummy(1) = gsn_add_polymarker(wks,map,metar_lon(:),metar_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_aws .and. naws .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("AWS",dates(idate),naws+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_aws
      else
         gsres@gsMarkerColor  = color_aws
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(2) = gsn_add_polymarker(wks,map,aws_lon(:),aws_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_ship .and. nship .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("SHIP",dates(idate),nship+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_ship
      else
         gsres@gsMarkerColor  = color_ship
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(3) = gsn_add_polymarker(wks,map,ship_lon(:),ship_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_buoy .and. nbuoy .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("BUOY",dates(idate),nbuoy+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_buoy
      else
         gsres@gsMarkerColor  = color_buoy
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(4) = gsn_add_polymarker(wks,map,buoy_lon(:),buoy_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_bogus .and. nbogus .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("BOGUS",dates(idate),nbogus+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_bogus
      else
         gsres@gsMarkerColor  = color_bogus
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(5) = gsn_add_polymarker(wks,map,bogus_lon(:),bogus_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_sound .and. nsound .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("sound",dates(idate),nsound+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_sound
      else
         gsres@gsMarkerColor  = color_sound
      end if
      gsres@gsMarkerIndex = 12 ;16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(6) = gsn_add_polymarker(wks,map,sound_lon(:),sound_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_airep .and. nairep .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("AIREP",dates(idate),nairep+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_airep
      else
         gsres@gsMarkerColor  = color_airep
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersizem3          ; default 0.007
      dummy(7) = gsn_add_polymarker(wks,map,airep_lon(:),airep_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_pilot .and. npilot .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("PILOT",dates(idate),npilot+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_pilot
      else
         gsres@gsMarkerColor  = color_pilot
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(8) = gsn_add_polymarker(wks,map,pilot_lon(:),pilot_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_satem .and. nsatem .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("SATEM",dates(idate),nsatem+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_satem
      else
         gsres@gsMarkerColor  = color_satem
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(9) = gsn_add_polymarker(wks,map,satem_lon(:),satem_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_satob .and. nsatob .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("GEO AMV",dates(idate),nsatob+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_satob
      else
         gsres@gsMarkerColor  = color_satob
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersizem5          ; default 0.007
      dummy(10) = gsn_add_polymarker(wks,map,satob_lon(:),satob_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( ob_format .eq. 2 ) then
      if ( proc_satob_modis .and. nsatob_modis .gt. 0 ) then
         if ( .not. plot_overlay ) then
            mpres = setmpres("MODIS AMV",dates(idate),nsatob_modis+"")
            map = gsn_csm_map(wks,mpres)
            ;gsres@gsMarkerColor  = "navy"
            gsres@gsMarkerColor  = color_satob_modis
         else
            gsres@gsMarkerColor  = color_satob_modis
         end if
         gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
         gsres@gsMarkerSizeF  = markersizem6          ; default 0.007
         dummy(11) = gsn_add_polymarker(wks,map,satob_modis_lon(:),satob_modis_lat(:),gsres)
         if ( .not. plot_overlay ) then
            draw(map)
            frame(wks)
         end if
      end if
      if ( proc_satob_avhrr .and. nsatob_avhrr .gt. 0 ) then
         if ( .not. plot_overlay ) then
            mpres = setmpres("AVHRR AMV",dates(idate),nsatob_avhrr+"")
            map = gsn_csm_map(wks,mpres)
            ;gsres@gsMarkerColor  = "navy"
            gsres@gsMarkerColor  = color_satob_avhrr
         else
            gsres@gsMarkerColor  = color_satob_avhrr
         end if
         gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
         gsres@gsMarkerSizeF  = markersizem6          ; default 0.007
         dummy(12) = gsn_add_polymarker(wks,map,satob_avhrr_lon(:),satob_avhrr_lat(:),gsres)
         if ( .not. plot_overlay ) then
            draw(map)
            frame(wks)
         end if
      end if
   end if
   if ( ob_format .eq. 1 ) then
      if ( proc_satob_polar .and. nsatob_polar .gt. 0 ) then
         if ( .not. plot_overlay ) then
            mpres = setmpres("POLAR AMV",dates(idate),nsatob_polar+"")
            map = gsn_csm_map(wks,mpres)
            ;gsres@gsMarkerColor  = "navy"
            gsres@gsMarkerColor  = color_satob_polar
         else
            gsres@gsMarkerColor  = color_satob_polar
         end if
         gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
         gsres@gsMarkerSizeF  = markersizem6          ; default 0.007
         dummy(18) = gsn_add_polymarker(wks,map,satob_polar_lon(:),satob_polar_lat(:),gsres)
         if ( .not. plot_overlay ) then
            draw(map)
            frame(wks)
         end if
      end if
   end if
   if ( proc_gpspw .and. ngpspw .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("GPSPW",dates(idate),ngpspw+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_gpspw
      else
         gsres@gsMarkerColor  = color_gpspw
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersizem2          ; default 0.007
      dummy(13) = gsn_add_polymarker(wks,map,gpspw_lon(:),gpspw_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_gpsrf .and. ngpsrf .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("GSPREF",dates(idate),ngpsrf+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_gpsrf
      else
         gsres@gsMarkerColor  = color_gpsrf
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersizem3          ; default 0.007
      dummy(14) = gsn_add_polymarker(wks,map,gpsrf_lon(:),gpsrf_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_qscat .and. nqscat .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("QSCAT",dates(idate),nqscat+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_qscat
      else
         gsres@gsMarkerColor  = color_qscat
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersizem6          ; default 0.007
      dummy(15) = gsn_add_polymarker(wks,map,qscat_lon(:),qscat_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_profl .and. nprofl .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("PROFILER",dates(idate),nprofl+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_profl
      else
         gsres@gsMarkerColor  = color_profl
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(16) = gsn_add_polymarker(wks,map,profl_lon(:),profl_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if
   if ( proc_airsr .and. nairsr .gt. 0 ) then
      if ( .not. plot_overlay ) then
         mpres = setmpres("AIRS Retrieval",dates(idate),nairsr+"")
         map = gsn_csm_map(wks,mpres)
         ;gsres@gsMarkerColor  = "navy"
         gsres@gsMarkerColor  = color_airsr
      else
         gsres@gsMarkerColor  = color_airsr
      end if
      gsres@gsMarkerIndex = 16                    ; Use filled dots for markers.
      gsres@gsMarkerSizeF  = markersized          ; default 0.007
      dummy(17) = gsn_add_polymarker(wks,map,airsr_lon(:),airsr_lat(:),gsres)
      if ( .not. plot_overlay ) then
         draw(map)
         frame(wks)
      end if
   end if

   if ( plot_overlay ) then
      ; add legend for types and counts
      getvalues map
        "vpWidthF"  : vpw
        "vpHeightF" : vph
      end getvalues
      lbres                    = True          ; labelbar only resources
      lbres@lbAutoManage       = True          ; Necessary to control sizes
      lbres@vpWidthF           = vpw*0.35 ;0.2 ;1.2 * 0.7 ; 1.0 * 0.7     ; labelbar width
      lbres@vpHeightF          = vph*1.0 ;0.5 ;0.3 * 0.7 ; 0.2 * 0.7     ; labelbar height
      lbres@lbBoxMajorExtentF  = 0.55          ; puts space between color boxes
      lbres@lbBoxMinorExtentF  = 0.15
      lbres@lbFillColors       = colors        ; labelbar colors
      lbres@lbMonoFillPattern  = True          ; Solid fill pattern
      ;lbres@lbLabelFontHeightF = 0.15 ; 0.07          ; font height. default is small
      lbres@lbLabelJust        = "CenterRight"  ; justify labels
      lbres@lbOrientation      = "Vertical"  ; arrange from left to right in a row
      lbres@lbLabelPosition    = "Right"
      lbres@lbJustification    = "TopRight"
      lbres@lbPerimOn          = False ; True
      lbres@lbLabelFont        = "courier"
      lbid = gsn_create_labelbar(wks,ntype,typeinfo,lbres)
      amres                  = True
      amres@amJust           = "TopRight"
      amres@amParallelPosF   =   0.85
      amres@amOrthogonalPosF =  -0.50 ;0.60
      annoid = gsn_add_annotation(map,lbid,amres)
   end if
   if ( plot_overlay ) then
      draw(map)
      frame(wks)
      delete(typeinfo)
      delete(typeinfo1)
      delete(typeinfo2)
      delete(colors)
      delete(color1)
      delete(color2)
      delete(lbres)
   end if
   system("rm -f "+plotname+"tmp")
   delete(data)
   delete(cdata)
   delete(dummy)
   if ( proc_synop .and. nsynop .gt. 0 ) then
      delete(synop_lat)
      delete(synop_lon)
   end if
   if ( proc_metar .and. nmetar .gt. 0 ) then
      delete(metar_lat)
      delete(metar_lon)
   end if
   if ( proc_aws .and. naws .gt. 0 ) then
      delete(aws_lat)
      delete(aws_lon)
   end if
   if ( proc_ship .and. nship .gt. 0 ) then
      delete(ship_lat)
      delete(ship_lon)
   end if
   if ( proc_profl .and. nprofl .gt. 0 ) then
      delete(profl_lat)
      delete(profl_lon)
   end if
   if ( proc_airsr .and. nairsr .gt. 0 ) then
      delete(airsr_lat)
      delete(airsr_lon)
   end if
   if ( proc_gpspw .and. ngpspw .gt. 0 ) then
      delete(gpspw_lat)
      delete(gpspw_lon)
   end if
   if ( proc_pilot .and. npilot .gt. 0 ) then
      delete(pilot_lat)
      delete(pilot_lon)
   end if
   if ( proc_buoy .and. nbuoy .gt. 0 ) then
      delete(buoy_lat)
      delete(buoy_lon)
   end if
   if ( proc_qscat .and. nqscat .gt. 0 ) then
      delete(qscat_lat)
      delete(qscat_lon)
   end if
   if ( proc_airep .and. nairep .gt. 0 ) then
      delete(airep_lat)
      delete(airep_lon)
   end if
   if ( proc_satem .and. nsatem .gt. 0 ) then
      delete(satem_lat)
      delete(satem_lon)
   end if
   if ( proc_satob .and. nsatob .gt. 0 ) then
      delete(satob_lat)
      delete(satob_lon)
   end if
   if ( ob_format .eq. 2 ) then
      if ( proc_satob_modis .and. nsatob_modis .gt. 0 ) then
         delete(satob_modis_lat)
         delete(satob_modis_lon)
      end if
      if ( proc_satob_avhrr .and. nsatob_avhrr .gt. 0 ) then
         delete(satob_avhrr_lat)
         delete(satob_avhrr_lon)
      end if
   end if
   if ( ob_format .eq. 1 ) then
      if ( proc_satob_polar .and. nsatob_polar .gt. 0 ) then
         delete(satob_polar_lat)
         delete(satob_polar_lon)
      end if
   end if
   if ( proc_bogus .and. nbogus .gt. 0 ) then
      delete(bogus_lat)
      delete(bogus_lon)
   end if
   if ( proc_sound .and. nsound .gt. 0 ) then
      delete(sound_lat)
      delete(sound_lon)
   end if
   if ( proc_gpsrf .and. ngpsrf .gt. 0 ) then
      delete(gpsrf_lat)
      delete(gpsrf_lon)
   end if
   delete(hdrstr)
   delete(hdrstr12)
   delete(stinfo)
   delete(olat)
   delete(olon)
   delete(isynop)
   delete(imetar)
   delete(iaws)
   delete(iship)
   delete(ibuoy)
   delete(ibogus)
   delete(isound)
   delete(iairep)
   delete(ipilot)
   delete(isatem)
   delete(isatob)
   if ( ob_format .eq. 2 ) then
      delete(isatob_modis)
      delete(isatob_avhrr)
   end if
   if ( ob_format .eq. 1 ) then
      delete(isatob_polar)
   end if
   delete(igpspw)
   delete(igpsrf)
   delete(iqscat)
   delete(iprofl)
   delete(iairsr)
   destroy(wks)

system("/usr/bin/convert -trim -density 150x150 "+plot_dir+"/obs_locations.pdf "+plot_dir+"/obs_locations.png")
system("rm -f "+plot_dir+"/obs_locations.pdf")

end do
end
