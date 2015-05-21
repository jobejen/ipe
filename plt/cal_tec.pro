;date: 113004
;name: calculate_tec
;purpose: calculate TEC from trigrid_result

PRO cal_tec $
, fxht_var, fxht_x,fxht_y $
, tec

nnloop=2
nplot=0L

size_results=SIZE(fxht_var)
nx=size_results[2]
ny=size_results[3]

d_y=fxht_y[2]-fxht_y[1]
print,' d_y [km]', d_y

;TEC=fltarr(nx)
TEC(*)=0.0e0
for ix=0,nx-1  do begin  ;glat
  for iy=0,ny-1  do begin  ;htkm

  ; log-> Ne
   ne1=10^(fxht_var[0,ix,iy])  ;[m-3]
   TEC(ix)= TEC(ix)+ ne1*(d_y*1.0e+3)  ;[m-3 * m] =[m-2]
  endfor ;iy=0,nx-1  do begin  ;htkm
endfor ;ix=0,nx-1  do begin


; 1[TECU]=10e16 [/m2]
tec(*)=tec(*)*1.0e-16

sw_iplot= 0
if ( sw_iplot eq 1) then begin
nnread1=5;720 ;[min];nnread ;7
;set color
ig=fix( 255.- 255.*float(nnloop-nplot)/float(nnread1) )     ;(nread-n_plot0)  ;*2
if ( ig lt 0 ) then ig=0
ir=fix(   0.+ 255.*float(nnloop-nplot)/float(nnread1) )     ;(nread-n_plot0)  ;*2
if ( ir gt 255 ) then ir=255
ib=fix( 255.- 255.*float((nnloop-nplot)*4)/float(nnread1) )    ;0L
if ( ib lt 0 ) then ib=0
RGB_vector=[ir,ig,ib]


;092804: debug
print, 'check color!', ir,ig,ib, nnloop,nplot,nnread1


;if ( nread eq n_plot0 ) then $
if ( nnloop eq nplot ) then $
iPlot, fxht_x, tec   $
;, TITLE='TEC [TECU]  gLON'+string(fix(glon(100,mpx,46)))  $
, IDENTIFIER=iToolID $
, COLOR = RGB_vector $
else  $
iPlot, fxht_x, tec   $
, OVERPLOT=iToolID   $
, COLOR = RGB_vector


print, "itoolid= ", itoolid
endif ;( sw_iplot eq 1) AND  then

sw_plot_tec=0
if ( sw_plot_tec eq 1 ) then $
Plot, fxht_x, tec   

end  ;PRO calculate_tec,...
