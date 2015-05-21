;010505: improved for the paper
;date: 113004
; copied from main_plot_ctip_gmcords_tsflux.pro  when plot_type=5
;purpose: interpolate from pq coords to rectangular grid
    ;        and plot contour plot of the interpolated value

;010505: PRO interpolate  $
;20120625 PRO interpolate_ctip   $
PRO intrp2fixht  $
;20120625 , in,is , glat, htkm  $
, in,is ,  htkm  $
, ut0   $
, elden  $
;, time_loop, time_loop_max  $
;, iToolID  $
;, run_id  $
;20120625 ,npts,nlp, bcol     ;010505: 
,npts,nlp, mlat_deg   $  ;010505: 
,tr_save, x_dsp0,y_dsp0 


d_x=5.  ;deg
d_y=20. ;20. ;km

;d_lat=45.
glat_max=+45.;140. ;90.+d_lat +10. ;-10.
glat_min=-glat_max; 60.  ;90.-d_lat +10. ;-10.
ht_min=100.  ;km  140.
ht_max=2500.;km  2500.;800.;



;nnloop=time_loop
;nnread1=time_loop_max




x0=fltarr(npts*nlp)
y0=fltarr(npts*nlp)
w0=fltarr(npts*nlp)  ;electron density
w01=fltarr(npts*nlp)  ;glat
w02=fltarr(npts*nlp)  ;glon


n_size=-1L
;mpx=0L ;11L  ;for mpx=0,NMP-1  do begin
;20120625 LT_tmp=ut0 +(glon(100,mpx,46)/15.)
;20120625 if ( lt_tmp ge 24. ) then   lt_tmp=lt_tmp  MOD 24.
;20120625 print, mpx,"  check glon 300km", glon(100,mpx,46), " LT",lt_tmp 

;; check x,y, grids
;iPLOT, glat(0:npts-1,mpx,0:nlp-1), htkm(0:npts-1,mpx,0:nlp-1)  $
;,/scatter ,TITLE='check  XY grid Points'

for lp=         0,nlp-1  do begin
  for  i=in(lp)-1,is(lp)-1  do begin


;20120625 mlat=90. -bcol(i,mpx,lp)/!DTOR ;[deg]
mlat=mlat_deg[i]/!DTOR ;[deg]

;010905:    if ( glat(i,mpx,lp) ge (glat_min-d_x) ) and ( glat(i,mpx,lp) le (glat_max+d_x) ) then begin
    if ( mlat           ge (glat_min-5.) ) and ( mlat           le (glat_max+5.) ) then begin
    if ( htkm(i) ge   (ht_min-100.) ) and ( htkm(i) le   (ht_max+500.) ) then begin

n_size=n_size+1
x0(n_size)=mlat  ;glat(i,mpx,lp)  ;010905:
y0(n_size)=htkm(i) 
w0(n_size)=elden[0,i]   ;electron density [m-3]
  if ( w0(n_size) gt 0. ) then w0(n_size)=ALOG10(w0(n_size))  $
                          else w0(n_size)=0.0001
w01(n_size)=elden[1,i]   ;glat deg
w02(n_size)=elden[2,i]   ;glon deg
 
    endif
    endif
  endfor ;i=in(lp),is(lp)
endfor    ;lp=         0,nlp-1  do begin

;endfor ;mpx=0,NMP-1  do begin

print, "n_size", n_size
print, 'check x0', min(x0),max(x0)
print, 'check y0', min(y0),max(y0)
print, 'check w0', min(w0),max(w0)
print, 'check w01', min(w01),max(w01)
print, 'check w02', min(w02),max(w02)

x1=fltarr(n_size+1)
y1=fltarr(n_size+1)
w1=fltarr(n_size+1)
w11=fltarr(n_size+1)
w12=fltarr(n_size+1)
x1(0:n_size)=x0(0:n_size)
y1(0:n_size)=y0(0:n_size)
w1(0:n_size)=w0(0:n_size)
w11(0:n_size)=w01(0:n_size)
w12(0:n_size)=w02(0:n_size)
print, 'check w1', min(w1),max(w1)
print, 'check w11', min(w11),max(w11)
print, 'check w12', min(w12),max(w12)

