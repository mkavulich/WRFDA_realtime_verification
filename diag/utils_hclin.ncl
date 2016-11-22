;
; Author: Hui-Chuan Lin   MMM/NESL/NCAR
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

undef("change_date")
function change_date(ccyy:integer, mm:integer, dd:integer, delta:integer)
local mmday, newday
begin

   mmday = (/31,28,31,30,31,30,31,31,30,31,30,31/)
   if ( isleapyear(ccyy) ) then
      mmday(1) = 29
   end if
   dd = dd + delta
   if ( dd .eq. 0 ) then
      mm = mm - 1
      if ( mm .eq. 0 ) then
         mm = 12
         ccyy = ccyy - 1
      end if
      dd = mmday(mm-1)
   else
      if ( dd .gt. mmday(mm-1) ) then
         dd = 1
         mm = mm + 1
         if ( mm .gt. 12 ) then
            mm = 1
            ccyy = ccyy + 1
         end if
      end if
   end if
   newday = ccyy*10000 + mm*100 + dd
   ; newday = sprinti("%0.4i",ccyy)+sprinti("%0.2i",mm)+sprinti("%0.2i",dd)
   return(newday)

end 

undef("advance_cymdh")
function advance_cymdh(currentdatestr:string, dh:integer)
local ccyy, mm, dd, hh, newday, newdatestr
begin

   currentdate = stringtochar(currentdatestr)
   ccyy = stringtointeger((/currentdate(0:3)/))
   mm   = stringtointeger((/currentdate(4:5)/))
   dd   = stringtointeger((/currentdate(6:7)/))
   hh   = stringtointeger((/currentdate(8:9)/))
   hh = hh + dh
   newday = ccyy*10000 + mm*100 + dd
   ; newday = sprinti("%0.4i",ccyy)+sprinti("%0.2i",mm)+sprinti("%0.2i",dd)
   do while (hh .lt. 0)
      hh = hh + 24
      newday = change_date( ccyy, mm, dd, -1 )
   end do
   do while (hh .gt. 23)
      hh = hh - 24
      newday = change_date( ccyy, mm, dd, 1 )
   end do
   ;   newdate = newday*100 + hh
   newdatestr = sprinti("%0.8i",newday) + sprinti("%0.2i",hh)
   return(newdatestr)

end

undef("get_dates_ccyymmddhh")
function get_dates_ccyymmddhh(start_date:string, end_date:string, cycle_period:integer)
local ntime, valid_date, cdate, date
begin
   ntime = 0
   valid_date = start_date
   do while ( valid_date .le. end_date )
      ntime = ntime + 1
      valid_date = advance_cymdh(valid_date,cycle_period)
   end do
   date = new(ntime,string)
   date(0) = start_date
   do i = 1, ntime-1
      date(i) = advance_cymdh(date(i-1),cycle_period)
   end do
   return(date)
end

undef("get_dates_mmddhh")
function get_dates_mmddhh(start_date:string, end_date:string, cycle_period:integer)
local ntime, valid_date, cdate, date, mmddhh
begin
   ntime = 0
   valid_date = start_date
   do while ( valid_date .le. end_date )
      ntime = ntime + 1
      valid_date = advance_cymdh(valid_date,cycle_period)
   end do
   date = new(ntime,string)
   mmddhh = new(ntime,string)
   date(0) = start_date
   cdate = stringtochar(date(0))
   mmddhh(0) = chartostring(cdate(4:9))
   do i = 1, ntime-1
      date(i) = advance_cymdh(date(i-1),cycle_period)
      cdate = stringtochar(date(i))
      mmddhh(i) = chartostring(cdate(4:9))
   end do
   return(mmddhh)
end

