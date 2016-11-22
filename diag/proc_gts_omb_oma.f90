program proc_gts_omb_oma

   implicit none

   integer            :: iunit = 16
   character(len=512) :: filename
   character(len=12)  :: varname, typename
   character(len=40)  :: stats_prefix
   character(len=10)  :: cdate

   integer, parameter :: maxtype = 18
   integer, parameter :: imiss = -999
   real,    parameter :: rmiss = -999.0
   integer, parameter :: nstdp = 18
   real, parameter    :: std_plevels(nstdp) = (/ 1000.0, 925.0, 850.0, 700.0, 600.0, 500.0, 400.0, &
                                                  300.0, 250.0, 200.0, 150.0, 100.0,  70.0,  50.0, &
                                                   30.0,  20.0,  10.0,   0.0 /)
      character(len=14), parameter :: type_names(maxtype) = (/ &
         "sound         ", &
         "profiler      ", &
         "airep         ", &
         "pilot         ", &
         "geoamv        ", &
         "polaramv      ", &
         "synop         ", &
         "metar         ", &
         "ships         ", &
         "buoy          ", &
         "sonde_sfc     ", &
         "qscat         ", &
         "gpsref        ", &
         "gpspw         ", &
         "tamdar_sfc    ", &
         "tamdar        ", &
         "airsr         ", &
         "satem         "  &
      /)

   integer      :: num_obs, ios, itype, ipres
   character*20 :: iv_type

   character*5  :: stn_id
   integer      :: n, k, kk, l, levels, dummy_i
   real         :: lat, lon, press, height, dummy
   real         :: tpw_obs, tpw_inv, tpw_err, tpw_inc
   real         :: u_obs, u_inv, u_error, u_inc, &
                   v_obs, v_inv, v_error, v_inc, &
                   t_obs, t_inv, t_error, t_inc, &
                   p_obs, p_inv, p_error, p_inc, &
                   q_obs, q_inv, q_error, q_inc, &
                   spd_obs, spd_inv, spd_err, spd_inc,   &
                   ref_obs, ref_inv, ref_error, ref_inc, &
                   rain_obs, rain_inv, rain_error, rain_inc, zk
   integer     :: u_qc, v_qc, t_qc, p_qc, q_qc, tpw_qc, spd_qc, ref_qc, rain_qc

   type stats_value
     integer     :: num
     real        :: mean
     real        :: rmse
   end type stats_value

   type(stats_value) :: stats_prf_u(maxtype,nstdp,2)
   type(stats_value) :: stats_prf_v(maxtype,nstdp,2)
   type(stats_value) :: stats_prf_t(maxtype,nstdp,2)
   type(stats_value) :: stats_prf_p(maxtype,nstdp,2)
   type(stats_value) :: stats_prf_q(maxtype,nstdp,2)
   type(stats_value) :: stats_prf_ref(nstdp,2)

   type(stats_value) :: stats_u(maxtype,2)
   type(stats_value) :: stats_v(maxtype,2)
   type(stats_value) :: stats_t(maxtype,2)
   type(stats_value) :: stats_p(maxtype,2)
   type(stats_value) :: stats_q(maxtype,2)
   type(stats_value) :: stats_pw(2)
   type(stats_value) :: stats_ref(2)

   stats_prf_u(:,:,:)%num  = 0
   stats_prf_v(:,:,:)%num  = 0
   stats_prf_t(:,:,:)%num  = 0
   stats_prf_p(:,:,:)%num  = 0
   stats_prf_q(:,:,:)%num  = 0
   stats_prf_ref(:,:)%num  = 0

   stats_prf_u(:,:,:)%mean = rmiss
   stats_prf_v(:,:,:)%mean = rmiss
   stats_prf_t(:,:,:)%mean = rmiss
   stats_prf_p(:,:,:)%mean = rmiss
   stats_prf_q(:,:,:)%mean = rmiss
   stats_prf_ref(:,:)%mean = rmiss

   stats_prf_u(:,:,:)%rmse = rmiss
   stats_prf_v(:,:,:)%rmse = rmiss
   stats_prf_t(:,:,:)%rmse = rmiss
   stats_prf_p(:,:,:)%rmse = rmiss
   stats_prf_q(:,:,:)%rmse = rmiss
   stats_prf_ref(:,:)%rmse = rmiss

   stats_u(:,:)%num  = 0
   stats_v(:,:)%num  = 0
   stats_t(:,:)%num  = 0
   stats_p(:,:)%num  = 0
   stats_q(:,:)%num  = 0
   stats_pw (:)%num  = 0
   stats_ref(:)%num  = 0

   stats_u(:,:)%mean = rmiss
   stats_v(:,:)%mean = rmiss
   stats_t(:,:)%mean = rmiss
   stats_p(:,:)%mean = rmiss
   stats_q(:,:)%mean = rmiss
   stats_pw (:)%mean = rmiss
   stats_ref(:)%mean = rmiss

   stats_u(:,:)%rmse = rmiss
   stats_v(:,:)%rmse = rmiss
   stats_t(:,:)%rmse = rmiss
   stats_p(:,:)%rmse = rmiss
   stats_q(:,:)%rmse = rmiss
   stats_pw (:)%rmse = rmiss
   stats_ref(:)%rmse = rmiss

   filename = 'gts_omb_oma'
   open(unit=iunit,file=trim(filename),form='formatted',status='old',iostat=ios)
   if (ios /= 0) then
      write(0,*) "Cannot open file "//trim(filename)
      stop
   end if

   read(iunit,'(a10)') cdate
