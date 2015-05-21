;pro plot_fort168  ;20120304:
pro plt_f168
factor_window=0.8
sw_output2file=1
TEST='v43'
HOME_DIR='/home/Naomi.Maruyama/iper'
RUN_DIR=HOME_DIR+'/'+TEST+'/'
DISP_DIR=HOME_DIR+'/fig/'+TEST+'/'
mlat_title='16'
plot_UT =16.002;40.97 ;16.97 ;52.97 ;64.97 ;17.06;
;high resolution
if ( mlat_title eq '10' ) then  FLDIM =  265L  else $
if ( mlat_title eq '35' ) then  FLDIM = 1357L  else $
if ( mlat_title eq '37' ) then  FLDIM = 1435L  else $
if ( mlat_title eq '38' ) then  FLDIM = 1473L  else $
if ( mlat_title eq '60' ) then  FLDIM = 2141L  else $
if ( mlat_title ge '85' ) then  FLDIM = 4501L  else $
if ( mlat_title ge '16' ) then  FLDIM =  161L 

PLOTDIM = FLDIM/2
Zn=fltarr(FLDIM)
TNXn=fltarr(FLDIM)
UNn=fltarr(FLDIM)
NNOn=fltarr(FLDIM)
EHTn=fltarr(3,FLDIM)   
TIn=fltarr(3,FLDIM)
Nn=fltarr(4,FLDIM)
PHIONn=fltarr(FLDIM)
;SH
Zs=fltarr(FLDIM)
TNXs=fltarr(FLDIM)
UNs=fltarr(FLDIM)
NNOs=fltarr(FLDIM)
EHTs=fltarr(3,FLDIM)   
TIs=fltarr(3,FLDIM)
Ns=fltarr(4,FLDIM)
PHIONs=fltarr(FLDIM)

;NH
  input_flnm=RUN_DIR+'fort.168' ;+'.mlat'+mlat_title+'.'+STRTRIM( string(FLDIM, FORMAT='(i4)'), 1)+'pts'
   openr, LUN168, input_flnm, /GET_LUN
;SH
  input_flnm=RUN_DIR+'fort.171' ;+'.mlat'+mlat_title+'.'+STRTRIM( string(FLDIM, FORMAT='(i4)'), 1)+'pts'
   openr, LUN171, input_flnm, /GET_LUN

   WHILE ( EOF(LUN168) eq 0 ) do begin

     fmt00='(A3,I3,A4,I3,A16,2F10.3)'
     fmt01='(3F10.2,22E9.2)'
     str00='mp='
     str01=' lp='
     string_tmp1=$
' U168 North, UT=' ;20120304 3d version
;'U168, North, UT='


;NH
   readf, LUN168, str00,mp_plot,str01,lp_plot,string_tmp1, UT_hr, LT_hr, FORMAT=fmt00
;'(A16,2F10.2)'

   print, $
str00,mp_plot,str01,lp_plot,string_tmp1, UT_hr, LT_hr
;string_tmp1, UT_hr, LT_hr
;SH
   readf, LUN171, str00,mp_plot,str01,lp_plot,string_tmp1, UT_hr, LT_hr, FORMAT=fmt00 
;string_tmp1, UT_hr, LT_hr, FORMAT='(A16,2F10.2)'
   print, $
;string_tmp1, UT_hr, LT_hr
str00,mp_plot,str01,lp_plot,string_tmp1, UT_hr, LT_hr

   string_tmp2='     Z         TN       UN       NNO      EHT      TI       TE       O+       H+      Min+     He+      PHION    PRODO+     N+     EQN2D   NPLSPRD'
;NH
   readf, LUN168, string_tmp2
  ;print, string_tmp
;SH
   readf, LUN171, string_tmp2

   for j=1-1,(FLDIM/2)+1-1 DO begin
;NH
   readf, LUN168, zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j,n3j,n4j,phionj $
,SUMIONJ,XIONNJ,EQN2DJ,NPLSPRDJ  $
, FORMAT=fmt01 ;'(3F10.2,22E9.2)'