undef("format_date_WRF")
function format_date_WRF(date:string)
local nchar, year, month, day, hour, minute, sec
begin
   ; date ccyymmddhh
   ; date ccyymmddhhmnss
   ; date_out ccyy-mm-dd_hh:mi:ss:00

   ndim = dimsizes(date)

   cdate = stringtochar(date)
   nchar = dimsizes(cdate)
   
   if ( dimsizes(nchar) .eq. 2 ) then
      if ( nchar(1) .ge. 10 ) then
         year   = stringtointeger(chartostring(cdate(:,0:3)))
         month  = stringtointeger(chartostring(cdate(:,4:5)))
         day    = stringtointeger(chartostring(cdate(:,6:7)))
         hour   = stringtointeger(chartostring(cdate(:,8:9)))
         if ( nchar(1) .ge. 14 ) then
            minute = stringtointeger(chartostring(cdate(:,10:11)))
            sec    = stringtointeger(chartostring(cdate(:,12:13)))
         else
            minute = 0
            sec    = 0
         end if
      end if
   else
      if ( nchar .ge. 10 ) then
         year   = stringtointeger(chartostring(cdate(0:3)))
         month  = stringtointeger(chartostring(cdate(4:5)))
         day    = stringtointeger(chartostring(cdate(6:7)))
         hour   = stringtointeger(chartostring(cdate(8:9)))
         if ( nchar .ge. 14 ) then
            minute = stringtointeger(chartostring(cdate(10:11)))
            sec    = stringtointeger(chartostring(cdate(12:13)))
         else
            minute = 0
            sec    = 0
         end if
       end if
   end if
   date_out  = year+"-" \
               +sprinti("%0.2i",month) +"-" \
               +sprinti("%0.2i",day)   +"_" \
               +sprinti("%0.2i",hour)  +":" \
               +sprinti("%0.2i",minute)+":" \
               +sprinti("%0.2i",sec)
   return(date_out)
end

undef("format_date_udunits")
function format_date_udunits(date:string)
local nchar, year, month, day, hour, minute, sec
begin
   ; date ccyymmddhh
   ; date ccyymmddhhmnss
   ; date_out ccyy-mm-dd_hh:mi:ss:00

   ndim = dimsizes(date)

   cdate = stringtochar(date)
   nchar = dimsizes(cdate)
   
   if ( dimsizes(nchar) .eq. 2 ) then
      if ( nchar(1) .ge. 10 ) then
         year   = stringtointeger(chartostring(cdate(:,0:3)))
         month  = stringtointeger(chartostring(cdate(:,4:5)))
         day    = stringtointeger(chartostring(cdate(:,6:7)))
         hour   = stringtointeger(chartostring(cdate(:,8:9)))
         if ( nchar(1) .ge. 14 ) then
            minute = stringtointeger(chartostring(cdate(:,10:11)))
            sec    = stringtointeger(chartostring(cdate(:,12:13)))
         else
            minute = 0
            sec    = 0
         end if
      end if
   else
      if ( nchar .ge. 10 ) then
         year   = stringtointeger(chartostring(cdate(0:3)))
         month  = stringtointeger(chartostring(cdate(4:5)))
         day    = stringtointeger(chartostring(cdate(6:7)))
         hour   = stringtointeger(chartostring(cdate(8:9)))
         if ( nchar .ge. 14 ) then
            minute = stringtointeger(chartostring(cdate(10:11)))
            sec    = stringtointeger(chartostring(cdate(12:13)))
         else
            minute = 0
            sec    = 0
         end if
       end if
   end if
   date_out  = year+"-" \
               +sprinti("%0.2i",month) +"-" \
               +sprinti("%0.2i",day)   +" " \
               +sprinti("%0.2i",hour)  +":" \
               +sprinti("%0.2i",minute)+":" \
               +sprinti("%0.2i",sec)
   return(date_out)
end

