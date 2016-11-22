; This utility merges output from converted grb files and extracted fields from wrf files
; To enhance fields included, modify metadata tables below to add additional entries to
; each component.
; G. Romine 2011-12

 load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
begin
 ;an_date   = "2015081712"
 an_date = getenv("DATE")
 ;file_type = "fg"
 file_type = "an"
 ;da_dir = "/glade/scratch/hclin/CONUS/wrfda/expdir/start2015060812/ob_ascii/hyb_e50_amsua/"+an_date
 da_dir = getenv("DOMAINPATH")
 grib_fil_path = da_dir+"/unipost_"+file_type
 out_path = "/glade/scratch/hclin/CONUS/wrfda/postdir/webplot"
 nfils = 1
system("\rm -f "+out_path+"/"+file_type+"_"+an_date+"_all.nc")
 cnew = addfile(out_path+"/"+file_type+"_"+an_date+"_all.nc","c")   ; new output
 fil  = addfile(da_dir+"/"+file_type+"_"+an_date+".nc","r")       ; orig diag file
; These are the fields in the original diag field
 if ( file_type .eq. "fg" ) then
   pull_field_names = (/"T2", "Q2", "U10", "V10", "XLAT", "XLONG", "U_LEV1", "V_LEV1", \
                        "NCL_REFL", "VINT_GRAUP", "T_LEV1", "Q_LEV1"/)
 else
   pull_field_names = (/"T2", "Q2", "U10", "V10", "XLAT", "XLONG", "U_LEV1", "V_LEV1", \
                        "RAINC", "RAINNC", "NCL_REFL", "VINT_GRAUP", "T_LEV1", "Q_LEV1"/)
 end if
; these are in the *TWO* grib files
 two_3d_field_names = (/"CAPE_GDS3_SPDY", "CIN_GDS3_SPDY"/)
 two_2d_field_names = (/"HLCY_GDS3_HTGY", "DPT_GDS3_SPDY", "PRMSL_GDS3_MSL", "P_WAT_GDS3_EATM" /)
 two_out_3d_field_names = (/"MLCAPE", "MLCIN"/)
 two_out_2d_field_names = (/"SRH3", "DEWPOINT_2M", "MSL_PRES", "P_WAT"/)
; these are in the *PRS* grib files
 prs_3d_field_names = (/"HGT_GDS3_ISBL", "TMP_GDS3_ISBL", "DPT_GDS3_ISBL", \
                        "U_GRD_GDS3_ISBL", "V_GRD_GDS3_ISBL", "ABS_V_GDS3_ISBL"/)
 prs_2d_field_names = (/"g3_rot_2"/)
 prs_1d_field_names = (/"lv_ISBL2"/) 
 prs_lev_copy       = (/200, 250, 300, 500, 700, 850, 925/) ; will only grab these levels
 prs_out_3d_field_names = (/"GEOP_HGT_PRS", "TEMP_PRS", "DEWPOINT_PRS", "U_GRID_PRS", \
                           "V_GRID_PRS", "ABS_VORT_PRS"/)
 prs_out_2d_field_names = (/"grid_wind_rotate"/)
; Only testing assembly of one time here, so grab the needed time from 
; fil and write those vars to cnew
 npulls = dimsizes(pull_field_names)
 ; step through each field
  do i=0,npulls-1
   print("   Extracting 3d variable "+pull_field_names(i))
    pull_var = fil->$pull_field_names(i)$(:,:,:)
    dims = dimsizes(pull_var)
; write to new file
   cnew->$pull_field_names(i)$ = pull_var
   delete(pull_var)
   delete(dims)
  end do
; grab the new vars from fil and add to cnew
 npulls = dimsizes(two_3d_field_names)
; step through each field
  do i=0,npulls-1
   ; read fields from each file, for the same pull_var and then write it
   print("   Extracting 3d variable "+two_3d_field_names(i))
    do j=0,nfils-1
      fil_t = addfile(grib_fil_path+"/two.nc","r")
      pull_var = fil_t->$two_3d_field_names(i)$(0,:,:)
      if (j .eq. 0) then
        dims = dimsizes(pull_var)
        alltimes_var = new ( (/nfils,dims(0),dims(1)/), typeof(pull_var) )
      end if
      alltimes_var(j,:,:) = pull_var(:,:)
      delete(pull_var)
      delete(fil_t)
    end do
