pro plt_psphere_eqv0
  dt =720  ;sec
  ut0=478800 - dt ;sec 133.                      ;[ut hr]
  nmp=80L
  nlp=93L
  NPTS2D=31287L
  Re_m=6.3712E+06 ;.. Earth radius [meter] 

  x=fltarr(nmp,nlp)
  y=fltarr(nmp,nlp)
  r=fltarr(nmp,nlp)
  z=fltarr(nmp,nlp)

;read_grid, JMIN_IN,
restore, filename=$
'~/wamns/grid/plt/plasma_grid.2xdyn.sav'
;'plasma_grid.2xdyn.sav'
print, JMIN_IN[0:1]
print, JMAX_IS[0:1]
print, z_km[0]

;mlon_deg
mlon_deg=findgen(nmp)*360./FIX(NMP)
print, mlon_deg

;read_plasma, xion
TEST='r336.2'
rundir=$
;'ipe_S_32328' ;original
'ipe_S_25827' ;depeleted
flnm=$
'~/wamns/'+TEST+'/trunk/run/'+rundir+'/plasma01' ;h+
;'/Users/naomimaruyama/sandbox/ipe/'+rundir+'/plasma01' ;h+
plt_DIR='~/wamns/fig/'+TEST+'/'
lun00=0L
openr,lun00,flnm,/get_lun, /F77_UNFORMATTED

;read loop
dum=fltarr(NPTS2D,NMP)
ut = ut0
 while ( eof(LUN00) eq 0 ) do begin
readu,lun00,dum
ut = ut + dt

;read sunlon
sunlons1 = +0.1030E+01

for mp=0,nmp-1 do begin

;calculate MLT, theta
   mlt    =  mlon_deg[mp]/15.0D0 - sunlons1 * 12.0D0 / !PI  +12.0 ;[hr]
   if ( mlt lt  0. ) then  mlt = mlt MOD 24.
   if ( mlt ge 24. ) then  mlt = mlt - 24.
   mlt = mlt*!PI/12.0D0         ;MLT_hr --> THETA[rad]
   ;shift MLT so that 12MLT on the right!
   ;clockwise 180 deg rotation
   shift_deg= $
; 180.
- 45.
   theta = mlt - shift_deg/180.*!PI      ;(radian)

   for lp=0,nlp-1 do begin
    midpoint = JMIN_IN[lp] + ( JMAX_IS[lp] - JMIN_IN[lp] )/2 -1
    r        = (Z_km[midpoint] * 1.0E+3  + Re_m) / Re_m  ;L value


    
    x[mp,lp] = r * COS(theta)
    y[mp,lp] = r * SIN(theta)
    z[mp,lp] = dum[midpoint,mp]

 endfor                         ; lp=0,nlp-1 do begin
endfor ;mp=0,nmp-1 do begin    


zmax=0.1e+10 ;2.61e+10 ;MAX(z)
zmin=4.79e-9;10 ;MIN(z)
print, MAX(z),MIN(z)

n_levels=100
X_max=+7.0
X_min=-X_max
Y_max=X_max
Y_min=-Y_max


char_size=1.
char_thick=1.
;MAX_xymin =

;n_ldct=8 ;green
n_ldct=1 ;blue
loadct, n_ldct
;choose color
 col_max = 255.9999999999999999
 col_min =   0.0000000000000
 text_color=col_min 

iwindow=1L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,0,XSIZE=500,YSIZE=500

contour,z,x,y $
,/irregular $
,/fill $
, levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
, xrange=[X_min,X_max], /xstyle  $
, yrange=[Y_min,Y_max], /ystyle  $
,XTITLE = 'X', YTITLE = 'Y' $ 
,TITLE = ' ' $
;, POSITION=[X0 , Y0 , X1 , Y1 ] $
, COLOR=text_color $
, charsize = char_size, charthick = char_thick  ;$
;, MAX_VALUE= MAX_xymin ;$
;,/NODATA





; plot earth
;---earth start
; potential inside the earth should not be plotted!!!
; create the earth artificially
; zz=dblarr(isize,jsize)
jsize_e = 200L
isize_e = 200L
xmin_e=fltarr(isize_e,jsize_e)
ymin_e=fltarr(isize_e,jsize_e)
zz_e  =fltarr(isize_e,jsize_e)
rxy_max = 1.0
xmin_e0 = -1.0
ymin_e0 = -1.0