write(0,*) cdate

   reports: do

      read(iunit,'(a20,i8)', end = 999, err = 1000) iv_type, num_obs

write(0,*) iv_type, num_obs

      itype = ob_index(trim(adjustl(iv_type)))

      select case (trim(adjustl(iv_type)))

      case ('synop', 'ships', 'buoy', 'metar', 'sonde_sfc', 'tamdar_sfc')
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)')levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, press, &       ! Lat/lon, pressure
                     u_obs, u_inv, u_qc, u_error, u_inc, &
                     v_obs, v_inv, v_qc, v_error, v_inc, &
                     t_obs, t_inv, t_qc, t_error, t_inc, &
                     p_obs, p_inv, p_qc, p_error, p_inc, &
                     q_obs, q_inv, q_qc, q_error, q_inc

                  ipres = pres_index(nstdp, std_plevels, press*0.01)
                  if ( ipres > 0 ) then
                     call calc_stats(stats_prf_u(itype,ipres,1), u_inv, u_qc)
                     call calc_stats(stats_prf_v(itype,ipres,1), v_inv, v_qc)
                     call calc_stats(stats_prf_t(itype,ipres,1), t_inv, t_qc)
                     call calc_stats(stats_prf_p(itype,ipres,1), p_inv, p_qc)
                     call calc_stats(stats_prf_q(itype,ipres,1), q_inv*1000.0, q_qc)
                     call calc_stats(stats_prf_u(itype,ipres,2), u_inc, u_qc)
                     call calc_stats(stats_prf_v(itype,ipres,2), v_inc, v_qc)
                     call calc_stats(stats_prf_t(itype,ipres,2), t_inc, t_qc)
                     call calc_stats(stats_prf_p(itype,ipres,2), p_inc, p_qc)
                     call calc_stats(stats_prf_q(itype,ipres,2), q_inc*1000.0, q_qc)
                  end if

                  call calc_stats(stats_u(itype,1), u_inv, u_qc)
                  call calc_stats(stats_v(itype,1), v_inv, v_qc)
                  call calc_stats(stats_t(itype,1), t_inv, t_qc)
                  call calc_stats(stats_p(itype,1), p_inv, p_qc)
                  call calc_stats(stats_q(itype,1), q_inv*1000.0, q_qc)
                  call calc_stats(stats_u(itype,2), u_inc, u_qc)
                  call calc_stats(stats_v(itype,2), v_inc, v_qc)
                  call calc_stats(stats_t(itype,2), t_inc, t_qc)
                  call calc_stats(stats_p(itype,2), p_inc, p_qc)
                  call calc_stats(stats_q(itype,2), q_inc*1000.0, q_qc)
               end do
            end do
         end if

         cycle reports

      case ('pilot', 'profiler', 'geoamv', 'qscat', 'polaramv')
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)')levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                      kk, l, stn_id, &          ! Station
                      lat, lon, press, &        ! Lat/lon, pressure
                      u_obs, u_inv, u_qc, u_error, u_inc, &
                      v_obs, v_inv, v_qc, v_error, v_inc

                  ipres = pres_index(nstdp, std_plevels, press*0.01)
                  if ( ipres > 0 ) then
                     call calc_stats(stats_prf_u(itype,ipres,1), u_inv, u_qc)
                     call calc_stats(stats_prf_v(itype,ipres,1), v_inv, v_qc)
                     call calc_stats(stats_prf_u(itype,ipres,2), u_inc, u_qc)
                     call calc_stats(stats_prf_v(itype,ipres,2), v_inc, v_qc)
                  end if

                  call calc_stats(stats_u(itype,1), u_inv, u_qc)
                  call calc_stats(stats_v(itype,1), v_inv, v_qc)
                  call calc_stats(stats_u(itype,2), u_inc, u_qc)
                  call calc_stats(stats_v(itype,2), v_inc, v_qc)
               end do
            end do
         end if
         cycle reports

      case ('gpspw' )
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)')levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, dummy, &       ! Lat/lon, dummy
                     tpw_obs, tpw_inv, tpw_qc, tpw_err, tpw_inc

                  call calc_stats(stats_pw(1), tpw_inv, tpw_qc)
                  call calc_stats(stats_pw(2), tpw_inc, tpw_qc)
               end do
            end do
         end if
         cycle reports

      case ('sound', 'tamdar', 'airep')
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)')levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, press, &       ! Lat/lon, dummy
                     u_obs, u_inv, u_qc, u_error, u_inc, &
                     v_obs, v_inv, v_qc, v_error, v_inc, &
                     t_obs, t_inv, t_qc, t_error, t_inc, &
                     q_obs, q_inv, q_qc, q_error, q_inc

                  ipres = pres_index(nstdp, std_plevels, press*0.01)
                  if ( ipres > 0 ) then
                     call calc_stats(stats_prf_u(itype,ipres,1), u_inv, u_qc)
                     call calc_stats(stats_prf_v(itype,ipres,1), v_inv, v_qc)
                     call calc_stats(stats_prf_t(itype,ipres,1), t_inv, t_qc)
                     call calc_stats(stats_prf_q(itype,ipres,1), q_inv*1000.0, q_qc)
                     call calc_stats(stats_prf_u(itype,ipres,2), u_inc, u_qc)
                     call calc_stats(stats_prf_v(itype,ipres,2), v_inc, v_qc)
                     call calc_stats(stats_prf_t(itype,ipres,2), t_inc, t_qc)
                     call calc_stats(stats_prf_q(itype,ipres,2), q_inc*1000.0, q_qc)
                  end if

                  call calc_stats(stats_u(itype,1), u_inv, u_qc)
                  call calc_stats(stats_v(itype,1), v_inv, v_qc)
                  call calc_stats(stats_t(itype,1), t_inv, t_qc)
                  call calc_stats(stats_q(itype,1), q_inv*1000.0, q_qc)
                  call calc_stats(stats_u(itype,2), u_inc, u_qc)
                  call calc_stats(stats_v(itype,2), v_inc, v_qc)
                  call calc_stats(stats_t(itype,2), t_inc, t_qc)
                  call calc_stats(stats_q(itype,2), q_inc*1000.0, q_qc)
               end do 
            end do
         end if
     cycle reports

      case ('ssmir' )
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)')levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, dummy, &       ! Lat/lon, dummy
                     spd_obs, spd_inv, spd_qc, spd_err, spd_inc, &
                     tpw_obs, tpw_inv, tpw_qc, tpw_err, tpw_inc
               end do
            end do
         end if
         cycle reports

      case ('ssmit' )
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)')levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,7(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, dummy, &       ! Lat/lon, dummy
                     dummy, dummy, dummy_i, dummy, dummy, &
                     dummy, dummy, dummy_i, dummy, dummy, &
                     dummy, dummy, dummy_i, dummy, dummy, &
                     dummy, dummy, dummy_i, dummy, dummy, &
                     dummy, dummy, dummy_i, dummy, dummy, &
                     dummy, dummy, dummy_i, dummy, dummy, &
                     dummy, dummy, dummy_i, dummy, dummy
               end do
            end do
         end if
         cycle reports

      case ('satem' )
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)') levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, press, &       ! Lat/lon, dummy
                     tpw_obs, tpw_inv, tpw_qc, tpw_err, tpw_inc
               end do  
            end do
         end if
         cycle reports

      case ('ssmt1' , 'ssmt2' )
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)') levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, dummy, &       ! Lat/lon, dummy
                     dummy,dummy, dummy_i, dummy, dummy
               end do 
            end do
         end if
         cycle reports

      case ('bogus' )
         ! TC Bogus data is written in two records
         ! 1st record holds info about surface level
         ! 2nd is for upper air

         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)') levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                      kk,l, stn_id, &          ! Station
                      lat, lon, press, &       ! Lat/lon, dummy
                      u_obs, u_inv, u_qc, u_error, u_inc, &
                      v_obs, v_inv, v_qc, v_error, v_inc
               end do
               read(iunit,'(i8)') levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, press, &       ! Lat/lon, dummy
                     u_obs, u_inv, u_qc, u_error, u_inc, &
                     v_obs, v_inv, v_qc, v_error, v_inc
               end do
            end do
         end if
         cycle reports

      case ('airsr' )
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)') levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, press, &       ! Lat/lon, dummy
                     t_obs, t_inv, t_qc, t_error, t_inc, &
                     q_obs, q_inv, q_qc, q_error, q_inc
               end do
            end do
         end if
         cycle reports

      case ('gpsref' )
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)') levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, height, &       ! Lat/lon, height
                     ref_obs, ref_inv, ref_qc, ref_error, ref_inc
                  call calc_stats(stats_ref(1), ref_inv, ref_qc)
                  call calc_stats(stats_ref(2), ref_inc, ref_qc)
               end do
            end do
         end if
         cycle reports

      case ('rain' )
         if (num_obs > 0) then
            do n = 1, num_obs
               read(iunit,'(i8)') levels
               do k = 1, levels
                  read(iunit,'(2i8,a5,2f9.2,f17.7,5(2f17.7,i8,2f17.7))', err= 1000)&
                     kk,l, stn_id, &          ! Station
                     lat, lon, height, &       ! Lat/lon, height
                     rain_obs, rain_inv, rain_qc, rain_error, rain_inc
               end do
            end do
         end if
         cycle reports

      case default;
         write(0, '(a,a20,a,i3)') &
            'Got unknown obs_type string:', trim(iv_type),' on unit ',iunit
         stop

      end select
   end do reports

