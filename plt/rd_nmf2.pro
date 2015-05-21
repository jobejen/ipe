pro rd_nmf2
which_hemi='NH'
;nmax=97L
nmax=25L

x=fltarr(nmax)
y1=fltarr(nmax)
y2=fltarr(nmax)


luntmp=100L

;for j = 0,1 do begin
for j = 0,0 do begin
if j eq 0 then $
;  rundir='ipe_80_24695' $
  rundir='ipe_80_21994' $ ;corrrected new wind direction
else if j eq 1 then $
  rundir='ipe_80_21994' ;corrrected new wind direction

flnmtmp='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r319/trunk/run/'+rundir+'/nmf2'+which_hemi+'.dat'
openr,luntmp,flnmtmp, /GET_LUN
               ;UT_hr, plot_zz[mp,lps], Z_km[Max_Subscript], glat_deg[Max_Subscript,mp], glon_deg[Max_Subscript,mp], ltime

i=-1L
while ( eof(luntmp) eq 0 ) do begin
readf, luntmp, v0,v1,v2,v3,v4,v5
i=i+1
print, i, v0,v1,v2,v3,v4,v5
ut00=120.
x[ i]=v0 - ut00

if j eq 0 then $
;  y1[i]=v1 * (1.0E-6) *(1.0E-5) $;m-3 -->cm-3
  y1[i]=v2 $
else if j eq 1 then $
;  y2[i]=v1 * (1.0E-6) *(1.0E-5) ;m-3 -->cm-3
  y2[i]=v2

endwhile
free_lun,luntmp


if j eq 0 then $
  plot = PLOT (X,Y1, $
;title="NmF2 X 10-5 (cm-3)") $
title=which_hemi+": hmF2 (km)"+rundir) $
else if j eq 1 then $
  plot = PLOT (X,Y2, OVERPLOT=1,LINESTYLE=2)
;  plot = PLOT (X,Y2, LINESTYLE=2, title=rundir)


; Set some properties
plot.SYM_INCREMENT = 10
plot.SYM_COLOR = "blue"
plot.SYM_FILLED = 1
plot.SYM_FILL_COLOR = 0

endfor ;j = 0,1 do begin

end ;rd_nmf2
