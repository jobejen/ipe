pro rd_noon_nmf2_wind

sw_wind_or_nmf2=0 ;0:nmf2; 1:wind
title_run= $
;'original';
;'EXB X 1.5'
;'EXB X 0.5'
'WIND X 1.5'
rundir= $
;'ipe_80_27926' ;original no wind
;'ipe_80_22905' ;original
;'ipe_80_16467' ;EXBX1.5
;'ipe_80_2024'  ;EXB X 0.5
'ipe_80_378'  ;wind X 1.5
   luntmpN=100
;path='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r319/trunk/run/'+rundir
path='./'
;   flnmtmpN=path+'/'+rundir+'noon_nmf2.dat' ;tmp20141008 original 27926
   flnmtmpN=path+'/'+rundir+'noon_nmf2_wind.dat'
   openr,luntmpN,flnmtmpN, /GET_LUN
   print, 'noon nmf2 file opened:',flnmtmpN

imax=25L
for i=0,imax-1 do begin
mp_output_noonprfl=0L
readf, luntmpN, mp_output_noonprfl 
print, 'mp=', mp_output_noonprfl 
readf, luntmpN, ut_hr, glon_output 
if i eq 0 then ut0=ut_hr
print,'nread=', i,' ut_hr=', ut_hr, (ut_hr-ut0), ' glon=',glon_output
NLP=170L
ny_max =NLP*2
ltime=fltarr(ny_max)
mlat=fltarr(ny_max)
nmf2=fltarr(ny_max)
wind=fltarr(ny_max)
readf, luntmpN, ltime
print,'ltime=', ltime[129] ;at jicamarca
readf, luntmpN, mlat
readf, luntmpN, nmf2
fac=1.0E-12
readf, luntmpN, wind ;positive NORTHward tmp20141008
;convert from NORTH to SOUTHward
wind = wind * (-1.0)


col_min=0.
col_max=255.



x_max=+80.;+5.; +55.;80.
x_min= -x_max
jmax=338L

y_plot=findgen(ny_max)*0.0
if ( sw_wind_or_nmf2 eq 0 ) then $
  y_plot = nmf2*fac  $
else if (sw_wind_or_nmf2 eq 1 ) then $
  y_plot = wind

if ( i eq 0 ) then begin
  DEVICE, RETAIN=2, DECOMPOSED=0
  WINDOW,0,XSIZE=1000,YSIZE=1000
  !P.BACKGROUND=255

  loadct, 0
  colory=0.


;nmf2
if ( sw_wind_or_nmf2 eq 0 ) then begin
  y_min=0.
  y_max=2.6E+12*fac ;f107=120
;  y_max=3.0E+12*fac ;f107=120
  ;y_max=3.2E+12*fac ;f107=180
  Y_TITLE = 'NmF2 X 10^-12 [m-3]'
  TITLE_main = title_run+' noon NmF2 profile'
  flnm_png=rundir+'noon_nmf2BW.png'
endif else if (sw_wind_or_nmf2 eq 1 ) then begin
  y_max=+90.
  y_min=-y_max
 Y_TITLE = 'field aligned wind [m/s]  positive SOUTHWARD'
 TITLE_main = title_run+' noon wind profile'
 flnm_png=rundir+'noon_windBW.png'
endif

  plot, mlat[0:jmax],$
 y_plot[0:jmax] $
        , xrange=[x_min, x_max ],  xstyle=1  $
        , yrange=[y_min , y_max ],  ystyle=1  $
        ,XTITLE = 'mlat [deg] ',YTITLE = Y_TITLE $
        ,TITLE = TITLE_main $
        , color=colory $
        ,/NODATA
;t  loadct, 4
  CONTINUE ;go to next i
endif

;dbg20141001
;if i eq 17 then begin
;  for j =0,ny_max-1 do print, j,nmf2[j]
;  print, MAX( nmf2, Max_Subscript ), Max_Subscript
;  STOP
;endif

;if ( ( (ut_hr-ut0) MOD 2. ) eq 1. ) then begin

;default
line_style=0
line_thick=1.5

;if (ut_hr-ut0) eq 9. then line_style=5 $ 
if (ut_hr-ut0) eq 10. then line_style=5 $ ;nm20141008 new MIN
;if (ut_hr-ut0) eq 11. then line_style=3  
;if (ut_hr-ut0) eq 13. then line_style=1  
;if (ut_hr-ut0) eq 15. then line_style=2  
else if (ut_hr-ut0) eq 17. then line_style=0  $
;if (ut_hr-ut0) eq 19. then line_style=4  
;if (ut_hr-ut0) eq 21. then line_style=5  
else if (ut_hr-ut0) eq 22. then line_style=3   $
;if (ut_hr-ut0) eq 23. then line_style=3  
;if (ut_hr-ut0) eq 1.  then line_style=1  
else if (ut_hr-ut0) eq 3.  then line_style=1  $
;if (ut_hr-ut0) eq 5.  then line_style=0  
;if (ut_hr-ut0) eq 7.  then line_style=4  
else $
;t print,'i=', i, line_style, line_thick
 CONTINUE ;go to next i

;if (ut_hr-ut0) eq 9. then line_thick=4.  
if (ut_hr-ut0) eq 10. then line_thick=4.  ;nm20141008 new MIN
if (ut_hr-ut0) eq 17. then line_thick=4.  

;print,'y_plot',y_plot
;t colory = col_min + (ut_hr-ut0)*(col_max-col_min)/FIX(imax)
  oplot, mlat[0:jmax], $
y_plot[0:jmax] $
, linestyle=line_style $
, thick=line_thick $
, color=colory


;if ( ( (ut_hr-ut0) MOD 2. ) eq 1. ) then $
;  xyouts, 0.85, (0.9 - FIX(i)*0.013) $
;ii=40L ;for nmf2?
ii=240L ;for wind
  xyouts, mlat[ii]*1.1, $
y_plot[ii]*1.05 $
,STRTRIM( string((ut_hr-ut0), FORMAT='(F3.0)'),1 )+'UT' $
, charsize=2., charthick=2. $
, color=colory $
, /DATA $
;, /norm $
, /noclip

;endif; ( ( (ut_hr-ut0) MOD 2. ) eq 1. ) then begin


endfor;for i=0,imax-1 do begin

output_png, flnm_png


end
