load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$HOME/bin/advance_cymdh.ncl"

   ;data_dir_top = "/glade/scratch/hclin/CONUS/wrfda/expdir" ;/start2015060812/ob_ascii" ;ccyymmddhh/statistics
   ;exps = (/ "ob_ascii/hybrid_ens75_amsua", "ob_prepb/hybrid_ens75_amsua" /)
   ;expnames = (/ "ob_ascii", "ob_prepb" /)
   ;init_start_date = "2015051300"
   ;init_end_date = "2015053100"
   ;cycle_period = 24

   data_dir_top = "/glade/scratch/hclin/CONUS/wrfda/expdir/start2015060812/ob_ascii" ;ccyymmddhh/statistics
   exps = (/ "hyb_e50_amsua" /)
   expnames = (/ "RT_WRFDA" /)
   ;init_start_date = "2015062712"
   ;init_end_date = "2015072712"
   init_end_date = getenv("ANAL_DATE")
   days_back = 15
   hours_back = -1*24*days_back
   init_start_date = advance_cymdh(init_end_date, hours_back)
   cycle_period = 12

   data_dir = data_dir_top+"/"+exps
   plot_dir_top = "/glade/scratch/hclin/CONUS/wrfda/diagdir/rt"
   plot_dir = plot_dir_top+"/"+init_end_date
