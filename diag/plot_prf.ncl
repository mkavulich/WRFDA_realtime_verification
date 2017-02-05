;
; Author: Hui-Chuan Lin   MMM/NESL/NCAR
;
; Purpose: plot the OMB/OMA MEAN/RMSE
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

date     = getenv("ANAL_DATE")
ob_type  = getenv("OB_TYPE")
var_type = getenv("VAR_TYPE")
diag_dir = getenv("DIAG_RUN_DIR")
;date     = "2015072800"
;ob_type  = "sound"
;var_type = "t"
;ob_type  = "geoamv"
;var_type = "u"

;obtype = (/ var_type+"_"+ob_type /)
obtype = (/ ob_type+"_"+var_type /)

plotdir = diag_dir + "/"+date
exp_dirs = (/ diag_dir+"/"+date /)
exp_names = (/ "RT-WRFDA" /)
nexp = dimsizes(exp_dirs)
nregion = 1

;obtype = (/ "t_120", "ps_181", "q_120", "u_220" /)
;obname = (/ "t SOUND", "ps SYNOP", "q SOUND", "u SOUND" /)
;obtype = (/ "t_120", "q_120", "u_220" /)
;obname = (/ "SOUND t", "SOUND q", "SOUND u" /)
;obtype = (/ "q_120" /)
;obname = (/ "q SOUND" /)
;obtype = (/ "t_120" /)
;obname = (/ "t SOUND" /)
;obtype = (/ "u_220" /)
;obname = (/ "u SOUND" /)
nvar = dimsizes(obtype)

omb_dirs = exp_dirs
oma_dirs = exp_dirs

