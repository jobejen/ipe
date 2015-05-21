! DATE: 08 September, 2011
!********************************************
!***      Copyright 2011 NAOMI MARUYAMA   ***
!***      ALL RIGHTS RESERVED             ***
!********************************************
! LICENSE AGREEMENT Ionosphere Plasmasphere Electrodynamics (IPE) model
! DEVELOPER: Dr. Naomi Maruyama
! CONTACT INFORMATION:
! E-MAIL : Naomi.Maruyama@noaa.gov
! PHONE  : 303-497-4857
! ADDRESS: 325 Broadway, Boulder, CO 80305
!--------------------------------------------  
      MODULE module_NEUTRAL_MKS
      USE module_precision
      USE module_IPE_dimension,ONLY: NPTS2D,NLP,NMP
      USE module_FIELD_LINE_GRID_MKS,ONLY: ON_m3,HN_m3,N2N_m3,O2N_m3,HE_m3,N4S_m3,TN_k,TINF_k,Un_ms1
      USE module_input_parameters,ONLY : parallelBuild

      IMPLICIT NONE

! --- PUBLIC ---
!dbg20110516: temporary moved to module plasma because it is calculated by flip right now.
!      REAL(KIND=real_prec), dimension(NPTS2D,NMP), PUBLIC ::  NNO_m3


! follow APEX paper: components (east, north, up)
!t      REAL(KIND=real_prec), dimension(3,NPTS2D,NMP),PUBLIC  :: Un_ms1  !Ue1 Eq(5.6) in magnetic frame !1st dim: corresponds to apexD1-3
!dbg20110923: temporary reduce the array size for memory saving...

      PRIVATE
      PUBLIC :: neutral


      CONTAINS
!---------------------------
      subroutine neutral (utime) 
      USE module_IPE_dimension,ONLY: IPDIM
      use module_FIELD_LINE_GRID_MKS, only : plasma_grid_3d,plasma_grid_Z, apexD, JMIN_IN,JMAX_IS,east,north,up,ISL,IBM,IGR,IQ,IGCOLAT,IGLON,JMIN_ING,JMAX_ISG
      USE module_physical_constants,ONLY: pi,zero
      USE module_input_parameters,ONLY: F107D,F107AV,AP,NYEAR,NDAY,sw_debug,mpstop,sw_grid,start_time,stop_time,sw_neutral
      USE module_unit_conversion,ONLY: M_TO_KM
      USE module_IO, ONLY:filename,FORM_dum,STATUS_dum,luntmp3
      USE module_open_file, ONLY:open_file
      implicit none

      INTEGER(KIND=int_prec), INTENT(in) :: utime  !universal time[sec]

      integer :: npts  !=IPDIM
      INTEGER(KIND=int_prec) :: IN, IS

      integer :: iyear, iday

      real(8) :: ut_hour 
      real(8) :: f107D_dum, f107A_dum 
      real(8),              dimension(IPDIM)   :: glon_deg, glat_deg, alt_km
      real(8),              dimension(7)       :: AP_dum
      REAL(KIND=real_prec), dimension(3,IPDIM) :: Vn_ms1  !geographic frame:1:east;2:north;3:up

      INTEGER(KIND=int_prec) :: i,lp,mp, midpoint,ipts
      REAL (KIND=real_prec) :: dotprod
!      INTEGER(KIND=int_prec) :: stat_alloc
      DOUBLE PRECISION :: GLATi,GLONGi,DECMAG !flip compatible
      REAL (KIND=real_prec) :: BCOMPU
      REAL (KIND=real_prec) :: dum0(NPTS2D)
!dbg20120313
      INTEGER(KIND=int_prec) :: utime_dum 
!------

      iyear = NYEAR
      iday  = NDAY
      f107D_dum  = F107D
      f107A_dum  = F107AV
!nm20110822: no more allocatable arrays
!      IF (.NOT. ALLOCATED(AP_dum) )  ALLOCATE ( AP_dum(1:7) )
      AP_dum(1:7)= AP(1:7)
      ut_hour = REAL(utime)/3600. !convert from sec to hours

IF( sw_debug )  THEN
        print *, ' iyear, iday, ut_hour = ', iyear, iday, ut_hour
        print *, ' f107D, f107A, AP = ', f107D_dum, f107A_dum, AP_dum
