;20150205
;purpose: UT variation of wind at 302km at mp=80
pro rd_wind

sw_dot=1L ;0:line; 1:dot
sw_wind_or_nmf2=1L ;0:nmf2; 1:wind
title_run= $
' '
;'original';
;'EXB X 1.5'
;'EXB X 0.5'
;'WIND X 1.5'
rundir= $
;'ipe_80_27926' ;original no wind
'ipe_80_22905' ;original
;'ipe_80_16467' ;EXBX1.5
;'ipe_80_2024'  ;EXB X 0.5
;'ipe_80_378'  ;wind X 1.5
   luntmpN=100
;path='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r319/trunk/run/'+rundir
path='./'
;   flnmtmpN=path+'/'+rundir+'noon_nmf2.dat' ;tmp20141008 original 27926
   flnmtmpN=path+'/tmp.dat'
   openr,luntmpN,flnmtmpN, /GET_LUN
   print, 'wind file opened:',flnmtmpN

imax=25L
for i=0,imax-1 do begin
mp_output_noonprfl=0L
readf, luntmpN, ut_hr
;print, 'ut_hr=', ut_hr
if i eq 0 then ut0=ut_hr
print,'nread=', i,' ut_hr=', ut_hr, (ut_hr-ut0)
NLP=170L
ny_max =248L;NLP*2
mlat=fltarr(ny_max)
wind=fltarr(ny_max)
mlat0=0.0e0
wind0=0.0e0

for k=0,ny_max-1 do begin
  readf, luntmpN, mlat0, wind0 ;positive NORTHward tmp20141008
;print,' mlat0', mlat0,'wind0',wind0
; NORTHward
  wind[k] = wind0 
  mlat[k] = mlat0
endfor

col_min=0.
col_max=255.



x_max=+50.;+5.; +55.;80.
x_min= -x_max
jmax=ny_max-1

y_plot=findgen(ny_max)*0.0
if ( sw_wind_or_nmf2 eq 0 ) then $
  y_plot = nmf2*fac  $
else if (sw_wind_or_nmf2 eq 1 ) then $
  y_plot = wind

;print, '(1)y_plot', y_plot
if ( i eq 0 ) then begin
  DEVICE, RETAIN=2, DECOMPOSED=0
  WINDOW,0,XSIZE=1000,YSIZE=1000
  !P.BACKGROUND=255

  loadct, 0
  colory=0.
char_size=4.
char_thick=2.5

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
  y_max= +80.;+90.
  y_min= -40.;-y_max
 Y_TITLE = 'Northward Field-Aligned Wind [m/s]'
 TITLE_main = title_run+'Wind Profile at 302 km'
 flnm_png=rundir+'windBW.png'
endif

;print, '(2)y_plot', y_plot

  plot, mlat[0:jmax],$
 y_plot[0:jmax] $
        , xrange=[x_min, x_max ],  xstyle=1  $
        , yrange=[y_min , y_max ],  ystyle=1  $
        ,XTITLE = 'MAGNETIC LATITUDE [deg.] ',YTITLE = Y_TITLE $
        ,TITLE = TITLE_main $
        , color=colory $
        ,charsize=char_size $
        ,charthick=char_thick $
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

if ( ( i MOD 3 ) eq 2 ) then begin

;default
line_style=0
line_thick=5.

if ( sw_dot eq 1 ) then begin
if (ut_hr-ut0) eq 2. then  line_style=5  
if (ut_hr-ut0) eq 5. then  line_style=0  ;nm20141008 new MIN
if (ut_hr-ut0) eq 8. then  line_style=4  
if (ut_hr-ut0) eq 11. then line_style=2  
if (ut_hr-ut0) eq 14. then line_style=4  
if (ut_hr-ut0) eq 17. then line_style=0
if (ut_hr-ut0) eq 20. then line_style=5  
if (ut_hr-ut0) eq 23. then line_style=3  
endif
;else $
;t print,'i=', i, line_style, line_thick
; CONTINUE ;go to next i

;if (ut_hr-ut0) eq 9. then line_thick=4.  
;if (ut_hr-ut0) eq 10. then line_thick=4.  ;nm20141008 new MIN
;if (ut_hr-ut0) eq 17. then line_thick=4.  

;print,'y_plot',y_plot
n_ldct=33
loadct, n_ldct
 colory = col_min + (ut_hr-ut0)*(col_max-col_min)/23.;FIX(imax)

print,'ut=', ut_hr, (ut_hr-ut0),colory

if ( (ut_hr-ut0) eq 23. ) then print, y_plot[0:jmax]
 
  oplot, mlat[0:jmax], $
y_plot[0:jmax] $
, linestyle=line_style $
, thick=line_thick $
, color=colory





;if ( ( (ut_hr-ut0) MOD 2. ) eq 1. ) then $
;  xyouts, 0.85, (0.9 - FIX(i)*0.013) $
;ii=40L ;for nmf2?
ii=37L; 240L ;for wind
  xyouts, mlat[ii], $
y_plot[ii] $
,STRTRIM( string( FIX(ut_hr-ut0), FORMAT='(i3)'),1 )+'UT' $
, charsize=3., charthick=2.5 $
, color=colory $
, /DATA $
;, /norm $
, /noclip


if i eq imax-2 then begin
  loadct, 0
  oplot, mlat[0:jmax], $
y_plot[0:jmax]*0.0 $
, linestyle=1 $
, thick=1.0 $
, color=0
endif

endif; ( ( (ut_hr-ut0) MOD 2. ) eq 1. ) then begin


endfor;for i=0,imax-1 do begin

if ( sw_dot eq 0 ) then tmp_string='line.png' else $
if ( sw_dot eq 1 ) then tmp_string='dot.png'
 flnm_png=rundir+'wind'+STRTRIM( string(n_ldct, FORMAT='(i2)'),1 )+tmp_string
print, flnm_png
output_png, flnm_png


end
