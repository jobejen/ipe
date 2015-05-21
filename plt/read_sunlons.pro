pro read_sunlons $
, sunlons1,TEST,rundir, LUN2013, n_read

if n_read eq 0 then begin
  input_DIR='/home/Naomi.Maruyama/wamns/'+TEST+'/trunk/run/'+rundir
  print, 'read_fort2013:input_DIR=', input_DIR
  input_flnm=input_DIR+'/fort.2013'
;LUN2013=0L
;i need to think about what to do after second time...
;open

   openr, LUN2013, input_flnm, /GET_LUN
endif
;read
;n_read = -1L
;t while ( eof(LUN2013) eq 0 ) do begin
;  n_read = n_read + 1
   readf, LUN2013,sunlons1 ;$
;FORMAT=$
;fmt00
;'(A16,2F10.2)'

;if sw_debug eq 1 then  
print,'n_rd=',n_read,' sunlons1=', sunlons1

;t endwhile

;i need to think about what to do after second time...
;close
;   FREE_LUN, LUN2013

print, "pro read_sunlons"
end ;pro read_sunlons
