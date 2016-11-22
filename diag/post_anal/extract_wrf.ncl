; ncl script to pull out select fields from a wrfinput file
; and save them to a smaller file
begin
; Read the desired fields from in_new and over-write the fields
; in the template file

 ;an_date     = "2015081712"
 an_date = getenv("DATE")
 ;da_dir = "/glade/scratch/hclin/CONUS/wrfda/expdir/start2015060812/ob_ascii/hyb_e50_amsua/"+an_date
 da_dir = getenv("DOMAINPATH")
 ;file_type = "fg"
 file_type = "an"
 if ( file_type .eq. "fg" ) then
    file_in  = "fg"
    file_out = "fg_"+an_date
    pull_field_names = (/"T2", "Q2", "U10", "V10",  \
                         "XLAT", "XLONG"/)
 else
    file_in =  "wrfvar_output_d01_"+an_date
    file_out = "an_"+an_date
    pull_field_names = (/"T2", "Q2", "U10", "V10",  \
                         "RAINC", "RAINNC", "XLAT", "XLONG"/)
 end if
 npulls = dimsizes(pull_field_names)

 fil   = addfiles(da_dir+"/"+file_in+".nc", "r")
 nfils = 1

  ;files = "wrfinput_d01"
  ;allfiles = systemfunc("ls " + files)
  ;nfils = dimsizes(allfiles)
  ;do i=0,nfils-1
  ; allfiles(i) = allfiles(i)+".nc"
  ;end do
  ;fil   = addfiles(allfiles, "r")
  ListSetType(fil, "join")
  ;print(nfils)

; REFL_10CM (Time,bottom_top,south_north,west_east)
; 
; Below will dump out the data to a file for replotting later
system("\rm -f "+da_dir+"/"+file_out+".nc")
    cnew = addfile(da_dir+"/"+file_out+".nc","c")
; Save some id information?

; step through each desired field
  do i=0,npulls-1
   print("   Extracting 3d variable "+pull_field_names(i))
   do fil_num=0,nfils-1
;    print(" reading file "+allfiles(fil_num))
; dimensions are ncljoin, Time, south_north, west_east
    pull_var = fil[fil_num]->$pull_field_names(i)$(:,:,:,:)
    dims = dimsizes(pull_var)
    if (fil_num .eq. 0) then  ; first iteration, make var
     alltimes_var = new ( (/nfils,dims(2),dims(3)/), typeof(pull_var) )
    end if
;    printVarSummary(pull_var)
    alltimes_var(fil_num,:,:) = pull_var(0,0,:,:)
    delete(pull_var)
   end do
; write to new file
   cnew->$pull_field_names(i)$ = alltimes_var
   delete(alltimes_var)
   delete(dims)
  end do
; Add the column max reflectivity? 
;  print("reflectivity...")
;  do fil_num=0,nfils-1
;    pull_var = fil[fil_num]->REFL_10CM
;    dims = dimsizes(pull_var)
;    if (fil_num .eq. 0) then  ; first iteration, make var
;     alltimes_var = new ( (/nfils,dims(2),dims(3)/), typeof(pull_var) )
;    end if
;;    alltimes_var(fil_num,:,:) = pull_var(0,0,:,:)
;    temp_var = pull_var(0,:,:,:)
;    alltimes_var(fil_num,:,:) = dim_max_n(temp_var,0)
;    delete(temp_var)
;    delete(pull_var)
;  end do
; Since we don't have a reflectivity in the wrfinput file for
; an analysis, will use the ncl built in to get something
; to plot
  do fil_num=0,nfils-1
    ;pull_var = fil[fil_num]->H_DIABATIC
    pull_var = fil[fil_num]->QVAPOR
    pull_var = 0.0
    dims = dimsizes(pull_var)
    if (fil_num .eq. 0) then  ; first iteration, make var
      alltimes_var = new ( (/nfils,dims(2),dims(3)/), typeof(pull_var) )
      delete(pull_var)
    end if
    pull_var1 = fil[fil_num]->T
    pull_var2 = fil[fil_num]->P
    pull_var3 = fil[fil_num]->PB
    qv = fil[fil_num]->QVAPOR
    qr = fil[fil_num]->QRAIN
    qs = fil[fil_num]->QSNOW
    qg = fil[fil_num]->QGRAUP
    th = pull_var1 + 300.
    P = pull_var2 + pull_var3
    tk = wrf_tk(P,th)
    ivarint  = 0   ; or 1
    iliqskin = 0 
    pull_var = wrf_dbz ( P, tk, qv, qr, qs, qg, ivarint, iliqskin) 
    printVarSummary(pull_var)
    temp_var = pull_var(0,:,:,:)
    alltimes_var(fil_num,:,:) = dim_max_n(temp_var,0)
  end do 
  cnew->NCL_REFL = alltimes_var
  delete(alltimes_var)
  delete(dims)