undef("get_month_name")
function get_month_name(mm:string)
local ndim,n,i,month
begin
   ndim = dimsizes(mm)
   if ( ndim .eq. 1 ) then
      if ( mm.eq."01" ) then
         month = "Jan"
      end if
      if ( mm.eq."02" ) then
         month = "Feb"
      end if
      if ( mm.eq."03" ) then
         month = "Mar"
      end if
      if ( mm.eq."04" ) then
         month = "Apr"
      end if
      if ( mm.eq."05" ) then
         month = "May"
      end if
      if ( mm.eq."06" ) then
         month = "JUN"
      end if
      if ( mm.eq."07" ) then
         month = "JUL"
      end if
      if ( mm.eq."08" ) then
         month = "AUG"
      end if
      if ( mm.eq."09" ) then
         month = "SEP"
      end if
      if ( mm.eq."10" ) then
         month = "OCT"
      end if
      if ( mm.eq."11" ) then
         month = "NOV"
      end if
      if ( mm.eq."12" ) then
         month = "DEC"
      end if
   end if
   if ( ndim .gt. 1 ) then
      month = new(ndim,"string")
      do i = 0, ndim-1
         if ( mm(i).eq."01" ) then
            month(i) = "JAN"
         end if
         if ( mm(i).eq."02" ) then
            month(i) = "FEB"
         end if
         if ( mm(i).eq."03" ) then
            month(i) = "MAR"
         end if
         if ( mm(i).eq."04" ) then
            month(i) = "APR"
         end if
         if ( mm(i).eq."05" ) then
            month(i) = "MAY"
         end if
         if ( mm(i).eq."06" ) then
            month(i) = "Jun"
         end if
         if ( mm(i).eq."07" ) then
            month(i) = "Jul"
         end if
         if ( mm(i).eq."08" ) then
            month(i) = "Aug"
         end if
         if ( mm(i).eq."09" ) then
            month(i) = "Sep"
         end if
         if ( mm(i).eq."10" ) then
            month(i) = "Oct"
         end if
         if ( mm(i).eq."11" ) then
            month(i) = "Nov"
         end if
         if ( mm(i).eq."12" ) then
            month(i) = "Dec"
         end if
      end do
   end if
   return(month)
end

undef("julianday")
function julianday(datestr:string)
local cdate, strlen, method, mmday, ccyy, mm, dd, ddd, jdtmp
begin
   cdate = stringtochar(datestr)
   slen = dimsizes(cdate)-1
   if ( slen .eq. 8 ) then
      method = 1  ; ccyymmdd to ccyyddd
   end if
   if ( slen .eq. 7 ) then
      method = 2  ; ccyyddd to ccyymmdd
   end if

   mmday = (/31,28,31,30,31,30,31,31,30,31,30,31/)

   ccyy = stringtoint(chartostring(cdate(0:3)))
   if ( mod(ccyy,4) .eq. 0 ) then
      mmday(2) = 29
      if ( mod(ccyy,100) .eq. 0 ) then
         mmday(2) = 28
      end if
      if ( mod(ccyy,400) .eq. 0 ) then
         mmday(2) = 29
      end if
   end if

   if ( method .eq. 1 ) then
      mm   = stringtoint(chartostring(cdate(4:5)))
      dd   = stringtoint(chartostring(cdate(6:7)))
      jd = 0
      do i = 0, mm-2
         jd = jd + mmday(i)
      end do
      jd = jd + dd
      date = sprinti("%0.4i", ccyy)+sprinti("%0.3i", jd)
    end if

    if ( method .eq. 2 ) then
       ddd   = stringtoint(chartostring(cdate(4:6)))
       jdtmp = 0
       do i = 0, 11
          jdtmp = jdtmp + mmday(i)
          if ( ddd .le. jdtmp ) then
             mm = i+1
             dd = ddd - ( jdtmp - mmday(i) )
             break
          end if
       end do

       date = sprinti("%0.4i", ccyy)+sprinti("%0.2i", mm)+sprinti("%0.2i", dd)
    end if
    return(date)
end

