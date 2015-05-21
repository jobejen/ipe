pro read_fort168_3d,LUN168,UT_hr,LT_hr,Z,TNX,UN,NNO,EHT,TI,N,PHION,NHEAT,SUMION,sw_version,mp_plot,mp_read,sw_debug,n_read

  ;get FLDIM
   size_result = size(Z)
if ( sw_debug eq 1 ) then   print, 'size=',size_result
   FLDIM = size_result[1]

   mp=0L
   lp=0L
   string_mp='mp='
   string_lp=' lp='
   string_tmp='U168, North, UT='

;NOTE! mp_read must be 1!!!
;dbg for m=0,mp_read do begin ;NMP-1 do begin
for m=0,1-1 do begin ;NMP-1 do begin
; for l=0,1 do begin ;NLP-1 do begin

;dbg print,'sub-read_fort168: m=',m;,' l=',l

   readf, LUN168, string_mp,mp,string_lp,lp,string_tmp,UT_hr,LT_hr, FORMAT='(A3,i3,A4,i3,A16,2F10.2)'
print,"n_read#",n_read,' sub-read_fort168:', string_mp,mp,string_lp,lp,string_tmp,UT_hr,' LT=',LT_hr

mp_plot=mp-1 ;IDL convention
;dbg20120304: LT_hr calculation in flux_tube_...f90 was not correct!
;if ( mp eq 4 ) then lt_hr=UT_hr+19.9999999-24.
;if ( mp eq 1 ) then lt_hr=UT_hr+19.2-24.

   string_tmp='     Z         TN       UN       NNO      EHT      TI       TE       O+       H+      Min+     He+      PHION'
   readf, LUN168, string_tmp
if ( sw_debug eq 1 ) then print, string_tmp

   fmt01='(3F10.2,22E9.2)'
   for j=1-1,(FLDIM/2)+1-1 do begin

   if ( sw_version eq 0 ) then $  ;old version
     readf, LUN168, zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j,n3j,n4j,phionj $
     ,nheatj, FORMAT='(3F10.2,9E9.2,E10.2)' $
   else  $ ;new version with sumion etc
     readf, LUN168, zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j,n3j,n4j,phionj $
;     ,nheatj, sumionj1,sumionj2,sumionj3
,SUMIONJ,XIONNJ,EQN2DJ,NPLSPRDJ  $
, FORMAT=fmt01 ;'(3F10.2,9E9.2,E10.2,3E9.2)'

;if ( m eq mp_plot ) then begin
        Z[j]  = zj
      TNX[j]  = tnxj
       UN[j]  = unj
      NNO[j]  = nnoj
      EHT[j]  = eht3j
   TI[1-1,j]  = ti1j
   TI[3-1,j]  = ti3j
    N[1-1,j]  = n1j
    N[2-1,j]  = n2j
    N[3-1,j]  = n3j
    N[4-1,J]  = n4j
    PHION[j]  = phionj
;    NHEAT[j]  = nheatj
  if ( sw_version eq 1 ) then begin ;new version
     SUMION[1-1,J]  =SUMIONJ
;     SUMION[2-1,J]  = sumionj2
;     SUMION[3-1,J]  = sumionj3
 endif
;endif ;( m eq 0 ) then begin

if ( sw_debug eq 1 ) then begin
   if ( j eq 0 ) then  print, UT_hr,LT_hr $
    , FORMAT='(2F10.2)'

  print,j,zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j $
  ,n3j,n4j,phionj $
  ,SUMIONJ,XIONNJ,EQN2DJ,NPLSPRDJ  $
  , FORMAT='(i5,3F10.2,22E9.2)'
endif

    ENDFOR                          ;   for j=1-1,(FLDIM_l/2)+1-1 do begin
;  ENDFOR                           ;l=0,NLP-1 do begin
ENDFOR                           ;for m=0,NMP-1 do begin



END ;PRO read_fort168_3d
