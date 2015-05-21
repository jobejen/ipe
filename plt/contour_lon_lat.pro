pro contour_lon_lat $
,JMIN_IN,JMAX_IS,Z_km,mlat_deg $
;,je_3d $
, XIONN_m3 $
,UT_hr, plot_DIR $
,n_read

sw_range=1L
nano=1.0E-9
unit='[m-3]';[nA/m2]'

; get n_read_max, ny_max
size_result = SIZE(JMIN_IN)
if ( n_read eq 0 ) then  print,'NLP',size_result
NLP = size_result[1]
ny_max =170*2;NLP*2

size_result = SIZE(XIONN_m3) ;je_3d)
if ( n_read eq 0 ) then  print,'NMP',size_result
NMP = size_result[3]    ;NMP=80
nx_max =size_result[3]    ;NMP=80


mlon_deg_min=100.
dmlon=4.50 ;deg
mlon_deg=findgen(NMP)*dmlon
for mp=0,nmp-1 do begin
if ( mlon_deg[mp] lt mlon_deg_min ) then  mlon_deg[mp]=mlon_deg[mp]+360.
endfor

plot_zz=fltarr(nx_max,ny_max)
plot_yy=fltarr(nx_max,ny_max)
plot_xx=fltarr(nx_max,ny_max)

ht_plot =380.00 ;[km]
VarType=0L
VarTitle=['O+','je2']

for mp=0,NMP-1 do begin
for lp=0,NLP-1 do begin

  in = JMIN_IN[lp]-1L
  is = JMAX_IS[lp]-1L
  midpoint=IN + ( IS - IN )/2
;NH  
  istep=+1
  for i=in,midpoint, istep  do begin
    if ( z_km[i] le ht_plot ) AND ( z_km[i+istep] gt ht_plot ) then begin
;print,'NH: mp',mp,' lp',lp,' i',i,' z_km',z_km[i] , ht_plot
      plot_zz[mp,lp] = XIONN_m3[VarType,i,mp] ;[m-3]
      plot_yy[mp,lp] = mlat_deg[i]
      plot_xx[mp,lp] = mlon_deg[mp]
      BREAK 
    endif
  endfor ;i

;SH  
  lps = NLP-1 + (NLP-1-lp)
  istep=-1 
  for i=is,midpoint, istep  do begin
    if ( z_km[i] le ht_plot ) AND ( z_km[i+istep] gt ht_plot )  then begin
;print,'SH: mp',mp,' lp',lp,' i',i,' z_km',z_km[i] , ht_plot
      plot_zz[mp,lps] = XIONN_m3[VarType,i,mp];[m-3]  je_3d[VarType,i,mp]/nano
      plot_yy[mp,lps] = mlat_deg[i]
      plot_xx[mp,lps] = mlon_deg[mp]
      BREAK
    endif
  endfor ;i

endfor ;lp=0,NLP-1 do begin
endfor ;mp=0,NMP-1 do begin

;debug
;mp=0L
;for l=0,ny_max-1 do print,l,plot_zz(mp,l),plot_xx(mp,l),plot_yy(mp,l)
;l=151
;for mp=0,nx_max-1  do print,mp,plot_zz(mp,l),plot_xx(mp,l),plot_yy(mp,l)

;(2) when time = time_max 
; plotting
if ( sw_range eq 1 ) then begin
zmin=1.e+10
zmax=7.e+12
endif else if ( sw_range eq 0 ) then begin
zmax = max(plot_zz)
zmin = min(plot_zz)
endif
print,'zmax',zmax,' zmin',zmin

MAX_xymin=zmax ;1.0E+3
n_levels=100L

X_min=mlon_deg_min ;  0.0
X_max=mlon_deg_min+360.
Y_max=+60.0
Y_min=-Y_max
X_TITLE='magnetic longitude[deg]'
Y_TITLE='magnetic latitude[deg]'

text_color=255.
char_size=1.0
char_thick=1.0
n_ldct=39
iwindow=1L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,iwindow,XSIZE=500,YSIZE=500
loadct,n_ldct

X0=0.10
X1=0.90
Y0=0.10
Y1=0.79
contour,plot_zz,plot_xx,plot_yy $
,/irregular $
,/fill $
,levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
,xrange=[X_min,X_max], /xstyle $
,yrange=[Y_min,Y_max], /ystyle $
,XTITLE=X_TITLE,YTITLE=Y_TITLE $
,TITLE=VarTitle[VarType]+unit+'  ht='+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'km  UT[hr]='+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 ) $
,POSITION=[X0,Y0,X1,Y1] $
,COLOR=text_color $
,charsize=char_size,charthick=char_thick $
,MAX_VALUE= MAX_xymin 

charsize_colorbar=1.5
format_colorbar='(E9.1)'
font=1 ;true-type 
position=[0.10, 0.90, 0.90, 0.95] ;for horizontal bar
COLORBAR, BOTTOM=bottom, CHARSIZE=charsize_colorbar, COLOR=color, DIVISIONS=divisions $
        , FORMAT=format_colorbar, POSITION=position, MAXRANGE=zmax,MINRANGE=zmin $
        , NCOLORS=ncolors,TITLE=title,VERTICAL=vertical,TOP=top,RIGHT=right $
        , MINOR=minor, RANGE=range, FONT=font, TICKLEN=ticklen $
        , _EXTRA=extra, INVERTCOLORS=invertcolors, TICKNAMES=ticknames

Filename_png=plot_DIR+VarTitle[VarType]+'_ht'+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'_ut'+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+'.png'
output_png, Filename_png



end ;pro contour_lon_lat
