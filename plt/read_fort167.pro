pro read_fort167,LUN167,UT_hr,LT_hr,Z,SL,GL,BM,GR,SZA,O0,H0,N20,O20,HE0,N4S0,sw_debug, title_hemi

read_special=0L;1L

  ;get FLDIM
   size_result = size(Z)
if ( sw_debug eq 1 ) then   print, 'size=',size_result
   FLDIM = size_result[1]


fmt00='(A29,2F10.3)'
   string_tmp1=$
'mp=  4 lp=100 U167 North, UT='
;'U167, North, UT='
;NH
   readf, LUN167, string_tmp1, UT_hr, LT_hr, FORMAT=$
fmt00
;'(A16,2F10.2)'
if ( sw_debug eq 1 ) then $
      print, 'check read-in:',string_tmp1, UT_hr, LT_hr


   string_tmp2='   JMIN   JMAX   CTIPDIM  INNO  IHEPLS  INPLS'
JMIN=0L
JMAX=0L
CTIPDIM=0L
INNO=0L
IHEPLS=0L
INPLS=0L
;NH
   readf, LUN167, string_tmp2
if ( sw_debug eq 1 ) then      print,   'NH',string_tmp2
   if ( title_hemi eq 'NH' ) then begin
     readf, LUN167, JMIN,  JMAX,  CTIPDIM, INNO, IHEPLS, INPLS, FORMAT='(22I7)'
     if ( sw_debug eq 1 ) then      print,   'NH',JMIN,  JMAX,  CTIPDIM, INNO, IHEPLS, INPLS
   endif

   string_tmp3='        PCO       DT          DTMIN       F107       F107A          FPAS        HPEQ      HEPRAT      COLFACX'

;blank line
;NH
   readf, LUN167, string_tmp3
if ( sw_debug eq 1 ) then      print, 'NH blank1!',string_tmp3


;NH
   readf, LUN167, string_tmp3
if ( sw_debug eq 1 ) then      print, 'NH',string_tmp3

   if ( title_hemi eq 'NH' ) then begin
     readf, LUN167,PCO,      DT,         DTMIN,      F107,      F107A,         FPAS,       HPEQ,     HEPRAT,     COLFACX, FORMAT='(22F12.3)'
     if ( sw_debug eq 1 ) then      print, 'NH',PCO,      DT,         DTMIN,      F107,      F107A,         FPAS,       HPEQ,     HEPRAT,     COLFACX
   endif


   string_tmp4='     Z      SL       GL      BM        GR       SZA        O         H       N2       O2       HE       N4S'

;blank line
;NH
   readf, LUN167, string_tmp4
if ( sw_debug eq 1 ) then      print, 'NH blank2!',string_tmp4



;NH
   readf, LUN167, string_tmp4
if ( sw_debug eq 1 ) then      print, 'NH',string_tmp4





for j=1-1,(FLDIM/2)+1-1 DO begin
;NH
   readf, LUN167, Zj,SLj,GLj,BMj,GRj,SZAj,Oj,Hj,N2j,O2j,HEj,N4Sj , FORMAT='(F10.2,E14.7,21E9.2)'
   Z(J) =zj
   SL(J) =SLj
   GL(J) =GLj
   BM(J) =BMj
   GR(J) =GRj
   SZA(J) =SZAj
   O0(J) =Oj
   H0(J) =Hj
   N20(J) =N2j
   O20(J) =O2j
   HE0(J) =HEj
   N4S0(J) =N4Sj


if ( sw_debug eq 1 ) then $
;   if ( j eq 5 ) then  $
print, j, Zj,SLj,GLj,BMj,GRj,SZAj,Oj,Hj,N2j,O2j,HEj,N4Sj , FORMAT='(i4,F10.2,22E9.2)'




ENDFOR


if ( read_special eq 1 ) then begin
;dbg20120304:
n_read=1000
string_tmp4='  E      SIGEXO  SIGIONO  SIGEXN2  SIGION2  SIGEL    PRED     FYSUM    TSIGNE   PHIUP    PHIDWN   PRODUP   PRODWN'

   readf, LUN167, string_tmp4
if ( sw_debug eq 1 ) then      print, 'NH extra!',string_tmp4
for n=0,n_read do begin
   readf, LUN167,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12, FORMAT='(F6.1,12E9.2)'

if ( a0 le 1.5 ) then $
   print,n,a0,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12, FORMAT='(i3,F6.1,12E9.2)'

if ( a0 le 1.5 ) $
;if ( a1 le 0.00 ) $
then break
endfor
endif ;( read_special eq 1 ) then begin

if ( sw_debug eq 1 ) then  print,'read_fort167 finished successfully!'
END ;pro read_fort167
