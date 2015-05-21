pro ctr_lt_lat $
,mp_plot $
,JMIN_IN,JMAX_IS,Z_km,mlat_deg $
,plot_z $
,UT_hr_save,LT_hr,plot_DIR $
,plot_zz,plot_xx,plot_yy,n_read $
,VarType $
, ht_plot, sw_output2file  $
, glon_deg,glat_deg,sw_frame $
, plot_UT



; get n_read_max, ny_max
size_result = SIZE(plot_zz)
if ( n_read eq 0 ) then  print,'n_read_max=',size_result
n_read_max=size_result[1] ;289
ny_max    =size_result[2] ;NLP*2

;NPAR
;  plot_z = fltarr(n_read_max,NPAR, 1 ,NPTS2D) 
size_result = SIZE(plot_z)
if ( n_read eq 0 ) then  print,'NPAR',size_result
NPAR = size_result[2]

;NLP
size_result = SIZE(JMIN_IN)
if ( n_read eq 0 ) then  print,'NLP',size_result
NLP = size_result[1]



;ht_plot = 400.00 ;[km]
;VarType=3L

VarUnit=[$
'[m-3]','[K]','[K]','[eV kg-1 s-1]' $
  ]
VarTitle=[$
'Ne','Te','To+','hr2','hr3','hr4','hr5','hr6','hr7' $
;'No+','NH+','NHe+','','Te','nh' $
;,'o2dis'    $  ;3   ;6:VarType
;,'meta'     $  ;4   ;7
;'ground'   $  ;5   ;8
;'3body'    $  ;7   ;9
;'electron' $  ;8   ;10
;,'SRO2dis'  $  ;9 
,'UVN2dis'  ]  ;12  ;11

for lp=0,NLP-1 do begin

  in = JMIN_IN[lp]-1L
  is = JMAX_IS[lp]-1L
  midpoint = JMIN_IN[lp] + ( JMAX_IS[lp] - JMIN_IN[lp] )/2 -1
;NH  
  for i=in,midpoint,+1  do begin
    if ( z_km[i] gt ht_plot ) then begin
;print,'NH: mp',mp_plot,' lp',lp,' i',i,' z_km',z_km[i,mp_plot] , ht_plot
      plot_zz[n_read,lp] = plot_z[n_read,VarType, mp_plot, i]

if( sw_frame eq 0 ) then $
      plot_yy[n_read,lp] = mlat_deg[i]  $
else if( sw_frame eq 1 ) then $
      plot_yy[n_read,lp] = glat_deg[i,mp_plot]  

if ( mp_plot eq  0 ) then $
 fac_lt=-4.8 $
else if ( mp_plot eq 39 ) then $
 fac_lt=6.925

      plot_xx[n_read,lp] = UT_hr_save[n_read]+fac_lt
      BREAK 
    endif
  endfor ;i

;SH  
  lps = NLP-1 + (NLP-1-lp) 
  for i=is,midpoint,-1  do begin
    if ( z_km[i] gt ht_plot ) then begin
;print,'SH: mp',mp_plot,' lp',lp,' i',i,' z_km',z_km[i,mp_plot] , ht_plot
      plot_zz[n_read,lps] = plot_z[n_read,VarType,  mp_plot,i]
if( sw_frame eq 0 ) then $
      plot_yy[n_read,lps] = mlat_deg[i] $
else if( sw_frame eq 1 ) then $
      plot_yy[n_read,lp] = glat_deg[i,mp_plot]  

if ( mp_plot eq  0 ) then $
fac_lt=-5. $
else if ( mp_plot eq 39 ) then $
fac_lt=6.925

      plot_xx[n_read,lps] = UT_hr_save[n_read]+fac_lt ;LT_hr[mp_plot,lp]
      BREAK
    endif
  endfor ;i

endfor ;lp=0,NLP-1 do begin

;(1) when time < time_max 
; get values & return
if ( n_read lt n_read_max-1L ) then $
  RETURN $
else if ( n_read eq n_read_max-1L ) then begin
;(2) when time = time_max 
; plotting
if ( VarType eq 1 ) then begin 
zmax=$
3000. ;40.;ht400;
zmin=$
0.;

endif else if ( VarType eq 2 ) then begin 
zmax=$
3000. ;40.;ht400;
zmin=$
500.  ;0.;

endif else if ( VarType eq 0 ) then begin 
zmax=$
7.e+12;$;
;max(plot_zz)
zmin=$
1.e+10;$
;min(plot_zz)
endif

print,'zmax',zmax,max(plot_zz),' zmin',zmin,min(plot_zz)

;MAX_xymin=1.0E+3 ;hrate
;MAX_xymin=5.0E+3 ;te
MAX_xymin=1.0E+13 ;Ne
n_levels=100L

print,' max(plot_xx)', max(plot_xx),' min(plot_xx)', min(plot_xx)
plot_xx = plot_xx - plot_UT/3600.
print,' max(plot_xx)', max(plot_xx),' min(plot_xx)', min(plot_xx)
X_max=MAX(plot_xx)
X_min=X_max-24.;68.9739-5.-24.; MIN(plot_xx);  0.0
if ( sw_frame eq 0 ) then begin 
Y_max=+60.0  ;90.0
Y_TITLE='magnetic latitude[deg]'
endif else if ( sw_frame eq 1 ) then begin 
Y_max=+90.0
Y_TITLE='geographic latitude[deg]'
endif