undef ("get_mapinfo")
function get_mapinfo(fname:string)
local wrf_file, dsizes, nx, ny, xlat, xlon
begin
   if ( isfilepresent(fname) ) then
      opts = True
      wrf_file=addfile(fname+".nc","r")
      if ( wrf_file@MAP_PROJ .eq. 1 ) then
         opts@mapproj = "LambertConformal"
         opts@truelat1 = wrf_file@TRUELAT1
         opts@truelat2 = wrf_file@TRUELAT2
         opts@clon     = wrf_file@STAND_LON
      end if
      if ( wrf_file@MAP_PROJ .eq. 2 ) then
         opts@mapproj = "Stereographic"
         opts@truelat1 = wrf_file@TRUELAT1
         opts@truelat2 = wrf_file@TRUELAT2
         opts@clon     = wrf_file@CEN_LON
         opts@clat     = wrf_file@CEN_LAT
      end if
      if ( wrf_file@MAP_PROJ .eq. 3 ) then
         opts@mapproj = "Mercator"
      end if
      dsizes = getfiledimsizes(wrf_file)
      nx = dsizes(2)
      ny = dsizes(3)
      xlat=wrf_file->XLAT
      xlon=wrf_file->XLONG
      opts@lat_ll  = xlat(0,0,0)
      opts@lat_ur  = xlat(0,ny-1,nx-1)
      opts@lon_ll  = xlon(0,0,0)
      opts@lon_ur  = xlon(0,ny-1,nx-1)
      opts@nx = nx
      opts@ny = ny
   else
      print("INFO: no first guess found for retrieving mapping info")
      opts = False
   end if
   return (opts)
end  ; end function get_mapinfo

undef("set_mpres")
function set_mpres(title:string, str1:string, str2:string, opts:logical)
begin
   mpres                         = True
   mpres@gsnPaperOrientation     = "portrait"
   mpres@gsnMaximize             = False            ; Maximize plot in frame.
   mpres@gsnDraw                 = False
   mpres@gsnFrame                = False            ; Don't advance the frame

   mpres@mpProjection            = opts@mapproj          ; choose projection
   if ( opts@mapproj .eq. "LambertConformal" ) then
      mpres@mpLambertParallel1F     = opts@truelat1      ; two parallels
      mpres@mpLambertParallel2F     = opts@truelat2
      mpres@mpLambertMeridianF      = opts@clon          ; central meridian
   end if
   if ( opts@mapproj .eq. "Stereographic" ) then
      mpres@mpCenterLatF         = opts@clat
      mpres@mpCenterLonF         = opts@clon
   end if
   mpres@mpLimitMode             = "Corners"
   mpres@mpLeftCornerLatF        = opts@lat_ll
   mpres@mpLeftCornerLonF        = opts@lon_ll
   mpres@mpRightCornerLatF       = opts@lat_ur
   mpres@mpRightCornerLonF       = opts@lon_ur

   mpres@pmTickMarkDisplayMode   = "Always"
   ; mpres@tmYROn                  = False
   ; mpres@tmXBOn                  = False
   mpres@tmXTMajorLengthF        = 0
   mpres@tmYLMajorLengthF        = 0
   mpres@tmXBMajorLengthF        = 0
   mpres@tmYRMajorLengthF        = 0
   mpres@mpOutlineBoundarySets   = "GeophysicalAndUSStates" ; state boundaries
   ;mpres@mpOutlineBoundarySets   = "AllBoundaries" ; state boundaries
   mpres@mpFillOn = False
   ;mpres@mpFillOn = True
   ;mpres@mpLandFillColor = "gray"
   ;mpres@tfDoNDCOverlay          = False
   mpres@tfDoNDCOverlay          = True
   mpres@mpUSStateLineColor      = "black"
   mpres@mpNationalLineColor     = "black"
   mpres@mpGeophysicalLineColor  = "black"
   mpres@mpGridAndLimbOn         = True
   mpres@mpGridSpacingF          = 10.0
   mpres@mpGridLineDashPattern   = 2
   mpres@mpGridLineDashSegLenF   = 0.06            ; default 0.15
   mpres@mpGridLineColor         = "white"
   mpres@mpGeophysicalLineThicknessF = 2.0
   mpres@mpNationalLineThicknessF = 3.0
   mpres@mpUSStateLineThicknessF = 1.0

   mpres@mpDataBaseVersion       = "MediumRes"
   mpres@mpDataSetName           = "Earth..4 "

   ; gsn resources:
   mpres@gsnStringFontHeightF    = 0.015
   mpres@gsnLeftString           = str1         ; add left string
   mpres@gsnRightString          = str2         ; add right string

   ; Title resources:
   mpres@tiMainString            = title
   mpres@tiMainOffsetYF          = 0.0             ; Move the title down.
   mpres@tiMainFontHeightF       = 0.015

   return(mpres)
