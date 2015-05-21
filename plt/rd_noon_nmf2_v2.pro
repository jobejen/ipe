pro rd_noon_nmf2_v2

sw_wind_or_nmf2=0 ;0:nmf2
title_run= $
' ';
;'original';
;'EXB X 1.5'
;'EXB X 0.5'
rundir= $
;'ipe_80_27926' ;original no wind
'ipe_80_22905' ;original
;'ipe_80_16467' ;EXBX1.5
;'ipe_80_2024'  ;EXB X 0.5
   luntmpN=100
;path='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r319/trunk/run/'+rundir
path='./'
   flnmtmpN=path+'/'+rundir+'noon_nmf2.v2.dat'
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
;NLP=170L
ny_max =111L;NLP*2
;ltime=fltarr(ny_max)
mlat=fltarr(ny_max)
nmf2=fltarr(ny_max)
hmf2=fltarr(ny_max)
tec=fltarr(ny_max)
readf, luntmpN, ltime
print,'ltime=', ltime ;at jicamarca
readf, luntmpN, mlat
readf, luntmpN, nmf2
readf, luntmpN, hmf2
readf, luntmpN, tec
fac=1.0E-12
;readf, luntmpN, wind ;tmp20141008

col_min=0.
col_max=255.

x_max=+50.;80.
x_min= -x_max
jmax=ny_max-1;338L

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
;  y_min=0.
  y_min=0.5
;  y_max=2.6E+12*fac ;f107=120
  y_max=2.7E+12*fac ;f107=120
  ;y_max=3.2E+12*fac ;f107=180
  Y_TITLE = 'NmF2 [10!U12!N  m!U-3!N]'
  TITLE_main = title_run+' Noon NmF2 Profile'
  flnm_png=rundir+'noon_nmf2BW.png'
endif else if (sw_wind_or_nmf2 eq 1 ) then begin
  y_max=+90.
  y_min=-y_max
 Y_TITLE = 'field aligned wind [m/s]'
 TITLE_main = title_run+' noon wind profile'
 flnm_png=rundir+'noon_windBW.png'
endif

char_size=4.;1.8
char_thick=2.5;2.

  plot, mlat[0:jmax],$
 y_plot[0:jmax] $
        , xrange=[x_min, x_max ],  xstyle=1  $
        , yrange=[y_min , y_max ],  ystyle=1  $
        ,XTITLE = 'MAGNETIC LATITUDE [deg.] ',YTITLE = Y_TITLE $
        ,TITLE = TITLE_main $
,charsize=char_size, charthick=char_thick $
        , color=colory $
        ,/NODATA
  loadct, 4
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
line_thick=3.;1.5

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
;print,'i=', i, line_style, line_thick
 CONTINUE ;go to next i

;if (ut_hr-ut0) eq 9. then line_thick=4.  
if (ut_hr-ut0) eq 10. then line_thick=5.  ;nm20141008 new MIN
if (ut_hr-ut0) eq 17. then line_thick=5.  

;print,'y_plot',y_plot
 colory = col_min + (ut_hr-ut0)*(col_max-col_min)/FIX(imax)
  oplot, mlat[0:jmax], $
y_plot[0:jmax] $
, linestyle=line_style $
, thick=line_thick $
, color=colory


;if ( ( (ut_hr-ut0) MOD 2. ) eq 1. ) then $
;  xyouts, 0.85, (0.9 - FIX(i)*0.013) $
ii=80L;81L
  xyouts, mlat[ii]*1.1, $
y_plot[ii]*1.0 $
,STRTRIM( string(FIX(ut_hr-ut0), FORMAT='(i3)'),1 )+'UT' $
, charsize=3.5, charthick=3. $
, color=colory $
, /DATA $
;, /norm $
, /noclip

;endif; ( ( (ut_hr-ut0) MOD 2. ) eq 1. ) then begin


endfor;for i=0,imax-1 do begin

output_png, flnm_png


end