END IF


! array initialization
!SMS$IGNORE BEGIN
      ON_m3  = zero
      HN_m3  = zero
      N2N_m3 = zero
      O2N_m3 = zero
      HE_m3  = zero
      N4S_m3 = zero
      TN_k   = zero
      TINF_k = zero
      Un_ms1 = zero
!SMS$IGNORE END

!SMS$PARALLEL(dh, lp, mp) BEGIN
!     apex_longitude_loop: DO mp = mpstrt, mpstop, mpstep          !1,NMP
!       apex_latitude_height_loop: DO lp = lpstrt, lpstop, lpstep  !1,NLP
      apex_longitude_loop: DO mp = 1,mpstop
        apex_latitude_height_loop: DO lp = 1,NLP

          IN = JMIN_IN(lp)
          IS = JMAX_IS(lp)
          NPTS = IS - IN + 1

!dbg20110923
IF( sw_debug )  print *,'sub-neut: mp=',lp,mp,IN,IS,npts


!

!nm20110822: no more allocatable arrays
!          IF (.NOT. ALLOCATED(glon_deg) )  ALLOCATE ( glon_deg(IN:IS) )
!          IF (.NOT. ALLOCATED(glat_deg) )  ALLOCATE ( glat_deg(IN:IS) )
!          IF (.NOT. ALLOCATED(alt_km) )  ALLOCATE (   alt_km(IN:IS) )
!          IF (.NOT. ALLOCATED(Vn_ms1) )  ALLOCATE ( Vn_ms1(3,IN:IS), STAT=stat_alloc )
!if ( stat_alloc/=0 ) then
!  print *, ALLOCATED(Vn_ms1)
!  print *, '!STOP! Vn_ms1 DEALLOCATION FAILED! in neutral:',stat_alloc,lp,mp,in,is,npts
!  STOP
!end if
          glon_deg(1:NPTS) = plasma_grid_3d(IN:IS,lp,mp,IGLON)*180./pi
          glat_deg(1:NPTS) = 90. - plasma_grid_3d(IN:IS,lp,mp,IGCOLAT)*180./pi
          alt_km  (1:NPTS) = plasma_grid_Z(IN:IS,lp) * M_TO_KM  !/ 1000. 

          call get_thermosphere (npts, &
                         iyear, iday, ut_hour, f107D_dum, f107A_dum, AP_dum, &
                         glon_deg, glat_deg, alt_km, &
                         he_m3( IN:IS,lp,mp) &
     &                 , on_m3( IN:IS,lp,mp) &
     &                 , o2n_m3(IN:IS,lp,mp) &
     &                 , n2n_m3(IN:IS,lp,mp) &
     &                 ,  hn_m3(IN:IS,lp,mp) &
     &                 , n4s_m3(IN:IS,lp,mp) &
     &                 ,   tn_k(IN:IS,lp,mp) &
     &                 , tinf_k(IN:IS,lp,mp) &
     &              ,Vn_ms1(1:3,1:NPTS   )   )

          midpoint = IN + (IS-IN)/2
          flux_tube: DO i=IN,IS
            ipts = i-IN+1 !1:NPTS

            IF ( sw_grid==0 ) THEN !APEX
!dbg20110728: un_ms1(1:2) components are not used for the moment, so commented out!!! they will be needed when calculating the field line integrals
!!note: SQRT(D3*D3...) is required for scaling because sum of D1^2(1:3) are not equal to 1 
!! get neutral wind vectors along a field line: 
!! Un(1)=Ue1=d1*U: positive east, Eq(5.6) 
!!!!            dotprod = DOT_PRODUCT( D1(1:3,i,mp), D1(1:3,i,mp) ) 
!            dotprod = D1(1,i,mp)*D1(1,i,mp)  + D1(2,i,mp)*D1(2,i,mp)  + D1(3,i,mp)*D1(3,i,mp) 
!            IF ( dotprod > 0.0 ) THEN
!              Un_ms1(1,i,mp) = &
!     &     (  D1(1,i,mp)*Vn_ms1(1,i) + D1(2,i,mp)*Vn_ms1(2,i) + D1(3,i,mp)*Vn_ms1(3,i)  )/ &
!     & SQRT(  dotprod   )
!            ELSE
!!dbg20110728 not 100% sure if this is appropriate???
!              Un_ms1(1,i,mp) = 0.0 
!            END IF
!
!! Un(2)=Ue2=d2*U: positive down/equatorward, Eq(5.6) 
!            dotprod = D2(1,i,mp)*D2(1,i,mp)  + D2(2,i,mp)*D2(2,i,mp)  + D2(3,i,mp)*D2(3,i,mp) 
!            IF ( dotprod > 0.0 ) THEN
!            Un_ms1(2,i,mp) = &
!     &     ( D2(1,i,mp)*Vn_ms1(1,i) + D2(2,i,mp)*Vn_ms1(2,i) + D2(3,i,mp)*Vn_ms1(3,i)  )/ &
!     & SQRT(  dotprod   )
!            ELSE
!              Un_ms1(2,i,mp) = 0.0
!            END IF
         

