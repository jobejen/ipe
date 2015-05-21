pro draw_arrow_test,u,v,thetaR,radi, rim_lat, sw_debug;$
;,X00,dX,X_SIZE,Y0,Y_SIZE

sw_v_or_e=0 ;0:V; 1:E
size_resultu=SIZE(u)
if sw_debug eq 1 then print,' size_u',size_resultu
size_resultv=SIZE(v)
if sw_debug eq 1 then print,' size_v',size_resultv
size_radi=SIZE(radi)
if sw_debug eq 1 then  print,' size_radi', size_radi
size_thetaR=SIZE(thetaR)
if sw_debug eq 1 then  print,' size_thetaR', size_thetaR

;for velocity
if ( sw_v_or_e eq 0 ) then begin
  ArrowRef=300. ;2000. ;m/s
;for velocity
  ArrowCol=0.;255. ;defalt black ;256 ;
;for velocity
  factor=0.025 ;0.05
;for velocity
  ArrowColR=255. ;white

endif else if ( sw_v_or_e eq 1 ) then begin
;for Efield
  ArrowRef=30. ;2000. ;mV/m
;for Efield
  ArrowCol=20.;255. ;defalt black ;256 ;
;for Efield
  factor=0.2 ;0.05
;for Efield
  ArrowColR=0. ;green

endif
;loadct, 0





value_thick=0.8

istep=3
jstep=2;1

for i=0L,size_thetaR[1]-1,   istep  do begin ;thetaR
  for j=0L,  size_radi[1]-1, jstep  do begin ;radi

  ;print, 'check thetaR',i, (thetaR[i]/!DTOR),thetaR[i]



;if ( radi[j] gt 10. ) then  BREAK
;if ( j ne 0 ) then  CONTINUE ;for V
;if ( j ne 2 ) then  CONTINUE ; for E

;ArrowCol=255.;0. ;black 
value_thick=2.
;endif else begin
;ArrowCol=255.
;value_thick=0.8
;endelse

X0_arrow = radi[j]*COS(thetaR[i])
Y0_arrow = radi[j]*SIN(thetaR[i])

U0=u[i,j]
V0=v[i,j]
mag = SQRT(U0*U0 + V0*V0)
Xmag = V0*cos(thetaR[i])-U0*sin(thetaR[i])
Ymag = V0*sin(thetaR[i])+U0*cos(thetaR[i])
costheta = Xmag/mag
if Ymag ge 0 then $
  sintheta = SQRT(1.0 -costheta*costheta) $
else $
  sintheta = - SQRT(1.0 -costheta*costheta)

comlat_min = -59.  +90. ;lat [deg.] from the pole
comlat_max = -50.  +90.
mlt_rad_min = (270.-15.*3.)*!DTOR
mlt_rad_max = (270.+15.*3.-360.)*!DTOR

;print, 'mlt_rad_min', mlt_rad_min,'mlt_rad_max',mlt_rad_max
;if ( mag gt 800. ) then 
;if ( radi[j] le 10. ) then mag = 0.0
;if ( radi[j] le comlat_min ) or ( radi[j] ge comlat_max ) then CONTINUE
;if ( thetaR[i] le mlt_rad_min ) and ( thetaR[i] ge mlt_rad_max ) then CONTINUE

  arwmag = mag * factor
  dX_arrow = arwmag * costheta
  dY_arrow = arwmag * sintheta

  X1_arrow = X0_arrow + dX_arrow
  Y1_arrow = Y0_arrow + dY_arrow
;print, 'check arrow ref location!!', X0_arrow, Y0_arrow, X1_arrow, Y1_arrow

    ARROW, X0_arrow, Y0_arrow, X1_arrow, Y1_arrow  $
  , /DATA       $ 
;, /NORMALIZED $
  , HSIZE= (!D.X_SIZE / 64.)*0.5 $
  , COLOR=ArrowCol $ ;index] $
;, HTHICK=value] $
;, /SOLID] $
  , THICK=value_thick

  endfor ;j=0L,size_radi[1]-1  do begin ;radi
endfor ;i=0L,size_thetaR[1]-1  ;thetaR


;draw arrow reference
X0_arrow=(90.-rim_lat) * 0.563 ;+28.
Y0_arrow=(90.-rim_lat) * 0.9451 * (-1.) ;-47.

U0=ArrowRef
V0=0.;ArrowRef
mag = SQRT(U0*U0 + V0*V0)

;thetaR(i)= FLOAT(i - L_6lt)*360.0*!DTOR/FLOAT(Xdm[1])
thetaRi=(-45.)*!DTOR
Xmag = V0*cos(thetaRi)-U0*sin(thetaRi)
Ymag = V0*sin(thetaRi)+U0*cos(thetaRi)
costheta = Xmag/mag
if Ymag ge 0 then $
  sintheta = SQRT(1.0 -costheta*costheta) $
else $
  sintheta = - SQRT(1.0 -costheta*costheta)

arwmag = mag * factor
dX_arrow = arwmag * costheta
dY_arrow = arwmag * sintheta

dX_arrow = arwmag * costheta
dY_arrow = arwmag * sintheta

X1_arrow = X0_arrow + dX_arrow
Y1_arrow = Y0_arrow + dY_arrow

ARROW, X0_arrow, Y0_arrow, X1_arrow, Y1_arrow  $
, /DATA       $ 
;, /NORMALIZED $
, HSIZE= (!D.X_SIZE / 64.)*0.5 $
, COLOR=ArrowColR  $ ;index] $
;, HTHICK=value] $
;, /SOLID] $
, THICK=value_thick

xyouts,$
; ( (X00+dX-3.2)/X_SIZE ), ( (Y0-0.07)/Y_SIZE) $
 0.70, 0.07 $
, 'V='+STRTRIM( string(ArrowRef,FORMAT='(f5.0)') ,1)+'[m/s]'  $
, charsize=2.0, charthick=2.0, /norm, /noclip

end ;pro draw_arrow_test
