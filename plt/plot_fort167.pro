;!!!UNDERCONSTRUCTION!!!
pro plot_fort167
mlat_title='88'
plot_UT = 16.9700 ;40.97
;high resolution
if ( mlat_title eq '10' ) then  FLDIM =  265L  else $
if ( mlat_title eq '35' ) then  FLDIM = 1357L  else $
if ( mlat_title eq '60' ) then  FLDIM = 2141L  else $
if ( mlat_title ge '85' ) then  FLDIM = 4501L

PLOTDIM = FLDIM/2
;NH
Zn  =dblarr(FLDIM)
SLn =dblarr(FLDIM)
GLn =dblarr(FLDIM)
BMn =dblarr(FLDIM)
GRn =dblarr(FLDIM)   
SZAn=dblarr(FLDIM)
On  =dblarr(FLDIM)
Hn  =dblarr(FLDIM)
N2n =dblarr(FLDIM)
O2n =dblarr(FLDIM)
HEn =dblarr(FLDIM)
N4Sn=dblarr(FLDIM)
;SH
Zs  =dblarr(FLDIM)
SLs =dblarr(FLDIM)
GLs =dblarr(FLDIM)
BMs =dblarr(FLDIM)
GRs =dblarr(FLDIM)   
SZAs=dblarr(FLDIM)
Os  =dblarr(FLDIM)
Hs  =dblarr(FLDIM)
N2s =dblarr(FLDIM)
O2s =dblarr(FLDIM)
HEs =dblarr(FLDIM)
N4Ss=dblarr(FLDIM)

;NH
  input_flnm='fort.167' ;+'.mlat'+mlat_title+'.'+STRTRIM( string(FLDIM, FORMAT='(i4)'), 1)+'pts'
   openr, LUN167, input_flnm, /GET_LUN
;SH
  input_flnm='fort.170' ;+'.mlat'+mlat_title+'.'+STRTRIM( string(FLDIM, FORMAT='(i4)'), 1)+'pts'
   openr, LUN170, input_flnm, /GET_LUN

   WHILE ( EOF(LUN167) eq 0 ) do begin

   string_tmp1='U167, North, UT='
;NH
   readf, LUN167, string_tmp1, UT_hr, LT_hr, FORMAT='(A16,2F10.2)'
   print, string_tmp1, UT_hr, LT_hr
;SH
   readf, LUN170, string_tmp1, UT_hr, LT_hr, FORMAT='(A16,2F10.2)'
   print, string_tmp1, UT_hr, LT_hr

   string_tmp2='   JMIN   JMAX   CTIPDIM  INNO  IHEPLS  INPLS'
JMIN=0L
JMAX=0L
CTIPDIM=0L
INNO=0L
IHEPLS=0L
INPLS=0L
;NH
   readf, LUN167, string_tmp2
   print,   'NH',string_tmp2
   readf, LUN167, JMIN,  JMAX,  CTIPDIM, INNO, IHEPLS, INPLS, FORMAT='(22I7)'
   print,   'NH',JMIN,  JMAX,  CTIPDIM, INNO, IHEPLS, INPLS
;SH
   readf, LUN170, string_tmp2
   print,   'SH',string_tmp2
;   readf, LUN170, JMIN,  JMAX,  CTIPDIM, INNO, IHEPLS, INPLS, FORMAT='(22I7)'
;   print,    'SH',JMIN,  JMAX,  CTIPDIM, INNO, IHEPLS, INPLS



   string_tmp3='        PCO       DT          DTMIN       F107       F107A          FPAS        HPEQ      HEPRAT      COLFACX'

;blank line
;NH
   readf, LUN167, string_tmp3
   print, 'NH blank1!',string_tmp3
;SH
   readf, LUN170, string_tmp3
   print, 'SH blank1!',string_tmp3

;NH
   readf, LUN167, string_tmp3
   print, 'NH',string_tmp3
   readf, LUN167,PCO,      DT,         DTMIN,      F107,      F107A,         FPAS,       HPEQ,     HEPRAT,     COLFACX, FORMAT='(22F12.3)'
   print, 'NH',PCO,      DT,         DTMIN,      F107,      F107A,         FPAS,       HPEQ,     HEPRAT,     COLFACX