for j = 1-1, jsize_e-1  do begin
  for i = 1-1, isize_e-1  do begin

    xmin_e[i,j] =  xmin_e0 + i*rxy_max/isize_e*2.
    ymin_e[i,j] =  ymin_e0 + j*rxy_max/jsize_e*2.
    rxy = SQRT( xmin_e[i,j]*xmin_e[i,j] + ymin_e[i,j]*ymin_e[i,j] )    

    if ( rxy le rxy_max ) then begin
       if ( xmin_e[i,j] ge 0. ) then  zz_e[ i,j] = +rxy_max*0.7 $
       else                           zz_e[ i,j] = -rxy_max*0.7

    endif else begin ;if ( rxy > rxy_max ) then begin
       xmin_e[i,j]=0.0
       ymin_e[i,j]=0.0
       zz_e[  i,j]=0.0
    endelse

  endfor
endfor
zmax_e =  rxy_max
zmin_e = -rxy_max
;---earth end

loadct, 0 ;blue/white linear
contour,zz_e,xmin_e,ymin_e $
,/irregular $
,/fill $
, levels=findgen(n_levels)*(zmax_e-zmin_e)/float(n_levels-1) +zmin_e $
;, xrange=[X_min,X_max], /xstyle  $
;, yrange=[Y_min,Y_max], /ystyle  $
;, XTITLE = 'XMIN' , YTITLE = Y_TITLE $
;, TITLE = ' ' $
;, POSITION=[ X0/X_SIZE, Y0/Y_SIZE, X1/X_SIZE, Y1/Y_SIZE] $
;tmp020810: , COLOR=text_color $
;, charsize = char_size, charthick = char_thick  $
, /NOERASE $
, /overplot

; add circles along L values
  loadct, 0
  col_cir = col_max  ;white
  ;col_cir = col_min ;black

  theta_rad = findgen(360)*1.0D0 /180. * !PI ;[deg]-->[rad]
  for k=1,5,2  do begin

;if k ne 3 OR k ne 5 then CONTINUE 

     radius_circle = findgen(360)*0.0 + 1.0*FLOAT(k+1)

;back ground black circle
    oplot , /polar , radius_circle , theta_rad  $
            , THICK=0.8 $
            , COLOR =0. $;black  col_cir $
            , LINESTYLE = 0
;over plotting white circle
    oplot , /polar , radius_circle , theta_rad  $
            , THICK=0.8 $
            , COLOR =255. $     ;white  col_cir $
            , LINESTYLE = 2
  endfor
;geo synchronous
  radius_circle = findgen(360)*0.0 + 6.6
  oplot , /polar , radius_circle , theta_rad  $
            , THICK=1.0 $
            , COLOR =255. $     ;white  col_cir $
            , LINESTYLE = 0
  loadct, n_ldct


title=' ';colorbar title'
font=1   ;True-Type: 1.
; X_SIZE=29.7
; Y_SIZE=20.5 
; X0 = 2.2
; Y0 = 2.6
; Y_cmargin=1.0
;dYc = 0.28
charsize_colorbar=2.
format_colorbar='(E9.1)'
;position=[X0/X_SIZE, (Y1+Y_cmargin)/Y_SIZE, X1/X_SIZE, (Y1+Y_cmargin+dYc)/Y_SIZE]
position=[0.08, 0.96, 0.92, 0.98]
COLORBAR, BOTTOM=bottom, CHARSIZE=charsize_colorbar, COLOR=color, DIVISIONS=divisions $
        , FORMAT=format_colorbar, POSITION=position, MAXRANGE=zmax, MINRANGE=zmin $
        , NCOLORS=ncolors, TITLE=title, VERTICAL=vertical, TOP=top, RIGHT=right $
        , MINOR=minor, RANGE=range, FONT=font, TICKLEN=ticklen $
          , _EXTRA=extra, INVERTCOLORS=invertcolors,  TICKNAMES=ticknames


loadct,0
print, ut,  ut/3600.
xyouts, 0.015, 0.02  $
,'UT [hrs]='+STRTRIM( string( (ut/3600.), FORMAT='(F7.3)'),1 ) $
, charsize =1.5, charthick=1.5 $
, /norm, /noclip


xyouts, 0.85, 0.02  $
,rundir $
, charsize =0.9, charthick=0.9 $
        , /norm, /noclip

filename_png=plt_DIR+'hp_mgeq_ut'+STRTRIM( string(ut/3600., FORMAT='(F6.2)'),1 )+rundir+'v0.png'
print, filename_png
output_png, filename_png

 endwhile                        ;( eof(LUN00) eq 0 ) do begin

free_Lun,lun00
print, 'plt_psphere_eqv0 finished!'
end                             ;pro plt_psphere_eqv0