Zn(J)=zj
TNXn(J)=tnxj
UNn(J)=unj
NNOn(J)=nnoj
EHTn(3-1,J)=eht3j
TIn(1-1,J)=ti1j
TIn(3-1,J)=ti3j
Nn(1-1,J)=n1j
Nn(2-1,J)=n2j
Nn(3-1,J)=n3j
Nn(4-1,J)=n4j
PHIONn(J)=phionj

;SH
   readf, LUN171, zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j,n3j,n4j,phionj $
,SUMIONJ,XIONNJ,EQN2DJ,NPLSPRDJ $
, FORMAT=fmt01 ;'(3F10.2,22E9.2)'

Zs(J)=zj
TNXs(J)=tnxj
UNs(J)=unj
NNOs(J)=nnoj
EHTs(3-1,J)=eht3j
TIs(1-1,J)=ti1j
TIs(3-1,J)=ti3j
Ns(1-1,J)=n1j
Ns(2-1,J)=n2j
Ns(3-1,J)=n3j
Ns(4-1,J)=n4j
PHIONs(J)=phionj

;if ( j eq 10 ) then  $
;print, j,zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j,n3j,n4j,phionj, FORMAT='(i5,3F10.2,22E9.2)'

   ENDFOR


if ( UT_hr ge plot_UT ) then begin
n_ldct=39
device, decomposed = 0 ,retain=2
window, 0 ,XSIZE=600*factor_window,YSIZE=400*factor_window
loadct, n_ldct ;=39
nh_blue=60. ;NH
sh_red=250. ;SH

j0=0L
j1=plotDIM-1
y_min =   90.
y_max = 630.;1000. ;18783.500 ;MAX(zn)
print, y_max
x_min = 1.0e-0
x_max = 5.0e+6 ;1.0e+8
;frame only
plot, Nn(0,j0:j1), Zn(j0:j1), /xlog $  ;O+
,xrange=[x_min,x_max], xstyle=1  $
,yrange=[y_min,y_max], ystyle=1  $
,title='mlatdeg='+mlat_title+'  UThr='+STRTRIM( string(ut_hr, FORMAT='(f7.2)'), 1)+'  LThr='+STRTRIM( string(lt_hr, FORMAT='(f7.2)'), 1) $
,linestyle = 0 $
,color=255.99 $
,/NODATA
;NH
oplot, Nn(0,j0:j1), Zn(j0:j1) $  ;O+
,linestyle = 0 $
,color=nh_blue
;SH
oplot, Ns(0,j0:j1), Zs(j0:j1) $  ;O+
,linestyle = 0 $
,color=sh_red

;NH
oplot,Nn(1,j0:j1), Zn(j0:j1) $    ;H+
,linestyle = 2 $
,color=nh_blue
;SH
oplot,Ns(1,j0:j1), Zs(j0:j1) $    ;H+
,linestyle = 2 $
,color=sh_red
;NH
oplot,Nn(3,j0:j1), Zn(j0:j1) $    ;He+
,linestyle = 1 $
,color=nh_blue
;SH
oplot,Ns(3,j0:j1), Zs(j0:j1) $    ;He+
,linestyle = 1 $
,color=sh_red
;NH
oplot,TIn(1-1,j0:j1), Zn(j0:j1) $    ;Ti
,linestyle = 3 $
,color=nh_blue
;SH
oplot,TIs(1-1,j0:j1), Zs(j0:j1) $    ;Ti
,linestyle = 3 $
,color=sh_red
;NH
oplot,TIn(3-1,j0:j1), Zn(j0:j1) $    ;Te
,linestyle = 4 $
,color=nh_blue
;SH
oplot,TIs(3-1,j0:j1), Zs(j0:j1) $    ;Te
,linestyle = 4 $
,color=sh_red

if ( sw_output2file eq 1 ) then begin
filename=DISP_DIR+'/mlat'+mlat_title+'_UT'+STRTRIM( string(ut_hr, FORMAT='(f7.2)'), 1)+'.png'
output_png, filename
endif

BREAK
endif ;( UT_hr eq plot_UT ) then begin

   endwhile                            ; ( EOF(LUN168) ne 0 ) then begin
   FREE_LUN, LUN168
   FREE_LUN, LUN171


end ;pro plt_f168
