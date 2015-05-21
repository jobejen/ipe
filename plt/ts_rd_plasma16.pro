;20140226: 
; purpose: read plasma16/17(exb drift) and plot for validation
pro ts_rd_plasma16
runid0='r336';r319.4';old_runs/v79';
runid1='S_29795';S_29672';640_14999';
path0='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/'
path=$
path0+runid0+'/trunk/run/ipe_'+runid1+'/'
;path0+'old_runs/v79/trunk/run/ipe_640_16051/'  ;old ref 1timestep
;path0+'old_runs/v79/trunk/run/ipe_640_14999/'  ;old ref 24hr
;path0+'r319.4/trunk/run/ipe_S_29672/'  ;latest trusted reference
path_plot=path0+'fig/drft/'
sw_output2file=1



;sw_drft=0 ;upward
sw_drft=1 ;eastward
if sw_drft eq 0 then begin
   flnm0='6'
   var_title='up'
endif else if sw_drft eq 1 then begin
   flnm0='7'
   var_title='east'
endif
flnm_fig=path_plot+runid0+'.'+runid1+var_title+'v3.png'

flnm=path+'plasma1'+flnm0
openr,lun,flnm,/get_lun, /F77_UNFORMATTED
print,lun,' opening file:',flnm


NLP=170L
NMP=80L
dum2=fltarr(NLP,NMP)

;time loop
tmax=0L
for t=0,tmax do begin
   print,'time=',t
   readu,lun,dum2

   plt_exb_drft $
,NLP,dum2,runid0,runid1,var_title,flnm_fig,sw_output2file


endfor                          ;t=0,tmax do begin
free_lun,lun
print,'pro ts_rd_plasma16 finished successfully!'
end                             ;pro ts_rd_plasma16
