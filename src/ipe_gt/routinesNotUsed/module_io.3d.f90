MODULE module_IO
      USE module_precision
      IMPLICIT NONE

! --- PRIVATE ---
!
! --- PUBLIC ---
      CHARACTER (LEN=100), PUBLIC :: filename
      CHARACTER (LEN=11),           PUBLIC :: FORM_dum
      CHARACTER (LEN=7),            PUBLIC :: STATUS_dum 
!--- unit numbers
      INTEGER (KIND=int_prec), PARAMETER, PUBLIC :: LUN_pgrid=7
      INTEGER (KIND=int_prec), PARAMETER, PUBLIC :: PRUNIT=8
      INTEGER (KIND=int_prec), PARAMETER, PUBLIC :: LUN_LOG=9
      INTEGER (KIND=int_prec), PUBLIC :: LUN_flip1, LUN_flip2, LUN_flip3, LUN_flip4
      INTEGER (KIND=int_prec), PUBLIC :: LUN_PLASMA0,LUN_PLASMA1,LUN_PLASMA2,LUN_PLASMA12
      PRIVATE
      PUBLIC :: open_output_files,output,close_files

      CONTAINS
!---------------------------
        SUBROUTINE open_output_files ( )
        USE module_input_parameters,ONLY: NYEAR,NDAY,HPEQ_flip,sw_debug
        IMPLICIT NONE
        CHARACTER (LEN=100) :: string_tmp
!
        IF ( NDAY < 100 ) THEN
          WRITE ( string_tmp, FMT="(i4,A2,i2)" ) NYEAR,'_0',NDAY
        ELSE         ! NDAY>=100
          WRITE ( string_tmp, FMT="(i4,A1,i3)" ) NYEAR,'_' ,NDAY
        END IF
        print *, string_tmp

!--- unit=8
        filename ='FLIP_ERROR_FLAG_'//TRIM(string_tmp)//'.log'
        FORM_dum ='formatted  ' 
        STATUS_dum ='unknown'
        CALL open_file ( filename, PRUNIT, FORM_dum, STATUS_dum )  

!--- unit=9
        filename ='logfile'//TRIM(string_tmp)//'.log'
        FORM_dum ='formatted  ' 
        STATUS_dum ='unknown'
        CALL open_file ( filename, LUN_LOG, FORM_dum, STATUS_dum )  

        IF ( sw_debug ) THEN
!--- unit=167
        LUN_FLIP1=167
        filename = 'fort167'
        FORM_dum ='formatted  ' 
        STATUS_dum ='unknown'
        CALL open_file ( filename, LUN_FLIP1, FORM_dum, STATUS_dum ) 

!--- unit=168
        LUN_FLIP2=168
        filename = 'fort168'
        CALL open_file ( filename, LUN_FLIP2, FORM_dum, STATUS_dum )

!--- unit=170
        LUN_FLIP3=170
        filename = 'fort170'
        CALL open_file ( filename, LUN_FLIP3, FORM_dum, STATUS_dum )

!--- unit=171
        LUN_FLIP4=171
        filename = 'fort171'
        CALL open_file ( filename, LUN_FLIP4, FORM_dum, STATUS_dum )
        END IF !( sw_debug ) THEN


!--- unit=180
        LUN_PLASMA0=180
        FORM_dum = 'unformatted' 
        filename = 'plasma0'
        CALL open_file ( filename, LUN_PLASMA0, FORM_dum, STATUS_dum )

!--- unit=181
        LUN_PLASMA1=181
        filename = 'plasma1'
        CALL open_file ( filename, LUN_PLASMA1, FORM_dum, STATUS_dum )

!--- unit=182
        LUN_PLASMA2=182
        filename = 'plasma2'
        CALL open_file ( filename, LUN_PLASMA2, FORM_dum, STATUS_dum )

        IF ( HPEQ_flip==0.0 ) THEN
!--- unit=1182 : input history file
          LUN_PLASMA12=1182
          STATUS_dum ='old'
          filename = 'plasma2in'
          CALL open_file ( filename, LUN_PLASMA12, FORM_dum, STATUS_dum )
        END IF

        END SUBROUTINE open_output_files
!---------------------------
        SUBROUTINE output ( utime )
        IMPLICIT NONE
!------------------------
        INTEGER (KIND=int_prec), INTENT(IN) :: utime !universal time [sec]

        WRITE(UNIT=PRUNIT,FMT="('utime [sec]=',i10)") utime

        END SUBROUTINE output
!---------------------------
        SUBROUTINE close_files ( )
        IMPLICIT NONE

        CLOSE(UNIT=PRUNIT)

        END SUBROUTINE close_files
!---------------------------
END MODULE module_IO

!-------
        SUBROUTINE open_file ( filename_dum, UNIT_dum, FORM_dum, STATUS_dum )  
        USE module_precision
        IMPLICIT NONE
        CHARACTER (LEN=*), INTENT(IN) :: filename_dum
        INTEGER (KIND=int_prec), INTENT(IN) :: UNIT_dum
        CHARACTER (LEN=*), INTENT(IN) :: FORM_dum
        CHARACTER (LEN=*), INTENT(IN) :: STATUS_dum
!---local
        LOGICAL :: flag
        INTEGER (KIND=int_prec) :: istat

        INQUIRE ( UNIT=UNIT_dum, OPENED=flag ) 
print *, flag
        IF ( .NOT. flag ) THEN
print *,'opening file:',filename_dum
          OPEN(UNIT=UNIT_dum,FILE=TRIM(filename_dum),STATUS=STATUS_dum,FORM=FORM_dum,IOSTAT=istat)
          IF ( istat /= 0 ) THEN
            print *,'ERROR OPENING FILE',filename_dum
            STOP
          END IF
        END IF      

        END SUBROUTINE open_file
