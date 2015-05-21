!nm20110616: modified to include the call to GT
!          3D version of module_neutral.f90
MODULE module_NEUTRAL_MKS
      USE module_precision
      USE module_IPE_dimension,ONLY: NPTS2D, NMP, NLP
      IMPLICIT NONE
! --- PRIVATE ---
!
! --- PUBLIC ---
!dbg20110516: temporary move to module plasma because it is calculated by flip right now.
!      REAL(KIND=real_prec), dimension(NPTS2D,NMP), PUBLIC ::  NNO_m3

      REAL(KIND=real_prec), dimension(NPTS2D,NMP), TARGET, PUBLIC ::  &
     &                    ON_m3, &
     &                    HN_m3, &
     &                   N2N_m3, &
     &                   O2N_m3, &
     &                    HE_m3, &
     &                   N4S_m3, &
     &                     TN_k, &
     &                   TINF_k

! follow APEX paper: components (east, north, up)
      REAL(KIND=real_prec), dimension(3,NPTS2D,NMP),PUBLIC  :: Un_ms1  !Ue1 Eq(5.6) in magnetic frame

      PRIVATE
      PUBLIC :: neutral


      CONTAINS
!---------------------------
   subroutine neutral (utime) 

      use module_FIELD_LINE_GRID_MKS, only : gcolat, glon, z_meter, D1, D2, D3, JMIN_IN,JMAX_IS
      USE module_physical_constants,ONLY: pi
      USE module_input_parameters,ONLY: F107D,F107AV,AP,NYEAR,NDAY,sw_debug,lpstrt,lpstop,sw_neutral
      implicit none

      INTEGER(KIND=int_prec), INTENT(in) :: utime  !universal time[sec]

      integer :: npts  !=FLDIM
      INTEGER(KIND=int_prec), POINTER :: IN, IS

      integer, POINTER :: iyear, iday

      real(8) :: ut_hour 
      real(8), POINTER :: f107D_dum, f107A_dum , AP_dum(:)

      real(8),              ALLOCATABLE, dimension(:)   :: glon_deg, glat_deg, alt_km
      REAL(KIND=real_prec), ALLOCATABLE, dimension(:,:) :: Vn_ms1  !geographic frame

      INTEGER(KIND=int_prec) :: i,mp,lp, midpoint
      
!------


IF ( sw_neutral == 'GT' ) THEN

   !!! Leslie: please work on this part!!!
   !!!  CALL GT_thermosphere (...arguments...)
   !!! the GT outputs that are required by ionosphere-plasmasphere: 
   !!! ---ON_m3,N2N_m3,O2N_m3,N4S_m3, NNO_m3,TN_k,TINF_k,un_ms1 : what new IP requires
   ! Flux grid :
   ! ON_m3 : o_density_copy
   ! N2N_m3 : n2_density_copy
   ! O2N_m3 : o2_density_copy
   ! N4S_m3 : not available from GT - will have to call MSIS
   ! NNO_m3 : not available from GT - will have to call MSIS
   ! TN_k : temperature_k_copy
   ! TINF_k : exospheric temperature - will have to estimate from temperature_k_copy
   !                                 - call subroutine to do this or from interpolate_from_gt2ip
   ! un_ms1 : neutral wind : all 3 components (east, north, up) (eastward, -southward, wvz_copy)


   !!! HN_m3,HE_m3 still need to be obtained from MSIS
   


   !!! need to add interpolation from thermospheric grid to ionosphere grid
   !!!  CALL interpolate_from_GT2IP ( ... )




ELSE IF ( sw_neutral == 'MSIS' ) THEN ! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

      ALLOCATE ( AP_dum(1:7) )

! do we pass these variables in somewhere?
      iyear => NYEAR
      iday  => NDAY        ! nday for GT_thermosphere
      f107D_dum  => F107D  ! f107 for GT_thermosphere
      f107A_dum  => F107AV
      AP_dum     => AP(1:7)

      ut_hour = REAL(utime)/3600. !convert from sec to hours  (utime : Universal_Time_Seconds)

  IF( sw_debug )  THEN
        print *, ' iyear, iday, ut_hour = ', iyear, iday, ut_hour
        print *, ' f107D, f107A, AP = ', f107D_dum, f107A_dum, AP_dum
  END IF

      apex_longitude_loop: DO mp = 1,NMP
        apex_latitude_height_loop: DO lp = lpstrt,lpstop !1,NLP

          IN => JMIN_IN(mp,lp)
          IS => JMAX_IS(mp,lp)
          NPTS = IS - IN + 1
          ALLOCATE ( glon_deg(IN:IS),glat_deg(IN:IS),alt_km(IN:IS),Vn_ms1(3,IN:IS) )

          glon_deg(IN:IS) = glon(IN:IS,mp)*180./pi
          glat_deg(IN:IS) = 90. - gcolat(IN:IS,mp)*180./pi
          alt_km  (IN:IS) = z_meter(IN:IS,mp) / 1000.

          call get_thermosphere (npts, &
                         iyear, iday, ut_hour, f107D_dum, f107A_dum, AP_dum, &
                         glon_deg, glat_deg, alt_km, &
                         he_m3( IN:IS,mp) &
     &                 , on_m3( IN:IS,mp) &
     &                 , o2n_m3(IN:IS,mp) &
     &                 , n2n_m3(IN:IS,mp) &
     &                 ,  hn_m3(IN:IS,mp) &
     &                 , n4s_m3(IN:IS,mp) &
     &                 ,   tn_k(IN:IS,mp) &
     &                 , tinf_k(IN:IS,mp) &
     &              ,Vn_ms1(1:3,IN:IS   )   )

