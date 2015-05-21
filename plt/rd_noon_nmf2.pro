pro rd_noon_nmf2

rundir='ipe_80_27926'
   luntmpN=100
;path='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r319/trunk/run/'+rundir
path='./'
   flnmtmpN=path+'/noon_nmf2.dat'
   openr,luntmpN,flnmtmpN, /GET_LUN
   print, 'noon nmf2 file opened:',flnmtmpN

imax=25L
for i=0,imax-1 do begin
readf, luntmpN, mp_output_noonprfl 
readf, luntmpN, ut_hr, glon_output 
if i eq 0 then ut0=ut_hr
print, i, (ut_hr-ut0), glon_output
NLP=170L
ny_max =NLP*2
ltime=fltarr(ny_max)
mlat=fltarr(ny_max)
nmf2=fltarr(ny_max)
;wind=fltarr(ny_max)
readf, luntmpN, ltime
readf, luntmpN, mlat
readf, luntmpN, nmf2
;readf, luntmpN, wind


col_min=0.
col_max=255.
fac=1.0E-12
y_min=0.
y_max=2.6E+12*fac
x_max= +80.
x_min= -x_max
jmax=338L

if ( i eq 0 ) then begin
  DEVICE, RETAIN=2, DECOMPOSED=0
  WINDOW,0,XSIZE=1000,YSIZE=1000
  !P.BACKGROUND=255

  loadct, 0
  colory=0.
  plot, mlat[0:jmax], nmf2[0:jmax]*fac $
        , xrange=[x_min, x_max ],  xstyle=1  $
        , yrange=[y_min , y_max ],  ystyle=1  $
        ,XTITLE = 'mlat [deg] ', YTITLE = 'NmF2 X 10^-12 [m-3]' $
        , color=colory $
        ,/NODATA
  loadct, 4
 
;dbg20141001
;for j =0,ny_max-1 do print, j,nmf2[j]


 CONTINUE ;go to next i
endif

if ( ( (ut_hr-ut0) MOD 2. ) eq 1. ) then begin

line_style=0
line_thick=1.5
if (ut_hr-ut0) eq 17. then line_thick=4.  
if (ut_hr-ut0) eq 9. then line_thick=4.  
colory = col_min + (ut_hr-ut0)*(col_max-col_min)/FIX(imax)
  oplot, mlat[0:jmax], nmf2[0:jmax]*fac $
, linestyle=line_style $
, thick=line_thick $
, color=colory


  xyouts, 0.85, (0.9 - FIX(i)*0.013) $
,'UT'+STRTRIM( string((ut_hr-ut0), FORMAT='(F4.0)'),1 )+'[hr]' $
, charsize=1.3, charthick=1.3 $
, color=colory $
, /norm, /noclip

endif; ( ( (ut_hr-ut0) MOD 2. ) eq 1. ) then begin


endfor;for i=0,imax-1 do begin

output_png, rundir+'noon_nmf2.png'

end
