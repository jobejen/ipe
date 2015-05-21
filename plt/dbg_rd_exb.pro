pro dbg_rd_exb
imax=97L
NMP=80L
NLP=170L
input_DIR=$
;'/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r292.5/trunk/run/ipe_80_30167/'
'/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r319/trunk/run/ipe_80_27926/'
;'/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r292.3/trunk/run/ipe_S_15734/'
print, input_DIR+'plasma16'
openr, LUN15, input_DIR+'plasma16', /GET_LUN $
, /F77_UNFORMATTED

;dum1=fltarr(NLP)
dum2=fltarr(NLP,NMP)
for itime=0,imax-1 do begin
;for mp=0,nmp-1 do begin
print,' itime=', (itime+1);,' mp=', (mp+1)
;readu, LUN15, dum1
readu, LUN15, dum2
;print, dum1
;print, dum2
;endfor ;mp
endfor ;itime
print, 'pro dbg_rd_exb finished'
end ;pro dbg_rd_ebx
