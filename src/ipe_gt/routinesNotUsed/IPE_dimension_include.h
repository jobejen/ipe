CHARACTER(LEN=2), PARAMETER :: title_lat='10'    !.. latitude of the flux tube

INTEGER(KIND=int_prec), PARAMETER :: FLDIM = &   !.. Field line grid dimension
!       &   265 !mlat=10[deg] at 90km
!       &   339 !mlat=35[deg] ---modified110210
!       &  1357 !mlat=35[deg] at 90km
!       &  2141 !mlat=60[deg] at 90km
!       &  4501 !mlat=85[deg] at 90km
               !mlat=88[deg] ---modified20101116 
!       &  6415 !mlat=88[deg] at 90km
!       &  1069 !mlat=88[deg] at 90km
       &  1117 !mlat=85[deg] at 90km low res

INTEGER(KIND=int_prec), PARAMETER :: NMP = 1     !.. # of flux tubes in longitude
INTEGER(KIND=int_prec), PARAMETER :: NPTS2D = &
    &  44438  ! # of points along all the flux tubes in one longitude plane
!     & 165717  ! # of points along all the flux tubes in one longitude plane
INTEGER(KIND=int_prec), PARAMETER :: NLP = 4
             !# of flux tubes in a meridional(height-latitutde) plane for the MPI test run 20110516
INTEGER(KIND=int_prec), PARAMETER :: NLP_all= &
      & 170   !# of flux tubes in a meridional(height-latitutde) plane (the entire grid) low res
!     & 209   !high res
INTEGER(KIND=int_prec), PARAMETER :: ISPEC = 9   !.. Species dimension
