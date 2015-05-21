;pro plot_efield ;shorter name
pro plt_ef
utime_min=605100;121500;141206L
utime_max=615600;;135900;utime_min+86400;83606 ;230306L ;314006L ;to plot ExB time variation on the 6th panel 
freq_plot_sec=300.;(utime_max-utime_min);900 ;3600L*6
sw_debug=0L
sw_plot_exb=0L ;1
if sw_plot_exb eq 0 then iplot_max=5 else $
if sw_plot_exb eq 1 then iplot_max=4
;HOMEDIR='/lfs0/projects/idea/maruyama/sandbox/ipe/'
HOMEDIR='/home/Naomi.Maruyama/'
;runDIR=HOMEDIR+'iper/'
runDIR=HOMEDIR+'wamns/'
figDIR=HOMEDIR+'iper/'
TEST0='3d'
TEST1='trans'
TEST2='v73.0'
runDATE='20120509'
plot_DIR=$
figDIR+'fig/'+TEST2+'/'
;runDIR+'fig/efield/'+TEST2+'/'

SW_range=1L
plot_NH=1L
  var_title=['pot130[kV]','ed1130[mV/m]','ed2130[mV/m]','pot130-mlat90[kV]','ed190[mV/m]','ed290/sini'] 
if( SW_range eq 1 ) then  begin
;  value_min_fix=[  -30.,     -20.,    -25. ,-30.,-20.]
;  value_max_fix=[  +30.,     +20.,    +25. ,+30.,+20.]
  if (plot_NH eq 1) then begin
    value_min_fix=[  -8.,     -2.,    -5. ,-8.,-2.,-5.]
    value_max_fix=[  +8.,     +2.,    +5. ,+8.,+2.,+5.]
  endif
endif

utime=0L
freq_output=300/60 ;min
n_read_max=143-108+1;(60/freq_output)*24 +1
utsec_save=fltarr(n_read_max)
utsec_save[*]=-9999L


nmlon=180L
nmlat=90L
poten=fltarr(nmlon+1,nmlat+1)
ed1130=fltarr(nmlon+1,nmlat+1)
ed2130=fltarr(nmlon+1,nmlat+1)
ylatm=fltarr(nmlat+1)
mlat130=fltarr(nmlat+1)
mlon130=fltarr(nmlon+1)
mlat90_0=fltarr(nmlat+1)
nmp=80L
nlp=170L
mlat90_1=fltarr(nlp*2)
ed190=fltarr(nmp,nlp*2)
ed190_save=fltarr(n_read_max)

ed290=fltarr(nmp,nlp*2)
ed290_save=fltarr(n_read_max)

mlon90_2d=fltarr(nmp,nlp*2)
mlat90_2d=fltarr(nmp,nlp*2)
formatE='(20E12.4)'
formatF='(20f10.4)'
formatF1='(i4,f10.4)'
formatI='(i12)'

input_DIR=$
runDIR+TEST2+'/bkup93/'
;runDIR+runDATE+'.'+TEST0+'.'+TEST1+'.'+TEST2+'/But'+STRTRIM( string(utime_max, FORMAT='(i7)'),1 )+'error/'
;input_DIR=runDIR+runDATE+'.'+TEST0+'.'+TEST1+'.'+TEST2+'/backup20111108/'
openr, LUN10, input_DIR+'fort.2010', /GET_LUN
;openr, LUN10, input_DIR+'fort.2009', /GET_LUN ;20120125utime
openr, LUN0, input_DIR+'fort.2000', /GET_LUN
openr, LUN1, input_DIR+'fort.2001', /GET_LUN
openr, LUN2, input_DIR+'fort.2002', /GET_LUN
openr, LUN3, input_DIR+'fort.2003', /GET_LUN
readf, LUN3, ylatm,  FORMAT=formatF
mlat130=ylatm-90.
openr, LUN4, input_DIR+'fort.2004', /GET_LUN
readf, LUN4, mlon130,  FORMAT=formatF
openr, LUN7, input_DIR+'fort.2007', /GET_LUN
readf, LUN7, mlat90_0,  FORMAT=formatF
openr, LUN8, input_DIR+'fort.2008', /GET_LUN
openr, LUN9, input_DIR+'fort.2009', /GET_LUN
openr, LUN6, input_DIR+'fort.2006', /GET_LUN
string='GL'
readf, LUN6 , string
print, string
for i=1,nlp do begin
readf, LUN6, ii,lat,  FORMAT=formatF1
mlat90_1(ii-1)=lat ;NH
readf, LUN6, ii,lat,  FORMAT=formatF1
mlat90_1(ii-1)=lat ;SH
endfor
print,'mlat90_1',mlat90_1
dlonm90km=4.50 ;deg
mlon90=findgen(nmp)*dlonm90km
print,'mlon90',mlon90
for i=0,nlp*2-1 do begin
mlon90_2d[0:nmp-1,i]=mlon90[0:nmp-1]
endfor
for j=0,nmp-1 do begin
mlat90_2d[j,0:nlp*2-1]=mlat90_1[0:nlp*2-1]
endfor

