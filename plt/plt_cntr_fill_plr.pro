;20150313: polar plot version, copied from plt_cntr_fill.pro
;20140225 separated out from plt_efv2.pro
;purpose: plot filled color contour
pro plt_cntr_fill_plr $
, iplot_max,mlon90_2d,mlat90_2d, sw_180,mlat130,poten,ed1130,ed2130,ed190,ed290,sw_debug,mlon130,mlat90_0,utime,runDATE,TEST2,plot_DIR,mp,lp, sw_output2file 
;
fac_window=10.
sw_arrow=1
  var_title=['pot130[kV]','ed1130[mV/m]','ed2130[mV/m]','pot130-mlat90[kV]','ed190[mV/m]','ed290'] 
SW_range=1L
plot_NH=1L
if( SW_range eq 1 ) then  begin
;  value_min_fix=[  -30.,     -20.,    -25. ,-30.,-20.]
;  value_max_fix=[  +30.,     +20.,    +25. ,+30.,+20.]
  if (plot_NH eq 1) then begin
    value_min_fix=[  -43.,     -33.,    -33. ,-43.,-33.,-33.]
    value_max_fix=[  +43.,     +33.,    +33. ,+43.,+33.,+33.]
;     val0=1.3
;     value_min_fix=[  -8.,     -val0,    -val0 ,-8., -val0, -val0]
;     value_max_fix=[  +8.,     +val0,    +val0 ,+8., +val0, +val0]
  endif
endif

iwindow=0L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,iwindow,XSIZE=1000*fac_window,YSIZE=700*fac_window
!p.multi=[0,3,2,0]
;!p.multi=[0,1,1,0]
n_ldct=39  ;rainbow+black
;loadct,n_ldct
redblue
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
;dbg20150313  for iplot=0,iplot_max do begin
for iplot=0,5 do begin
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


; polar plot
;temporary set sunlon
sunlons1 = $
;-1.929 ;  near 0ut
0.2409E+00 ;17ut
if ( iplot le 2 ) then begin
  krmax=11L;25L;SH -42.

;if ( which_hem eq 'NH' ) then $
  jj=krmax-1 ;$ SH
;else if ( which_hem eq 'SH' ) then $
;  jj=ny_max-2-krmax+1


  rim_lat = mlat130[jj]
  print, 'mlat130=',mlat130[0:jj]
endif else if ( iplot eq 3 ) then begin
  krmax=11L;SH  -4
  jj=krmax-1 ;$ SH
  rim_lat = mlat90_0[jj]
  print,'mlat90_0=', mlat90_0[0:jj+5]
endif else begin 
  krmax=14L;SH  -41.9
  jj=krmax-1 ;$ SH
  rim_lat = mlat90_2d[0,jj+5]
  print,'mlat90_2d=', mlat90_2d[0,0:jj+5]
endelse 
print,iplot,krmax,' rim_lat[deg]=', rim_lat


if ( iplot lt 4 ) then $
  size_result=SIZE(mlon130) $
else $
  size_result=SIZE(mlon90_2d)
imax=size_result[1]
print,iplot,' imax', imax
mlt=fltarr(imax)
comlat = fltarr(krmax)
if ( iplot ge 4 ) then begin
  mlt    = fltarr(imax,krmax)  
  comlat = fltarr(imax,krmax)  
endif
zz_plr=fltarr(imax,krmax)
for i=0,imax-1 do begin
  for j=0,krmax-1 do begin


if ( iplot le 3 ) then begin
;   mlt[i]    = mlon130[i]/15.0D0 - sunlons1 * 12.0D0 / !PI   +12.0 ;[hr]
;NOTE! mlon130 is already in MLT!!!
   mlt[i]    = mlon130[i]*24./360. ;deg-->hr 

  if ( mlt[i] lt  0. ) then  mlt[i] = mlt[i] MOD 24.
  if ( mlt[i] ge 24. ) then  mlt[i] = mlt[i] - 24.
endif else begin
   mlt[i,j]    = mlon90_2d[i,j]/15.0D0 - sunlons1 * 12.0D0 / !PI   +12.0 ;[hr] !CORRECT!
  if ( mlt[i,j] lt  0. ) then  mlt[i,j] = mlt[i,j] MOD 24.
  if ( mlt[i,j] ge 24. ) then  mlt[i,j] = mlt[i,j] - 24.
endelse


;      if ( which_hem eq 'NH' ) then begin
;SH
         jj = j 

if ( iplot le 2 ) then $
         comlat[jj] = 90. + mlat130[j] $;[deg]
else if ( iplot eq 3 ) then $
         comlat[jj] = 90. + mlat90_0[j] $
else $
         comlat[i,jj] = 90. + mlat90_2d[i,j]


;      endif else if ( which_hem eq 'SH' ) then  begin
;         jj = jmin-j 
;         comlat[jj] = 90. + plot_yy[mp,j] ;[deg] ;degrees measured from South Pole
;      endif


    zz_plr[i,j] = zz[i,j]
  endfor ;j