do iv = 0, nvar-1 ;big main loop over obtype

   omb_file = new((/nexp,nregion/),"string")
   oma_file = new((/nexp,nregion/),"string")

   got_Info = False ;initialize

   imiss_exp = 0
   do iexp = 0, nexp-1 ;loop over experiments

      ; reading data
      imiss_reg = 0
      do i = 0, nregion-1 ;loop over regions

         ; no region indicator
         ;omb_file(iexp,i) = omb_dirs(iexp)+"/"+"omb_stats_"+obtype(iv)
         ;oma_file(iexp,i) = oma_dirs(iexp)+"/"+"oma_stats_"+obtype(iv)
         omb_file(iexp,i) = omb_dirs(iexp)+"/"+"omb_stats_prf_"+var_type+"_"+ob_type
         oma_file(iexp,i) = oma_dirs(iexp)+"/"+"oma_stats_prf_"+var_type+"_"+ob_type

         print("omb: "+omb_file(iexp,i))
         print("oma: "+oma_file(iexp,i))

         found_omb = True ; initialize
         found_oma = True ; initialize
         ;if ( .not. isfilepresent(omb_file(iexp,i)) ) then
         if ( .not. fileexists(omb_file(iexp,i)) ) then
            print("Error opening "+omb_file(iexp,i))
            found_omb = False
         end if
         ;if ( .not. isfilepresent(oma_file(iexp,i)) ) then
         if ( .not. fileexists(oma_file(iexp,i)) ) then
            print("Error opening "+oma_file(iexp,i))
            found_oma = False
         end if
         if ( (.not. found_omb) .and. (.not. found_oma) ) then
            ;print("ERROR: no valid stats files found for exp "+exp_names(iexp)+", region "+stats_region(i))
            print("ERROR: no valid stats files found for exp "+exp_names(iexp))
            imiss_reg = imiss_reg + 1
            if ( imiss_reg .eq. nregion ) then
               imiss_exp = imiss_exp + 1
               if ( imiss_exp .eq. nexp ) then
                  exit
               else
                  continue
               end if
            end if
         end if

         nrow1 = 0 ; initialize
         nrow2 = 0 ; initialize
         if ( found_omb ) then
            nrow1 = stringtointeger(systemfunc("wc -l "+omb_file(iexp,i)))
            nrow = nrow1
         end if
         if ( found_oma ) then
            nrow2 = stringtointeger(systemfunc("wc -l "+oma_file(iexp,i)))
            nrow = nrow2
         end if
         if ( (found_omb .and. found_oma) .and. (nrow1 .ne. nrow1) ) then
            print("number of dates do not match between omb and oma files")
            exit
         end if
         ncol = 5 ; 1:date, 2:plevel, 3:nobs, 4:mean, 5:rms

         if ( .not. got_Info ) then
            ; retrieve some basic numbers
            if ( found_omb ) then
               data = asciiread(omb_file(iexp,i), -1, "string")
            else
               if ( found_oma ) then
                  data = asciiread(oma_file(iexp,i), -1, "string")
               else
                  continue
               end if
            end if
            cdata = stringtochar(data)
            dates_tmp = charactertostring(cdata(:,0:9))
            plevs = stringtofloat(charactertostring(cdata(:,12:19)))
            ndate = dimsizes(ind(plevs.eq.plevs(0)))
            nplev = dimsizes(ind(dates_tmp.eq.dates_tmp(0)))
            dates = new(ndate, "string")
            do n = 0, ndate-1
               dates(n) = dates_tmp(n*nplev)
            end do
            delete(data)
            delete(cdata)
            delete(dates_tmp)
            std_plevels = plevs(0:nplev-1)

            nobs  = new((/nexp,nregion,2,ndate,nplev/),"float")
            nobs@_FillValue = -999.0
            nobs!0 = "exp"
            nobs!1 = "region"
            nobs!2 = "ges_type"  ; 0:omb, 1:oma
            nobs!3 = "date"
            nobs!4 = "plev"
            xmean = nobs
            xrms = nobs

            got_Info = True
         end if

         if ( found_omb ) then
            datatmp = asciiread(omb_file(iexp,i),(/nrow,ncol/),"float")
            datatmp@_FillValue = -999.0
            nobs(iexp,i,0,:,:)  = onedtond(datatmp(:,2),(/ndate,nplev/))
            xmean(iexp,i,0,:,:) = onedtond(datatmp(:,3),(/ndate,nplev/))
            xrms(iexp,i,0,:,:)  = onedtond(datatmp(:,4),(/ndate,nplev/))
            delete(datatmp)
         end if

         if ( found_oma ) then
            datatmp = asciiread(oma_file(iexp,i),(/nrow,ncol/),"float")
            datatmp@_FillValue = -999.0
            nobs(iexp,i,1,:,:)  = onedtond(datatmp(:,2),(/ndate,nplev/))
            xmean(iexp,i,1,:,:) = onedtond(datatmp(:,3),(/ndate,nplev/))
            xrms(iexp,i,1,:,:)  = onedtond(datatmp(:,4),(/ndate,nplev/))
            delete(datatmp)
         end if

         if ( num(.not.ismissing(nobs)) .eq. 0 ) then
            print("STOP: no valid data found for "+obtype(iv))
            exit
         end if
      end do ; region loop
   end do ; nexp loop
   ; done reading data for obtype(iv)

   ;plotting for obtype(iv)

   colors = (/ "red", "blue", "forestgreen", "orange", "cyan", "brown" /)
   colors_prf = (/ "red", "red", "blue", "blue", "cyan", "brown" /)
   colors_exp = (/ "red", "blue", "forestgreen", "forestgreen", "cyan", "brown" /)
   res                        = True
   res@gsnPaperOrientation    = "portrait"
   res@gsnMaximize            = False               ; Maximize plot in frame.
   res@gsnFrame               = False               ; Don't advance the frame
   res@gsnDraw                = False
   res@tmYROn                 = False
   res@tmXTOn                 = False
   res@tmYLMinorOn            = False
   res@tmXBMinorOn            = False
   res@tmYLMajorThicknessF    = 1.0                 ; default 2.0
   res@tmXBMajorThicknessF    = 1.0                 ; default 2.0
   res@xyMarkLineMode         = "MarkLines"
   res@xyMarkers              = (/ 1, 1, 1, 1, 1, 1, 1, 1 /)
   res@xyMarkerColors         = colors
   res@xyLineColors           = colors
   res@xyLineThicknesses      = (/ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 /)      ; default 1.0
   res@xyMarkerSizes          = (/ 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02 /)   ; default 0.01
   res@xyDashPatterns         = (/ 0, 0, 0, 0, 0, 0, 0, 0 /)
   res@tmLabelAutoStride      = True                ; Auto stride
   res@pmLegendDisplayMode    = "Always"            ; turn on legend
   res@pmLegendSide           = "Right"             ; Change location of
   res@pmLegendWidthF         = 0.1                 ; Change width and default 0.55
   res@pmLegendHeightF        = 0.1                 ; height of legend. default 0.18
   res@lgLabelFontHeightF     = .015                ; change font height default 0.02
   ;res@xyExplicitLegendLabels = (/"OMB", "OMA"/)    ; explicit labels

   pres                = True              ; mod panel plot
   pres@gsnPanelBottom = 0.10              ; add some space at bottom
   pres@gsnFrame              = False

   ;vertical profile
   res_prf = res

   out_type = "pdf"
   da_system = "WRFDA"
   plot = new(6,graphic)

   ;group regions for each obtype and experiment
   do ii = 0, nexp-1
      ;id_exp = 2
      id_exp = ii
      outname = "prf_omb_oma_"+obtype(iv)
      wks = gsn_open_wks(out_type,plotdir+"/"+outname)
      res_prf = res
      res_prf@gsnXRefLine            = 0.0
      res_prf@trYReverse             = True
      res_prf@trYLog                 = True
      res_prf@tmYLMode               = "Explicit"
      res_prf@tmYLLabels             = std_plevels
      res_prf@tmYLValues             = std_plevels
      res_prf@tmLabelAutoStride      = False
      res_prf@tmXBLabelFontHeightF   = 0.015
      res_prf@xyMarkerColors         = colors_prf
      res_prf@xyLineColors           = colors_prf
      res_prf@xyDashPatterns         = (/ 0, 2, 0, 2, 0, 0, 0, 0 /)
      res_prf@gsnRightString         = "DATE: "+date(0)
      res_prf@gsnLeftString          = ob_type+"  "+var_type
      res_prf@tmYROn                 = True
      if ( obtype(iv) .eq. "t_sound" ) then
         ;res_prf@trXMaxF                = 4.0
      end if
      if ( obtype(iv) .eq. "q_sound" ) then
         ;res_prf@trXMaxF                = 3.0
         ;res_prf@trXMinF                = -1.0
      end if
      if ( obtype(iv) .eq. "u_sound" .or. obtype(iv) .eq. "v_sound" ) then
         ;res_prf@trXMaxF                = 6.0
         ;res_prf@trXMinF                = -2.0
      end if
      if ( obtype(iv) .eq. "q_sound" ) then
         res_prf@trYMinF                = 300.0
      else
         res_prf@trYMinF                = 100.0
      end if
      pdata = new((/nregion,4,nplev/),"float") ; omb_bias, oma_bias, omb_rmse, oma_rmse
      pdata@_FillValue = -999.0
      ; group rmse and bias
      do i = 0, nregion-1
         ;id_region = ind(stats_region.eq."NH")
         id_region = i
         res_prf@tmYUseLeft             = False
         res_prf@trYLog                 = True
         res_prf@tmYRMode               = "Explicit"
         res_prf@tmYRValues             = std_plevels
         res_prf@tmYRLabelsOn           = True
         YRLabels = sprintf("%5.0f",nobs(ii,i,0,0,:))
         res_prf@tmYRLabels             = YRLabels
         res_prf@tmYRLabelFontHeightF   = 0.012
         ;res_prf@tiMainString          = ob_type+" "+var_type
         res_prf@pmLegendDisplayMode    = "Never"
         if ( nplev .gt. 0 ) then
            ;pdata(id_region,0,:) = dim_avg_n(xmean(id_exp,id_region,0,:,:),0)
            ;pdata(id_region,1,:) = dim_avg_n(xmean(id_exp,id_region,1,:,:),0)
            ;pdata(id_region,2,:) = dim_avg_n(xrms (id_exp,id_region,0,:,:),0)
            ;pdata(id_region,3,:) = dim_avg_n(xrms (id_exp,id_region,1,:,:),0)
            pdata(id_region,0,:) = xmean(id_exp,id_region,0,0,:)
            pdata(id_region,1,:) = xmean(id_exp,id_region,1,0,:)
            pdata(id_region,2,:) = xrms (id_exp,id_region,0,0,:)
            pdata(id_region,3,:) = xrms (id_exp,id_region,1,0,:)
            plot(i)  = gsn_csm_xy (wks,pdata(id_region,:,0:nplev-2),std_plevels(0:nplev-2),res_prf)
            draw(plot(i))
            ;frame(wks)
         end if
      end do ;region loop
      ;pres@txString = ob_type+" "+var_type
      ;gsn_panel(wks,plot(0:nregion-1),(/2,2/),pres)
      lgres                    = True
      lgres@lgLineColors       = colors_prf
      lgres@lgPerimOn          = False                 ; turn off perimeter
      lgres@lgDashIndexes      = (/0,2,0,2/)           ; dash indexes
      ;lgres@lgLineLabelStrings = (/ "OMB_BIAS", "OMA_BIAS", "OMB_RMSE", "OMA_RMSE" /)
      lgres@lgLabelFontHeightF = 0.045                  ; change font height
      lgres@lgLineThicknessF = 2.0
      labels = (/ " OMB_BIAS", " OMA_BIAS", " OMB_RMSE", " OMA_RMSE" /)
      ;if ( obtype(iv) .eq. "u_sound" .or. obtype(iv) .eq. "v_sound" ) then
      ;   lgres@vpWidthF           = 0.12                  ; width of legend (NDC)
      ;   lgres@vpHeightF          = 0.08                  ; height of legend (NDC)
      ;   gsn_legend_ndc(wks,4,labels,0.87,0.60,lgres)
      ;else
      ;   lgres@vpWidthF           = 0.15                  ; width of legend (NDC)
      ;   lgres@vpHeightF          = 0.10                  ; height of legend (NDC)
      ;   gsn_legend_ndc(wks,4,labels,0.8,0.87,lgres)
      ;end if
         lgres@vpWidthF           = 0.25                  ; width of legend (NDC)
         lgres@vpHeightF          = 0.10                  ; height of legend (NDC)
         ;gsn_legend_ndc(wks,4,labels,0.875,0.30,lgres)
         gsn_legend_ndc(wks,4,labels,0.4,0.15,lgres)
      frame(wks)                                   ; now advance the frame
      destroy(wks)
      delete(res_prf)
      delete(pdata)
      delete(lgres)
      delete(labels)
   end do ;exp loop
   ; done vertical profile

;exit

   destroy(wks)
   delete(plot)

   delete(omb_file)
   delete(oma_file)
   delete(nobs)
   delete(xmean)
   delete(xrms)

system("/usr/bin/convert -trim -density 150x150 "+plotdir+"/"+outname+".pdf "+plotdir+"/"+outname+".png")
system("rm -f "+plotdir+"/"+outname+".pdf")

end do ; ob nvar loop
