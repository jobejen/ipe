;20140226 separate from ts_rd_plasma16.pro
;purpose: plot EXB drift
;called from ts_rd_plasma16
pro plt_exb_drft $
,NLP,dum2,runid0,runid1,var_title,flnm_fig,sw_output2file

sw_dbg=1L
vmax=0.;+14000.
vmin=-14000.;+ 9000.;vmax*(-1.)

rd_grd $
,NLP,mlat90


   mpstart=1-1
   mpstop=80-1
;mlon loop
   for mp=mpstart,mpstop do begin
      print,'mp=',(mp+1)
      dum1=fltarr(NLP)
      dum1[0:NLP-1]=dum2[0:NLP-1,mp]


      if ( mp gt 1) AND (mp lt 78 ) then CONTINUE ;go to next mp

      if ( sw_dbg eq 1 ) then begin
         if ( mp eq 0 ) then begin
         for i=0,nlp-1 do begin
            if ( mlat90[i] lt -40. ) then  print,i,mlat90[i],dum1[i]
         endfor
      endif
      endif


      loadct,0
      line_color=250
      if mp eq 0  then begin
         line_style=0 
; line_color=250
      endif else if mp eq 1  then begin
         line_style=2
; line_color=150
      endif  else if mp eq 78 then begin
         line_style=4
      endif  else if mp eq 79 then begin
         line_style=5
;line_color=50
      endif
      if ( mp eq mpstart ) then $
         plot,mlat90,dum1 $
              , yrange=[vmin , vmax ],  ystyle=1 $
;              , xrange=[-90. , 0. ],  xstyle=1 $
              , xrange=[-80. , -45. ],  xstyle=1 $
              , title=runid0+'_'+runid1+' mp'+STRTRIM( string((mp+1), FORMAT='(i2)'),1 )$
              ,XTITLE = 'mlatitude[deg] ', YTITLE = 'VEXB'+var_title+'[m/s]' $
                    , linestyle=line_style $;,color=line_color $
      else    oplot,mlat90,dum1 $
                    , linestyle=line_style ;,color=line_color
   endfor                       ;mp

;reference
   oplot,mlat90,(dum1*0.0) $
                    , linestyle=1
;output 
if ( sw_output2file eq 1 ) THEN  output_png, flnm_fig

print,'pro plt_exb_drft finished successfully!'
end ;pro plt_exb_drft