endfor ;i

mlt = mlt*!PI/12.0D0   ;MLT_hr --> THETA[rad]
;shift the MLT so that 00MLT comes at the bottom of the plot!
;clockwise 90deg rotation
mlt = mlt - !PI*0.50D0       ;(radian)


   zmax=MAX(zz_plr)
   zmin=MIN(zz_plr)
   if ( sw_debug eq 1 ) then  $
      print,iplot,' maxZ=',zmax,' minZ=',zmin
   
   if( SW_range eq 1 ) then  begin
  zmax=value_max_fix[iplot]
  zmin=value_min_fix[iplot]
endif
max_z_data = MAX(zz_plr)
min_z_data = MIN(zz_plr)

get_position $
, iplot, iwindow  $
, X0 , Y0 , X1 , Y1





if ( iplot ge 4 ) then $
;contour,zz,mlon90_2d,mlat90_2d $
polar_contour_qhull,zz_plr,mlt,comlat $
,/irregular $
,/fill $
, levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
;, xrange=[X_min,X_max], /xstyle  $
;, yrange=[Y_min,Y_max], /ystyle  $
  , xstyle = 5, ystyle = 5  $
;,XTITLE = 'mlon90', YTITLE = 'mlat90' $ 
,TITLE = ' ' $
, POSITION=[X0 , Y0 , X1 , Y1 ] $
, COLOR=text_color $
, charsize = char_size, charthick = char_thick  $
,sw_debug $

;else if ( iplot eq 3 ) then $
;contour,zz,mlon130,mlat90_0 $
;,/fill $
;, levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
;, xrange=[X_min,X_max], /xstyle  $
;, yrange=[Y_min,Y_max], /ystyle  $
;;,XTITLE = 'mlon130', YTITLE = 'mlat90' $ 
;,TITLE = ' ' $
;, POSITION=[X0 , Y0 , X1 , Y1 ] $
;, COLOR=text_color $
;, charsize = char_size, charthick = char_thick  $


else $
;dbg20150313 contour,zz,mlon130,mlat130 $
polar_contour_qhull,zz_plr,mlt,comlat $
,/fill $
, levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
;, xrange=[X_min,X_max], /xstyle  $
;, yrange=[Y_min,Y_max], /ystyle  $
  , xstyle = 5, ystyle = 5  $
;,XTITLE = 'mlon130', YTITLE = 'mlat130' $ 
,TITLE = ' ' $
, POSITION=[X0 , Y0 , X1 , Y1 ] $
, COLOR=text_color $
, charsize = char_size, charthick = char_thick $
,sw_debug

if sw_arrow eq 1 then begin
if  iplot eq 0 OR iplot eq  4 then begin
loadct, 2
print,iplot,'check imax=', imax,krmax
u=fltarr(imax,krmax)
v=fltarr(imax,krmax)
for j=0,krmax-1 do begin
  for i=0,imax-1 do begin

if ( iplot eq 0 ) then begin
    u[i,j]= ed1130[i,j]
;print, 'check u=',u[i,j],i,j
    v[i,j]= ed2130[i,j]
 endif else if ( iplot eq 4 ) then begin
    u[i,j]= ed190[i,j]
;print, 'check u=',u[i,j],i,j
    v[i,j]= ed290[i,j]
 endif

  endfor ;i
endfor ;j

if ( iplot eq 0 ) then $
  draw_arrow_test, u, v, mlt, comlat, rim_lat $
; when comlat and rim_lat has 2 dims
else if ( iplot eq 4 ) then $
  draw_arrow_test2D, u, v, mlt, comlat, rim_lat 

endif ;if iplot eq 0
endif ;if sw_arrow eq 1 then begin

;;***rule: AXIS, X,Y, XAXIS=0
rim_colat = 90.+ rim_lat
AXIS,  0.,  0., XAXIS = 0  $
, Xrange = [-rim_colat, +rim_colat],  Xstyle = 1 $
, color =col_min
AXIS,  0.,  0., YAXIS = 0  $
, Yrange = [-rim_colat, +rim_colat],  Ystyle = 1 $
, color =col_min


;nm102306: new axis
;plot latitude circle-- 80deg--50deg(k=3)  --> 10deg(7)  ;nm010107:
loadct, 0
;nm010107: for k=0,3 do begin
for k=0,4 do begin
lat_circle = findgen(imax)*0.0 + 10.0*FLOAT(k+1)

if ( lat_circle[0] gt rim_colat ) then break  ;exit from the k loop

if ( iplot le 3 ) then $
oplot , /polar , lat_circle[0:imax-1] , mlt[0:imax-1]  $
, THICK=1.0, COLOR = col_min, LINESTYLE = 1 $
else  $
oplot , /polar , lat_circle[0:imax-1] , mlt[0:imax-1,0]  $
, THICK=1.0, COLOR = col_min, LINESTYLE = 1 

endfor
;loadct, n_ldct 
redblue
;---

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