;n_plot0=1+3; 12+6
;if ( nread eq  n_plot0  ) then $
;; check x,y,Z
;010905: iPLOT, x1,y1,w1  $
;010905: ,/scatter ,TITLE='check  XYZ Points: Ne[log/m3]' 


;010905: added
;010905: icontour, w1, x1,y1 $
;010905:, title='check  Ne  LT'+string(fix(LT_tmp)) $
;010905:, N_LEVELS=60

;010905:goto, jump0  ;010905:


; triangulate prosedure
TRIANGULATE,X1,Y1,Tr 
help, Tr

;d_x=5.
;d_y=20.
trigrid_result=trigrid(x1,y1,w1,tr  $
, [d_x,d_y], [glat_min,ht_min,glat_max,ht_max] $
;, NX=12, NY=24  $
)
size_result=size(trigrid_result)
print, 'check trigrid_result', size_result , min(trigrid_result),max(trigrid_result)

nx=size_result(1)
ny=size_result(2)
print,'nx',nx,'ny',ny
tr_save[0,0:nx-1,0:ny-1]=trigrid_result[0:nx-1,0:ny-1]

;20130602 commented out why tr_save[1-2] are needed??
;trigrid_result=trigrid(x1,y1,w11,tr  $
;, [d_x,d_y], [glat_min,ht_min,glat_max,ht_max] $
;;, NX=12, NY=24  $
;)
;tr_save[1,0:nx-1,0:ny-1]=trigrid_result[0:nx-1,0:ny-1]
;
;trigrid_result=trigrid(x1,y1,w12,tr  $
;, [d_x,d_y], [glat_min,ht_min,glat_max,ht_max] $
;, NX=12, NY=24  $
;)
;tr_save[2,0:nx-1,0:ny-1]=trigrid_result[0:nx-1,0:ny-1]


x_dsp=fltarr(nx,ny)
y_dsp=fltarr(nx,ny)
for ix=0,nx-1  do  x_dsp(ix,0:ny-1)=fix(ix)*d_x + glat_min
for iy=0,ny-1  do  y_dsp(0:nx-1,iy)=fix(iy)*d_y +   ht_min

;010905:iSurface, trigrid_result, x_dsp,y_dsp  $
;010905:, TITLE='0:Linear Interpolation (trigrid): ne [log/m3]'


x_dsp0=findgen(nx)*d_x + glat_min
y_dsp0=findgen(ny)*d_y +   ht_min
;if ( (nnloop MOD 240) eq 0 ) then $  ;092804: debug
sw_icontour=0
if ( sw_icontour eq 1 ) then $
iContour, trigrid_result, x_dsp0,y_dsp0  $ 
;20120625 , TITLE='Linear Interpolation(trigrid):Ne[log/cm3]  LT'+string(fix(LT_tmp))  $
, N_LEVELS=100
;, min=1.88586      max=6.29121  :sw1
;, min=1.01164      max=6.31277  :sw2wts

;010905: another contour plot added
;contour, zz, mlt,mlat $
;,/fill $
;, levels=findgen(n_levels)*(value_max-value_min)/float(n_levels-1) +value_min $
;, xrange=[X_min,X_max], /xstyle  $
;, yrange=[Y_min,Y_max], /ystyle  $
;,XTITLE = 'MLT [hrs]', YTITLE = 'MLAT [deg]' $ 
;,TITLE = var_title(iplot) $
;, POSITION=[X0 , Y0 , X1 , Y1 ] $
;,/NOERASE

sw_ctr_fxht=1
if ( sw_ctr_fxht eq 1 ) then begin
x_min=MIN(x_dsp0)
x_max=MAX(x_dsp0)
y_min=MIN(y_dsp0)
y_max=MAX(y_dsp0)
zmin=MIN(trigrid_result)
zmax=MAX(trigrid_result)
print,'zmin',zmin,' zmax',zmax
n_lvls=100
loadct,39
contour,trigrid_result, x_dsp0,y_dsp0 $
,/fill $
,levels=indgen(n_lvls)*(zmax-zmin)/float(n_lvls-1) +zmin $
,xrange=[X_min,X_max], /xstyle $
,yrange=[Y_min,Y_max], /ystyle 
endif ;( sw_ctr_fxht eq 1 ) then begin

;010905:jump0:  ;010905:
STOP
end ;PRO interpolate_ctip
