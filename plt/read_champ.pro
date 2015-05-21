;20140808: champ: copied from read_hinotori
;20131219: hinoroti: ncount is obtained from previously running plt_ipe.pro
pro read_champ
fac_window=1.0
sw_outputpng=0
sw_plot_ti=0
sw_debug=1
chr_title='F107=130'
chr_title2='410.km'
;chr_title3='.vpara';.ori'
ltimemin=0.;11.
ltimemax=24.;15.
mlatmax=60.;45.
nmax=737199L
luntmp=100
flnmtmp='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/champ/champ_te'+chr_title2+'.'+chr_title+'.dat';+chr_title3
openr,luntmp,flnmtmp, /GET_LUN
ncount=nmax ;58246L
var=fltarr(7,ncount)

;plot array
imax=24+1L
dlat=5.
dlt=1.
y_max=+60.
y_min=-y_max

x_max=+24.
x_min=0.

jmax=FIX( (y_max-y_min)/dlat ) +1
print,' imax', imax,'jmax',jmax
xary=findgen(imax)*dlt + 0.0
print,'xarray',xary
yary=findgen(jmax)*dlat +y_min
print,'yarray',yary
zary=fltarr(imax,jmax)

i=-1L
while ( eof(luntmp) eq 0 ) do begin
;readf, luntmp, ut_hr0, ne_m0, te_k0, ti_k0,mlat0, glon0, ltime0
readf, luntmp,    var0,  var1,  var2, var3, var4,  var5,  var6
if ( var6 ge 24. ) then  var6 = ( var6 MOD 24. )  
if ( var4 le mlatmax ) AND ( var6 ge ltimemin) AND ( var6 le ltimemax ) then begin
i=i+1L
;if ( sw_debug eq 1 ) then print, 'i=', i
if ( sw_debug eq 1 ) then print, i,'ut_hr',var0,  var1,  var2, var3, var4,  var5,  var6
var[0,i]=var0
var[1,i]=var1
var[2,i]=var2
var[3,i]=var3
var[4,i]=var4
var[5,i]=var5
var[6,i]=var6

; longitudinal average:
jj =FIX ( (var4-y_min)/dlat )
ii =FIX ( (var6-x_min)/dlt  )
print,'ii',ii,'jj',jj
zary[ii,jj] = var2

endif ;( var4 le mlatmax ) then begin

if i ge nmax then begin
  print,'i=', i,'nmax=', nmax
;STOP
  BREAK  ;exit from while loop
endif

endwhile
nmax=i






;plot champ contour
Filename_png='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/champ/champ.'+chr_title+'.'+chr_title2+'.png'
iwindow=1L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,iwindow,XSIZE=500*fac_window,YSIZE=500*fac_window
n_ldct=5L
loadct,n_ldct


colmin=0.
colmax=255.

n_levels=100
zmax=3000.
zmin=0.

xary2=zary
for jj=0,jmax-1 do xary2[*,jj] =xary[*] 

yary2=zary
for ii=0,imax-1 do yary2[ii,*] =yary[*] 

contour, xary2,yary2,zary $
,/fill $
,levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
,xrange=[X_min,X_max], /xstyle $
,yrange=[Y_min,Y_max], /ystyle ;$
;,XTITLE=X_TITLE,YTITLE=Y_TITLE $
;,TITLE=VarTitle[VarType]+unit[VarType]+'  ht='+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'km  UT[hr]='+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+'_'+TEST $
;,TITLE='UT '+STRTRIM( string(ut_hr_disp, FORMAT='(F6.2)'),1 ) $
;,POSITION=[X0,Y0,X1,Y1] $
;,COLOR=text_color $
;,charsize=char_size,charthick=char_thick $
;,MAX_VALUE= MAX_xymin

if ( sw_outputpng eq 1 ) then $
  output_png, Filename_png

print,'pro read_champ finished!'
end;pro read_champ
