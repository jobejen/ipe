!20110623: some lines commented out for test_GT
!20110414: modified to run the low resolution version
!20110120: 
!          3D version of module_field_line_grid.f90
MODULE module_FIELD_LINE_GRID_MKS
      USE module_precision
      USE module_IPE_dimension,ONLY: NPTS2D,NMP,NLP,NLP_all
      IMPLICIT NONE

! --- PRIVATE ---
!
! --- PUBLIC ---
!... read in parameters
      INTEGER(KIND=int_prec), DIMENSION(NMP,NLP_all),TARGET,PUBLIC :: JMIN_IN,JMAX_IS  !.. first and last indices on field line grid
      REAL(KIND=real_prec), DIMENSION(NPTS2D,NMP), PRIVATE ::  r_meter     !.. distance from the center of the Earth[meter]
      REAL(KIND=real_prec), DIMENSION(NPTS2D,NMP), PUBLIC ::  GCOLAT  !.. geographic co-latitude [rad]
      REAL(KIND=real_prec), DIMENSION(NPTS2D,NMP), PUBLIC ::  GLON    !.. geographic longitude [rad]
      REAL(KIND=real_prec), DIMENSION(NPTS2D,NMP), PUBLIC ::  Qvalue
      REAL(KIND=real_prec), DIMENSION(NPTS2D,NMP), TARGET,PUBLIC ::  SL_meter  !.. distance of point from northern hemisphere foot point [meter]
      REAL(KIND=real_prec), DIMENSION(NPTS2D,NMP), TARGET,PUBLIC ::  BM_nT      !.. magnetic field strength [nT]
      REAL(KIND=real_prec),           ALLOCATABLE, TARGET,PUBLIC ::  SZA_rad(:) !solar zenith angle [radians]
! components (east, north, up) of base vectors
      REAL(KIND=real_prec), DIMENSION(3,NPTS2D,NMP), PUBLIC ::  D1    !.. Eq(3.8) Richmond 1995
      REAL(KIND=real_prec), DIMENSION(3,NPTS2D,NMP), PUBLIC ::  D2    !.. Eq(3.9) Richmond 1995
      REAL(KIND=real_prec), DIMENSION(3,NPTS2D,NMP), PUBLIC ::  D3    !.. Eq(3.10) Richmond 1995
      REAL(KIND=real_prec), DIMENSION(3,NPTS2D,NMP), PUBLIC ::  E1    !.. Eq(3.11) Richmond 1995
      REAL(KIND=real_prec), DIMENSION(3,NPTS2D,NMP), PUBLIC ::  E2    !.. Eq(3.12) Richmond 1995
!20101119:removed       REAL(KIND=real_prec), DIMENSION(3,FLDIM), PUBLIC ::  Grdlbm2 !.. for calcuting div(vem) 
      REAL(KIND=real_prec), DIMENSION(2,NMP,NLP_all), PUBLIC ::  Be3         ! .. Eq(4.13) Richmond 1995 at Hr=90km in the NH(1)/SH(2) foot point [nT]
      REAL(KIND=real_prec), DIMENSION(NPTS2D,NMP), PUBLIC ::  GL_rad      !.. magnetic co-latitude Eq(6.1) [rad]
!
!... read in parameters
!------------
!...calculated parameters
      REAL(KIND=real_prec), DIMENSION(NPTS2D,NMP),   PUBLIC ::  Z_meter !.. altitude [meter]
      REAL(KIND=real_prec), DIMENSION(NMP,NLP), TARGET, PUBLIC ::  Pvalue  !.. p coordinate (L-shell)
      REAL(KIND=real_prec), DIMENSION(NPTS2D,NMP),TARGET,PUBLIC ::  GR_mks  !.. Gravity [m2 s-1]


      PRIVATE
      PUBLIC :: init_plasma_grid


      CONTAINS
!---------------------------
! initialise plasma grids
!----------------------------
SUBROUTINE init_plasma_grid ( )
        USE module_IPE_dimension, ONLY: title_LAT
        USE module_physical_constants, ONLY: earth_radius, pi, G0
        USE module_input_parameters, ONLY: sw_debug,lpstrt,lpstop
        USE module_IO, ONLY: filename,LUN_pgrid
        IMPLICIT NONE

! 0: low resolution: NMP=170, NPTS2D = 44438
        CHARACTER(LEN=*), PARAMETER :: filepath_pgrid_low= &
     & '../field_line_grid/20110413_3Dlowres/'               !20110414 low resolution
        CHARACTER(LEN=*), PARAMETER :: filename_pgrid_low1= &
     &    'GIP_apex_coords_mlon0_newgrid'                    !mp=1: mlon=0[deg] low resolution
! 1: high resolution: NMP=209, NPTS2D = 165717
        CHARACTER(LEN=*), PARAMETER :: filepath_pgrid_high= &
     & '../field_line_grid/20110121_3D/'                     !20110121 3D  original (high) resolution
        CHARACTER(LEN=*), PARAMETER :: filename_pgrid_high1= &
     &    'GIP_apex_coords_mlon0_p2tbsv2'                    !mp=1:  mlon=0[deg] original (high) resolution
