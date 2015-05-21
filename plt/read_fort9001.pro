pro read_fort9001 $
, ph0,ph1,th0,th1, sw_debug $
,TEST,rundir,LUN9001,n_read,nmp,nlp

print, '(1) read_fort9001'

if ( n_read eq 0 ) then begin
input_DIR='/home/Naomi.Maruyama/wamns/'+TEST+'/trunk/run/'+rundir
print, 'read_fort9001:input_DIR=', input_DIR
input_flnm=input_DIR+'/fort.9001'
;LUN9001=0L

;i need to think about what to do after second time...
;open
   openr, LUN9001, input_flnm, /GET_LUN
endif ;( n_read eq 0 ) then begin

print, '(2) read_fort9001', nmp,nlp
;read
n_read9001 = -1L
mp=0L
lp=0L
;i need to think about modifying how to advance the loop after 2nd
;time step...
;n_read9001_max=nmp * nlp???
;while ( eof(LUN9001) eq 0 ) do begin
while ( n_read9001 le 5920 ) do begin


  n_read9001 = n_read9001 + 1
print, '(3) read_fort9001=',n_read9001
   readf, LUN9001,mp,lp,phi0,phi1,the0,the1 ;$
;FORMAT=$
;fmt00
;'(A16,2F10.2)'

print, '(4) read_fort9001'
;if sw_debug eq 1 then  $
print,'n_rd9001=',n_read9001,' mp=', mp,' lp=',lp,phi0,phi1,the0,the1

ph0[mp-1,lp-1]=phi0
ph1[mp-1,lp-1]=phi1
th0[mp-1,lp-1]=the0
th1[mp-1,lp-1]=the1



endwhile


;if mp eq nmp and lp eq nlp then begin
  print, "pro read_fort9001 finished!"
  RETURN ;exit from while 
;endif

;close



end ;pro read_fort9001
