load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$BIN_DIR/advance_cymdh.ncl"


   data_dir_top = getenv("DIAG_RUN_DIR_TOP")
   plot_dir_top = getenv("PLOT_DIR_TOP")

   exps = (/ "rt" /)
   exp_names = (/ "RT_WRFDA" /)
   ;init_start_date = "2015062712"
   ;init_end_date = "2015080100"
   init_end_date = getenv("ANAL_DATE")
   days_back = getenv("PLOT_TIME_SERIES_DAYS")
   hours_back = -1*24*stringtointeger(days_back)
   init_start_date = advance_cymdh(init_end_date, hours_back)
   ob_type = getenv("OB_TYPE")
   ob_var  = getenv("VAR_TYPE")
   ;ob_type = "sound"
   ;ob_var  = "t"
   if ( ob_type .eq. "sound" .or. ob_type .eq. "pilot" ) then
      cycle_period = 12
   else
      cycle_period = 06
   end if

   nplev = 18
   ncol = 5

   data_dir = data_dir_top
   plot_dir = plot_dir_top+"/"+init_end_date
   
   system("mkdir -p "+plot_dir)

   init_dates  = get_dates_ccyymmddhh(init_start_date, init_end_date, cycle_period)  ; initial dates
   num_init_dates = dimsizes(init_dates)
   nexp = dimsizes(exps)

   if ( ob_var .eq. "q" ) then
      plevs_plot = (/ 925.0, 850.0, 700.0 /)
   else
      plevs_plot = (/ 850.0, 700.0, 500.0, 300.0 /)
   end if

   pdata  = new((/nexp,nplev,2,3,num_init_dates/),"float") ;omb/oma, num/ave/rms
   pdata@_FillValue = -999.0
   pdata!0 = "exp"
   pdata!1 = "plev"
   pdata!2 = "ges_type"  ; 0:omb, 1:oma
   pdata!3 = "stat_type"  ; 0:num, 1:ave, 2:rms
   pdata!4 = "date"

   omb_prf_files = new((/nexp, num_init_dates/), "string")
   oma_prf_files = new((/nexp, num_init_dates/), "string")
   do iexp = 0, nexp-1
      print("Processing "+exps(iexp)+" for "+ob_type+" "+ob_var+" ...")
      do i = 0, num_init_dates-1
         ;print("   Processing "+init_dates(i)+" ...")
         omb_prf_files(iexp,i) = data_dir(iexp)+"/"+init_dates(i)+"/omb_stats_prf_"+ob_var+"_"+ob_type
         oma_prf_files(iexp,i) = data_dir(iexp)+"/"+init_dates(i)+"/oma_stats_prf_"+ob_var+"_"+ob_type
         ;print("omb: "+omb_prf_files(iexp,i))
         ;print("oma: "+oma_prf_files(iexp,i))
         found_omb = True ; initialize
         found_oma = True ; initialize
         if ( .not. fileexists(omb_prf_files(iexp,i)) ) then
            print("Error opening "+omb_prf_files(iexp,i))
            found_omb = False
         end if
         if ( .not. fileexists(oma_prf_files(iexp,i)) ) then
            print("Error opening "+oma_prf_files(iexp,i))
            found_oma = False
         end if
         if ( (.not. found_omb) .and. (.not. found_oma) ) then
            print("ERROR: no valid stats prf files found for date "+init_dates(i))
            continue
         end if
         if ( found_omb ) then
            datatmp = asciiread(omb_prf_files(iexp,i),(/nplev,ncol/),"float")
            datatmp@_FillValue = -999.0
            pdata(iexp,:,0,:,i)  = (/ datatmp(:,2:4) /)
            plevels = datatmp(:,1)
            delete(datatmp)
         end if
         if ( found_oma ) then
            datatmp = asciiread(oma_prf_files(iexp,i),(/nplev,ncol/),"float")
            datatmp@_FillValue = -999.0
            pdata(iexp,:,1,:,i)  = (/ datatmp(:,2:4) /)
            plevels = datatmp(:,1)
            delete(datatmp)
         end if
      end do
   end do

   print("Plotting...")

   out_type = "pdf"
   xc = ispan(1,num_init_dates,1)
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
   res@trXMinF                = 1.0
   res@trXMaxF                = num_init_dates
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

   do n = 0, nexp-1
   do k = 0, nplev-1
      if ( ismissing(ind(plevs_plot.eq.plevels(k))) ) then
         continue
      end if
      outname = "ts_omb_oma_"+ob_type+"_"+ob_var+"_"+sprintf("%3.0f",plevels(k))+"hPa"
      wks = gsn_open_wks(out_type,plot_dir+"/"+outname)
      if ( num(.not.ismissing(pdata(n,k,:,:,:))) .gt. 0 ) then
         res@tiYAxisString = "NUMBER"
         res@tiXAxisString = ""
         plot(0)  = gsn_csm_xy (wks,xc,pdata(n,k,:,0,:),res)
         res@tiYAxisString = "AVERAGE"
         res@tiXAxisString = ""
         res@tiMainString  = ""
         res@gsnYRefLine = 0.0
         res@gsnYRefLineDashPattern = 2
         plot(1)  = gsn_csm_xy (wks,xc,pdata(n,k,:,1,:),res)
         res@tiYAxisString = "RMSE"
         res@tiMainString  = ""
         res@tiXAxisString = XAxisString
         plot(2)  = gsn_csm_xy (wks,xc,pdata(n,k,:,2,:),res)
         pres                = True              ; mod panel plot
         pres@gsnPanelBottom = 0.03              ; add some space at bottom
         pres@txString = exp_names(n)+"    "+ob_type+"   "+ob_var+"  "+sprintf("%3.0f",plevels(k))+"hPa"
         gsn_panel(wks,plot,(/3,1/),pres)
      end if
      destroy(wks)
system("/usr/bin/convert -trim -density 150x150 "+plot_dir+"/"+outname+".pdf "+plot_dir+"/"+outname+".png")
system("rm -f "+plot_dir+"/"+outname+".pdf")
   end do
   end do

exit
