MODULE module_input_parameters
      USE module_precision
      IMPLICIT NONE

!--- IPE wide run parameters
      INTEGER (KIND=int_prec), PUBLIC   :: start_time  !=0  !UT[sec]
      INTEGER (KIND=int_prec), PUBLIC   :: stop_time   !=60 !UT[sec]
      INTEGER (KIND=int_prec), PUBLIC   :: time_step   !=60 ![sec]

      REAL (KIND=real_prec), PUBLIC,TARGET :: F107D   !.. Daily F10.7
      REAL (KIND=real_prec), PUBLIC,TARGET :: F107AV  !.. 81 day average F10.7
!
      INTEGER (KIND=int_prec), PUBLIC,TARGET :: NYEAR ! year
      INTEGER (KIND=int_prec), PUBLIC,TARGET :: NDAY  ! day number
!
!--- FLIP specific input parameters
      REAL (KIND=real_prec), PUBLIC,TARGET :: DTMIN_flip  !.. Minimum time step allowed (&=10 secs?)
      INTEGER (KIND=int_prec),PUBLIC,TARGET :: sw_INNO  !.. switch to turn on FLIP NO calculation if <0
      REAL (KIND=real_prec), PUBLIC,TARGET :: FPAS_flip   !.. Pitch angle scattering fraction
      REAL (KIND=real_prec), PUBLIC :: HPEQ_flip   !.. Sets initial equatorial [H+][cm-3] if positive
      REAL (KIND=real_prec), PUBLIC,TARGET :: HEPRAT_flip !.. Intial He+/H+ ratio (.01 to 1.0)
      REAL (KIND=real_prec), PUBLIC,TARGET :: COLFAC_flip !.. O+ - O collision frequency Burnside factor (1.0 to 1.7)
      INTEGER (KIND=int_prec),PUBLIC,TARGET :: sw_IHEPLS !.. switches He+ diffusive solutions on if > 0
      INTEGER (KIND=int_prec),PUBLIC,TARGET :: sw_INPLS  !.. switches N+ diffusive solutions on if > 0
      INTEGER (KIND=int_prec),PUBLIC :: sw_wind_flip  !.. switch for neutral wind input to FLIP: 1:ON; 0:ZERO wind
      INTEGER (KIND=int_prec),PUBLIC :: sw_depleted_flip  !.. switch for depleted flux tube in FLIP: 1:ON; 0:OFF 
      INTEGER (KIND=int_prec),PUBLIC :: start_time_depleted !.. time UT to start to deplete the flux tube
      INTEGER,PUBLIC :: sw_neutral_heating_flip  !.. switch for neutral heating calculation in FLIP: 1:ON; 0:OFF


!--- MSIS/HWM specific input parameters
      REAL (KIND=real_prec), DIMENSION(7), PUBLIC,TARGET :: AP   ! magnetic index(daily)
!.. MSIS: or when sw(9)=-1. :                 
!           - array containing:                                         
!             (1) daily ap                                              
!             (2) 3 hr ap index for current time                        
!             (3) 3 hr ap index for 3 hrs before current time           
!             (4) 3 hr ap index for 6 hrs before current time           
!             (5) 3 hr ap index for 9 hrs before current time           
!             (6) average of eight 3 hr ap indicies from 12 to 33 hrs pr
!                    to current time                                    
!             (7) average of eight 3 hr ap indicies from 36 to 57 hrs pr
!                    to current time 
!.. HWM:        ap - two element array with                                    
!             ap(1) = magnetic index(daily) (use 4 in lower atmos.)     
!             ap(2)=current 3hr ap index (used only when sw(9)=-1.) 
!
!--- all the SWITCHes either integer or logical or character
      LOGICAL, PUBLIC :: sw_debug
      INTEGER(KIND=int_prec), DIMENSION(2), PUBLIC :: iout
      INTEGER(KIND=int_prec), PUBLIC :: lpstrt,lpstop
      CHARACTER(len=4), PUBLIC :: sw_neutral    !GT/MSIS
!
      NAMELIST/NMIPE/start_time &
     &,stop_time &
     &,time_step &
     &,F107D   &
     &,F107AV  &
     &,NYEAR  &
     &,NDAY
      NAMELIST/NMFLIP/DTMIN_flip  & 
     &,sw_INNO   & 
     &,FPAS_flip   & 
     &,HPEQ_flip   & 
     &,HEPRAT_flip & 
     &,COLFAC_flip & 
     &,sw_IHEPLS &
     &,sw_INPLS  &
     &,sw_wind_flip &
     &,sw_depleted_flip &
     &,start_time_depleted &
     &,sw_neutral_heating_flip
      NAMELIST/NMMSIS/AP
      NAMELIST/NMSWITCH/sw_debug,iout, lpstrt,lpstop, sw_neutral

      PRIVATE
      PUBLIC :: read_input_parameters


      CONTAINS
!---------------------------
! initialise plasma grids
        SUBROUTINE read_input_parameters ( )
        IMPLICIT NONE
!---------
        INTEGER(KIND=int_prec),PARAMETER :: LUN_nmlt=1
        CHARACTER(LEN=*),PARAMETER :: INPTNMLT='IPE.inp'
        INTEGER(KIND=int_prec) :: IOST_OP
        INTEGER(KIND=int_prec) :: IOST_RD
        

        OPEN(LUN_nmlt,FILE=INPTNMLT,ERR=222,IOSTAT=IOST_OP,STATUS='OLD')
        READ(LUN_nmlt,NML=NMIPE    ,ERR=222,IOSTAT=IOST_RD,END=111)
        READ(LUN_nmlt,NML=NMFLIP   ,ERR=222,IOSTAT=IOST_RD,END=111)
        READ(LUN_nmlt,NML=NMMSIS   ,ERR=222,IOSTAT=IOST_RD,END=111)
        READ(LUN_nmlt,NML=NMSWITCH ,ERR=222,IOSTAT=IOST_RD,END=111)

222     IF ( IOST_OP /= 0 ) THEN
          WRITE(6,*) "OPEN NAMELIST FAILED!", IOST_OP
          STOP
        ELSEIF ( IOST_RD /= 0 ) THEN
          WRITE(6,*) "READ NAMELIST FAILED!", IOST_RD
          STOP
        ENDIF

111     CONTINUE
        WRITE(6,NML=NMIPE)
        WRITE(6,NML=NMFLIP)
        WRITE(6,NML=NMMSIS)
        WRITE(6,NML=NMSWITCH)
        CLOSE(LUN_nmlt)
        END SUBROUTINE read_input_parameters

END MODULE module_input_parameters