end  ; end function set_mpres

undef("get_xb_labels")
function get_xb_labels(start_date:string, end_date:string, cycle_period:integer)
local dates, ntime, xc, date_char, dd, ddhh, mmddhh
begin
   dates = get_dates_ccyymmddhh(start_date, end_date, cycle_period)
   ntime = dimsizes(dates)
   xc = ispan(1,ntime,1)   ; set the x-axis values for statistics time-series plot

   if ( ntime .gt. 1 ) then
      date_char = stringtochar(dates)  ; (/ntime, 10/)
      hh = chartostring(date_char(:,8:9))
      ddhh = chartostring(date_char(:,6:9))
      mmddhh = chartostring(date_char(:,4:9))
      if ( mod(cycle_period,12) .eq. 0 ) then
         hh_plot = chartostring(date_char(0,8:9))
      else
         hh_plot = "00"
      end if
      index_01h = ind(hh.eq.hh_plot)
      index_01d = ind(ddhh.eq."01"+hh_plot)
      index_01y = ind(mmddhh.eq."0101"+hh_plot)
      if ( dimsizes(index_01d) .le. 2 ) then
         xb_labels = chartostring(date_char(index_01h,6:7))
         ;xb_labels = get_month_name(chartostring(date_char(index_01h,4:5)))+"~C~ "+chartostring(date_char(index_01h,6:7))
         ;xb_labels = get_month_name(chartostring(date_char(index_01h,4:5)))+chartostring(date_char(index_01h,6:7))
         xb_values = xc(index_01h)
      else
         if ( dimsizes(index_01y) .le. 2 ) then
            xb_labels = get_month_name(chartostring(date_char(index_01d,4:5)))
            xb_values = xc(index_01d)
         else
            xb_labels = chartostring(date_char(index_01y,0:3))
            xb_values = xc(index_01y)
         end if
      end if
   else
      xb_labels = -999
   end if
   return(xb_labels)
end ; function get_xb_labels

undef("get_xb_values")
function get_xb_values(start_date:string, end_date:string, cycle_period:integer)
local dates, ntime, xc, date_char, dd, ddhh, mmddhh
begin
   dates = get_dates_ccyymmddhh(start_date, end_date, cycle_period)
   ntime = dimsizes(dates)
   xc = ispan(1,ntime,1)   ; set the x-axis values for statistics time-series plot
   if ( ntime .gt. 1 ) then
      date_char = stringtochar(dates)  ; (/ntime, 10/)
      hh = chartostring(date_char(:,8:9))
      ddhh = chartostring(date_char(:,6:9))
      mmddhh = chartostring(date_char(:,4:9))
      if ( mod(cycle_period,12) .eq. 0 ) then
         hh_plot = chartostring(date_char(0,8:9))
      else
         hh_plot = "00"
      end if
      index_01h = ind(hh.eq.hh_plot)
      index_01d = ind(ddhh.eq."01"+hh_plot)
      index_01y = ind(mmddhh.eq."0101"+hh_plot)
      if ( dimsizes(index_01d) .le. 2 ) then
         xb_labels = chartostring(date_char(index_01h,6:7))
         xb_values = xc(index_01h)
      else
         if ( dimsizes(index_01y) .le. 2 ) then
            xb_labels = chartostring(date_char(index_01d,4:5))
            xb_values = xc(index_01d)
         else
            xb_labels = chartostring(date_char(index_01y,0:3))
            xb_values = xc(index_01y)
         end if
      end if
   else
      xb_values = -999
   end if
   return(xb_values)
end ; function get_xb_values