; Add the column integrated graupel 
; NOTE this is in the state already GRPL_MAX - but I was seeing
; different values - so need to check the code that is
; computing this in the SRD calcs
  print("graupel...")
  do fil_num=0,nfils-1
    pull_var = fil[fil_num]->QGRAUP
    dims = dimsizes(pull_var)
    if (fil_num .eq. 0) then  ; first iteration, make var
     alltimes_var = new ( (/nfils,dims(2),dims(3)/), typeof(pull_var) )
    end if
    temp_var = pull_var(0,:,:,:)
    alltimes_var(fil_num,:,:) = dim_sum_n(temp_var,0)
    delete(temp_var)
    delete(pull_var)
  end do
  cnew->VINT_GRAUP = alltimes_var
  delete(alltimes_var)
  delete(dims)

; Add the lowest model layer temp
  print("temp at lev 1...")
  do fil_num=0,nfils-1
    pull_var1 = fil[fil_num]->T
    pull_var2 = fil[fil_num]->P
    pull_var3 = fil[fil_num]->PB
    th = pull_var1 + 300.
    P = pull_var2 + pull_var3
    pull_var = wrf_tk(P,th)
    pull_var = pull_var-273.16
    pull_var@units = "C"
    dims = dimsizes(pull_var)
    if (fil_num .eq. 0) then  ; first iteration, make var
     alltimes_var = new ( (/nfils,dims(2),dims(3)/), typeof(pull_var) )
    end if
    temp_var = pull_var(0,0,:,:)
    alltimes_var(fil_num,:,:) = temp_var
    delete(temp_var)
    delete(pull_var)
    delete(pull_var1)
    delete(pull_var2)
    delete(pull_var3)
    delete(th)
    delete(P)
  end do
  cnew->T_LEV1 = alltimes_var
  delete(alltimes_var)
  delete(dims)

; Add the lowest model layer water vapor
  print("qvap at lev 1...")
  do fil_num=0,nfils-1
    pull_var = fil[fil_num]->QVAPOR
    dims = dimsizes(pull_var)
    if (fil_num .eq. 0) then  ; first iteration, make var
     alltimes_var = new ( (/nfils,dims(2),dims(3)/), typeof(pull_var) )
    end if
    temp_var = pull_var(0,0,:,:)
    alltimes_var(fil_num,:,:) = temp_var
    delete(temp_var)
    delete(pull_var)
  end do
  cnew->Q_LEV1 = alltimes_var
  delete(alltimes_var)
  delete(dims)

; Add the lowest model layer u
  print("u at lev 1...")
  do fil_num=0,nfils-1
    pull_var = fil[fil_num]->U
    dims = dimsizes(pull_var)
    if (fil_num .eq. 0) then  ; first iteration, make var
     alltimes_var = new ( (/nfils,dims(2),dims(3)/), typeof(pull_var) )
    end if
    temp_var = pull_var(0,0,:,:)
    alltimes_var(fil_num,:,:) = temp_var
    delete(temp_var)
    delete(pull_var)
  end do
  cnew->U_LEV1 = alltimes_var
  delete(alltimes_var)
  delete(dims)

; Add the lowest model layer v
  print("v at lev 1...")
  do fil_num=0,nfils-1
    pull_var = fil[fil_num]->V
    dims = dimsizes(pull_var)
    if (fil_num .eq. 0) then  ; first iteration, make var
     alltimes_var = new ( (/nfils,dims(2),dims(3)/), typeof(pull_var) )
    end if
    temp_var = pull_var(0,0,:,:)
    alltimes_var(fil_num,:,:) = temp_var
    delete(temp_var)
    delete(pull_var)
  end do
  cnew->V_LEV1 = alltimes_var
  delete(alltimes_var)
  delete(dims)

; Add the times
  print("times...")
  do fil_num=0,nfils-1
    pull_var = fil[fil_num]->Times
    dims = dimsizes(pull_var)
    if (fil_num .eq. 0) then  ; first iteration, make var
     alltimes_var = new ( (/nfils,dims(1)/), typeof(pull_var) )
    end if
    alltimes_var(fil_num,:) = pull_var(0,:)
    delete(pull_var)
  end do
  cnew->Times = alltimes_var
  delete(alltimes_var)
  delete(dims)
    
end
