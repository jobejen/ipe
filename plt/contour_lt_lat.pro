pro contour_lt_lat $
,mp_plot $
,JMIN_IN,JMAX_IS,Z_km,mlat_deg $
,plot_z $
,UT_hr_save,LT_hr,plot_DIR $
,plot_zz,plot_xx,plot_yy,n_read $
,VarType $
, ht_plot



; get n_read_max, ny_max
size_result = SIZE(plot_zz)
if ( n_read eq 0 ) then  print,'n_read_max=',size_result
n_read_max=size_result[1] ;289
ny_max    =size_result[2] ;NLP*2

;NPAR
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
'[K]','[m-3]','[eV kg-1 s-1]' $
  ]
VarTitle=[$
'Te','No+','hr1','hr2','hr3','hr4','hr5','hr6','hr7' $
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
      plot_yy[n_read,lp] = mlat_deg[i]
      plot_xx[n_read,lp] = UT_hr_save[n_read]-5. ;LT_hr[mp_plot,lp]
      BREAK 
    endif
  endfor ;i

;SH  
  lps = NLP-1 + (NLP-1-lp) 
  for i=is,midpoint,-1  do begin
    if ( z_km[i] gt ht_plot ) then begin
;print,'SH: mp',mp_plot,' lp',lp,' i',i,' z_km',z_km[i,mp_plot] , ht_plot
      plot_zz[n_read,lps] = plot_z[n_read,VarType,  mp_plot,i]
      plot_yy[n_read,lps] = mlat_deg[i]
      plot_xx[n_read,lps] = UT_hr_save[n_read]-5. ;LT_hr[mp_plot,lp]
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
zmax=$
3000. ;40.;ht400;
;7.e+12;$;
;max(plot_zz)
zmin=$
500.  ;0.;
;1.e+10;$
;min(plot_zz)
print,'zmax',zmax,max(plot_zz),' zmin',zmin,min(plot_zz)

;MAX_xymin=1.0E+3 ;hrate
;MAX_xymin=5.0E+3 ;te
MAX_xymin=1.0E+13 ;Ne
n_levels=100L

X_min=47.-24.;68.9739-5.-24.; MIN(plot_xx);  0.0
X_max=47.;68.9739-5.; MAX(plot_xx); 24.0
Y_max=+60.0;90.0
Y_min=-Y_max
X_TITLE='LT[hr]'
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
,TITLE=VarTitle[VarType]+' '+VarUnit[VarType]+'  ht='+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'km   mp='+STRTRIM( string(mp_plot, FORMAT='(i1)'),1 ) $
,POSITION=[X0,Y0,X1,Y1] $
,COLOR=text_color $
,charsize=char_size,charthick=char_thick $
,MAX_VALUE= MAX_xymin 

charsize_colorbar=1.5
;format_colorbar='(F4.1)' ;hrate
format_colorbar='(F5.0)' ;Te
;format_colorbar='(E10.2)' ;No+
font=1 ;true-type 
position=[0.10, 0.90, 0.90, 0.95] ;for horizontal bar
COLORBAR, BOTTOM=bottom, CHARSIZE=charsize_colorbar, COLOR=color, DIVISIONS=divisions $
        , FORMAT=format_colorbar, POSITION=position, MAXRANGE=zmax,MINRANGE=zmin $
        , NCOLORS=ncolors,TITLE=title,VERTICAL=vertical,TOP=top,RIGHT=right $
        , MINOR=minor, RANGE=range, FONT=font, TICKLEN=ticklen $
        , _EXTRA=extra, INVERTCOLORS=invertcolors, TICKNAMES=ticknames

xyouts,0.40,0.96 $
 ,'MAX/MIN:'+STRTRIM( STRING( MAX(plot_zz), FORMAT=format_colorbar), 1)+'/'+STRTRIM( STRING( MIN(plot_zz), FORMAT=format_colorbar), 1) $
 ,charsize=1.0, charthick=1.0 $
 ,/norm, /noclip

Filename_png=plot_DIR+VarTitle[VarType]+'_ht'+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'_mp'+STRTRIM( string(mp_plot, FORMAT='(i1)'),1 )+'.png'
output_png, Filename_png

endif ;else if ( n_read eq n_read_max ) then begin

end ;pro contour_lt_lat
