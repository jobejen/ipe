;20120601: validate the new way of cal exb drift

  pro rd_EXB3D $
, plot_VEXB_ut, plot_VEXB,mp,lp,NMP,NLP, input_DIR,sw_debug,n_max1

size_results=SIZE(plot_VEXB_ut)
n_max=size_results[1]

NPTS2D=44438L
VEXB3D=fltarr(2,NPTS2D,NMP)
openr, LUN14, input_DIR+'ut_rec', /GET_LUN 
openr, LUN16, input_DIR+'plasma17', /GET_LUN $
, /F77_UNFORMATTED ;$

n=-1L
;while(eof(LUN14) eq 0 ) do begin
while( n lt n_max-1 ) do begin
n=n+1L
 readf, LUN14, record_number, UT_sec
print,n,'rec#',record_number,' UThr',(UT_sec /3600.)
plot_VEXB_ut[n] = UT_sec

     readu, LUN16, VEXB3D
in_lp=42298-1
is_lp=42382-1
midpoint = IN_lp + ( IS_lp - IN_lp )/2 -1L
if sw_debug eq 1 then  print, 'VEXB3D_ms1=',VEXB3D[2-1,midpoint,mp],mp,lp,midpoint,in_lp,is_lp
;for j=2,2 do begin
;jth=lp + 10*j
j=2L
if ( n eq 0 ) then  print ,j,'VEXB3D: midpoint=',midpoint
plot_VEXB[n,j]=VEXB3D[2-1,midpoint,mp]
;endfor ;j
endwhile;(eof(LUN14) eq 0 ) do begin

n_max1=n

FREE_LUN, LUN14
FREE_LUN, LUN16
end;  pro rd_EXB3D, plot_VEXB_ut, plot_VEXB