!nm20110414: mp=2 will not be used in the test of the low/high resolution!!!
        CHARACTER(LEN=*), PARAMETER :: filename_pgrid_high2= &
     &    'GIP_apex_coords_mlon180_p2tbsv2'                  !mp=2:  mlon=180[deg]

        REAL(KIND=real_prec), DIMENSION(NPTS2D) :: r_meter     !.. distance from the center of the Earth[meter]
        INTEGER (KIND=int_prec) :: istat
        CHARACTER (LEN=11) :: FORM_dum
        CHARACTER (LEN=7)  :: STATUS_dum 
        INTEGER (KIND=int_prec) :: i, mp,lp
        REAL (KIND=real_prec) :: sinI
        INTEGER (KIND=int_prec), parameter :: sw_sinI=0  !0:flip; 1:APEX
!dbg
        INTEGER (KIND=int_prec), POINTER :: in,is
!---

        apex_longitude_loop: DO mp = 1,NMP 

IF ( sw_debug ) print *,'init_plasma_grid : mp = ',mp        


! 0: low resolution: NMP=170, NPTS2D = 44438
        IF ( NLP_all == 170 ) THEN
          IF ( mp==1 ) THEN
            filename =filepath_pgrid_low//filename_pgrid_low1
          ELSE
            print *,'!STOP! invalid mp=',mp
            STOP
          END IF

! 1: high resolution: NMP=209, NPTS2D = 165717
        ELSE IF ( NLP_all == 209 ) THEN
          if ( mp==1 ) then 
             filename =filepath_pgrid_high//filename_pgrid_high1  
          else if ( mp==2 ) then 
             filename =filepath_pgrid_high//filename_pgrid_high2
          endif
        END IF !( NLP_all == 170 ) THEN


          FORM_dum ='formatted' 
          STATUS_dum ='old'
          CALL open_file ( filename, LUN_pgrid, FORM_dum, STATUS_dum ) 

! read plasma grid
          READ(UNIT=LUN_pgrid, FMT=*) JMIN_IN(mp,1:NLP_all), JMAX_IS(mp,1:NLP_all)
          READ(UNIT=LUN_pgrid, FMT=*) r_meter(1:NPTS2D),GCOLAT(1:NPTS2D,mp), GLON(1:NPTS2D,mp), Qvalue(1:NPTS2D,mp)
          READ(UNIT=LUN_pgrid, FMT=*) GL_rad(1:NPTS2D,mp)
          READ(UNIT=LUN_pgrid, FMT=*) SL_meter(1:NPTS2D,mp), BM_nT(1:NPTS2D,mp)
          READ(UNIT=LUN_pgrid, FMT=*) D1(1:3,1:NPTS2D,mp),D2(1:3,1:NPTS2D,mp),D3(1:3,1:NPTS2D,mp)
          READ(UNIT=LUN_pgrid, FMT=*) E1(1:3,1:NPTS2D,mp),E2(1:3,1:NPTS2D,mp)  !20101119:removed ,Grdlbm2 
          READ(UNIT=LUN_pgrid, FMT=*) Be3(1,mp,1:NLP_all),Be3(2,mp,1:NLP_all) !NH,SH
          CLOSE(UNIT=LUN_pgrid)


IF ( sw_debug ) then  ! lrm20120531

   ! Check JMIN_IN, JMAX_IS
   print *,'init_plasma_grid : JMIN_IN(:,1) = ',JMIN_IN(:,1)
   print *,'init_plasma_grid : JMAX_IS(:,1) = ',JMAX_IS(:,1)
   print *,'init_plasma_grid : JMIN_IN(:,NLP) = ',JMIN_IN(:,NLP)
   print *,'init_plasma_grid : JMAX_IS(:,NLP) = ',JMAX_IS(:,NLP)


END IF


! calculate coordinate parameters
! make sure to use the MKS units.
          Z_meter(1:NPTS2D,mp) = r_meter(1:NPTS2D) - earth_radius ![meter]

!.. p coordinate (L-shell) is a single value along a flux tube 
!NOTE: in FLIP, PCO is only used in setting up the rough plasmasphere H+ initial profiles (See PROFIN). It does not have to be accurate.
          apex_latitude_height_loop:   DO lp = 1,NLP

            IN => JMIN_IN(mp,lp)
            IS => JMAX_IS(mp,lp)

!t 20110623 commented out because of the test_GT
!t            CALL Get_Pvalue_Dipole ( r_meter(IN), GL_rad(IN,mp), Pvalue(mp,lp) )   