! un(3)=Ue3=d3*U: positive parallel to a field line, Eq(5.6) 
               dotprod = apexD(i,lp,mp,east ,3)*apexD(i,lp,mp,east ,3)  &
                    &  + apexD(i,lp,mp,north,3)*apexD(i,lp,mp,north,3) &
                    &  + apexD(i,lp,mp,up   ,3)*apexD(i,lp,mp,up   ,3)
               IF ( dotprod > 0.0 ) THEN
                  Un_ms1(i,lp,mp,3) = & 
                       &     ( apexD(i,lp,mp,east ,3)*Vn_ms1(1,ipts)     &
                       &     + apexD(i,lp,mp,north,3)*Vn_ms1(2,ipts)     &
                       &     + apexD(i,lp,mp,up   ,3)*Vn_ms1(3,ipts) ) / &
                       &     SQRT(  dotprod   )
               ELSE
                  Un_ms1(i,lp,mp,3) = 0.0
               END IF
!!!DOT_PRODUCT( D3(1:3,i,mp), Vn_ms1(1:3,i) ) / SQRT(  DOT_PRODUCT( D3(1:3,i,mp), D3(1:3,i,mp) )  )

!dbg20110131: the midpoint values become NaN otherwise because of inappropriate D1/3 values...
               IF ( lp>=1 .AND. lp<=6 .AND. i==midpoint )   Un_ms1(i,lp,mp,:) = Un_ms1(i-1,lp,mp,:) 

            ELSE IF ( sw_grid==1 ) THEN !FLIP

               GLONGi=glon_deg(ipts) !GEOGRAPHIC longitude[deg]
               GLATi=glat_deg(ipts) !GEOGRAPHic latitude[deg]
               CALL MAGDEC(GLATi,GLONGi,DECMAG) !-- magnetic declination for winds
               DECMAG=DECMAG/57.296
               !.. Horizontal component
!FLIP or: BCOMPU = (UHED(1)*COS(DECMAG)+UHED(2)*SIN(DECMAG))
               BCOMPU = ( vn_ms1(2,ipts)*COS(DECMAG) + vn_ms1(1,ipts)*SIN(DECMAG) )
!FLIP or: UN(J)= -ABS(COSDIP(J))*BCOMPU * 100.0   !.. The wind along B in cm/s 
!*(-1) will be done in flux_tube_solver...f90
! unit: meter s-1: unit conversion to cm/s will be done in CTIP-INT.f
               Un_ms1(i,lp,mp,3) = ABS( apexD(i,lp,mp,north,3) )*BCOMPU    !.. The wind along B

if( 350.<=alt_km(ipts).and.alt_km(ipts)<=450.) then
print *,i,ipts,alt_km(ipts),Vn_ms1(1,ipts),Un_ms1(i,lp,mp,3),glongi,glati,(decmag*57.296),BCOMPU
endif

END IF !( sw_grid==0 ) THEN !APEX

          END DO flux_tube !: DO i=IN,IS

