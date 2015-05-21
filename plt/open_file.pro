;opening files
pro open_file,  input_DIR, LUN,version,input_flnm $
,sw_3DJ,sw_hr, sw_lun,title_res $
,sw_debug

size_results=SIZE(input_DIR)
n_file=size_results[1]
if ( sw_debug eq 1 ) then  print,'n_file=',n_file


if(sw_lun[0] eq 1 ) then  input_flnm[0]='ut_rec';.log'
if(sw_lun[1] eq 1 ) then  input_flnm[1]='../../../wamns/grid/plt/plasma_grid.'+title_res
if(sw_lun[2] eq 1 ) then  input_flnm[2]='plasma00' ;o+
if(sw_lun[6] eq 1 ) then  input_flnm[6]='plasma01' ;h+
if(sw_lun[8] eq 1 ) then  input_flnm[8]='plasma02' ;he+
if(sw_lun[9] eq 1 ) then  input_flnm[9]='plasma03' ;N+
if(sw_lun[10] eq 1 ) then  input_flnm[10]='plasma04' ;NO+
if(sw_lun[11] eq 1 ) then  input_flnm[11]='plasma05' ;O2+
if(sw_lun[12] eq 1 ) then  input_flnm[12]='plasma06' ;N2+
if(sw_lun[13] eq 1 ) then  input_flnm[13]='plasma07' ;o+(2D)
if(sw_lun[14] eq 1 ) then  input_flnm[14]='plasma08' ;o+(2P)

if(sw_lun[3] eq 1 ) then  input_flnm[3]='plasma09' ;Te
if(sw_lun[7] eq 1 ) then  input_flnm[7]='plasma10' ;Ti

if(sw_lun[4] eq 1 ) then  input_flnm[4]='plasma12' ;Vo+
if(sw_lun[5] eq 1 ) then  input_flnm[5]='plasma16' ;VExBup
if(sw_lun[15] eq 1 ) then  input_flnm[15]='plasma17' ;VExBe
if(sw_lun[16] eq 1 ) then  input_flnm[16]='plasma18' ;VExBth

;if ( sw_hr  eq 1 ) then begin
;for jth=1,7 do begin
;  input_flnm[jth+5]='fort.500'+STRTRIM( STRING( jth, FORMAT='(i1)'), 1) ;hrate(1) !!PGR 
;print,jth,(jth+5),input_flnm[jth+5]
;endfor
;endif
;if ( sw_3DJ eq 1 ) then input_flnm[6]='fort.4007' ;je3


  for i = 0, n_file-1  do begin

     if ( sw_lun[i] ne 1 ) then  CONTINUE

;dbg20121124      if ( i eq 0 ) or ( i gt 9 ) then $ 
      if ( i eq 0 )  then $ 
        openr, LUNi, input_DIR[i]+input_flnm[i], /GET_LUN $
      else $       
        openr, LUNi, input_DIR[i]+input_flnm[i], /GET_LUN $
        , /F77_UNFORMATTED

      LUN[i]=LUNi
if ( i le 1 ) then       print,'opening file:',input_DIR[i]+input_flnm[i], LUN[i]
      
  endfor                        ;i = 0, n_file-1  do begin
end ;pro open_file
