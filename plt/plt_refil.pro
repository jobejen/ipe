;20120322UNDERCONSTRUCTION!!!
pro plt_refil   , mlat_deg, JMIN_IN,JMAX_IS, plot_z,mp_plot,n_read_max,ut_hr_save,fac_window, plot_UT,plot_UT_end,runID

TEST='FPAS3'

FMT_l='(F7.1)'

for jth=4,5 do begin ;4:h+ ;5:he+

   if jth eq 4 then VarTitle='H+' else $
   if jth eq 5 then VarTitle='He+' ;else $
print, jth,VarTitle

imin=0
imax=2
for i=imin,imax do begin

if ( i eq 0 ) then begin
  lp=29  ;L=3.15
  line_style=0
  line_thick=3.
endif else if ( i eq 1 ) then begin
  lp=25 ;L=3.94
  line_style=5
  line_thick=3.
endif else if ( i eq 2 ) then begin
  lp=23 ;L=5.13
  line_style=4
  line_thick=3.
endif

   if jth eq 4 then color_line=50 else $
   if jth eq 5 then color_line=254
;color_line=50 ;50*(lp-lpstrt)/20
;d print, 'color_line', color_line

Re=6.3712E+03;km
r_ref=Re+90. ;km for reference ht for rcm
;assuming that latitude grid is identical for all LT sectors

midpoint = JMIN_IN[lp]-1 + ( JMAX_IS(lp) - JMIN_IN(lp) )/2
theta = (90.- mlat_deg[  JMIN_IN[lp]-1 ])  *!PI / 180.  ;[deg]-->[rad]
sinthet = SIN( theta ) 
lval    = r_ref / ( Re * sinthet * sinthet )
print,'L-value=',lval,' mlat=',mlat_deg[jmin_in(lp)-1],' lp=',lp;,(jmin_in(lp)-1),(jmax_is(lp)-1)
;print,midpoint,mlat_deg[midpoint]

den=fltarr(n_read_max)
rat=fltarr(n_read_max)
for n=0,n_read_max-1 do begin
   den[n]=plot_z[n,jth,0,midpoint]*1.0E-6 ;m-3-->cm-3
   rat[n]=plot_z[n,jth,0,midpoint] / plot_z[n,0,0,midpoint]
endfor

calculate_refilling_rate, den, ut_hr_save, n_read_max

print,' ratio=', rat

x_min=345600./3600.  ;plot_UT/3600.
x_max=950400./3600.;x_min+24.     ;plot_UT_end/3600. - plot_UT/3600.
y_min=0.

   if jth eq 4 then y_max=1200.  else $
   if jth eq 5 then y_max= 110.; [cm-3] 



;dbg
;d print,'check den', den
;d print,'check ut', ut_hr_save
if ( i eq imin ) then begin
  device, decomposed = 0 ,retain=2
  window, 0 ,XSIZE=800*fac_window,YSIZE=800*fac_window
!P.BACKGROUND=255
   loadct, 0
   plot, ut_hr_save, den $
; need to specify xmin,xmax
  ,xrange=[x_min,x_max], xstyle=1  $
  ,yrange=[y_min,y_max], ystyle=1  $
  ,title=TEST+' '+VarTitle+': L='+STRTRIM( string(lval, FORMAT=FMT_l), 1) $ ;+title_plot  $
  ,linestyle = 0 $
  ,color=0. $ ;color_line 
  ,thick=line_thick $
, charsize=2.0, charthick=2.0 $
  ,/NODATA

endif 
   loadct, 39
   oplot, ut_hr_save, den $
          ,linestyle =line_style $
          ,thick=line_thick $
          ,color=color_line 

endfor                          ;i=imin,imax

FILE_DISP=TEST+VarTitle+'_L'+STRTRIM( string(lval, FORMAT=FMT_l), 1)+'.png'
;  if ( sw_output2file eq 1 ) then  
output_png, FILE_DISP

endfor ;jth=4,5 do begin ;4:h+ ;5:he+
end ;pro plt_refil   , mlat_deg, JMIN_IN,JMAX_IS, plot_z