;SH
   readf, LUN170, string_tmp3
   print, 'SH',string_tmp3
;   readf, LUN170,PCO,      DT,         DTMIN,      F107,      F107A,         FPAS,       HPEQ,     HEPRAT,     COLFACX, FORMAT='(22F12.3)'
;   print, 'SH',PCO,      DT,         DTMIN,      F107,      F107A,         FPAS,       HPEQ,     HEPRAT,     COLFACX

   string_tmp4='     Z      SL       GL      BM        GR       SZA        O         H       N2       O2       HE       N4S'

;blank line
;NH
   readf, LUN167, string_tmp4
   print, 'NH blank2!',string_tmp4
;SH
   readf, LUN170, string_tmp4
   print, 'SH blank2!',string_tmp4


;NH
   readf, LUN167, string_tmp4
   print, 'NH',string_tmp4
;SH
   readf, LUN170, string_tmp4
   print, 'SH',string_tmp4

   for j=1-1,(FLDIM/2)+1-1 DO begin
;NH
   readf, LUN167, Zj,SLj,GLj,BMj,GRj,SZAj,Oj,Hj,N2j,O2j,HEj,N4Sj , FORMAT='(F10.2,22E9.2)'

  Zn(J) =zj
 SLn(J) =SLj
 GLn(J) =GLj
 BMn(J) =BMj
 GRn(J) =GRj
SZAn(J) =SZAj
  On(J) =Oj
  Hn(J) =Hj
 N2n(J) =N2j
 O2n(J) =O2j
 HEn(J) =HEj
N4Sn(J) =N4Sj

;SH
   readf, LUN170, Zj,SLj,GLj,BMj,GRj,SZAj,Oj,Hj,N2j,O2j,HEj,N4Sj , FORMAT='(F10.2,22E9.2)'

  Zs(J) =zj
 SLs(J) =SLj
 GLs(J) =GLj
 BMs(J) =BMj
 GRs(J) =GRj
SZAs(J) = SZAj
  Os(J) =Oj
  Hs(J) =Hj
 N2s(J) =N2j
 O2s(J) =O2j
 HEs(J) =HEj
N4Ss(J) =N4Sj

if ( j eq 10 ) then  $
print, j, Zj,SLj,GLj,BMj,GRj,SZAj,Oj,Hj,N2j,O2j,HEj,N4Sj , FORMAT='(F10.2,22E9.2)'

   ENDFOR





if ( UT_hr ge plot_UT ) then begin
n_ldct=39
device, decomposed = 0 ,retain=2
window, 0 ,XSIZE=600,YSIZE=400
loadct, n_ldct ;=39
nh_blue=60. ;NH
sh_red=250. ;SH

j0=0L
j1=plotDIM-1
y_min =   90.
y_max = 362713.94 ;MAX(Zn) ;1000. ;18783.500 ;MAX(zn)
print, 'y_max', y_max
x_min =  90.0
x_max = y_max ;MAX(zn) ;1.01E+11
;frame only
plot, Zn(j0:j1), Zn(j0:j1), /xlog,/ylog $
,xrange=[x_min,x_max], xstyle=1  $
,yrange=[y_min,y_max], ystyle=1  $
,title='SL: mlat[deg]='+mlat_title+'  UT[hrs]='+STRTRIM( string(ut_hr, FORMAT='(f7.2)'), 1)+'  LT[hrs]='+STRTRIM( string(lt_hr, FORMAT='(f7.2)'), 1) $
,linestyle = 0 $
,color=255.99 $
,/NODATA
;NH
oplot, Zn(j0:j1), Zn(j0:j1) $
,linestyle = 0 $
,color=nh_blue
;SH
oplot, Zs(j0:j1), Zs(j0:j1) $
,linestyle = 1 $
,color=sh_red


filename='Z_mlat'+mlat_title+'_UT'+STRTRIM( string(ut_hr, FORMAT='(f7.2)'), 1)+'.png'
output_png, filename
BREAK
endif ;( UT_hr eq plot_UT ) then begin

   endwhile                            ; ( EOF(LUN167) ne 0 ) then begin
   FREE_LUN, LUN167
   FREE_LUN, LUN170


end ;pro plot_fort167
