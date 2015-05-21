;20140225: separated out from plt_efv2.pro
;purpose: plot ExB time variation
;if ( sw_plot_exb eq 1 ) and ( utime eq utime_max ) then begin

pro plt_drft $
,mp,lp,NMP,NLP, input_DIR,sw_debug,n_read, utsec_save,ed190_save, title_exb,plot_DIR,utime,runDATE,mlat90_2d,sw_output2file,utime_min

;VEXB(mp,lp)
print,' n_read', n_read
n_max =n_read;105-9+1L;5L;138-124+1L;4*24+1L;12*24+1L  ###CHANGE!
plot_VEXB_ut = fltarr(n_max)
plot_VEXB    = fltarr(n_max,3); 0:upward; 1:eastward
n_max1=0L

;  read_EXB $  ;20120306
  rd_EXB $
, plot_VEXB_ut, plot_VEXB,mp,lp,NMP,NLP, input_DIR,sw_debug, mlat90_2d $
,n_max1
;20120601
;  rd_EXB3D $
;, plot_VEXB_ut, plot_VEXB,mp,lp,NMP,NLP, input_DIR,sw_debug,n_max1

if ( sw_debug eq 1 ) then begin 
  for i=0,n_read do print,i,(utsec_save[i]/3600.),ed190_save[i]
endif
;I must double chekc the Bmag90 value!!!
if ( lp eq 66-1 ) then begin ;jicamarca ;2xdyn
;if ( lp eq 130-1 ) then begin ;jicamarca ;new201207
;if ( lp eq 34-1 ) then begin ;jicamarca ;dyn grid
  if ( mp eq 0L ) then begin
    Bmag90=2.5574958e-05 ;[tesla] at h_ref=90km for lp=129 mlat=-9.05
    glon=288.2
  endif else if ( mp eq 4-1L ) then begin
    Bmag90=2.739e-05 ;
    glon=299.8955
  endif else if ( mp eq 8-1L ) then begin
    Bmag90=2.923e-05 ;
    glon=316.5370
  endif else if ( mp eq 19-1L ) then begin
    Bmag90=3.242e-05 ;[tesla] at h_ref=90km for lp=129 mlat=-9.05
    glon=7.1758
  endif else if ( mp eq 19L ) then begin
    Bmag90=3.281e-05 ;[tesla] at h_ref=90km for lp=129 mlat=-9.05
    glon=11.27843 
  endif else if ( mp eq 59L ) then begin
    Bmag90=3.158e-05 ;[tesla] at h_ref=90km for lp=129 mlat=-9.05
    glon=194.2077 
 endif

endif else if ( lp eq 45 ) then begin ;arecibo
  Bmag90=3.4480501e-05 ;[tesla] at h_ref=90km for lp=46 mlat=-30
  glon=286.1
endif else if ( lp eq 39 ) then begin ;st santin
;  Bmag90=3.9341376e-05   ;mp=0
;  glon=284.3881
  Bmag90=4.056e-05   ;mp=17
  glon=365.74725
endif else if ( lp eq 28 ) then begin ;MSH
  Bmag90=4.8025999e-05 
  glon=279.174
endif
print,'bmag90',bmag90,'glon',glon

nmax=n_read*2+2
exb =fltarr(nmax)
exb[0       :n_read    ] = ed190_save[0:n_read] * 1.0E-03 / Bmag90
exb[n_read+1:n_read*2+1] = ed190_save[0:n_read] * 1.0E-03 / Bmag90
slt =fltarr(nmax) 
slt00=432000./3600. +24.;utime_min/3600. ;dbg20141111  ###CHANGE!!!
slt[0       :n_read    ] = utsec_save[0:n_read]/3600. +glon/15. -slt00
slt[n_read+1:n_read*2+1] = utsec_save[0:n_read]/3600. +glon/15. -slt00
;debug
if ( sw_debug eq 1 ) then  print,'check SLT',MIN(slt),MAX(slt)

;tmp20130603
iwindow=1L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,iwindow,XSIZE=800,YSIZE=800
!p.multi=[0,1,1,0]
n_ldct=39  ;rainbow+black

