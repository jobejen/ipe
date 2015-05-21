pro read_fort168,LUN168,UT_hr,LT_hr,Z,TNX,UN,NNO,EHT,TI,N,PHION,NHEAT,SUMION,sw_version,sw_debug $
, xionn, eqn2d, nplsrd

  ;get FLDIM
   size_result = size(Z)
if ( sw_debug eq 1 ) then   print, 'size=',size_result
   FLDIM = size_result[1]

   string_tmp='U168, North, UT='

if ( sw_version le 2 ) then $
  format168='(A16,2F10.2)' $
else $ ;if ( sw_version gt 3 ) then $ yet 20110810another new version  
  format168='(A16,2F10.3)'

   readf, LUN168, string_tmp, UT_hr, LT_hr, FORMAT=format168
if ( sw_debug eq 1 ) then   $
  print, string_tmp, UT_hr, LT_hr

if ( sw_version le 1 ) then $
   string_tmp='     Z         TN       UN       NNO      EHT      TI       TE       O+       H+      Min+     He+      PHION' $
else if ( sw_version eq 2 ) then $
   string_tmp='     Z         TN       UN       NNO      EHT      TI       TE       O+       H+      Min+     He+      PHION    PRODO+     N+     EQN2D   NPLSPRD'

   readf, LUN168, string_tmp
if ( sw_debug eq 1 ) then $
  print, string_tmp


   for j=1-1,(FLDIM/2)+1-1 do begin
;print,'j',j

   if ( sw_version eq 0 ) then $  ;old version
     readf, LUN168, zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j,n3j,n4j,phionj $
     ,nheatj, FORMAT='(3F10.2,9E9.2,E10.2)' $
   else if ( sw_version eq 1 ) then $  ;new version with sumion after 20110803
     readf, LUN168, zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j,n3j,n4j,phionj $
     ,nheatj,sumionj1,sumionj2,sumionj3, FORMAT='(3F10.2,9E9.2,E10.2,3E9.2)' $
   else if ( sw_version ge 2 ) then $ ;another new version 20110805 suggested by phil
     readf, LUN168, zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j,n3j $
     ,xionn3j,phionj,sumionj1,xionn4j,eqn2dj,nplsrdj, FORMAT='(3F10.2,13E9.2)'

     Z[j]      = zj
     TNX[j]    = tnxj
     UN[j]     = unj
     NNO[j]    = nnoj
     EHT[j]= eht3j
     TI[1-1,j] = ti1j
     TI[3-1,j] = ti3j
     N[1-1,j]  = n1j
     N[2-1,j]  = n2j
     N[3-1,j]  = n3j
  if ( sw_version le 1 ) then $
     N[4-1,J]  = n4j
     PHION[j]  = phionj
  if ( sw_version le 1 ) then $
     NHEAT[j]  = nheatj
  if ( sw_version ge 1 ) then begin ;new version
     SUMION[1-1,J]  = sumionj1

    if ( sw_version eq 1 ) then begin ;new version
     SUMION[2-1,J]  = sumionj2
     SUMION[3-1,J]  = sumionj3
    endif
endif
    if ( sw_version ge 2 ) then begin
     xionn[3-1,j]=xionn3j
     xionn[4-1,j]=xionn4j
     eqn2d[    j]=eqn2dj
     nplsrd[   j]=nplsrdj
    endif

if ( sw_debug eq 1 ) and ( j eq 10 ) then  $
  print, j,zj,tnxj,unj,nnoj,eht3j,ti1j,ti3j,n1j,n2j $
;,n3j,n4j,phionj $
;,nheatj $
, FORMAT='("j=",i5,3F10.2,22E9.2)'

   ENDFOR

END ;PRO read_fort168