n_read=-1L
while(eof(LUN10) eq 0 ) do begin
n_read=n_read+1
readf, LUN10, utime,  FORMAT=formatI
utsec_save[n_read]=utime
print,'rd#',n_read,' uts',utime ;,' uts_save',utsec_save[n_read]

readf, LUN0, poten,  FORMAT=formatE
readf, LUN1, ed1130,  FORMAT=formatE
readf, LUN2, ed2130,  FORMAT=formatE
readf, LUN8, ed190,  FORMAT=formatE
;20120125: readf, LUN9, ed290,  FORMAT=formatE
mp=10-1L
;mp=0L
;mp=17L ;st santin
;mp=4-1L
;mp=8-1L
;mp=60-1L
lp=129L  ;-9.05[deg] mp=0;jicamarca: ht=254.107km
;lp=45L  ;-31.43605[deg];mp=0  Arecibo:31; ht=2504.20km
;lp=28L  ;-56.78335[deg];mp=0 MSH:57; ht=15159.6km
;lp=39L  ;-40.4614[deg]; st santin:40; ht=4790.30km
;lp=46L  ;-29[deg]

ed190_save[n_read]=ed190[mp,lp]
ed290_save[n_read]=ed290[mp,lp]
if ( n_read eq 0 ) then  print,'mp=',mp,' lp=',lp,' mlat90=',mlat90_2d[mp,lp]
title_exb='lat='+STRTRIM( string(mlat90_2d[mp,lp], FORMAT='(F6.2)'),1 )+' mp='+STRTRIM( string((mp+1), FORMAT='(i2)'),1 ) ;IDL convention


;if $
;( utime gt utsec_save[0]) and $
;( ( (utime-utsec_save[0]) MOD freq_plot_sec ) LT 0.00001 ) then begin
iwindow=0L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,iwindow,XSIZE=900,YSIZE=650
!p.multi=[0,3,2,0]
n_ldct=39  ;rainbow+black
loadct,n_ldct
text_color=160  ;within rainbow+black color table
char_size =2.0
char_thick=1.5
;choose color
 col_max = 255.9999999999999999
 col_min =   0.0000000000000
n_levels=100L

X_min=MIN(mlon130)
X_max=MAX(mlon130)
Y_max=MAX(mlat130)
Y_min=-Y_max;MIN(mlat130)
if ( plot_NH eq 1 ) then begin
  Y_max=+60.
  Y_min=+0.
endif


charsize_colorbar=3.4
format_colorbar='(f6.2)'
for iplot=0,iplot_max do begin
if ( iplot eq 0 ) then begin
 zz=poten*1.0E-3   ;V-->kV
endif else if ( iplot eq 1 ) then begin
 zz=ed1130
endif else if ( iplot eq 2 ) then begin
 zz=ed2130
endif else if ( iplot eq 3 ) then begin
 zz=poten*1.0E-3   ;V-->kV
endif else if ( iplot eq 4 ) then begin
 zz=ed190 ;mV/m
endif else if ( iplot eq 5 ) then begin
 zz=ed290 ;mV/m
endif

zmax=MAX(zz)
zmin=MIN(zz)
if ( sw_debug eq 1 ) then  $
  print,' maxZ=',zmax,' minZ=',zmin

if( SW_range eq 1 ) then  begin
  zmax=value_max_fix[iplot]
  zmin=value_min_fix[iplot]
endif
max_z_data = MAX(zz)
min_z_data = MIN(zz)

get_position $
, iplot, iwindow  $
, X0 , Y0 , X1 , Y1


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
filename=plot_DIR+'ts_efield.'+'UTsec'+STRTRIM( string(utime, FORMAT='(i6)'),1 )+runDATE+TEST2+'NH'+STRTRIM( string(mlat90_2d[mp,lp], FORMAT='(F6.2)'),1 )+'mp'+STRTRIM( string(mp, FORMAT='(i2)'),1 )+'ed2_sini.png'