Y_min=-Y_max
X_TITLE='LT[hr]'

text_color=255.
char_size=1.0
char_thick=1.0
n_ldct=5;39
iwindow=1L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,iwindow,XSIZE=500,YSIZE=500*0.7 ;20120406 validation
!P.MULTI=[0,1,1] ;20120406 validation
loadct,n_ldct

X0=0.10
X1=0.90
;X1=;0.47 ;0.90
Y0=0.10
Y1=0.79
contour,plot_zz,plot_xx,plot_yy $
,/irregular $
,/fill $
,levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
,xrange=[X_min,X_max], /xstyle $
,yrange=[Y_min,Y_max], /ystyle $
,XTITLE=X_TITLE,YTITLE=Y_TITLE $
,TITLE=VarTitle[VarType]+' '+VarUnit[VarType]+'  ht='+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'km   mp='+STRTRIM( string(mp_plot, FORMAT='(i2)'),1 ) $
,POSITION=[X0,Y0,X1,Y1] $
,COLOR=text_color $
,charsize=char_size,charthick=char_thick $
,MAX_VALUE= MAX_xymin 

charsize_colorbar=1.5
;format_colorbar='(F4.1)' ;hrate
if ( VarType eq 1 ) or ( VarType eq 2 ) then $ 
  format_colorbar='(F5.0)' $ ;Te
else if ( VarType eq 0 ) then $ 
  format_colorbar='(E10.2)' ;No+
font=1 ;true-type 
position=[0.10, 0.90, 0.90, 0.95] ;for horizontal bar
;position=[0.10, 0.90, 0.47, 0.95] ;for horizontal bar
COLORBAR, BOTTOM=bottom, CHARSIZE=charsize_colorbar, COLOR=color, DIVISIONS=divisions $
        , FORMAT=format_colorbar, POSITION=position, MAXRANGE=zmax,MINRANGE=zmin $
        , NCOLORS=ncolors,TITLE=title,VERTICAL=vertical,TOP=top,RIGHT=right $
        , MINOR=minor, RANGE=range, FONT=font, TICKLEN=ticklen $
        , _EXTRA=extra, INVERTCOLORS=invertcolors, TICKNAMES=ticknames

xyouts, $
;0.40,0.96 $
0.30,0.96 $
 ,'MAX/MIN:'+STRTRIM( STRING( MAX(plot_zz), FORMAT=format_colorbar), 1)+'/'+STRTRIM( STRING( MIN(plot_zz), FORMAT=format_colorbar), 1) $
 ,charsize=1.0, charthick=1.0 $
 ,/norm, /noclip



sw_champ_prf = 0 
factor=[1.0e-12, 1., 1.]
 ;20120406 validation
if ( sw_champ_prf eq 1 ) then begin
y_min1=[-0.3, 400.,400.]
y_max1=[ 2.4, 3700., 3700.]
lpi=112
print, 'mlat',plot_yy[10,lpi],lpi
for i=0,n_read_max-1 do begin
print, 'lt',  plot_xx[i,lpi],' te',plot_zz[i,lpi]
endfor
plot, (plot_xx[*,lpi]-72.), plot_zz[*,lpi]*factor[VarType] $
  ,xrange=[0. ,24. ], xstyle=1  $
;Ne  ,yrange=[-0.3 , 2.4 ], ystyle=1  ;$
;  ,yrange=[400. , 3700. ], ystyle=1  ;$
  ,yrange=[y_min1[VarType],y_max1[VarType]], ystyle=1  ;$

endif else if ( sw_champ_prf eq 2 ) then begin
y_min1=[ 0.3, 800.,800.]
y_max1=[ 2.1, 2000., 2000.]
lpi=112 -9 -15
n_readx=190-79
print, 'n_readx=',n_readx,'LT=', (plot_xx[n_readx,lpi]-72.), plot_xx[n_readx,lpi]

plot, plot_yy[n_readx,*], plot_zz[n_readx,*]*factor[VarType] $
  ,xrange=[-30. ,30. ], xstyle=1  $
  ,yrange=[y_min1[VarType],y_max1[VarType]], ystyle=1  $
,TITLE=' LT='+STRTRIM( string((plot_xx[n_readx,lpi]), FORMAT='(F7.2)'),1 )+'('+STRTRIM( string((plot_xx[n_readx,lpi]-72.), FORMAT='(F7.2)'),1 )+')[hr]'

endif  ;( sw_champ eq 1 ) then begin


if ( sw_output2file eq 1 ) then begin
Filename_png=plot_DIR+VarTitle[VarType]+'_ht'+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'_mp'+STRTRIM( string(mp_plot, FORMAT='(i2)'),1 )+'.vld'+STRTRIM( string(sw_champ_prf, FORMAT='(i1)'),1 )+'.png'
print, 'output to file:',Filename_png
output_png, Filename_png
endif

endif ;else if ( n_read eq n_read_max ) then begin

end ;pro contour_lt_lat