system("mkdir -p "+plot_dir)

   ob_types = (/ "sound", "sonde_sfc", "synop", "geoamv", "airep", \
                 "pilot", "metar", "ships", "qscat", "profiler",   \
                 "buoy", "gpsref", "satem", "gpspw" /)
   ;ob_types = (/ "sound", "synop", "gpsref" /)
   ob_vars = (/ "u", "v", "t", "p", "q", "ref", "tpw" /)

   init_dates  = get_dates_ccyymmddhh(init_start_date, init_end_date, cycle_period)  ; initial dates
   num_init_dates = dimsizes(init_dates)
   nexp = dimsizes(exps)
   ntype = dimsizes(ob_types)
   nvar = dimsizes(ob_vars)

   proc_data = True
   ;proc_data = False
   plot_individual = True
   ;plot_group = True
   plot_group = False
   if ( nexp .eq. 1 ) then
      plot_individual = True
      plot_group = False
   end if
   group_exps = (/ "ob_ascii/hybrid_ens75_amsua", "ob_prepb/hybrid_ens75_amsua" /)
   group_legends = (/ "ascii", "prepb" /)
   np = dimsizes(group_exps)

   stats_nc_outname = "statistics.nc"

   if ( proc_data ) then
   uu = new((/nexp, ntype, 2, 3, num_init_dates/), "float")  ; OI/AO, num/ave/rms
   vv = new((/nexp, ntype, 2, 3, num_init_dates/), "float")
   tt = new((/nexp, ntype, 2, 3, num_init_dates/), "float")
   pp = new((/nexp, ntype, 2, 3, num_init_dates/), "float")
   qq = new((/nexp, ntype, 2, 3, num_init_dates/), "float")
   ref = new((/nexp, 2, 3, num_init_dates/), "float")
   tpw = new((/nexp, 2, 3, num_init_dates/), "float")
   fnames = new((/nexp, num_init_dates/), "string")
   do n = 0, nexp-1
      print("Processing "+exps(n)+" ...")
      do i = 0, num_init_dates-1
         print("   Processing "+init_dates(i)+" ...")
         fnames(n,i) = data_dir(n)+"/"+init_dates(i)+"/statistics"
         ;if ( .not. isfilepresent(fnames(n,i)) ) then
         if ( .not. fileexists(fnames(n,i)) ) then ;ncl version 6.2.1 and later
            print("      "+fnames(n,i)+" not found")
            continue
         end if
         ;if ( isfilepresent(fnames(n,i)) ) then
         if ( fileexists(fnames(n,i)) ) then ;ncl version 6.2.1 and later
            do itype = 0, ntype-1
               if ( ob_types(itype) .eq. "gpsref" ) then
                  ref(n,0,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $2}'"))
                  ref(n,0,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $3}'"))
                  ref(n,0,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $3}'"))
                  ref(n,1,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $2}'"))
                  ref(n,1,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $3}'"))
                  ref(n,1,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $3}'"))
               end if   ; for gpsref
               if ( ob_types(itype) .eq. "gpspw" ) then
                  tpw(n,0,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $2}'"))
                  tpw(n,0,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $3}'"))
                  tpw(n,0,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $3}'"))
                  tpw(n,1,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $2}'"))
                  tpw(n,1,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $3}'"))
                  tpw(n,1,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $3}'"))
               end if   ; for gpstpw
               if (  ob_types(itype) .ne. "gpspw"  .and. \
                     ob_types(itype) .ne. "gpsref" .and. \
                     ob_types(itype) .ne. "satem" ) then
                  uu(n,itype,0,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $2}'"))
                  uu(n,itype,0,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $3}'"))
                  uu(n,itype,0,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $3}'"))
                  uu(n,itype,1,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $2}'"))
                  uu(n,itype,1,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $3}'"))
                  uu(n,itype,1,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $3}'"))
                  vv(n,itype,0,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $3}'"))
                  vv(n,itype,0,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $4}'"))
                  vv(n,itype,0,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $4}'"))
                  vv(n,itype,1,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $3}'"))
                  vv(n,itype,1,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $4}'"))
                  vv(n,itype,1,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $4}'"))
               end if  ; for u and v
               if (  ob_types(itype) .eq. "sound"     .or. \
                     ob_types(itype) .eq. "sonde_sfc" .or. \
                     ob_types(itype) .eq. "synop"     .or. \
                     ob_types(itype) .eq. "airep"     .or. \
                     ob_types(itype) .eq. "metar"     .or. \
                     ob_types(itype) .eq. "ships"     .or. \
                     ob_types(itype) .eq. "buoy" ) then
                  tt(n,itype,0,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $4}'"))
                  tt(n,itype,0,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $5}'"))
                  tt(n,itype,0,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $5}'"))
                  tt(n,itype,1,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $4}'"))
                  tt(n,itype,1,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print $5}'"))
                  tt(n,itype,1,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print $5}'"))
               end if
               if (  ob_types(itype) .eq. "sonde_sfc" .or. \
                     ob_types(itype) .eq. "synop"     .or. \
                     ob_types(itype) .eq. "metar"     .or. \
                     ob_types(itype) .eq. "ships"     .or. \
                     ob_types(itype) .eq. "buoy" ) then
                  qq(n,itype,0,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $6}'"))
                  qq(n,itype,0,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print 1000*$7}'"))
                  qq(n,itype,0,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print 1000*$7}'"))
                  qq(n,itype,1,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $6}'"))
                  qq(n,itype,1,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print 1000*$7}'"))
                  qq(n,itype,1,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print 1000*$7}'"))
               end if
               if (  ob_types(itype) .eq. "sound" ) then
                  qq(n,itype,0,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $5}'"))
                  qq(n,itype,0,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print 1000*$6}'"))
                  qq(n,itype,0,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print 1000*$6}'"))
                  qq(n,itype,1,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $5}'"))
                  qq(n,itype,1,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print 1000*$6}'"))
                  qq(n,itype,1,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print 1000*$6}'"))
               end if
               if (  ob_types(itype) .eq. "sonde_sfc" .or. \
                     ob_types(itype) .eq. "synop"     .or. \
                     ob_types(itype) .eq. "metar"     .or. \
                     ob_types(itype) .eq. "ships"     .or. \
                     ob_types(itype) .eq. "buoy" ) then
                  pp(n,itype,0,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $5}'"))
                  pp(n,itype,0,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print 0.01*$6}'"))
                  pp(n,itype,0,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of OI for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print 0.01*$6}'"))
                  pp(n,itype,1,0,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Number | awk '{print $5}'"))
                  pp(n,itype,1,1,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep Average | awk '{print 0.01*$6}'"))
                  pp(n,itype,1,2,i) = stringtofloat(systemfunc("cat "+fnames(n,i)+\
                         "|awk /'Diagnostics of AO for "+ob_types(itype)+"'/,/RMSE/| grep RMSE | awk '{print 0.01*$6}'"))
               end if
            end do
         end if
      end do
   end do

   system("/bin/rm -f "+stats_nc_outname)   ; remove any pre-existing file
   ncdf = addfile(stats_nc_outname ,"c")  ; open output netCDF file

    ; make time and UNLIMITED dimension      ; recommended  for most applications
      ; filedimdef(ncdf,"time",-1,True) 

    ; output variables directly
       ncdf->tpw  = tpw
       ncdf->ref  = ref
       ncdf->uu   = uu
       ncdf->vv   = vv
       ncdf->tt   = tt
       ncdf->qq   = qq
       ncdf->pp   = pp
   else

      ncdf = addfile(stats_nc_outname ,"r")  ; open output netCDF file
      tpw = ncdf->tpw
      ref = ncdf->ref
      uu  = ncdf->uu
      vv  = ncdf->vv
      tt  = ncdf->tt
      qq  = ncdf->qq
      pp  = ncdf->pp
   end if  ; end if proc_data

   print("Plotting...")

   out_type = "pdf"
   xc = ispan(0,num_init_dates-1,1)
   xb_labels = get_xb_labels(init_start_date, init_end_date, cycle_period)
   xb_values = get_xb_values(init_start_date, init_end_date, cycle_period)
   
   colors = (/ "red", "blue", "green", "orange" /)
   
   res                        = True
   res@gsnPaperOrientation    = "portrait"
   res@gsnMaximize            = False               ; Maximize plot in frame.
   res@gsnFrame               = False               ; Don't advance the frame
   res@gsnDraw                = False               
   res@vpXF                   = 0.05                  ; position and sizes
   res@vpYF                   = 0.98                  ; for XY plo
   res@vpHeightF              = 0.30                ; change aspect ratio of plot
   res@vpWidthF               = 0.90                
   res@tmYROn                 = False
   res@tmXTOn                 = False
   res@tmYLMinorOn            = True
   res@tmXBMinorOn            = True
   res@tmYLMajorThicknessF    = 2.5                 ; default 2.0
   res@tmXBMajorThicknessF    = 2.5                 ; default 2.0
   res@xyMarkLineMode         = "MarkLines"         
   res@xyMarkers              = (/ 1, 1, 1, 1 /)
   res@xyMarkerColors         = colors
   res@xyMarkerSizes          = (/ 0.02, 0.02, 0.02, 0.02 /)   ; default 0.01
   res@xyDashPatterns         = (/ 0, 0, 0, 0 /)
   res@xyLineThicknesses      = (/ 2.0, 2.0, 2.0, 2.0 /)      ; default 1.0
   res@xyLineColors           = colors
   res@tmXBFormat             = "f"                            ; not to add trailing zeros
   res@tmXBLabelFont          = 21
   res@tmXBLabelFontHeightF   = 0.020
   ;res@tmXBMinorPerMajor      = 3
   ;res@tmXBTickStartF         = 0
   ;res@tmXBTickEndF           = 192
   ;res@tmXBTickSpacingF       = 24
   res@tmXBMode               = "Explicit"
   res@tmXBLabels             = xb_labels ;(::2)
   res@tmXBValues             = xb_values ;(::2)
   ;res@tmXBMinorValues        = xminor
   ;res@tmYLMode               = "Manual"
   ;res@tmYLMinorPerMajor      = 4
   ;res@tmYLTickStartF         = 0
   ;res@tmYLTickEndF           = 5
   ;res@tmYLTickSpacingF       = 0.5
   ;res@trYMinF                = 0.0
   ; res@trYMaxF                =  3.0
   res@trXMinF                = 0.0
   res@trXMaxF                = num_init_dates-1
   res@pmLegendDisplayMode    = "Always"            ; turn on legend
   res@pmLegendSide           = "Right"             ; Change location of
   res@pmLegendWidthF         = 0.08                 ; Change width and default 0.55
   res@pmLegendHeightF        = 0.08                 ; height of legend. default 0.18
   ;res@pmLegendOrthogonalPosF = -0.55
   ;res@pmLegendParallelPosF   = 0.30  ;(rightward)
   res@lgLabelFontHeightF     = 0.015                ; change font height default 0.02
   ; res@xyExplicitLegendLabels = exps
   ; res@xyExplicitLegendLabels = (/ "OMB", "OMA" /)

   res@tiMainFontHeightF = 0.020
   res@tiXAxisFontHeightF = 0.020
   res@tiYAxisFontHeightF = 0.020
   ;res@tiXAxisString = init_start_date+" - "+init_end_date+" every "+cycle_period+" hour"
   XAxisString = init_start_date+" - "+init_end_date+" every "+cycle_period+" hour"

   plot = new(3, graphic)
   res@xyExplicitLegendLabels = (/ "OMB", "OMA" /)
   if ( plot_individual ) then
   do n = 0, nexp-1
      ;wks = gsn_open_wks(out_type,plot_dir(n)+"/"+expnames(n)+"_conv_omb_oma_ts")
      wks = gsn_open_wks(out_type,plot_dir+"/"+"ts_conv_omb_oma")
      if ( num(.not.ismissing(ref(n,:,:,:))) .gt. 0 ) then
         var = "gpsref"
         res@tiYAxisString = "NUMBER"
         res@tiXAxisString = ""
         plot(0)  = gsn_csm_xy (wks,xc,ref(n,:,0,:),res)
         res@tiYAxisString = "AVERAGE"
         res@tiXAxisString = ""
         res@tiMainString  = ""
         res@gsnYRefLine = 0.0
         plot(1)  = gsn_csm_xy (wks,xc,ref(n,:,1,:),res)
         res@tiYAxisString = "RMSE"
         res@tiMainString  = ""
         res@tiXAxisString = XAxisString
         plot(2)  = gsn_csm_xy (wks,xc,ref(n,:,2,:),res)
         pres                = True              ; mod panel plot
         pres@gsnPanelBottom = 0.03              ; add some space at bottom
         pres@txString = expnames(n)+"    "+var
         gsn_panel(wks,plot,(/3,1/),pres)
      end if
      if ( num(.not.ismissing(tpw(n,:,:,:))) .gt. 0 ) then
         var = "gpspw"
         res@tiYAxisString = "NUMBER"
         res@tiXAxisString = ""
         plot(0)  = gsn_csm_xy (wks,xc,tpw(n,:,0,:),res)
         res@tiYAxisString = "AVERAGE"
         res@tiXAxisString = ""
         res@tiMainString  = ""
         res@gsnYRefLine = 0.0
         plot(1)  = gsn_csm_xy (wks,xc,tpw(n,:,1,:),res)
         res@tiYAxisString = "RMSE"
         res@tiXAxisString = XAxisString
         res@tiMainString  = ""
         plot(2)  = gsn_csm_xy (wks,xc,tpw(n,:,2,:),res)
         pres                = True              ; mod panel plot
         pres@gsnPanelBottom = 0.03              ; add some space at bottom
         pres@txString = expnames(n)+"    "+var
         gsn_panel(wks,plot,(/3,1/),pres)
      end if
      do i = 0, ntype-1
         if ( num(.not.ismissing(uu(n,i,:,:,:))) .gt. 0 ) then
            var = "U"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            res@tiXAxisString = ""
            plot(0)  = gsn_csm_xy (wks,xc,uu(n,i,:,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiXAxisString = ""
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,uu(n,i,:,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiXAxisString = XAxisString
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,uu(n,i,:,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = expnames(n)+"    "+ob_types(i)+"  "+var
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
         if ( num(.not.ismissing(vv(n,i,:,:,:))) .gt. 0 ) then
            var = "V"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            res@tiXAxisString = ""
            plot(0)  = gsn_csm_xy (wks,xc,vv(n,i,:,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiXAxisString = ""
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,vv(n,i,:,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiXAxisString = XAxisString
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,vv(n,i,:,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = expnames(n)+"    "+ob_types(i)+"  "+var
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
         if ( num(.not.ismissing(tt(n,i,:,:,:))) .gt. 0 ) then
            var = "T"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            res@tiXAxisString = ""
            plot(0)  = gsn_csm_xy (wks,xc,tt(n,i,:,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiXAxisString = ""
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,tt(n,i,:,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiXAxisString = XAxisString
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,tt(n,i,:,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = expnames(n)+"    "+ob_types(i)+"  "+var
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
         if ( num(.not.ismissing(qq(n,i,:,:,:))) .gt. 0 ) then
            var = "Q"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            res@tiXAxisString = ""
            plot(0)  = gsn_csm_xy (wks,xc,qq(n,i,:,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiXAxisString = ""
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,qq(n,i,:,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiXAxisString = XAxisString
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,qq(n,i,:,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = expnames(n)+"    "+ob_types(i)+"  "+var
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
         if ( num(.not.ismissing(pp(n,i,:,:,:))) .gt. 0 ) then
            var = "P"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            res@tiXAxisString = ""
            plot(0)  = gsn_csm_xy (wks,xc,pp(n,i,:,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiXAxisString = ""
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,pp(n,i,:,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiXAxisString = XAxisString
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,pp(n,i,:,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = expnames(n)+"    "+ob_types(i)+"  "+var
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
      end do

      destroy(wks)
   end do
   end if  ; end if plot_individual

   delete(res@xyExplicitLegendLabels)
   res@xyExplicitLegendLabels = expnames
   if ( plot_group ) then
      delete(res@xyExplicitLegendLabels)
      ; res@xyExplicitLegendLabels = group_exps
      res@xyExplicitLegendLabels = group_legends
      xp = new(np,"integer")
      do kk = 0, np-1
         xp(kk) = ind(exps.eq.group_exps(kk))
      end do
   do jj = 0, 1
      if ( jj .eq. 0 ) then
         wks = gsn_open_wks(out_type,plot_dir+"/"+"ts_conv_omb")
         stat = "OMB"
      else
         wks = gsn_open_wks(out_type,plot_dir+"/"+"ts_conv_oma")
         stat = "OMA"
      end if
      if ( num(.not.ismissing(ref(xp,jj,:,:))) .gt. 0 ) then
         var = "gpsref"
         ;res@tiMainString  = var
         res@tiYAxisString = "NUMBER"
         plot(0)  = gsn_csm_xy (wks,xc,ref(xp,0,0,:),res)
         res@tiYAxisString = "AVERAGE"
         res@tiMainString  = ""
         res@gsnYRefLine = 0.0
         plot(1)  = gsn_csm_xy (wks,xc,ref(xp,0,1,:),res)
         res@tiYAxisString = "RMSE"
         res@tiMainString  = ""
         plot(2)  = gsn_csm_xy (wks,xc,ref(xp,0,2,:),res)
         pres                = True              ; mod panel plot
         pres@gsnPanelBottom = 0.03              ; add some space at bottom
         pres@txString = var+"    "+stat
         gsn_panel(wks,plot,(/3,1/),pres)
      end if
      if ( num(.not.ismissing(tpw(xp,jj,:,:))) .gt. 0 ) then
         var = "gpspw"
         ;res@tiMainString  = var
         res@tiYAxisString = "NUMBER"
         plot(0)  = gsn_csm_xy (wks,xc,tpw(xp,0,0,:),res)
         res@tiYAxisString = "AVERAGE"
         res@tiMainString  = ""
         res@gsnYRefLine = 0.0
         plot(1)  = gsn_csm_xy (wks,xc,tpw(xp,0,1,:),res)
         res@tiYAxisString = "RMSE"
         res@tiMainString  = ""
         plot(2)  = gsn_csm_xy (wks,xc,tpw(xp,0,2,:),res)
         pres                = True              ; mod panel plot
         pres@gsnPanelBottom = 0.03              ; add some space at bottom
         pres@txString = var+"    "+stat
         gsn_panel(wks,plot,(/3,1/),pres)
      end if
      do i = 0, ntype-1
         if ( num(.not.ismissing(uu(xp,i,jj,:,:))) .gt. 0 ) then
            var = "U"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            plot(0)  = gsn_csm_xy (wks,xc,uu(xp,i,jj,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,uu(xp,i,jj,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,uu(xp,i,jj,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = ob_types(i)+"  "+var+"    "+stat
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
         if ( num(.not.ismissing(vv(xp,i,jj,:,:))) .gt. 0 ) then
            var = "V"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            plot(0)  = gsn_csm_xy (wks,xc,vv(xp,i,jj,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,vv(xp,i,jj,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,vv(xp,i,jj,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = ob_types(i)+"  "+var+"    "+stat
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
         if ( num(.not.ismissing(tt(xp,i,jj,:,:))) .gt. 0 ) then
            var = "T"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            plot(0)  = gsn_csm_xy (wks,xc,tt(xp,i,jj,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,tt(xp,i,jj,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,tt(xp,i,jj,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = ob_types(i)+"  "+var+"    "+stat
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
         if ( num(.not.ismissing(qq(xp,i,jj,:,:))) .gt. 0 ) then
            var = "Q"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            plot(0)  = gsn_csm_xy (wks,xc,qq(xp,i,jj,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,qq(xp,i,jj,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,qq(xp,i,jj,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = ob_types(i)+"  "+var+"    "+stat
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
         if ( num(.not.ismissing(pp(xp,i,jj,:,:))) .gt. 0 ) then
            var = "P"
            ;res@tiMainString  = ob_types(i)+"  "+var
            res@tiYAxisString = "NUMBER"
            plot(0)  = gsn_csm_xy (wks,xc,pp(xp,i,jj,0,:),res)
            res@tiYAxisString = "AVERAGE"
            res@tiMainString  = ""
            res@gsnYRefLine = 0.0
            plot(1)  = gsn_csm_xy (wks,xc,pp(xp,i,jj,1,:),res)
            res@tiYAxisString = "RMSE"
            res@tiMainString  = ""
            plot(2)  = gsn_csm_xy (wks,xc,pp(xp,i,jj,2,:),res)
            pres                = True              ; mod panel plot
            pres@gsnPanelBottom = 0.03              ; add some space at bottom
            pres@txString = ob_types(i)+"  "+var+"    "+stat
            gsn_panel(wks,plot,(/3,1/),pres)
         end if
      end do

      destroy(wks)
   end do
   end if   ; end if plot_group

exit