IF ( sw_debug ) THEN
      print "('mp=',i6,'  lp=',i6,'  IN=',i6,'  IS=',i6,'  NPTS=',i8)", lp,mp,IN, IS, npts
      print "(' glon_deg = ',2F10.4)", glon_deg(1), glon_deg(npts)
      print "(' glat_deg = ',2F10.4)", glat_deg(1), glat_deg(npts)
      print "(' alt_km   = ',2F12.2)", alt_km(1), alt_km(npts)

      print "(' LOG10 O_density_m3    = ',2F10.4)", LOG10(on_m3(IN,lp,mp)), LOG10(on_m3(IS,lp,mp))
      print "(' LOG10 H_density_m3    = ',2F10.4)", LOG10(hn_m3(IN,lp,mp)), LOG10(hn_m3(IS,lp,mp))
      print "(' LOG10 N2_density_m3   = ',2F10.4)", LOG10(n2n_m3(IN,lp,mp)), LOG10(n2n_m3(IS,lp,mp))
      print "(' LOG10 O2_density_m3   = ',2F10.4)", LOG10(o2n_m3(IN,lp,mp)), LOG10(o2n_m3(IS,lp,mp))
      print "(' LOG10 HE_density_m3   = ',2F10.4)", LOG10(he_m3(IN,lp,mp)), LOG10(he_m3(IS,lp,mp))
      print "(' LOG10 N4S_density_m3  = ',2F10.4)", LOG10(n4s_m3(IN,lp,mp)), LOG10(n4s_m3(IS,lp,mp))

      print "(' tn_k   = ',2F10.4)",tn_k(IN,lp,mp), tn_k(IS,lp,mp)
      print "(' tinf_k = ',2F10.4)",tinf_k(IN,lp,mp), tinf_k(IS,lp,mp)


      print "(' vn_east_ms1  = ',2F10.4)",vn_ms1(1,1), vn_ms1(1,npts)
      print "(' vn_north_ms1 = ',2F10.4)",vn_ms1(2,1), vn_ms1(2,npts)

!dbg20110923      print "(' un_meast_ms1     = ',2F10.4)",un_ms1(IN,lp,mp,1), un_ms1(IS,lp,mp,1)
!dbg20110923      print "(' un_down/eq_ms1   = ',2F10.4)",un_ms1(IN,lp,mp,2), un_ms1(IS,lp,mp,2)
      print "(' un_para_ms1      = ',2F10.4)",un_ms1(IN,lp,mp,3), un_ms1(IS,lp,mp,3)
END IF !( sw_debug ) THEN 


!nm20110822: no more allocatable arrays
!          IF ( ALLOCATED( glon_deg ) )  DEALLOCATE( glon_deg )
!          IF ( ALLOCATED( glat_deg ) )  DEALLOCATE( glat_deg )
!          IF ( ALLOCATED( alt_km   ) )  DEALLOCATE( alt_km  )
!          IF ( ALLOCATED( Vn_ms1   ) )  DEALLOCATE( Vn_ms1   )

        END DO  apex_latitude_height_loop !: DO lp = 1,NLP

!nm20120312 output wind
!write (6000,fmt=*) utime, Un_ms1(1:NPTS2D,mp,3) 
if ( sw_neutral==2  ) then
!write (6000,fmt=*) utime, Un_ms1(1:NPTS2D,mp,3) 
  if(parallelBuild) then
    print*,'module_neutral: sw_neutral=2 disabled for parallel runs'
    print*,'stopping in module_neutral'
    stop
  else
    if ( utime==start_time ) then
      luntmp3=6003
      filename="wind_input"
      FORM_dum="formatted  "
      STATUS_dum="old"
      CALL open_file ( filename, luntmp3, FORM_dum, STATUS_dum ) 
    endif
!read (unit=luntmp3,fmt=*) utime_dum, Un_ms1(1:NPTS2D,mp,3) 
    read (unit=luntmp3,fmt=*) utime_dum, dum0 
    if( utime_dum /=utime ) then 
      print *,"sub-neutral: !STOP! INVALID utime_dum!",utime_dum
      STOP
    endif
    do lp=1,NLP
      Un_ms1(JMIN_IN(lp):JMAX_IS(lp),lp,mp,3) = dum0(JMIN_ING(lp):JMAX_ISG(lp))
    enddo

    if( utime==stop_time )   CLOSE(UNIT=luntmp3)
  endif ! parallelBuild

end if !sw_neutral

      END DO  apex_longitude_loop  !: DO mp = 1,NMP
!SMS$PARALLEL END

!      IF ( ALLOCATED(AP_dum) )  DEALLOCATE ( AP_dum )
      end subroutine neutral

      END MODULE module_NEUTRAL_MKS
