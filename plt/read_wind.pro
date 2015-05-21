;20140108
;purpose: read wind on IPE grid for validation purpose
pro read_wind, ut_hr $
, Vn_ms1 $
;, Un_ms1 $
, luntmp7, luntmp3 $
, MaxFluxTube, nlp, nmp, JMIN_IN,JMAX_IS, sw_debug



;d print,'read_wind: JMIN_IN',JMIN_IN
;
;udum0=fltarr(MaxFluxTube,NLP   )
NMPdum=80L
udum=fltarr(MaxFluxTube,NLP,NMPdum) ;before 20140806
;udum1=fltarr(MaxFluxTube,NLP,NMP,3) ;runs after 20140806
;
;t for k=1-1,nmp-1 do begin
;t   if ( k eq 0 ) then begin
    readf, luntmp7, utime_dum
    print, 'sub-read_wind: utime=',utime_dum, utime_dum/3600., ut_hr
if ( ut_hr ne utime_dum/3600. ) then STOP
;t  endif
;input to IPE
;readu, luntmp3, Vn_ms1 ;(1:3,1:NPTS,1:nmp) 
;print, 'sub-read_wind',vn_ms1[0,0,0], vn_ms1[0,1116,0]
;output to IPE
;t  readu, luntmp3, udum0 ;(1:MaxFluxTube,1:NLP,1:nmp,3:3) 
;t  if ( sw_debug eq 1 ) then print,k, 'sub-read_wind',Udum0[*,130,0]
;t  for j=1-1,NLP-1 do begin
;t    for i=1-1,MaxFluxTube-1 do begin
;t      udum[i,j,k]=udum0[i,j]
;t    endfor ;i
;t  endfor ;j
;t endfor ;k=1-1,nmp-1 do begin
readu, luntmp3, udum ;(1:MaxFluxTube,1:NLP,1:nmp,3:3) 
;readu, luntmp3, udum1 ;(1:MaxFluxTube,1:NLP,1:nmp,1:3) 

;dbg
;lpdbg=46-1L
;print, udum[0:396,lpdbg,0]

;dbg20140806
;print,'check udum', MAX(udum), MIN(udum)
;print,'check udum1', MAX(udum1), MIN(udum1)

;udum-->vn_ms1
for k=1-1,nmp-1 do begin
   for j=1-1,nlp-1 do begin
      in=JMIN_IN[j]
      is=JMAX_IS[j]

      for i=1-1, is-in+1-1  do begin
         ii = i + (in-1)
;dbg if k eq 0 AND i ge 0 AND i le 5 then  print, i,ii,j,in,k

;nm20141015: positive northward
         vn_ms1[2-1,ii,k] = udum[i,j,k]


; if j eq lpdbg then print, i,j,k,ii,vn_ms1[2-1,ii,k];, udum[i,j,k]
;         vn_ms1[2-1,ii,k] = udum1[i,j,k,3-1]
      endfor                    ;i
   endfor                       ;j
endfor                          ;k

;dbg20140806
;print,'check vn_ms1', MAX( vn_ms1(2-1,*,*) ), MIN( vn_ms1(2-1,*,*) )
;STOP
  if ( sw_debug eq 1 ) then print , 'sub-read_wind finished!'



end;