999 continue
   close (iunit)

   do k = 1, 2 !1=omb, 2=oma
      select case ( k )
         case ( 1 )
            stats_prefix = 'omb_stats_prf_'
         case ( 2 )
            stats_prefix = 'oma_stats_prf_'
      end select
      do n = 1, maxtype
         typename = type_names(n)
         if ( sum(stats_prf_u(n,:,k)%num) > 0 ) then
            varname = 'u'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats_prf(filename, stats_prf_u(n,:,k))
         end if
         if ( sum(stats_prf_v(n,:,k)%num) > 0 ) then
            varname = 'v'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats_prf(filename, stats_prf_v(n,:,k))
         end if
         if ( sum(stats_prf_t(n,:,k)%num) > 0 ) then
            varname = 't'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats_prf(filename, stats_prf_t(n,:,k))
         end if
         if ( sum(stats_prf_p(n,:,k)%num) > 0 ) then
            varname = 'p'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats_prf(filename, stats_prf_p(n,:,k))
         end if
         if ( sum(stats_prf_q(n,:,k)%num) > 0 ) then
            varname = 'q'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats_prf(filename, stats_prf_q(n,:,k))
         end if
      end do !ntype
   end do !omb/oma

   do k = 1, 2 !1=omb, 2=oma
      select case ( k )
         case ( 1 )
            stats_prefix = 'omb_stats_'
         case ( 2 )
            stats_prefix = 'oma_stats_'
      end select
      do n = 1, maxtype
         typename = type_names(n)
         if ( stats_u(n,k)%num > 0 ) then
            varname = 'u'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats(filename, stats_u(n,k))
         end if
         if ( stats_v(n,k)%num > 0 ) then
            varname = 'v'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats(filename, stats_v(n,k))
         end if
         if ( stats_t(n,k)%num > 0 ) then
            varname = 't'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats(filename, stats_t(n,k))
         end if
         if ( stats_p(n,k)%num > 0 ) then
            varname = 'p'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats(filename, stats_p(n,k))
         end if
         if ( stats_q(n,k)%num > 0 ) then
            varname = 'q'
            filename = trim(stats_prefix)//trim(varname)//'_'//trim(typename)
            call write_stats(filename, stats_q(n,k))
         end if
      end do !ntype
      if ( stats_pw(k)%num > 0 ) then
         varname = 'pw'
         filename = trim(stats_prefix)//trim(varname)//'_gpspw'
         call write_stats(filename, stats_pw(k))
      end if
      if ( stats_ref(k)%num > 0 ) then
         varname = 'ref'
         filename = trim(stats_prefix)//trim(varname)//'_gpsref'
         call write_stats(filename, stats_ref(k))
      end if
   end do !omb/oma
   stop

