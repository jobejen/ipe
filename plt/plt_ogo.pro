pro plt_ogo


title_run='ogo';

rundir='ipe_80_27926'
luntmpN=100
path='./'
flnmtmpN=''
;t   openr,luntmpN,flnmtmpN, /GET_LUN
;t    print, 'ogo file opened:',flnmtmpN

;imax=25L
;t for i=0,imax-1 do begin
mp_output_noonprfl=0L
;readf, luntmpN, mp_output_noonprfl 
;print, 'mp=', mp_output_noonprfl 
;readf, luntmpN, ut_hr, glon_output 
;if i eq 0 then ut0=ut_hr
;print,'nread=', i,' ut_hr=', ut_hr, (ut_hr-ut0), ' glon=',glon_output
ny_max =97L
ut_hr=fltarr(ny_max)
kp   =fltarr(ny_max)
hptec=fltarr(ny_max)
hpeq =fltarr(ny_max)
teeq =fltarr(ny_max)
nmf2 =fltarr(ny_max)


ut_hr = findgen(ny_max) ;hours
kp[*] = 3.
hptec[*] = 1.0E13
hpeq[*] = 5.0E2
teeq[*] = 5000.
nmf2[*] = 1.0E5

;readf, luntmpN, v0,v1,v2,v3,v4,v5
;ut_hr[i]=v0




col_min=0.
col_max=255.



x_max=24.;+5.; +55.;80.
x_min=0.


y_plot=fltarr(ny_max)



;if ( i eq 0 ) then begin
  DEVICE, RETAIN=2, DECOMPOSED=0
  WINDOW,0,XSIZE=1000,YSIZE=1000
  !P.BACKGROUND=255
;                   columns,rows
	!p.multi=[0,1,5,0]
;endif

  loadct, 0
  colory=0.


  TITLE_main = title_run+' ogo 1968-08-05'
  flnm_png=rundir+'ogo.png'

  y_min=0.
  y_max=9.
  Y_TITLE = 'kp'
jmax=ny_max-1
y_plot[0:jmax] = kp[0:jmax]

  plot, ut_hr[0:jmax],$
 y_plot[0:jmax] $
        , xrange=[x_min, x_max ],  xstyle=1  $
        , yrange=[y_min , y_max ],  ystyle=1  $
        ,XTITLE = 'UT [hrs] ',YTITLE = Y_TITLE $
        ,TITLE = TITLE_main $
        , color=colory $
        ,/NODATA
loadct, 4

;default
line_style=0
line_thick=1.5

;1st panel
  oplot, ut_hr[0:jmax], $
y_plot[0:jmax] $
, linestyle=line_style $
, thick=line_thick $
, color=colory

;2nd panel
  y_min=1.E+12
  y_max=1.E+14 
  Y_TITLE = 'H+ TEC'
  y_plot[0:jmax] = hptec[0:jmax]
  plot, ut_hr[0:jmax], $
y_plot[0:jmax] $
        , xrange=[x_min, x_max ],  xstyle=1  $
        , yrange=[y_min , y_max ],  ystyle=1 ,/YLOG   $
;        ,XTITLE = 'UT [hrs] ' $
,YTITLE = Y_TITLE $
;        ,TITLE = TITLE_main $
, linestyle=line_style $
, thick=line_thick $
, color=colory

;3rd panel
  y_min=1.E+0
  y_max=5.E+3 
  Y_TITLE = 'H+ eq'
  y_plot[0:jmax] = hpeq[0:jmax]
  plot, ut_hr[0:jmax], $
y_plot[0:jmax] $
        , xrange=[x_min, x_max ],  xstyle=1  $
        , yrange=[y_min , y_max ],  ystyle=1 ,/YLOG  $
;        ,XTITLE = 'UT [hrs] ' $
,YTITLE = Y_TITLE $
;        ,TITLE = TITLE_main $
, linestyle=line_style $
, thick=line_thick $
, color=colory

;4th panel
  y_min=1000.
  y_max=7000.
  Y_TITLE = 'Te_eq'
  y_plot[0:jmax] = teeq[0:jmax]
  plot, ut_hr[0:jmax], $
y_plot[0:jmax] $
        , xrange=[x_min, x_max ],  xstyle=1  $
        , yrange=[y_min , y_max ],  ystyle=1  $
;        ,XTITLE = 'UT [hrs] ' $
,YTITLE = Y_TITLE $
;        ,TITLE = TITLE_main $
, linestyle=line_style $
, thick=line_thick $
, color=colory

;5th panel
  y_min=1.E+4
  y_max=5.E+6
  Y_TITLE = 'NmF2'
  y_plot[0:jmax] = nmf2[0:jmax]
  plot, ut_hr[0:jmax], $
y_plot[0:jmax] $
        , xrange=[x_min, x_max ],  xstyle=1  $
        , yrange=[y_min , y_max ],  ystyle=1 ,/YLOG  $
;        ,XTITLE = 'UT [hrs] ' $
,YTITLE = Y_TITLE $
;        ,TITLE = TITLE_main $
, linestyle=line_style $
, thick=line_thick $
, color=colory

;ii=240L ;for wind
;  xyouts, mlat[ii]*1.1, $
;y_plot[ii]*1.05 $
;,STRTRIM( string((ut_hr-ut0), FORMAT='(F3.0)'),1 )+'UT' $
;, charsize=2., charthick=2. $
;, color=colory $
;, /DATA $
;;, /norm $
;, /noclip

;t endfor;for i=0,imax-1 do begin

output_png, flnm_png


end