!dbg20110131:
midpoint = IN + (IS-IN)/2

          flut_tube: DO i=IN,IS
!note: SQRT(D3*D3...) is required for scaling because sum of D1^2(1:3) are not equal to 1 
! get neutral wind vectors along a field line: 
! Un(1)=Ue1=d1*U: positive east, Eq(5.6) 
            Un_ms1(1,i,mp) = &
     &     (  D1(1,i,mp)*Vn_ms1(1,i) + D1(2,i,mp)*Vn_ms1(2,i) + D1(3,i,mp)*Vn_ms1(3,i)  )/ &
     & SQRT(  D1(1,i,mp)*D1(1,i,mp)  + D1(2,i,mp)*D1(2,i,mp)  + D1(3,i,mp)*D1(3,i,mp)   )

! Un(2)=Ue2=d2*U: positive down/equatorward, Eq(5.6) 
            Un_ms1(2,i,mp) = &
     &     ( D2(1,i,mp)*Vn_ms1(1,i) + D2(2,i,mp)*Vn_ms1(2,i) + D2(3,i,mp)*Vn_ms1(3,i)  )/ &
     & SQRT( D2(1,i,mp)*D2(1,i,mp)  + D2(2,i,mp)*D2(2,i,mp)  + D2(3,i,mp)*D2(3,i,mp)   )

! un(3)=Ue3=d3*U: positive parallel to a field line, Eq(5.6) 
            Un_ms1(3,i,mp) = & 
     &     ( D3(1,i,mp)*Vn_ms1(1,i) + D3(2,i,mp)*Vn_ms1(2,i) + D3(3,i,mp)*Vn_ms1(3,i) )/ &
     & SQRT( D3(1,i,mp)*D3(1,i,mp)  + D3(2,i,mp)*D3(2,i,mp)  + D3(3,i,mp)*D3(3,i,mp)  )
!DOT_PRODUCT( D3(1:3,i,mp), Vn_ms1(1:3,i) ) / SQRT(  DOT_PRODUCT( D3(1:3,i,mp), D3(1:3,i,mp) )  )

!dbg20110131: the midpoint values become NaN otherwise because of inappropriate D1/3 values...
IF ( lp>=1 .AND. lp<=6 .AND. i==midpoint )   Un_ms1(1:3,i,mp) = Un_ms1(1:3,i-1,mp) 

          END DO flut_tube !: DO i=IN,IS

IF ( sw_debug ) THEN
      print "('mp=',i6,'  lp=',i6,'  IN=',i6,'  IS=',i6)", mp,lp,IN, IS
      print "(' glon_deg = ',2F10.4)", glon_deg(IN), glon_deg(IS)
      print "(' glat_deg = ',2F10.4)", glat_deg(IN), glat_deg(IS)
      print "(' alt_km   = ',2F12.2)", alt_km(IN), alt_km(IS)

      print "(' LOG10 O_density_m3    = ',2F10.4)", LOG10(on_m3(IN,mp)), LOG10(on_m3(IS,mp))
      print "(' LOG10 H_density_m3    = ',2F10.4)", LOG10(hn_m3(IN,mp)), LOG10(hn_m3(IS,mp))
      print "(' LOG10 N2_density_m3   = ',2F10.4)", LOG10(n2n_m3(IN,mp)), LOG10(n2n_m3(IS,mp))
      print "(' LOG10 O2_density_m3   = ',2F10.4)", LOG10(o2n_m3(IN,mp)), LOG10(o2n_m3(IS,mp))
      print "(' LOG10 HE_density_m3   = ',2F10.4)", LOG10(he_m3(IN,mp)), LOG10(he_m3(IS,mp))
      print "(' LOG10 N4S_density_m3  = ',2F10.4)", LOG10(n4s_m3(IN,mp)), LOG10(n4s_m3(IS,mp))

      print "(' tn_k   = ',2F10.4)",tn_k(IN,mp), tn_k(IS,mp)
      print "(' tinf_k = ',2F10.4)",tinf_k(IN,mp), tinf_k(IS,mp)


      print "(' vn_east_ms1  = ',2F10.4)",vn_ms1(1,IN), vn_ms1(1,IS)
      print "(' vn_north_ms1 = ',2F10.4)",vn_ms1(2,IN), vn_ms1(2,IS)

      print "(' un_meast_ms1      = ',2F10.4)",un_ms1(1,IN,mp), un_ms1(1,IS,mp)
      print "(' un_down/eq_ms1   = ',2F10.4)",un_ms1(2,IN,mp), un_ms1(2,IS,mp)
      print "(' un_para_ms1      = ',2F10.4)",un_ms1(3,IN,mp), un_ms1(3,IS,mp)
END IF !( sw_debug ) THEN 


          IF ( ALLOCATED( glon_deg ) )  DEALLOCATE( glon_deg )
          IF ( ALLOCATED( glat_deg ) )  DEALLOCATE( glat_deg )
          IF ( ALLOCATED( alt_km   ) )  DEALLOCATE( alt_km  )
          IF ( ALLOCATED( Vn_ms1   ) )  DEALLOCATE( Vn_ms1   )

        END DO  apex_latitude_height_loop !: DO lp = 1,NLP
      END DO  apex_longitude_loop  !: DO mp = 1,NMP


END IF !( sw_neutral == 'MSIS' ) THEN  ! ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


      end subroutine neutral

END MODULE module_NEUTRAL_MKS