;plot ExB time variation
if ( sw_plot_exb eq 1 ) and ( utime eq utime_max ) then begin

;VEXB(mp,lp)
  n_max =16L;12*24+1L
  plot_VEXB_ut = fltarr(n_max)
  plot_VEXB    = fltarr(n_max,3)
n_max1=0L
;  read_EXB $  ;20120306
  rd_EXB $
, plot_VEXB_ut, plot_VEXB,mp,lp,NMP,NLP, input_DIR,sw_debug,n_max1

if ( sw_debug eq 1 ) then begin 
  for i=0,n_read do print,i,(utsec_save[i]/3600.),ed190_save[i]
endif
;I must double chekc the Bmag90 value!!!
if ( lp eq 130-1 ) then begin ;jicamarca
  if ( mp eq 0L ) then begin
    Bmag90=2.5574958e-05 ;[tesla] at h_ref=90km for lp=129 mlat=-9.05
    glon=288.2
  endif else if ( mp eq 4-1L ) then begin
    Bmag90=2.739e-05 ;
    glon=299.8955
  endif else if ( mp eq 8-1L ) then begin
    Bmag90=2.923e-05 ;
    glon=316.5370
  endif else if ( mp eq 10-1L ) then begin
    Bmag90=2.829e-05 ;
    glon=327.2482
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
slt[0       :n_read    ] = utsec_save[0:n_read]/3600. +glon/15. ;-48.
slt[n_read+1:n_read*2+1] = utsec_save[0:n_read]/3600. +glon/15. ;-24.
;debug
if ( sw_debug eq 1 ) then  print,'check SLT',MIN(slt),MAX(slt)

plot,slt[0:n_read*2+1],exb[0:n_read*2+1] $
, yrange=[-50. , +50. ],  ystyle=1  $
, xrange=[ MIN(slt), MAX(slt) ],  xstyle=1  $
,XTITLE = 'LT[hr] '+title_exb, YTITLE = 'Ed1_90XB[m/S]' $
, charsize =2.5, charthick=2.5 $
;, TITLE=title_exb $
, thick=2.0

loadct,n_ldct
oplot,slt[0:n_read*2+1],exb[0:n_read*2+1] $
 , linestyle=0, thick=2.0, color=50. ;blue

nmax=n_max1*2+2
exb =fltarr(nmax)
jth=0
exb[0     :n_max1    ] = plot_VEXB[0:n_max1,jth]
exb[n_max1+1:n_max1*2+1] = plot_VEXB[0:n_max1,jth]
slt =fltarr(nmax)
slt[0       :n_max1    ] = plot_VEXB_ut[0:n_max1]/3600. +glon/15. ;-48.
slt[n_max1+1:n_max1*2+1] = plot_VEXB_ut[0:n_max1]/3600. +glon/15. ;-24.
;debug
if ( sw_debug eq 1 ) then  print,'2check SLT',MIN(slt),MAX(slt)

oplot,slt[0:n_max1*2+1],exb[0:n_max1*2+1] $
  , linestyle=5, thick=2.0, color=250. ;red

jth=1
exb[0     :n_max1      ] = plot_VEXB[0:n_max1,jth]
exb[n_max1+1:n_max1*2+1] = plot_VEXB[0:n_max1,jth]
oplot,slt[0:n_max1*2+1],exb[0:n_max1*2+1] $
  , linestyle=1, thick=2.0, color=200. ;red
jth=2
exb[0     :n_max1      ] = plot_VEXB[0:n_max1,jth]
exb[n_max1+1:n_max1*2+1] = plot_VEXB[0:n_max1,jth]
oplot,slt[0:n_max1*2+1],exb[0:n_max1*2+1] $
  , linestyle=4, thick=2.0, color=150. ;red

;reference
loadct,0
oplot,slt[0:n_max1*2+1],exb[0:n_max1*2+1] *0.0 $
  , linestyle=1, thick=1.0
endif

output_png, filename
;BREAK ;exit from the while loop
;endif ;( ( (utime-utime_save) MOD freq_plot_sec ) LT 0.00001 ) then begin

endwhile ;(eof(LUN10) eqq 0 ) do begin


free_lun,lun10
free_lun,lun0
free_lun,lun1
free_lun,lun2
free_lun,lun3
free_lun,lun4
free_lun,lun6
free_lun,lun7
free_lun,lun8
;20120125: free_lun,lun9
;print,'mlat90='
;for i=0,nlp*2-1 do print,i,mlat90_2d[0,i]

end ;pro plt_ef
