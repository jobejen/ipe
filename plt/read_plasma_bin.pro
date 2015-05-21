pro read_plasma_bin,LUN,UT_hr, XIONN_m3,XIONV_ms1,TE_TI_k,VEXB,sw_debug $
,sw_3DJ,je_3d,sw_hr,hrate, sw_dif, sw_lun $
,NMP_in



UT_sec=0L
record_number=0L
; read plasma1
     readf, LUN[0], record_number, UT_sec
 UT_hr = UT_sec /3600.
print,' rec#',record_number,' UThr',UT_hr, UT_sec

size_result=size(XIONN_m3)
if ( sw_debug eq 1 ) then  $
   print,size_result

NPTS2D=size_result[2]
NMP=size_result[3]
if ( sw_debug eq 1 ) then  $
  print, 'NMP',NMP
if ( NMP_in eq 1 ) then NMP=NMP_in
dum=fltarr(NPTS2D,NMP)

;
size_result=size(VEXB)
NLP=size_result[2]
if ( sw_debug eq 1 ) then  $
  print, 'NLP=',NLP

if ( sw_lun[2] eq 1 ) then begin
   jth=0                        ;o+
   readu, LUN[2], dum

;dbg20140825
;for i=0,1 do begin
;print ,i,'check o+ MAX',MAX(dum3[*,*,i], Max_Subscript),Max_Subscript
;print ,i,'check o+ MIN',MIN(dum3[*,*,i], Min_Subscript),Min_Subscript
;for j=0,5 do  print, j,dum3[j,0,i]
;for j=1109,1114 do  print, j,dum3[j,0,i]
;endfor

