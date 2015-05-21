program read_ipe_ascii
implicit none
INTEGER, PARAMETER :: NPTS2D =44438
INTEGER, PARAMETER :: NMP =80  !# of magnetic longitude sectors
INTEGER, PARAMETER :: NLP =170 !# of field line grids in one longitude sector
INTEGER, PARAMETER :: real_prec  = 4
REAL (KIND=real_prec),DIMENSION(NPTS2D,NMP) :: oplus
integer :: n_read,lun,lun1
integer,PARAMETER :: rec_start=1
integer,PARAMETER :: rec_stop=1
integer:: NMP_all,NLP_all,NPTS2D_dum
integer,PARAMETER:: NMP0=1
integer,PARAMETER:: NMP1=80
integer,dimension(NLP)::IN,IS
REAL (KIND=real_prec),DIMENSION(NPTS2D) :: Z,GL
REAL (KIND=real_prec),DIMENSION(NPTS2D,NMP) :: GCOLAT,GLON
REAL (KIND=real_prec),DIMENSION(1:NMP+1) :: mlon_rad
REAL(KIND=real_prec), PARAMETER :: pi = 3.1415926536
CHARACTER(LEN=*),PARAMETER:: which_format='ascii'
!grid
lun=100
lun1=101
IF ( which_format=='binary') THEN
  OPEN(UNIT=lun,FILE='plasma_grid',STATUS='old',FORM='unformatted')
ELSE IF ( which_format=='ascii') THEN
OPEN(UNIT=lun,FILE='plasma_grid.'//which_format,STATUS='old',FORM='formatted')
END IF

IF ( which_format=='binary') THEN
    READ(UNIT=lun) NMP_all
    READ(UNIT=lun) NLP_all
    READ(UNIT=lun) NPTS2D_dum
    READ(UNIT=lun) IN(1:NLP_all)
    READ(UNIT=lun) IS(1:NLP_all)
    READ(UNIT=lun) mlon_rad( 1: NMP_all+1 ) !rad
    READ(UNIT=lun) Z(     1:NPTS2D_dum) !meter
    READ(UNIT=lun) GL(    1:NPTS2D_dum) !rad
    READ(UNIT=lun) GCOLAT(1:NPTS2D_dum, NMP0:NMP1)  !rad
    READ(UNIT=lun) GLON(  1:NPTS2D_dum, NMP0:NMP1) !rad
ELSE IF ( which_format=='ascii') THEN

    READ(UNIT=lun,FMT="(i10)") NMP_all
    READ(UNIT=lun,FMT="(i10)") NLP_all
    READ(UNIT=lun,FMT="(i10)") NPTS2D_dum
    READ(UNIT=lun,FMT="(20i10)") IN(1:NLP_all)
    READ(UNIT=lun,FMT="(20i10)") IS(1:NLP_all)
    READ(UNIT=lun,FMT="(20E12.4)") mlon_rad( 1: NMP_all+1 ) !rad
    READ(UNIT=lun,FMT="(20E12.4)") Z(     1:NPTS2D_dum) !meter
    READ(UNIT=lun,FMT="(20E12.4)") GL(    1:NPTS2D_dum) !rad
    READ(UNIT=lun,FMT="(20E12.4)") GCOLAT(1:NPTS2D_dum, NMP0:NMP1)  !rad
    READ(UNIT=lun,FMT="(20E12.4)") GLON(  1:NPTS2D_dum, NMP0:NMP1) !rad

END IF
    CLOSE(UNIT=lun)
    print *,'read plasma_grid finished'

!dbg20111003:
print *,'NMP_all',NMP_all
print *,'NLP_all',NLP_all
print *,'NPTS2D_dum',NPTS2D_dum

print *,'IN',IN(2)
print *,'IS',IS(1)

print *,'mlon[deg]',mlon_rad(2)*180./pi
 print *,'Z[meter]',z(1118)
!print *,'Z[meter]',z(1:1200)
print *,'GL[deg]',GL(1118)*180./pi
print *,'GLAT[deg]',90.-GCOLAT(1118,2)*180./pi
print *,'GLON[deg]',GLON(1118,2)*180./pi


!O+ density
IF ( which_format=='binary') THEN
  OPEN(UNIT=lun,FILE='startup00',STATUS='old',FORM='unformatted')
ELSE IF ( which_format=='ascii') THEN
  OPEN(UNIT=lun,FILE='startup00.'//which_format,STATUS='old',FORM='formatted')
END IF
read_loop: DO n_read=rec_start, rec_stop

IF ( which_format=='binary') THEN
  READ (UNIT=lun ) oplus
ELSE IF ( which_format=='ascii') THEN
  READ (UNIT=lun,FMT="(20E12.4)" ) oplus
END IF
print *,'n_read=',n_read,'!dbg! read oplus finished'
print *,'O+[m-3]',maxval(oplus),minval(oplus)
end do read_loop
CLOSE(lun)

end program read_ipe_ascii