; get rid of some of the bad attributes
    delete(alltimes_var@long_name)
    delete(alltimes_var@model)
    delete(alltimes_var@center)
    delete(alltimes_var@parameter_number)
    delete(alltimes_var@parameter_table_version)
    delete(alltimes_var@level_indicator)
; write to new file
   cnew->$two_out_3d_field_names(i)$ = alltimes_var
   delete(alltimes_var)
   delete(dims)
  end do
 npulls = dimsizes(two_2d_field_names)
; step through each field
  do i=0,npulls-1
   print("   Extracting 2d variable "+two_2d_field_names(i))
    do j=0,nfils-1
      fil_t = addfile(grib_fil_path+"/two.nc","r")
      pull_var = fil_t->$two_2d_field_names(i)$(:,:)
      if (j .eq. 0) then
        dims = dimsizes(pull_var)
        alltimes_var = new ( (/nfils,dims(0),dims(1)/), typeof(pull_var) )
      end if
      alltimes_var(j,:,:) = pull_var(:,:)
      delete(pull_var)
      delete(fil_t)
    end do
; get rid of some of the bad attributes
    delete(alltimes_var@long_name)
    delete(alltimes_var@model)
    delete(alltimes_var@center)
    delete(alltimes_var@parameter_number)
    delete(alltimes_var@parameter_table_version)
    delete(alltimes_var@level_indicator)
; write to new file
   cnew->$two_out_2d_field_names(i)$ = alltimes_var
   delete(alltimes_var)
   delete(dims)
  end do
; Add the pressure level fields
 npulls = dimsizes(prs_3d_field_names)
; step through each field
  do i=0,npulls-1
   ; read fields from each file, for the same pull_var and then write it
   print("   Extracting 3d variable "+prs_3d_field_names(i))
    do j=0,nfils-1
      fil_p = addfile(grib_fil_path+"/prs.nc","r")
      pull_vert = fil_p->$prs_1d_field_names(0)$
      prs_indices = ind_nearest_coord(prs_lev_copy, pull_vert,0)
      nlevs = dimsizes(prs_indices)
      pull_var = fil_p->$prs_3d_field_names(i)$(prs_indices,:,:)
      if (j .eq. 0) then
        dims = dimsizes(pull_var)
        alltimes_var = new ( (/nfils,dims(0),dims(1),dims(2)/), typeof(pull_var) )
      end if
      alltimes_var(j,:,:,:) = pull_var(:,:,:)
      delete(pull_var)
      delete(fil_p)
    end do
; get rid of some of the bad attributes
    delete(alltimes_var@long_name)
    delete(alltimes_var@model)
    delete(alltimes_var@center)
    delete(alltimes_var@parameter_number)
    delete(alltimes_var@parameter_table_version)
    delete(alltimes_var@level_indicator)
; write to new file
   cnew->$prs_out_3d_field_names(i)$ = alltimes_var
   delete(alltimes_var)
   delete(dims)
  end do

; Add a time
    pull_var = fil->Times
    dims = dimsizes(pull_var)
;    alltimes_var = new ( (/dims(0),dims(1)/), typeof(pull_var) )
;    alltimes_var = pull_var(:,:)
  cnew->Times = pull_var
  delete(pull_var)
  delete(dims)
  delete(fil)

; Add isotachs for the pressure levels
 ; read fields from each file, for the same pull_var and then write it
 print("   Extracting isotachs ")
    do j=0,nfils-1
      fil_p = addfile(grib_fil_path+"/prs.nc","r")
      pull_vert = fil_p->$prs_1d_field_names(0)$
      prs_indices = ind_nearest_coord(prs_lev_copy, pull_vert,0)
      nlevs = dimsizes(prs_indices)
      u_grid = fil_p->U_GRD_GDS3_ISBL(prs_indices,:,:)
      v_grid = fil_p->V_GRD_GDS3_ISBL(prs_indices,:,:)
      pull_var = sqrt(u_grid^2.0+v_grid^2.0)
      if (j .eq. 0) then
        dims = dimsizes(pull_var)
        alltimes_var = new ( (/nfils,dims(0),dims(1),dims(2)/), typeof(pull_var) )
      end if
      alltimes_var(j,:,:,:) = pull_var(:,:,:)
      delete(pull_var)
      delete(fil_p)
    end do
; add some attributes
   alltimes_var@units = "m/s"
   alltimes_var@description = "Isotachs at mandatory pressure levels"
; write to new file
   cnew->ISOTACH_PRS = alltimes_var
   delete(alltimes_var)
   delete(dims)
   delete(u_grid)
   delete(v_grid)
end 
