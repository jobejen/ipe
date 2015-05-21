;20131219: hinoroti: ncount is obtained from previously running plt_ipe.pro
pro read_hinotori
fac_window=1.0
sw_outputpng=1
sw_plot_ti=0
sw_debug=1
chr_title='F107=200'
chr_title2='800km'
;chr_title3='.vpara';.ori'
glonx=250.
dlon=7.
glonmin=0.;glonx-dlon
glonmax=360.;glonx+dlon
ltimemin=11.
ltimemax=15.
mlatmax=45.
imax=100000L
luntmp=100
flnmtmp='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/hinotori/hinotori_te'+chr_title2+'.'+chr_title+'.dat';+chr_title3
openr,luntmp,flnmtmp, /GET_LUN
ncount=imax ;58246L
var=fltarr(7,ncount)
i=-1L
while ( eof(luntmp) eq 0 ) do begin
;readf, luntmp, ut_hr0, ne_m0, te_k0, ti_k0,mlat0, glon0, ltime0
readf, luntmp,    var0,  var1,  var2, var3, var4,  var5,  var6
if ( var6 ge 24. ) then  var6 = ( var6 MOD 24. )  
if ( var4 le mlatmax ) AND ( var6 ge ltimemin) AND ( var6 le ltimemax ) then begin
i=i+1L
;if ( sw_debug eq 1 ) then print, 'i=', i
if ( sw_debug eq 1 ) then print, 'ut_hr',var0,  var1,  var2, var3, var4,  var5,  var6
var[0,i]=var0
var[1,i]=var1
var[2,i]=var2
var[3,i]=var3
var[4,i]=var4
var[5,i]=var5
var[6,i]=var6
endif ;( var4 le mlatmax ) then begin

if i ge imax then begin
  print,'i=', i,'imax=', imax
;STOP
  BREAK  ;exit from while loop
endif

endwhile
imax=i
;plot ushape
Filename_png='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/hinotori/hinotori_ushape.'+chr_title+'.'+chr_title2+'.png'
iwindow=1L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,iwindow,XSIZE=500*fac_window,YSIZE=500*fac_window
n_ldct=40L
;loadct,n_ldct

x_min=4.8
x_max=6.65
y_min=1000.
y_max=5000.
log10ne=fltarr(imax+1)
;ploty=fltarr(imax+1)
color_mlat=fltarr(imax+1)
colmin=0.
colmax=255.
for i=0,imax do begin

  if ( var[5,i] ge glonmin ) AND ( var[5,i] lt glonmax ) THEN  begin
    log10ne[i]=ALOG10(var[1,i]*1.0E-6)
    color_mlat[i]=colmin +  (ABS(var[4,i])-0.) * (colmax-colmin) / (45. - 0.) 
    if ( sw_debug eq 1 ) then print,i, var[4,i],color_mlat[i]
  endif
;  ploty[i]=var[2,i]
endfor ;i


;TODO: create fitting curves
;jmax=10L
;denmin = 
;dden =
;denav=findgen(jmax)*dmlat + 0.0
;print, mlatav
;for i=0,imax do begin
;  for j=0,jmax-1 do begin
;    if (ABS(var[4,i]) ge mlatav[j] ) AND (ABS(var[4,i]) lt mlatav[j+1] ) then begin 
;    endif
;endfor

;1)plot only axis 
loadct,0
plot,  log10ne[*],var[2,*], /NoData $
;dbg20140103;plot,  var[5,*],var[2,*], /NoData $  
, xrange=[ X_MIN, X_MAX ], xstyle=1  $
, yrange=[ Y_MIN, Y_MAX ], ystyle=1  $
, color=colormax $
,  title=chr_title+'  ALT='+chr_title2;+chr_title3 ;$
;2)plot only data points
loadct,n_ldct
for i=0,imax DO plots,  $
log10ne[i],var[2,i] $
;dbg20140103; var[5,i],var[2,i] $  
, color=color_mlat[i] $
, PSYM=7,SYMSIZE=1

;20131226 plot Ti
if ( sw_plot_ti eq 1 ) then $
  for i=0,imax DO plots, $
 log10ne[i],var[3,i] $
;dbg20140103;var[5,i],var[3,i] $ 
  , color=color_mlat[i] $
  , PSYM=3,SYMSIZE=1

if ( sw_outputpng eq 1 ) then $
  output_png, Filename_png
end;pro read_hinotori
