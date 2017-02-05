;
; Author: Hui-Chuan Lin
;
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$BIN_DIR/utils_hclin.ncl"

   ;expnames = (/ "gfs", "cold", "warm" /)
   ;plotdir = "/glade/scratch/hclin/DA/DA2014/Spring2012/x1.40962_m80/diag_rad"
   ;expdir1 = "/glade/scratch/hclin/DA/DA2014/Spring2012/x1.40962_m80/diag_rad/3dvar_amsua"
   ;expdir2 = "/glade/scratch/hclin/DA/DA2014/Spring2012/x1.40962_m80/diag_rad/3dvar_amsua_c"
   ;expdir3 = "/glade/scratch/hclin/DA/DA2014/Spring2012/x1.40962_m80/diag_rad/3dvar_amsua_w"
   ;expdirs = (/ expdir1, expdir2, expdir3 /)

   expnames = (/ "RT_WRFDA" /)
   diag_dir = getenv("DIAG_RUN_DIR")
   plotdir_top = diag_dir
   ;expdir1 = "/glade/scratch/hclin/CONUS/wrfda/expdir/start2015060812/ob_ascii/hyb_e50_amsua"
   expdir1 = getenv("DA_RUN_DIR_TOP")
   expdirs = (/ expdir1 /)
   nexp = dimsizes(expdirs)

   inst = getenv("INSTRUMENT")
   end_date = getenv("ANAL_DATE")
   days_back = 15
   hours_back = -1*24*days_back
   start_date = advance_cymdh(end_date, hours_back)
   ;start_date   = "2015062806"
   ;end_date     = "2015072706"
   cycle_period = 12

   plotdir = plotdir_top+"/"+end_date

   out_type = "pdf"
   ;out_type = "png"
   da_system = "WRFDA"
   ;da_system = "GSI"

   plot_opt = "all" ; "land_only"  "sea_only"
   plot_qced = True
   plot_var_chan = False
   plot_group_exp_only = False

   if ( da_system .eq. "WRFDA" ) then
      ;instrument = (/ "eos-2-amsua", "metop-2-amsua", "noaa-15-amsua", "noaa-16-amsua", \
      ;                "noaa-18-amsua", "noaa-15-amsub", "noaa-16-amsub", "noaa-17-amsub", \
      ;                "noaa-18-mhs", "metop-2-mhs", "noaa-19-amsua", "noaa-19-mhs" /)
      ;chanindex = (/ (/ 5, 6, 7, 8, 9 /), \
      ;               (/ 5, 6, 7, 8, 9 /), \
      ;               (/ 5, 6, 7, 8, 9 /), \
      ;               (/ 5, 6, 7, 8, 9 /), \
      ;               (/ 5, 6, 7, 8, 9 /), \
      ;               (/ 3, 4, 5, 0 ,0 /), \
      ;               (/ 3, 4, 5, 0, 0 /), \
      ;               (/ 3, 4, 5, 0, 0 /), \
      ;               (/ 3, 4, 5, 0, 0 /), \
      ;               (/ 3, 4, 5, 0, 0 /), \
      ;               (/ 5, 6, 7, 8, 9 /), \
      ;               (/ 3, 4, 5, 0, 0 /) /)
      ;instrument = (/ "noaa-18-amsua", "metop-2-amsua", "noaa-19-amsua", "noaa-15-amsua" /)
      ;chanindex = (/ (/ 6, 7, 8 /), \
      ;               (/ 6, 7, 8 /), \
      ;               (/ 6, 7, 8 /), \
      ;               (/ 6, 7, 8 /) /)
      ;instrument = (/ "noaa-18-amsua", "noaa-19-amsua", "noaa-15-amsua" /)
      ;chanindex = (/ (/ 6, 7, 8 /), \
      ;               (/ 6, 7, 8 /), \
      ;               (/ 6, 7, 8 /) /)
      ;instrument = (/ "metop-2-amsua" /)
      instrument = (/ inst /)
      chanindex = (/ (/ 6 /) /)
   end if

   if ( da_system .eq. "GSI" ) then
      ;instrument = (/ "amsua_n15", "amsua_n18", "amsua_metop-a", "amsub_n17", "mhs_n18", "mhs_metop-a" /)
      ;chanindex = (/ (/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 /), \
      ;               (/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 /), \
      ;               (/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 /), \
      ;               (/ 1, 2, 3, 4, 5, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0 /), \
      ;               (/ 1, 2, 3, 4, 5, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0 /), \
      ;               (/ 1, 2, 3, 4, 5, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0 /) /)
      instrument = (/ "amsua_n19", "amsua_n15", "amsua_n18", "amsua_metop-a" /)
      chanindex = (/ (/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 /), \
                     (/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 /), \
                     (/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 /), \
                     (/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 /) /)
      ;instrument = (/ "airs_aqua" /)
      ;chanindex = (/ (/ 190,192,198,201,204,207,210,215,216,221,226,227,232,252,253,256,257,261,262,267,272,295,299, \
      ;       305,310,321,325,333,338,355,362,375,475,484,497,528,587,672,787,791,870,914,950, \
      ;       1301,1304,1329,1371,1382,1415,1424,1449,1455,1477,1500,1519,1565,1574,1627,1669,1694,1766,1800,\
      ;       1826,1865,1866,1868,1869,1872,1873,1876,1881,1882,1911,1917,1918,1924,1928 /) /)  ; set the channels to plot
   end if

   ninst = dimsizes(instrument)

   date = get_dates_ccyymmddhh(start_date, end_date, cycle_period)
   ntime = dimsizes(date)
   xc = ispan(1,ntime,1)   ; set the x-axis values for statistics time-series plot

   xb_labels = get_xb_labels(start_date, end_date, cycle_period)
   xb_values = get_xb_values(start_date, end_date, cycle_period)

   num_chan = new(ninst, integer)
   dsize = dimsizes(chanindex)
   do i = 0, ninst-1
      if ( dimsizes(dsize) .eq. 1 ) then
         num_chan(i) = dimsizes(ind(chanindex(:).ne.0))
      else
         num_chan(i) = dimsizes(ind(chanindex(i,:).ne.0))
      end if
   end do

   varnames = (/ "obs", "bak", "omb_bc", "omb_nobc", "obs_bc", "bc", "oma", "amb" /)  ; should not be changed
   ;varplot  = (/ False, False, False,     False,     False,   False, False,     False /)
   varplot  = (/ False, False, True,       True,     False,    False,  True, False /)
   nvar = dimsizes(varnames)
   group_index = (/ 3, 2, 6 /)

   do iinst = 0, ninst-1  ; this is ninst_loop
      print("instrument: "+instrument(iinst))
      plot_ch = new(num_chan(iinst),integer)
      if ( dimsizes(dsize) .eq. 1 ) then
         plot_ch = chanindex(0:num_chan(iinst)-1)
      else
         plot_ch = chanindex(iinst,0:num_chan(iinst)-1)
      end if
      xnum  = new((/nexp,nvar,num_chan(iinst),ntime/),integer)    ; for omb_nobc, omb_bc, and oma, bc, obs, obs_bc, bak, amb
      xnum!2 = "channel"                        ; name the dimension
      xnum!3 = "date"
      xnum&channel = (/ plot_ch /)              ; define coordinate variable
      xnum&date = (/ stringtointeger(date) /)
      xmean = new((/nexp,nvar,num_chan(iinst),ntime/),float)      ; for omb_nobc, omb_bc, and oma, bc, obs, obs_bc, bak, amb
      xmean!2 = "channel"
      xmean!3 = "date"
      xmean&channel = (/ plot_ch /)
      xmean&date = (/ stringtointeger(date) /)
      xrms = xmean
      xstd = xmean

      npts = new((/nexp,nvar,num_chan(iinst),ntime/),integer)
      npts!2 = "channel"                        ; name the dimension
      npts!3 = "date"
      npts&channel = (/ plot_ch /)              ; define coordinate variable
      npts&date = (/ stringtointeger(date) /)
      npts_sele = npts
      npts_qc = npts
      npts_qc_anl = npts
      npts_land = npts
      npts_sea  = npts

      got_wn = False
      do iexp = 0, nexp-1  ; this is nexp_loop
         print("   exp: "+expnames(iexp))
         do itime = 0, ntime-1   ; this is ntime_loop

            ;filename = "diags01_" + instrument(iinst) + "_" + date(itime)
            ;fullname = expdirs(iexp)+"/"+date(itime)+"/"+filename
            filename = "diags_" + instrument(iinst) + "_" + date(itime)
            ;fullname = expdirs(iexp)+"/"+date(itime)+"/var/"+filename
            ;filename = "oma_" + instrument(iinst) + "_" + date(itime)
            fullname = expdirs(iexp)+"/"+date(itime)+"/"+filename
            ;fullname = expdirs(iexp)+"/"+filename

            if ( .not. isfilepresent(fullname+".nc") ) then
               print("Can not find the file "+fullname+".nc"+"  Will skip it")
            else
               infile = addfile(fullname+".nc","r")
               print("      Processing date: "+date(itime))
               ;
               ; read in data
               ;
               ichan = infile->ichan
               lat   = infile->lat
               lon   = infile->lon
               isflg = infile->isflg
               ;if ( .not. got_wn ) then
               ;   wavenumber = infile->wavenumber
               ;   wavenumber!0 = "chan"
               ;   wavenumber&chan = ichan
               ;   got_wn = True
               ;end if
               qc    = infile->tb_qc
               qc!0     = "pixel"
               qc!1     = "chan"
               qc&chan  = ichan
               qc_anl   = qc ; initialize
               muse     = qc ; initialize
               muse_anl = qc ; initialize
               if ( da_system .eq. "GSI" ) then
                  if ( isfilevar(infile, "tb_qc_anl") ) then
                     qc_anl      = (/infile->tb_qc_anl/)
                  end if
                  if ( isfilevar(infile, "muse") ) then
                     muse = (/infile->muse/)
                  end if
                  if ( isfilevar(infile, "muse_anl") ) then
                     muse_anl = (/infile->muse_anl/)
                  end if
               end if
               dSizes = getfiledimsizes(infile)
               nchan = dSizes(0)
               npixel = dSizes(1)
               data = new((/nvar,npixel,nchan/), "float")
               data!0    = "variable"
               data!1    = "pixel"
               data!2    = "chan"
               data&chan = ichan
               obs   = infile->tb_obs
               bak   = infile->tb_bak
               oma   = infile->tb_oma
               omb_bc   = infile->tb_inv    ; omb with bias correction
               omb_nobc = where(.not.ismissing(obs) .and. .not.ismissing(bak), obs-bak, obs@_FillValue)
               obs_bc = where(.not.ismissing(bak) .and. .not.ismissing(omb_bc), bak+omb_bc, obs@_FillValue)
               bc = omb_nobc - omb_bc   ; bias correction term
               data(0,:,:) = (/obs/)
               data(1,:,:) = (/bak/)
               data(2,:,:) = (/omb_bc/)
               data(3,:,:) = (/omb_nobc/)
               data(4,:,:) = (/obs_bc/)
               data(5,:,:) = (/bc/)
               got_oma = False
               if ( num(.not.ismissing(oma)) .gt. 0 ) then
                  got_oma = True
                  ana = where(.not.ismissing(obs_bc) .and. .not.ismissing(oma), obs_bc-oma, obs@_FillValue)
                  amb = ana - bak
                  data(6,:,:) = (/oma/)
                  data(7,:,:) = (/amb/)
               end if

               do ich = 0, num_chan(iinst)-1
                  do ivar = 0, nvar-1

                     ;  Mask out data according to the isflg type:
                     if ( plot_opt .eq. "land_only" ) then
                        data(variable|ivar,pixel|:,{chan|plot_ch(ich)}) = mask(data(variable|ivar,pixel|:,{chan|plot_ch(ich)}), isflg, 2)
                     end if
                     if ( plot_opt .eq. "sea_only" ) then
                        data(variable|ivar,pixel|:,{chan|plot_ch(ich)}) = mask(data(variable|ivar,pixel|:,{chan|plot_ch(ich)}), isflg, 0)
                     end if
                     if ( plot_qced ) then
                        if ( varnames(ivar) .eq. "oma" .or. varnames(ivar) .eq. "amb" ) then
                           data(variable|ivar,pixel|:,{chan|plot_ch(ich)}) = mask(data(variable|ivar,pixel|:,{chan|plot_ch(ich)}), qc_anl(pixel|:, {chan|plot_ch(ich)}), 1)
                           data(variable|ivar,pixel|:,{chan|plot_ch(ich)}) = mask(data(variable|ivar,pixel|:,{chan|plot_ch(ich)}), muse_anl(pixel|:, {chan|plot_ch(ich)}), 1)
                        else
                           data(variable|ivar,pixel|:,{chan|plot_ch(ich)}) = mask(data(variable|ivar,pixel|:,{chan|plot_ch(ich)}), qc(pixel|:, {chan|plot_ch(ich)}), 1)
                           data(variable|ivar,pixel|:,{chan|plot_ch(ich)}) = mask(data(variable|ivar,pixel|:,{chan|plot_ch(ich)}), muse(pixel|:, {chan|plot_ch(ich)}), 1)
                        end if
                     end if

                     npts_sele(iexp,ivar,ich,itime) = num(.not.ismissing(data(variable|ivar,pixel|:,{chan|plot_ch(ich)})))
                     if ( npts_sele(iexp,ivar,ich,itime) .gt. 0 ) then
                        xnum(iexp,ivar,ich,itime) = (/ npts_sele(iexp,ivar,ich,itime) /)
                        xmean(iexp,ivar,ich,itime) = sum(data(variable|ivar,pixel|:,{chan|plot_ch(ich)}))/tofloat(npts_sele(iexp,ivar,ich,itime))
                        xrms(iexp,ivar,ich,itime) = sqrt(sum(data(variable|ivar,pixel|:,{chan|plot_ch(ich)})*data(variable|ivar,pixel|:,{chan|plot_ch(ich)}))/tofloat(npts_sele(iexp,ivar,ich,itime)))
                        xstd(iexp,ivar,ich,itime) = sqrt(sum((data(variable|ivar,pixel|:,{chan|plot_ch(ich)})-xmean(iexp,ivar,ich,itime))*(data(variable|ivar,pixel|:,{chan|plot_ch(ich)})-xmean(iexp,ivar,ich,itime)))/tofloat(npts_sele(iexp,ivar,ich,itime)))
                     end if
                  end do
               end do

               delete(ichan)
               delete(lat)
               delete(lon)
               delete(isflg)
               delete(obs)
               delete(bak)
               delete(oma)
               delete(omb_bc)
               delete(omb_nobc)
               delete(obs_bc)
               delete(bc)
               delete(qc)
               delete(qc_anl)
               delete(muse)
               delete(muse_anl)
               if ( got_oma ) then
                  delete(ana)
                  delete(amb)
               end if
               delete(data)
            end if
         end do  ; end ntime_loop
      end do  ; end nexp_loop