plot,slt[0:n_read*2+1],exb[0:n_read*2+1] $
, yrange=[-100. , +100. ],  ystyle=1  $
;, yrange=[-25. , +55. ],  ystyle=1  $
;, yrange=[-0. , +20. ],  ystyle=1  $
;, xrange=[ MIN(slt), MAX(slt) ],  xstyle=1  $
;, xrange=[ 19.2133, 43.2133 ],  xstyle=1  $
;, xrange=[ 19.2, 19.2133+24.*1. ],  xstyle=1  $
, xrange=[ 7., 19. ],  xstyle=1  $
;, xrange=[ 19.2133, 19.2133+1. ],  xstyle=1  $
,XTITLE = 'LT[hr] '+title_exb, YTITLE = 'VEXB[m/s]' $
, charsize =2.5, charthick=2.5 $
;, TITLE=title_exb $
, thick=2.0 $
,/NODATA

loadct,n_ldct
;;oplot,slt[0:n_read*2+1],exb[0:n_read*2+1] $
;oplot,slt[0:n_read],exb[0:n_read] $
; , linestyle=0, thick=2.0, color=50. ;blue

nmax=n_max1*2+2
exb =fltarr(nmax)
jth=0 ;upward EXB
exb[0     :n_max1    ] = plot_VEXB[0:n_max1,jth]
exb[n_max1+1:n_max1*2+1] = plot_VEXB[0:n_max1,jth]
slt =fltarr(nmax)
slt[0       :n_max1    ] = plot_VEXB_ut[0:n_max1]/3600. +glon/15. -slt00
slt[n_max1+1:n_max1*2+1] = plot_VEXB_ut[0:n_max1]/3600. +glon/15. -slt00
;debug
if ( sw_debug eq 1 ) then  print,'2check SLT',MIN(slt),MAX(slt)

;dbg20130531!
;why n_max1*2???
;lt is going through for 24hr diurnal variations twice why??? both
;variations look identical sofar...
for i=0,n_max1*2+1 do begin
print,  i,slt[i],exb[i]
;print,  i,slt[i],exb[i]
endfor
;STOP

;oplot,slt[0:n_max1*2+1],exb[0:n_max1*2+1] $
oplot,slt[0:n_max1],exb[0:n_max1] $
;  , linestyle=5, thick=2.0, color=250. ;red
  , linestyle=0, thick=2.0, color=250. ;red

jth=1; 20140225zonal drift
exb[0     :n_max1      ] = plot_VEXB[0:n_max1,jth]
exb[n_max1+1:n_max1*2+1] = plot_VEXB[0:n_max1,jth]
;oplot,slt[0:n_max1*2+1], exb[0:n_max1*2+1] $
;  , linestyle=3, thick=2.0, color=165. ;
;jth=2 
;exb[0     :n_max1      ] = plot_VEXB[0:n_max1,jth]
;exb[n_max1+1:n_max1*2+1] = plot_VEXB[0:n_max1,jth]
;oplot,slt[0:n_max1*2+1],exb[0:n_max1*2+1] $
;  , linestyle=4, thick=2.0, color=199. ;




;20130822 compare with larisa's drift
sw_compare_with_obs=0L
if ( sw_compare_with_obs eq 1 ) then  begin

openr, LUN11, 'vdriftFSJan252009.txt', /GET_LUN
string=''
for i=0,6 do begin
  readf, lun11, string
  print, i,string
endfor
nmax2=49L
slt1  =fltarr(nmax2*2)
drift1=fltarr(nmax2*2)
for i=0, nmax2-1 do begin
  readf, lun11, slt2,drift2
  print, i, slt2,drift2
  slt1[i]    = slt2
  drift1[i]  = drift2

;2nd round
  slt1[i+nmax2]   = slt2 + 24.
  drift1[i+nmax2] = drift2
endfor
free_lun,lun11

for i=0,nmax2*2-1 do begin
print,i,slt1[i],drift1[i]
endfor

oplot,slt1,drift1 $
  , linestyle=0, thick=2.0, color=150. ;???
endif ;( sw_compare_with_obs eq 1 ) then 

;reference
loadct,0
oplot,slt[0:n_max1*2+1],exb[0:n_max1*2+1] *0.0 $
  , linestyle=1, thick=1.0

filename=plot_DIR+'ts_efield.'+'UTsec'+STRTRIM( string(utime, FORMAT='(i6)'),1 )+runDATE+'NH'+STRTRIM( string(mlat90_2d[mp,lp], FORMAT='(F6.2)'),1 )+'mp'+STRTRIM( string(mp, FORMAT='(i2)'),1 )+'.exb.png'

if ( sw_output2file eq 1 ) THEN  output_png, filename

end ;pro plt_drft
;endif ;if ( sw_plot_exb eq 1 ) and ( utime eq utime_max ) then begin???