IF ( sw_debug ) THEN
print "('lp=',i6,'  IN=',i6,'  IS=',i6,'  NPTS=',i6)", lp,IN,IS,(IS-IN+1)
print "('r [m]      =',2E12.4)", r_meter(in),r_meter(is)
print "('G-LAT [deg]=',2f10.4)",(90.-GCOLAT(in,mp)*180./pi),(90.-GCOLAT(is,mp)*180./pi)
print "('M-LAT [deg]=',2f10.4)",(90.-GL_rad(in,mp)*180./pi),(90.-GL_rad(is,mp)*180./pi)
print "('GLON  [deg]=',2f10.4)",(GLON(in,mp)*180./pi),(GLON(is,mp)*180./pi)
print "('Qvalue     =',2E12.4)", Qvalue(in,mp), Qvalue(is,mp)
print "('BM [nT]    =',2E12.4)", BM_nT(in,mp), BM_nT(is,mp)
print "('D1         =',2E12.4)", D1(1,in,mp), D1(1,is,mp)
print "('D2         =',2E12.4)", D2(1,in,mp), D2(1,is,mp)
print "('D3         =',6E12.4)", D3(1:3,in,mp), D3(1:3,is,mp)
print "('E1         =',2E12.4)", E1(1,in,mp), E1(1,is,mp)
print "('E2         =',2E12.4)", E2(1,in,mp), E2(1,is,mp)
print "('Be3 [nT] NH/SH  =',2E12.4)", Be3(1,mp,lp), Be3(2,mp,lp)
!20101119:removed print "('Grdlbm2    =',2E12.4)", Grdlbm2(1,in,mp),Grdlbm2(1,iout(2))

print "('SL [m]     =',4E13.5)", SL_meter(in:in+1,mp), SL_meter(is-1:is,mp)
print "('Z  [m]     =',4E13.5)",  Z_meter(in:in+1,mp),  Z_meter(is-1:is,mp)

!t print "('Pvalue     =',F10.4)", Pvalue(mp,lp)

END IF !( sw_debug ) THEN



!t 20110623 commented out because of the test_GT
! assuming Newtonian gravity: G0 is gravity at the sea level (z=0) 
!NOTE: positive in NORTHern hemisphere; negative in SOUTHern hemisphere
!t         flux_tube: DO i=IN,IS
!t           CALL Get_sinI ( sw_sinI, sinI, i, mp ) 
!t           GR_mks(i,mp)  =  G0 * ( earth_radius * earth_radius ) / ( r_meter(i) * r_meter(i) ) * sinI * (-1.0)
!t
!t!IF ( sw_debug )  print "(4E12.4)", Z_meter(i,mp),sinI, (G0 * ( earth_radius * earth_radius ) / ( r_meter(i) * r_meter(i) )),  GR_mks(i,mp)
!t        
!t         END DO flux_tube
!tIF ( sw_debug )  then
!t  if ( sw_sinI==0 ) then
!t    print *,'sinI: flip'
!t  else if ( sw_sinI==1 ) then
!t    print *, 'sinI: APEX'
!t  endif
!t  print "('GRavity[m2 s-1]=',4E12.4)",GR_mks(in:in+2,mp),GR_mks(is,mp)
!tEND IF

!debug20110314
if( sw_debug .and. mp==1 .and. lp>=lpstrt .and. lp<=lpstop ) then
print *,'lp=',lp,' in=',in,' is=',is,(is-in+1),(90.-gl_rad(in,mp)*180./pi)
endif !(mp==1) then


! debug:  write plasma grid
!if( mp==1 .and. lp>=lpstrt .and. lp<=lpstop ) then
!FORM_dum ='formatted  ' 
!STATUS_dum ='unknown'
!write ( filename, FMT="('grid_lp',i2)") lp 
!print *,'mp=',mp,' lp=',lp,' opening file',filename
!
!        CALL open_file ( filename, LUN_pgrid, FORM_dum, STATUS_dum )
!        write(UNIT=LUN_pgrid, FMT=*) (in-in+1), (is-in+1)
!        write(UNIT=LUN_pgrid, FMT=*) r_meter(in:is),GCOLAT(in:is,mp), GLON(in:is,mp), Qvalue(in:is,mp)
!        write(UNIT=LUN_pgrid, FMT=*) GL_rad(in:is,mp)
!        write(UNIT=LUN_pgrid, FMT=*) SL_meter(in:is,mp), BM_nT(in:is,mp)
!        write(UNIT=LUN_pgrid, FMT=*) D1(1:3,in:is,mp),D2(1:3,in:is,mp),D3(1:3,in:is,mp)
!        write(UNIT=LUN_pgrid, FMT=*) E1(1:3,in:is,mp),E2(1:3,in:is,mp)  !Grdlbm2 !20101119:removed ,
!        write(UNIT=LUN_pgrid, FMT=*) Be3(1,mp,lp)  ! .. Eq(4.13) Richmond 1995 at Hr=90km in the NH foot point [nT]
!        CLOSE(UNIT=LUN_pgrid)
!endif


       END DO apex_latitude_height_loop   !: DO lp = 1,NLP



     END DO apex_longitude_loop         !: DO mp = 1,NMP 

!debug
!STOP

        END SUBROUTINE init_plasma_grid
!---------------------------

END MODULE module_FIELD_LINE_GRID_MKS
