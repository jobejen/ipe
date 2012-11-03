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
!
      SUBROUTINE allocate_arrays ( switch )
      USE module_precision
      USE module_IPE_dimension,ONLY: NMP,NLP,ISTOT
      USE module_FIELD_LINE_GRID_MKS,ONLY: &
     & plasma_grid_3d,plasma_3d,r_meter2D,ON_m3,HN_m3,N2N_m3,O2N_m3&
     &,apexD,apexE,VEXBup,MaxFluxTube,HE_m3,N4S_m3,TN_k,TINF_K,Un_ms1 &
     &,Be3, Pvalue, JMIN_IN, JMAX_IS,hrate_mks3d,midpnt &
     &,mlon_rad, plasma_grid_Z, plasma_grid_GL, plasma_3d_old
  
      USE module_input_parameters,ONLY: sw_neutral_heating_flip
      IMPLICIT NONE
      INTEGER (KIND=int_prec),INTENT(IN) :: switch
      INTEGER (KIND=int_prec) :: stat_alloc

! (0) ALLOCATE arrays
      IF ( switch==0 ) THEN
        print *,'ALLOCATing ARRAYS',ISTOT,MaxFluxTube,NLP,NMP
        allocate( plasma_grid_3d(      MaxFluxTube,NLP,NMP,6) &
     &,           plasma_grid_Z (      MaxFluxTube,NLP      ) &
     &,           plasma_grid_GL(      MaxFluxTube,NLP      ) &
     &,           r_meter2D     (      MaxFluxTube,NLP      ) &
     &,           plasma_3d     (ISTOT,MaxFluxTube,NLP,NMP  ) &
     &,           plasma_3d_old (ISTOT,MaxFluxTube,NLP,NMP  ) &
     &,           apexD         (3:3  ,MaxFluxTube,NLP,NMP,3) &
     &,           apexE         (2    ,MaxFluxTube,NLP,NMP,3) )

!---neutral

        allocate( ON_m3 (    MaxFluxTube,NLP,NMP) &
     &,           HN_m3 (    MaxFluxTube,NLP,NMP) &
     &,           N2N_m3(    MaxFluxTube,NLP,NMP) &
     &,           O2N_m3(    MaxFluxTube,NLP,NMP) &
     &,           HE_m3 (    MaxFluxTube,NLP,NMP) &
     &,           N4S_m3(    MaxFluxTube,NLP,NMP) &
     &,           TN_k  (    MaxFluxTube,NLP,NMP) &
     &,           TINF_K(    MaxFluxTube,NLP,NMP) &
     &,           Un_ms1(3:3,MaxFluxTube,NLP,NMP) )

        IF ( sw_neutral_heating_flip==1 ) THEN
          ALLOCATE(hrate_mks3d(7,MaxFluxTube,NLP,NMP),STAT=stat_alloc)
          IF ( stat_alloc==0 ) THEN
            print *,' hrate_mks3d ALLOCATION SUCCESSFUL!!!'
          ELSE !stat_alloc/=0
            print *,"!STOP hrate_mks3d ALLOCATION FAILD!:NHEAT",stat_alloc
            STOP
          END IF
        END IF !( sw_neutral_heating_flip==1 )

        ALLOCATE ( Be3     (2,NLP,NMP  ) &
     &,            VEXBup  (  NLP,NMP  ) &
     &,            Pvalue  (  NLP      ) &
     &,            JMIN_IN (  NLP      ) &
     &,            JMAX_IS (  NLP      ) &
     &,            midpnt  (  NLP      ) &
     &,            mlon_rad(      NMP+1) &
     &,            STAT=stat_alloc       )
 
      IF ( stat_alloc==0 ) THEN
        print *,'ALLOCATion SUCCESSFUL!!!'
      ELSE !stat_alloc/=0
        print *,switch,"!STOP! ALLOCATION FAILD!:",stat_alloc
        STOP
      END IF
!SMS$IGNORE BEGIN
      VEXBup = 0.0
!SMS$IGNORE END

! (1) DEALLOCATE arrays
ELSE IF ( switch==1 ) THEN
print *,'DE-ALLOCATing ARRAYS'
! field line grid
      DEALLOCATE ( &
     &    plasma_grid_3d &
!---
     &,        apexD     &
!dbg20110923     &,        apexE &
!---
     &,          Be3     &
     &,       Pvalue     &
     &,      JMIN_IN     &
     &,      JMAX_IS     &
!---
     &,      mlon_rad    &
!---plasma
     &,  plasma_3d       &
     &,  plasma_3d_old   &
!dbg20120501     &,  plasma_3d4n &
     &,  VEXBup          &
     &,STAT=stat_alloc     )
 
      IF ( stat_alloc==0 ) THEN
        print *,'DE-ALLOCATion SUCCESSFUL!!!'
      ELSE !/=0
        print *, ALLOCATED( plasma_grid_3d )
        print *,switch,"!STOP! DEALLOCATION FAILD!:",stat_alloc
        STOP
      END IF


!---neutral heating
      IF ( sw_neutral_heating_flip==1 ) THEN
         DEALLOCATE ( hrate_mks3d &
              &,  STAT=stat_alloc         )
         IF ( stat_alloc==0 ) THEN
            print *,'DE-ALLOCATion SUCCESSFUL!!! NHEAT'
         ELSE !/=0
            print *, ALLOCATED( hrate_mks3d )
            print *,switch,"!STOP! DEALLOCATION FAILD!: NHEAT",stat_alloc
            STOP
         END IF
      END IF !( sw_neutral_heating_flip==1 ) THEN


END IF !( switch==1 ) THEN

      END SUBROUTINE allocate_arrays
