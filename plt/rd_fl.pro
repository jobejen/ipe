pro rd_fl, nmp,nlp1,lmfl,sw_debug  ;read_flux

;nmp=80L
;nlp1=40L
;lmfl=fltarr(nmp,nlp1)

lun9009=0L
  input_flnm='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r336.2/trunk/run/ipe_S_22744'
  openr, lun9009, input_flnm+'/fort.9009', /GET_LUN 

format9009="(2i3,9E9.2)"
  mp0=0L
  lp0=0L
  
  z=0.0
  on=0.0
  hn=0.0
  tnx=0.0
  ti=0.0
  te=0.0
  nop=0.0
  nhp=0.0
  sch=0.0

for mp=0,nmp-1 do begin
  for lp=0,nlp1-1 do begin

     readf, lun9009, mp0,lp0, z,on,hn $
       ,tnx ,ti,te,nop,nhp $
       ,sch, FORMAT=format9009

     if sw_debug eq 1 then print, mp0,lp0, z,on,hn $
       ,tnx ,ti,te,nop,nhp $
       ,sch

 ; z_sv[mp,lp]=z  
 ;, (1.38E-16 * ( ti(1,j802)+ti(3,j802) )*0.5 / $
 ; (1.662E-24*16*(-1.)*GR(j802) ) )*1.E-5 !scale height[cm-->km]

;calculate limiting flux
fac_fl=1.E-8
     lmfl[mp,lp] = 2.5E-11 * tnx^0.5 * hn * nop * sch*1.E+5 *fac_fl ;scale ht[km-->cm]
if sw_debug eq 1 then     print, 'limiting fl=',lmfl[mp,lp]  ;flux= X.XX * 10^8 cm^2 s^-1
     
  endfor ;lp=0,40-1 do begin
endfor; mp=0,nmp-1 do begin
print,'MAX=', MAX(lmfl),' MIN=', MIN(lmfl)

free_lun, lun9009
print, "read_flux finished successfully!"
end                             ;pro read_flux