XIONN_m3[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
if sw_debug eq 1 then  print, 'o+ XIONN_m3=',jth,XIONN_m3[jth,60,0]
endif ;( sw_lun

if ( sw_lun[6] eq 1 ) then begin
   jth=1                        ;h+
   readu, LUN[6], dum
   XIONN_m3[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
   if sw_debug eq 1 then  print, 'H+ XIONN_m3=',jth,XIONN_m3[jth,60,0]
endif ;( sw_lun

if ( sw_dif eq 0 ) then begin
   if ( sw_lun[8] eq 1 ) then begin
      jth=2                     ;he+
      readu, LUN[8], dum
      XIONN_m3[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
      if sw_debug eq 1 then  print, 'He+ XIONN_m3=',jth,XIONN_m3[jth,60,0]


;dbg20141016
;if ( record_number ge 63) then begin
;in=29177;JMIN_IN[57]-1
;inmax=in+40L
;print, '(2) check He+'
;for kk=in,in+40 do  print,kk,XIONN_m3[3-1,kk,52];, z_km[kk]
;endif ;( UT_sec ge 54000) then begin

   endif ;   if ( sw_lun[8] eq 1 ) then begin

   if ( sw_lun[9] eq 1 ) then begin
     jth=3                        ;n+
     readu, LUN[9], dum
     XIONN_m3[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
     if sw_debug eq 1 then  print, 'N+ XIONN_m3=',jth,XIONN_m3[jth,60,0]
   endif ;( sw_lun

   if ( sw_lun[10] eq 1 ) then begin
     jth=4                        ;no+
     readu, LUN[10], dum
;dbg print, 'debug dum =',dum[60,0]
     XIONN_m3[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
     if sw_debug eq 1 then  print, 'NO+ XIONN_m3=',jth,XIONN_m3[jth,60,0]
   endif ;( sw_lun

   if ( sw_lun[11] eq 1 ) then begin
     jth=5                        ;o2+
     readu, LUN[11], dum
     XIONN_m3[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
     if sw_debug eq 1 then  print, 'O2+ XIONN_m3=',jth,XIONN_m3[jth,60,0]
   endif ;( sw_lun

   if ( sw_lun[12] eq 1 ) then begin
     jth=6                        ;n2+
     readu, LUN[12], dum
     XIONN_m3[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
     if sw_debug eq 1 then  print, 'n2+ XIONN_m3=',jth,XIONN_m3[jth,60,0]
   endif ;( sw_lun

   if ( sw_lun[13] eq 1 ) then begin
     jth=7                        ;o+(2D)
     readu, LUN[13], dum
     XIONN_m3[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
     if sw_debug eq 1 then  print, 'o+(2D) XIONN_m3=',jth,XIONN_m3[jth,60,0]
   endif ;( sw_lun

   if ( sw_lun[14] eq 1 ) then begin
     jth=8                        ;o+(2P)
     readu, LUN[14], dum
     XIONN_m3[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
     if sw_debug eq 1 then  print, 'o+(2P) XIONN_m3=',jth,XIONN_m3[jth,60,0]
   endif ;( sw_lun
endif ;( sw_dif eq 0 ) then begin

;Te:
if ( sw_lun[3] eq 1 ) then begin
   jth=3-1
   readu, LUN[3], dum
   TE_TI_k[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
   if sw_debug eq 1 then  print, 'TE_TI_k=',TE_TI_k[jth,0,0]
endif


;Ti:
if ( sw_lun[7] eq 1 ) then begin
   jth=1-1
   readu, LUN[7], dum
   TE_TI_k[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
   if sw_debug eq 1 then  print, 'TE_TI_k=',TE_TI_k[jth,0,0]
endif

if ( sw_dif eq 0 ) then begin
   if ( sw_lun[4] eq 1 ) then begin
      jth=0                     ;Vo+
      readu, LUN[4], dum
      XIONV_ms1[jth,0:NPTS2D-1,0:NMP-1]=dum[0:NPTS2D-1,0:NMP-1]
      if sw_debug eq 1 then  print, 'XIONV_ms1=',jth,XIONV_ms1[jth,60,0]
   endif ;( sw_lun[9] eq 1 ) then begin
endif

if ( sw_dif eq 0 ) then begin
   dum=fltarr(NLP,NMP)
   if ( sw_lun[5] eq 1 ) then begin
      readu, LUN[5], dum
      jth=2
      for mp=0,nmp-1 do begin
;VEXBup(mp,lp)
         if  sw_debug eq 1 then  print,'VEXBup  mp=', mp
         VEXB[mp,0:nlp-1,jth]=dum[0:nlp-1,mp] ;+upward
      endfor                               ;mp
      if sw_debug eq 1 then   $
         print, 'VEXBup_ms1=',$
;VEXB[0,130,jth],VEXB[0,120,jth] ;low
VEXB[*,72,jth]
   endif                        ;( sw_lun[9] eq 1 ) then begin
;
   if ( sw_lun[15] eq 1 ) then begin
;VEXBe(mp,lp)
      readu, LUN[15], dum
jth=0
for mp=0,nmp-1 do begin
VEXB[mp,0:nlp-1,jth]=dum[0:nlp-1,mp] ;+eastward
endfor
      if sw_debug eq 1 then   $
;         print, 'VEXBe_ms1=',VEXB[0,130,jth],VEXB[0,120,jth]
;         ;original new grid 201207
         print, 'VEXBe_ms1=',VEXB[0,65,jth],VEXB[0,55,jth] ;2xdyn grid
   endif                        ;( sw_lun[9] eq 1 ) then begin
;
   if ( sw_lun[16] eq 1 ) then begin
;VEXBth(mp,lp)
      readu, LUN[16], dum
jth=1
      for mp=0,nmp-1 do begin
         VEXB[mp,0:nlp-1,jth]=dum[0:nlp-1,mp] ;+southward
      endfor 
      if sw_debug eq 1 then   $
         print, 'VEXBth_ms1=' $
;,VEXB[0,130,jth],VEXB[0,120,jth] ;original new grid 201207
,VEXB[0,65,jth],VEXB[0,55,jth] ;2xdyn grid
   endif                        ;( sw_lun[9] eq 1 ) then begin
endif



if ( sw_3DJ eq 1 ) then begin
     readf, LUN[6], je_3d
;if sw_debug eq 1 then  
print, 'je_3d[unit???]=',je_3d[0,0:20,0]
endif

if ( sw_hr eq 1 ) then begin
mptmp=0L
hrtmp=fltarr(NPTS2D)

for jth=1,7 do begin
;hr-jth
     readf, LUN[jth+5], mptmp
     readf, LUN[jth+5], hrtmp ;(1) !!PGR elec_ion
;jth=1-1
hrate[jth-1,1-1:NPTS2D-1,mptmp-1]=hrtmp[1-1:NPTS2D-1]
endfor

endif

;;;;dbg transport
;jth=1L
;mp=0L
;dum=fltarr(NPTS2D)
;     readf, LUN[4], dum
;XIONN_m3[jth,0:NPTS2D-1,mp]=dum[0:NPTS2D-1]
;if sw_debug eq 1 then  print, 'XIONN_m3=',jth,XIONN_m3[jth,60,mp]


END ;PRO read_bin
