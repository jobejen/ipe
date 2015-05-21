;20140225 separated out from plt_efv2.pro
;purpose: plot filled color contour
pro plt_cntr_fill $
, iplot_max,mlon90_2d,mlat90_2d, sw_180,mlat130,poten,ed1130,ed2130,ed190,ed290,sw_debug,mlon130,mlat90_0,utime,runDATE,TEST2,plot_DIR,mp,lp, sw_output2file 
;
  var_title=['pot130[kV]','ed1130[mV/m]','ed2130[mV/m]','pot130-mlat90[kV]','ed190[mV/m]','ed290'] 
SW_range=1L
plot_NH=1L
if( SW_range eq 1 ) then  begin
;  value_min_fix=[  -30.,     -20.,    -25. ,-30.,-20.]
;  value_max_fix=[  +30.,     +20.,    +25. ,+30.,+20.]
  if (plot_NH eq 1) then begin
    value_min_fix=[  -8.,     -2.,    -5. ,-8.,-2.,-5.]
    value_max_fix=[  +8.,     +2.,    +5. ,+8.,+2.,+5.]
;     val0=1.3
;     value_min_fix=[  -8.,     -val0,    -val0 ,-8., -val0, -val0]
;     value_max_fix=[  +8.,     +val0,    +val0 ,+8., +val0, +val0]
  endif
endif

iwindow=0L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,iwindow,XSIZE=1000,YSIZE=700
!p.multi=[0,3,2,0]
;!p.multi=[0,1,1,0]
n_ldct=39  ;rainbow+black
loadct,n_ldct
text_color=160  ;within rainbow+black color table
char_size =2.0
char_thick=1.5
;choose color
 col_max = 255.9999999999999999
 col_min =   0.0000000000000
n_levels=100L

if ( sw_180 eq 1 ) then begin
   X_min=-180.                  ;MIN(mlon130)
   X_max=+180.                  ;MAX(mlon130)
endif else if ( sw_180 eq 0 ) then begin
   X_min=0.                     ;MIN(mlon130)
   X_max=+360.                  ;MAX(mlon130)
endif 

Y_max=MAX(mlat130)
Y_min=-Y_max;MIN(mlat130)
if ( plot_NH eq 1 ) then begin
;  Y_max=+60.
  Y_max=+90.
  Y_min=+0.
endif

charsize_colorbar=3.4
format_colorbar='(f6.2)'
for iplot=0,iplot_max do begin
   if ( iplot eq 0 ) then begin
      zz=poten*1.0E-3           ;V-->kV
   endif else if ( iplot eq 1 ) then begin
      zz=ed1130
   endif else if ( iplot eq 2 ) then begin
      zz=ed2130
   endif else if ( iplot eq 3 ) then begin
      zz=poten*1.0E-3           ;V-->kV
   endif else if ( iplot eq 4 ) then begin
      zz=ed190                  ;mV/m
   endif else if ( iplot eq 5 ) then begin
      zz=ed290                  ;20120604:*(-1.) ;mV/m  ed2 corrected in the source file!
   endif

   zmax=MAX(zz)
   zmin=MIN(zz)
   if ( sw_debug eq 1 ) then  $
      print,iplot,' maxZ=',zmax,' minZ=',zmin
   
   if( SW_range eq 1 ) then  begin
  zmax=value_max_fix[iplot]
  zmin=value_min_fix[iplot]
endif
max_z_data = MAX(zz)
min_z_data = MIN(zz)

get_position $
, iplot, iwindow  $
, X0 , Y0 , X1 , Y1



;if ( iplot eq 4 ) then begin
;
;print, 'mlon90_2d', mlon90_2d
;print, 'mlat90_2d', mlat90_2d
;stop
;endif

if ( iplot ge 4 ) then $
contour,zz,mlon90_2d,mlat90_2d $
,/irregular $
,/fill $
, levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
, xrange=[X_min,X_max], /xstyle  $
, yrange=[Y_min,Y_max], /ystyle  $
,XTITLE = 'mlon90', YTITLE = 'mlat90' $ 
,TITLE = ' ' $
, POSITION=[X0 , Y0 , X1 , Y1 ] $
, COLOR=text_color $
, charsize = char_size, charthick = char_thick  $

else if ( iplot eq 3 ) then $
contour,zz,mlon130,mlat90_0 $
,/fill $
, levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
, xrange=[X_min,X_max], /xstyle  $
, yrange=[Y_min,Y_max], /ystyle  $
,XTITLE = 'mlon130', YTITLE = 'mlat90' $ 
,TITLE = ' ' $
, POSITION=[X0 , Y0 , X1 , Y1 ] $
, COLOR=text_color $
, charsize = char_size, charthick = char_thick  $

else $
contour,zz,mlon130,mlat130 $
,/fill $
, levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
, xrange=[X_min,X_max], /xstyle  $
, yrange=[Y_min,Y_max], /ystyle  $
,XTITLE = 'mlon130', YTITLE = 'mlat130' $ 
,TITLE = ' ' $
, POSITION=[X0 , Y0 , X1 , Y1 ] $
, COLOR=text_color $
, charsize = char_size, charthick = char_thick 


add_colorbar $
, X0, X1, Y1 $
,zmax, zmin   $
, iwindow $
,charsize_colorbar,format_colorbar


xyouts, x0, (y1+0.01) $
, var_title[iplot]+'  MAX/MIN:'+STRTRIM( string(max_z_data, FORMAT='(E9.2)'), 1)+'/'+STRTRIM( string(min_z_data, FORMAT='(E9.2)'), 1)  $
, charsize =1.0, charthick=char_thick $
, /norm, /noclip

endfor ;iplot=0,2 do begin


loadct,0
xyouts, 0.03, 0.96  $
,'UT [sec]='+STRTRIM( string(utime, FORMAT='(i7)'),1 )+' '+runDATE+TEST2 $
, charsize =1.5, charthick=char_thick $
, /norm, /noclip

filename=plot_DIR+'ts_efield.'+'UTsec'+STRTRIM( string(utime, FORMAT='(i6)'),1 )+runDATE+'.png'
if ( plot_NH eq 1 ) then $
; filename='ts_efield.'+runDATE+'NH.png'
filename=plot_DIR+'ts_efield.'+'UTsec'+STRTRIM( string(utime, FORMAT='(i6)'),1 )+runDATE+'NH'+STRTRIM( string(mlat90_2d[mp,lp], FORMAT='(F6.2)'),1 )+'mp'+STRTRIM( string(mp, FORMAT='(i2)'),1 )+'ed2.v2.png'

if ( sw_output2file eq 1 ) THEN  output_png, filename

end ;plt_cntr_fill $