;
; plotting
;
      plot = new(3,graphic)
      res                        = True
      res@gsnPaperOrientation    = "portrait"
      res@gsnMaximize            = False               ; Maximize plot in frame.
      res@gsnFrame               = False               ; Don't advance the frame
      res@gsnDraw                = False
      res@vpHeightF              = 0.25                ; change aspect ratio of plot
      res@vpWidthF               = 0.90
      res@tmYROn                 = False
      res@tmXTOn                 = False
      res@tmYLMinorOn            = False
      res@tmXBMinorOn            = False
      res@tmYLMajorThicknessF    = 1.0                 ; default 2.0
      res@tmXBMajorThicknessF    = 1.0                 ; default 2.0
      ; res@tmXBMajorLengthF       = 0.0
      res@xyMarkLineMode         = "MarkLines"
      res@xyMarkers              = (/ 1, 1, 1, 1, 1, 1, 1 /)
      res@xyMarkerColors         = (/ 2, 19, 4, 14, 16, 8, 10, 12, 13, 23/)
      res@xyLineColors           = (/ 2, 19, 4, 14, 16, 8, 10, 12, 13, 23/)
      ;res@xyMarkerSizes          = (/ 0.01, 0.01, 0.01, 0.01, 0.01, 0.01, 0.01 /)   ; default 0.01
      ;res@xyLineThicknesses      = (/ 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0 /)      ; default 1.0
      res@xyMarkerSizes          = (/ 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02 /)   ; default 0.01
      res@xyLineThicknesses      = (/ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 /)      ; default 1.0
      res@xyDashPatterns         = (/ 0, 0, 0, 0, 0, 0, 0, 0, 0 /)
      res@gsnYRefLine            = 0.0
      res@tmXBMode               = "Explicit"
      res@tmXBLabels             = xb_labels ;xmajor
      res@tmXBValues             = xb_values
      res@trXMaxF                = xc(ntime-1)
      res@tmLabelAutoStride      = True                ; Auto stride
      res@pmLegendDisplayMode    = "Always"            ; turn on legend
      res@pmLegendSide           = "Right"             ; Change location of
      res@pmLegendWidthF         = 0.1                 ; Change width and default 0.55
      res@pmLegendHeightF        = 0.1                 ; height of legend. default 0.18
      res@lgLabelFontHeightF     = .012                ; change font height default 0.02
      ;res@gsnLeftStringFontHeightF = 0.015

      if ( ntime .gt. 1 .and. num(.not.ismissing(xmean)) .gt. 0 ) then
         do ich = 0, num_chan(iinst)-1
            if ( num(.not.ismissing(xmean(:,:,ich,:))) .gt. 0 ) then
               do ivar = 0, nvar-1
                  if ( .not. plot_var_chan ) then
                     continue
                  end if
                  if ( .not. varplot(ivar) ) then
                     continue
                  end if
                  if ( ivar .eq. 0 ) then
                     var_plot = "OBS"
                  end if
                  if ( ivar .eq. 1 ) then
                     var_plot = "BAK"
                  end if
                  if ( ivar .eq. 2 ) then
                     var_plot = "OMB_bc"
                  end if
                  if ( ivar .eq. 3 ) then
                     var_plot = "OMB_nobc"
                  end if
                  if ( ivar .eq. 4 ) then
                     var_plot = "OBS_bc"
                  end if
                  if ( ivar .eq. 5 ) then
                     var_plot = "BC"
                  end if
                  if ( ivar .eq. 6 ) then
                     if ( .not. got_oma ) then
                        continue
                     end if
                     var_plot = "OMA"
                  end if
                  if ( ivar .eq. 7 ) then
                     if ( .not. got_oma ) then
                        continue
                     end if
                     var_plot = "AMB"
                  end if
                  if ( nexp .gt. 1 ) then
                     outname = var_plot+"_"+instrument(iinst)+"_ch"+sprinti("%0.4i",plot_ch(ich))+"_"+date(0)+"_"+date(ntime-1)+"_"+cycle_period+"h"
                  else
                     outname = expnames(0)+"_"+var_plot+"_"+instrument(iinst)+"_ch"+sprinti("%0.4i",plot_ch(ich))+"_"+date(0)+"_"+date(ntime-1)+"_"+cycle_period+"h"
                  end if
                  wks = gsn_open_wks(out_type,plotdir+"/"+outname)
                  colormap = "default"
                  gsn_define_colormap(wks,colormap)
                  setvalues wks
                     "wkForegroundColor" : (/0.,0.,0./)
                     "wkBackgroundColor" : (/1.,1.,1./)
                  end setvalues
                  res_stats = res
                  res_stats@xyExplicitLegendLabels = expnames
                  res_stats@xyLineThicknesses      = (/ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 /)      ; default 1.0
                  res_stats@xyMarkerSizes          = (/ 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02 /)   ; default 0.01
                  ;res_stats@gsnLeftString = var_plot
                  res_stats@tiYAxisString = "Number"
                  plot(0)  = gsn_csm_xy (wks,xc,xnum(:,ivar,ich,:),res_stats)
                  res_stats@tiYAxisString = "Mean (K)"
                  plot(1)  = gsn_csm_xy (wks,xc,xmean(:,ivar,ich,:),res_stats)
                  res_stats@tiYAxisString = "Stdv (K)"
                  res_stats@tiXAxisString = date(0)+"  -  "+date(ntime-1)+"   every "+cycle_period+ " h" ;"DATE"
                  plot(2)  = gsn_csm_xy (wks,xc,xstd(:,ivar,ich,:),res_stats)
                  pres                = True              ; mod panel plot 
                  pres@gsnPanelBottom = 0.03              ; add some space at bottom 
                  ;pres@txString = var_plot+"   "+instrument(iinst)+"_chan-"+sprinti("%0.4i",plot_ch(ich))+"_wn-"+sprintf("%6.1f",wavenumber({chan|plot_ch(ich)})) ;+"   "+date(0)+" -- "+date(ntime-1)
                  pres@txString = var_plot+"   "+instrument(iinst)+"_chan-"+sprinti("%0.4i",plot_ch(ich))
                  gsn_panel(wks,plot,(/3,1/),pres)
                  ;delete(pres)
                  ;delete(plot)
                  delete(res_stats)
                  destroy(wks)
               end do ; nvar loop
               if ( .not. plot_group_exp_only ) then
               do iexp = 0, nexp-1
                  ;hcl outname = expnames(iexp)+"_"+instrument(iinst)+"_ch"+sprinti("%0.4i",plot_ch(ich))+"_"+date(0)+"_"+date(ntime-1)+"_"+cycle_period+"h"
                  outname = "ts_rad_omb_oma_"+instrument(iinst)+"_ch"+sprinti("%0.4i",plot_ch(ich))
                  wks = gsn_open_wks(out_type,plotdir+"/"+outname)
                  colormap = "default"
                  gsn_define_colormap(wks,colormap)
                  setvalues wks
                     "wkForegroundColor" : (/0.,0.,0./)
                     "wkBackgroundColor" : (/1.,1.,1./)
                  end setvalues
                  res_stats = res
                  ;res_stats@xyLineThicknesses      = (/ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 /)      ; default 1.0
                  res_stats@xyLineThicknesses      = (/ 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0 /)      ; default 1.0
                  res_stats@xyMarkerSizes          = (/ 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02 /)   ; default 0.01
                  res_stats@xyMarkerColors         = (/ 19, 2, 10, 13, 16, 8, 10, 12, 13, 23/)
                  res_stats@xyLineColors           = (/ 19, 2, 10, 13, 16, 8, 10, 12, 13, 23/)
                  res_stats@xyExplicitLegendLabels = varnames(group_index)
                  res_stats@tiYAxisString = "Number"
                  plot(0)  = gsn_csm_xy (wks,xc,xnum(iexp,group_index,ich,:),res_stats)
                  res_stats@tiYAxisString = "Mean (K)"
                  plot(1)  = gsn_csm_xy (wks,xc,xmean(iexp,group_index,ich,:),res_stats)
                  res_stats@tiYAxisString = "Stdv (K)"
                  res_stats@tiXAxisString = date(0)+"  -  "+date(ntime-1)+"   every "+cycle_period+ " h" ;"DATE"
                  plot(2)  = gsn_csm_xy (wks,xc,xstd(iexp,group_index,ich,:),res_stats)
                  pres                = True              ; mod panel plot 
                  pres@gsnPanelBottom = 0.03              ; add some space at bottom 
                  ;pres@txString = expnames(iexp)+"  "+instrument(iinst)+"_chan-"+sprinti("%0.4i",plot_ch(ich))+"_wn-"+sprintf("%6.1f",wavenumber({chan|plot_ch(ich)})) ;+"   "+date(0)+" -- "+date(ntime-1)
                  pres@txString = expnames(iexp)+"  "+instrument(iinst)+"_chan-"+sprinti("%0.4i",plot_ch(ich))
                  gsn_panel(wks,plot,(/3,1/),pres)
                  delete(pres)
                  ;delete(plot)
                  delete(res_stats)
                  destroy(wks)
               end do ; nexp loop
               end if
            
            end if
         end do  ; end ich loop
      end if
      ;delete(plot)
      ;delete(res_stats)

      ; single-experiment, multi-channel plots
      if ( .not. plot_group_exp_only ) then
      do iexp = 0, nexp-1
         if ( ntime .gt. 1 .and. num(.not.ismissing(xmean(iexp,:,:,:))) .gt. 0 ) then
            if ( num(.not.ismissing(xmean(iexp,0,:,:))) .gt. 0 ) then
               do ivar = 0, nvar-1
                  if ( .not. varplot(ivar) ) then
                     continue
                  end if
                  if ( ivar .eq. 0 ) then
                     var_plot = "OBS"
                  end if
                  if ( ivar .eq. 1 ) then
                     var_plot = "BAK"
                  end if
                  if ( ivar .eq. 2 ) then
                     var_plot = "OMB_bc"
                  end if
                  if ( ivar .eq. 3 ) then
                     var_plot = "OMB_nobc"
                  end if
                  if ( ivar .eq. 4 ) then
                     var_plot = "OBS_bc"
                  end if
                  if ( ivar .eq. 5 ) then
                     var_plot = "BC"
                  end if
                  if ( ivar .eq. 6 ) then
                     if ( .not. got_oma ) then
                        continue
                     end if
                     var_plot = "OMA"
                  end if
                  if ( ivar .eq. 7 ) then
                     if ( .not. got_oma ) then
                        continue
                     end if
                     var_plot = "AMB"
                  end if
                  outname = expnames(iexp)+"_"+var_plot+"_"+instrument(iinst)+"_"+date(0)+"_"+date(ntime-1)+"_"+cycle_period+"h"
                  wks = gsn_open_wks(out_type,plotdir+"/"+outname)
                  colormap = "default"
                  gsn_define_colormap(wks,colormap)
                  setvalues wks
                     "wkForegroundColor" : (/0.,0.,0./)
                     "wkBackgroundColor" : (/1.,1.,1./)
                  end setvalues
                  res_stats = res
                  res_stats@xyExplicitLegendLabels = " ch"+plot_ch
                  ;res_stats@gsnLeftString = var_plot
                  res_stats@tiYAxisString = "Number"
                  plot(0)  = gsn_csm_xy (wks,xc,xnum(iexp,ivar,:,:),res_stats)
                  res_stats@tiYAxisString = "Mean (K)"
                  plot(1)  = gsn_csm_xy (wks,xc,xmean(iexp,ivar,:,:),res_stats)
                  res_stats@tiYAxisString = "Stdv (K)"
                  res_stats@tiXAxisString = date(0)+"  -  "+date(ntime-1)+"   every "+cycle_period+ " h" ;"DATE"
                  plot(2)  = gsn_csm_xy (wks,xc,xstd(iexp,ivar,:,:),res_stats)
                  pres                = True              ; mod panel plot
                  pres@gsnPanelBottom = 0.03              ; add some space at bottom
                  pres@txString = expnames(iexp)+"   "+var_plot+"   "+instrument(iinst)
                  gsn_panel(wks,plot,(/3,1/),pres)

                  delete(pres)
                  delete(res_stats@xyExplicitLegendLabels)
                  ;delete(plot)
                  delete(res_stats)
                  destroy(wks)
               end do
            end if
         end if
      end do
      end if

      ; single-channel, multi-experiment plots
      if ( nexp .gt. 1 ) then
         do ich = 0, num_chan(iinst)-1
            if ( ntime .gt. 1 .and. num(.not.ismissing(xmean(:,:,ich,:))) .gt. 0 ) then
               if ( num(.not.ismissing(xmean(:,0,ich,:))) .gt. 0 ) then
                  do ivar = 0, nvar-1
                     if ( .not. varplot(ivar) ) then
                        continue
                     end if
                     if ( ivar .eq. 0 ) then
                        var_plot = "OBS"
                     end if
                     if ( ivar .eq. 1 ) then
                        var_plot = "BAK"
                     end if
                     if ( ivar .eq. 2 ) then
                        var_plot = "OMB_bc"
                     end if
                     if ( ivar .eq. 3 ) then
                        var_plot = "OMB_nobc"
                     end if
                     if ( ivar .eq. 4 ) then
                        var_plot = "OBS_bc"
                     end if
                     if ( ivar .eq. 5 ) then
                        var_plot = "BC"
                     end if
                     if ( ivar .eq. 6 ) then
                        if ( .not. got_oma ) then
                           continue
                        end if
                        var_plot = "OMA"
                     end if
                     if ( ivar .eq. 7 ) then
                        if ( .not. got_oma ) then
                           continue
                        end if
                        var_plot = "AMB"
                     end if
                     outname = "allexp_"+var_plot+"_"+instrument(iinst)+"_ch"+sprinti("%0.4i",plot_ch(ich))+"_"+date(0)+"_"+date(ntime-1)+"_"+cycle_period+"h"
                     wks = gsn_open_wks(out_type,plotdir+"/"+outname)
                     colormap = "default"
                     gsn_define_colormap(wks,colormap)
                     setvalues wks
                        "wkForegroundColor" : (/0.,0.,0./)
                        "wkBackgroundColor" : (/1.,1.,1./)
                     end setvalues
                     res_stats = res
                     res_stats@xyLineThicknesses      = (/ 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0 /)      ; default 1.0
                     res_stats@xyMarkerSizes          = (/ 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02 /)   ; default 0.01
                     res_stats@xyMarkerColors         = (/ 2, 10, 19, 13, 16, 8, 10, 12, 13, 23/)
                     res_stats@xyLineColors           = (/ 2, 10, 19, 13, 16, 8, 10, 12, 13, 23/)
                     res_stats@xyExplicitLegendLabels = expnames
                     ;res_stats@gsnLeftString = var_plot
                     res_stats@tiYAxisString = "Number"
                     plot(0)  = gsn_csm_xy (wks,xc,xnum(:,ivar,ich,:),res_stats)
                     res_stats@tiYAxisString = "Mean (K)"
                     plot(1)  = gsn_csm_xy (wks,xc,xmean(:,ivar,ich,:),res_stats)
                     res_stats@tiYAxisString = "Stdv (K)"
                     res_stats@tiXAxisString = date(0)+"  -  "+date(ntime-1)+"   every "+cycle_period+ " h" ;"DATE"
                     plot(2)  = gsn_csm_xy (wks,xc,xstd(:,ivar,ich,:),res_stats)
                     pres                = True              ; mod panel plot
                     pres@gsnPanelBottom = 0.03              ; add some space at bottom
                     ;pres@txString = var_plot+"   "+instrument(iinst)+"_chan-"+sprinti("%0.4i",plot_ch(ich))+"_wn-"+sprintf("%6.1f",wavenumber({chan|plot_ch(ich)}))
                     pres@txString = var_plot+"   "+instrument(iinst)+"_chan-"+sprinti("%0.4i",plot_ch(ich))
                     gsn_panel(wks,plot,(/3,1/),pres)
                     delete(pres)
                     ;delete(plot)
                     delete(res_stats)
                     destroy(wks)
                  end do
               end if
            end if
         end do
      end if
      ;delete(res_stats)
      ;delete(wavenumber)
      delete(plot_ch)
      delete(xnum)
      delete(xmean)
      delete(xrms)
      delete(xstd)
      delete(npts)
      delete(npts_sele)
      delete(npts_land)
      delete(npts_sea)
      delete(npts_qc)
      delete(npts_qc_anl)
   end do  ; end ninst_loop