1000 continue
   write(0, '(a,i3)') 'read error on unit: ',iunit

contains

   integer function ob_index(ob_type)
      implicit none
      character(len=*), intent (in) :: ob_type

      integer :: n

      ob_index= imiss ! initialized as a missing value
      do n = 1, maxtype
         if ( trim(type_names(n)) == trim(ob_type) ) then
            ob_index = n
            return
         end if
      end do
   end function ob_index

   integer function pres_index (nstdp, std_plevels, pres)
      implicit none
      integer, intent(in)  :: nstdp
      real,    intent(in)  :: std_plevels(nstdp)
      real,    intent(in)  :: pres
      integer              :: k

      pres_index = imiss  ! initialized as a missing value
      if ( pres >= std_plevels(1) ) then
         pres_index = 1
         return
      else if ( pres < std_plevels(nstdp-1) .and. pres >= std_plevels(nstdp) ) then
         pres_index = nstdp
         return
      else
         do k = 2, nstdp-1
            if ( pres >= std_plevels(k) ) then
               pres_index = k
               return
            end if
         end do
      end if
   end function pres_index

   subroutine calc_stats(stats, xval, iqc)
      implicit none
      type(stats_value), intent(inout) :: stats
      real,              intent(in)    :: xval
      integer,           intent(in)    :: iqc

      real :: c1, c2

      if ( iqc < 0 ) return
      stats%num = stats%num + 1
      c1 = 1.0/stats%num
      c2 = (stats%num-1)*c1
      stats%mean = c2*stats%mean + xval*c1
      stats%rmse = c2*stats%rmse + xval*xval*c1
   end subroutine calc_stats

   subroutine write_stats_prf(outname, stats)
      character(len=*),  intent(in)    :: outname
      type(stats_value), intent(inout) :: stats(nstdp)
      integer :: ounit_stats = 15
      integer :: iost, i
      open(ounit_stats,file=trim(outname),form='formatted',status='unknown',iostat=iost)
      do i = 1, nstdp
         stats(i)%rmse = sqrt(stats(i)%rmse)
         if ( stats(i)%num == 0 ) then
            stats(i)%num  = imiss
            stats(i)%mean = rmiss
            stats(i)%rmse = rmiss
         end if
         write(ounit_stats,'(a10,f10.1,i10,4(f15.3))') cdate, std_plevels(i), &
            stats(i)%num, stats(i)%mean, stats(i)%rmse
      end do
      close(ounit_stats)
   end subroutine write_stats_prf

   subroutine write_stats(outname, stats)
      character(len=*),  intent(in)    :: outname
      type(stats_value), intent(inout) :: stats
      integer :: ounit_stats = 15
      integer :: iost, i
      open(ounit_stats,file=trim(outname),form='formatted',status='unknown',iostat=iost)
      stats%rmse = sqrt(stats%rmse)
      if ( stats%num == 0 ) then
         stats%num  = imiss
         stats%mean = rmiss
         stats%rmse = rmiss
      end if
      write(ounit_stats,'(a10,i10,4(f15.3))') cdate, stats%num, stats%mean, stats%rmse
      close(ounit_stats)
   end subroutine write_stats
end program proc_gts_omb_oma
