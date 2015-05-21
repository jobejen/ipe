;  pro read_EXB $
  pro rd_EXB $
, plot_VEXB_ut, plot_VEXB,mp,lp,mpstop,NLP, input_DIR,sw_debug, mlat90_2d $
,n_max1   ;output

print,'start rd_EXB',nlp,mpstop
;input_DIR='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r336/trunk/run/ipe_S_29795/'
sw_exb_zonal=0L
size_results=SIZE(plot_VEXB_ut)
n_max=size_results[1]
;n_max=1
;NLP=170L
;NMP=80L
;sw_debug=1L

;mpstop=NMP
VEXB =fltarr(NLP,mpstop)
VEXBe=fltarr(NLP,mpstop);zonal drift
openr, LUN14, input_DIR+'ut_rec', /GET_LUN 
openr, LUN15, input_DIR+'plasma16', /GET_LUN $
, /F77_UNFORMATTED
if ( sw_exb_zonal eq 1 ) then $
openr, LUN17, input_DIR+'plasma17', /GET_LUN $
, /F77_UNFORMATTED

record_number=0L
n=-1L
;while(eof(LUN14) eq 0 ) do begin
while( n lt n_max-1 ) do begin
n=n+1L
 readf, LUN14, record_number, UT_sec
print,'rd_exb: n=',n,' rec#',record_number,' UThr',(UT_sec /3600.),' UTs',UT_sec
plot_VEXB_ut[n] = UT_sec


;dum=fltarr(NLP)
;for i=0,mpstop-1 do begin
;print,'mp_read=',i
;   readu, LUN15, dum            ;VEXB upward
   readu, LUN15, VEXB ;upward
;print, dum ;dbg20141111
;STOP
;   VEXB[ 0:NLP-1,i]=dum[0:NLP-1]
   if ( sw_exb_zonal eq 1 ) then begin
      readu, LUN17, VEXBe ;East
;      VEXBe[0:NLP-1,i]=dum[0:NLP-1]
   endif
;endfor
;print, i
;STOP ;dbg20141111
if sw_debug eq 1 then  begin
   print, 'VEXB_ms1: upward',VEXB[lp,mp],mp,lp,' eastward=',VEXBe[lp,mp]
   if ( sw_exb_zonal eq 1 ) then print, 'VEXB_ms1: eastward=',VEXBe[lp,mp]
endif

;20140225
;t if ( sw_exb_zonal eq 1 ) then begin
iwindow=2L
DEVICE, RETAIN=2, DECOMPOSED=0
WINDOW,iwindow,XSIZE=800,YSIZE=800
!p.multi=[0,1,1,0]
loadct, 39
vmax=230. ;500.
vmin=vmax *(-1.)
mpt=0L
;print,mpt,vexbe[0:nlp-1,mpt]

;t plot, mlat90_2d[0,0:nlp-1], vexbe[0:nlp-1,mpt] $
plot, mlat90_2d[0,0:nlp-1], vexb[0:nlp-1,mpt] $
, yrange=[vmin , vmax ],  ystyle=1 $
, xrange=[-90. ,   0. ],  xstyle=1 $
,XTITLE = 'mlat [deg]', $
;t YTITLE = 'VEXBe [m/s]' $
YTITLE = 'VEXBup [m/s]' $
,title='vexb '+STRTRIM( string(UT_sec, FORMAT='(i7)'),1 ) $
, linestyle=0, color=254. ;red
mpt=40L
;print,mpt,vexbe[0:nlp-1,mpt]
;t oplot, mlat90_2d[0,0:nlp-1], vexbe[0:nlp-1,mpt] $
;t , linestyle=5, color=50. ;blue
;mpt=80-1L
mpt=60
;print,mpt,vexbe[0:nlp-1,mpt]
;t oplot, mlat90_2d[0,0:nlp-1], vexbe[0:nlp-1,mpt] $
;t , linestyle=2, color=150. ;green

mpt=20
;print,mpt,vexbe[0:nlp-1,mpt]
;t oplot, mlat90_2d[0,0:nlp-1], vexbe[0:nlp-1,mpt] $
;t , linestyle=4, color=190. ;yellow

;t oplot, mlat90_2d[0,0:nlp-1],vexbe[0:nlp-1,0]*0.0 $
;t , linestyle=1
output_png, 'vexb'+STRTRIM( string(UT_sec, FORMAT='(i7)'),1 )+'.png'
;t endif ;( sw_exb_zonal eq 1 ) then begin

;for j=0,2 do begin
;jth=lp; + 10*j
;if ( n eq 0 ) then  print ,j,'VEXB: jth=',jth
plot_VEXB[n,0]=VEXB[ lp,mp];upward drift
plot_VEXB[n,1]=VEXBe[lp,mp];zonal drift
;endfor ;j
endwhile;(eof(LUN14) eq 0 ) do begin

n_max1=n

FREE_LUN, LUN14
FREE_LUN, LUN15
if ( sw_exb_zonal eq 1 ) then $
FREE_LUN, LUN17
end;  pro rd_EXB, plot_VEXB_ut, plot_VEXB
