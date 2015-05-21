pro dbg_prfl_ht
sw_debug=1L
sw_plt_prfl=1L

;lun0=0L
;open grid file
filename_grid_sav= $
'/home/Naomi.Maruyama/sandbox/ipe/trunk/plt/grd/plasma_grid.low.sav' ;zeus
;'/home/maruyama/p2/ipe/trunk217/plt/grd/plasma_grid.low.sav'  ;jet
;openr, LUN0, '/home/Naomi.Maruyama/sandbox/ipe/trunk/plt/grd/', /GET_LUN $
;        , /F77_UNFORMATTED
;read_grid
 sw_debug_old=sw_debug
 restore, filename=filename_grid_sav
 print,'restoring the grid file=',filename_grid_sav
 sw_debug=sw_debug_old

;validate the reading
if sw_debug eq 1 then  print,'size jmin',SIZE(jmin_in)
if sw_debug eq 1 then  print,'size jmax',SIZE(jmax_is)

if sw_debug eq 1 then  print,'size z_km',SIZE(Z_km)
if sw_debug eq 1 then  print,'size mlat_deg ',SIZE(mlat_deg)

;if sw_debug eq 1 then    print,'NMP0',NMP0
;if sw_debug eq 1 then    print,'NMP1',NMP1

if sw_debug eq 1 then print,'NMP_all',NMP_all
if sw_debug eq 1 then print,'NLP_all',NLP_all
if sw_debug eq 1 then print,'NPTS2D_dum',NPTS2D_dum

lpj=0L
if sw_debug eq 1 then print,lpj,'JMIN_IN(1)',JMIN_IN[lpj]
if sw_debug eq 1 then print,'JMAX_IS(1)',JMAX_IS[lpj], JMIN_IN[lpj+1]

lpj=129L ;low
;lpj=34L ;dyn
ipts=JMIN_IN[lpj]-1 ;idl convention
if sw_debug eq 1 then print,lpj,ipts,'z_km',z_km[ipts]
if sw_debug eq 1 then print,'mlat_deg',mlat_deg[ipts]

mp=0L
if sw_debug eq 1 then print,mp,'GLAT-deg',glat_deg[ipts, mp]
if sw_debug eq 1 then print,'GLON-deg',glon_deg[ipts, mp]

if sw_debug eq 1 then  print, 'plasma0: IN=',JMIN_IN[0],' IS=',JMAX_IS[0],Z_km[0],mlat_deg[0]

;open/read plasma07

;! 0: O+ density [m-3]
;! 1: H+ density
;! 2: He+ density
;! 3: N+ density
;! 4: NO+ density
;! 5: O2+ density
;! 6: N2+ density
;! 7: O+(2D) density
;! 8: O+(2P) density
title_file='00'
openr, LUN0, $
;'/home/Naomi.Maruyama/wamns/v57/but107100/plasma'+title_file $  ;zeus
;'/home/maruyama/p2/ipe/trunk217/run/ipe_7913/plasma'+title_file $  ;jet
'/scratch1/portfolios/NCEPDEV/swpc/noscrub/Yangyi.Sun/ipe_para/km_20130827/trunk/run/ipe_640_2392/plasma'+title_file $  ;zeus
, /GET_LUN $
        , /F77_UNFORMATTED

NPTS2D=NPTS2D_dum
NMP=NMP_all
dum=fltarr(NPTS2D,NMP)
readu, LUN0, dum
if sw_debug eq 1 then  print, 'plasma',title_file,'[m-3]=',dum[60,0]

;set up parameters before calling prfl_ht

;plot profile
if ( sw_plt_prfl eq 1 ) then begin
sw_output2file=0 ;1'PNG' ;0NONE';
sw_fort=168
   print,'calling prfl_ht',sw_output2file
   prfl_ht $
,plot_x,plot_y, title_hemi,mlat_title,ut_hr,lt_hr $
,plot_DIR,FLDIM_plot,mp_plot,sw_debug,sw_fort $
,sw_dif,sw_output2file,n_file,fac_window

endif

print, 'prodbg_prfl_ht finished!'
end ; dbg_prfl_ht
