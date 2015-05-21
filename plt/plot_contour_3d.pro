;TODO
;sw_save available so that I do not have to read the data everytime I run this code!!!
;include parallel plasma velocity to help the debug!!!
pro plot_contour_3d
mp_plot=1-1L
sw_hr=1L
sw_3DJ=0L
sw_anim=0L
; freq_plot_hr = (60.*12.)/60. ;frequency of plotting in hr
freq_plot_hr=3600.*48./3600.
;READ, freq_plot_hr,PROMPT='Enter frequency of plotting in hour:'

sw_save=1L ;0:no save; 1:save; 2:restore
;READ, sw_save,PROMPT='Enter switch for saving readin data 0or1:'

plot_UT =68.9739;(75506.+0.)/3600.
STOP_TIME=248306L
rundate='20111201'
TEST0='trans'
TEST='v21'
title_test=TEST0+'.'+TEST  ;trans.'+TEST
title_hemi='glb';SH'eq';
plot_type=0L ;0:contour; 1:ht profile; 2:LT-LAT contour; 3:LON-LAT contour
version='3d'


HOME_DIR='/lfs0/projects/idea/maruyama/sandbox/ipe/run/'
n_file=7L;6L;
input_flnm=['','','','','','','']
input_DIR=['','','','','','','']
input_DIR[*]=rundate+'.'+version+'.'+title_test+'/';backup20111202/';But'+STOP_TIME+'/'
input_DIR[1]='../plot/'

sw_debug=0L


mlat_title='79.56'
title_res='low'
title_f107='f180'
which_endian='big_endian'
;plot_DIR='../figures/'+title_res+'res/'+title_f107+'/glb/'
plot_DIR=$
;HOME_DIR+'../figures/glb/nmp80/fpasp0.3/'
 HOME_DIR+'../figures/'+TEST0+'/'+TEST+'/'
filename_sav=plot_DIR+rundate+'_'+version+'.'+title_res+'.sav'

if title_res eq 'low' then begin
  NLP=170L;low res
  NPTS2D=44438L ;low res
endif else begin
  NLP=209L;high res
  NPTS2D=165717L ;high res
endelse

NMP=80L
ISPEC=9L
ISPEV=4L
FLDIM = 1115L

   LUN  = INTARR(n_file)
n_read_max=86400*2/900+1L;256-27+1; 86400/300 +1 ;=289
  UT_hr = 0.00D0
  UT_hr_save = fltarr(n_read_max)
;  LT_hr = fltarr(  NMP,NLP)
NPAR   =3L ; 9L;12L
;i should be aware of the memory limit!!!
if ( plot_type eq 0 ) or ( plot_type eq 2 ) then begin
;  plot_z = fltarr(n_read_max,NPAR, NMP,NPTS2D)
  plot_z = fltarr(n_read_max,NPAR, 1,NPTS2D) ;to save memory!!!
  if ( plot_type eq 0 ) then $
  plot_VEXB = fltarr(n_read_max,NMP,NLP)
endif

if ( sw_3DJ eq 1 ) then $
  je_3d=fltarr(2,NPTS2D,NMP)

if ( sw_hr eq 1 ) then $
  hrate=fltarr(7,NPTS2D,1) ;  hrate=fltarr(7,NPTS2D,NMP)



XIONN_m3 =fltarr(2,NPTS2D,NMP)  ;fltarr(ISPEC,NPTS2D,NMP)
XIONV_ms1=fltarr(1,NPTS2D,NMP) ;fltarr(ISPEV,NPTS2D,NMP)
TE_TI_k  =fltarr(    3,NPTS2D,NMP)
VEXB=fltarr(NMP,NLP) ;before2011-11-16.v18 only meridional transport version
;after 2011-11-16.v18: VEXB=fltarr(2,NPTS2D,NMP) ;zonal transport version
;NHEAT_mks=dblarr(      NPTS2D,NMP)
;hrate_mks=dblarr(    6,NPTS2D,NMP)

if ( plot_type eq 2 ) then begin
  n_read_max2 = 86400*2/900 +1 ;=289
;  n_read_max2 = (133106-61106)/300 +1 ;=289
  plot_zz = fltarr(n_read_max2,NLP*2L)
  plot_xx = fltarr(n_read_max2,NLP*2L)
  plot_yy = fltarr(n_read_max2,NLP*2L)
endif

z_km =fltarr(NPTS2D) ;,NMP)
mlat_deg  =fltarr(NPTS2D) ;,NMP) ;GL_rad
JMIN_IN=lonarr(NLP)
JMAX_IS=lonarr(NLP)

if ( sw_save eq 2 ) then begin
  restore, filename=filename_sav
  print,'restoring the file=',filename_sav
endif

;opening files
open_file, HOME_DIR, input_DIR, LUN,version,input_flnm $
,sw_3DJ,sw_hr

n_read=-1L
;while ( EOF(LUN[1]) eq 0 ) or ( n_read le n_read_max-1 ) do begin
while ( n_read lt n_read_max-1 ) do begin
  n_read = n_read+1
;  if ( sw_debug ) then  $
print,'n_read=',n_read, n_read_max

  if ( sw_save eq 1 ) then begin

  if ( n_read eq 0 ) then  read_grid,LUN,JMIN_IN,JMAX_IS,Z_km,mlat_deg,sw_debug
  read_plasma_bin,LUN,UT_hr,XIONN_m3,XIONV_ms1,TE_TI_k,VEXB,sw_debug $
,sw_3DJ,je_3d,sw_hr,hrate
  UT_hr_save[n_read]=UT_hr

  if ( plot_type eq 0 ) or ( plot_type eq 2 ) then begin
    ipts=0L
    for mp=mp_plot,mp_plot do begin ;NMP-1 do begin
;0 Ne electron density[m-3]
;     for ipts=0L,NPTS2D-1L do  $
;      plot_z[n_read,0,mp,ipts] = TOTAL( XIONN_m3[0:5,ipts,mp] )
;1-3:O+,H+,He+   ,N+,NO+,O2+,  N2+,O+(2D),O+(2P)
      for jth=0,0 do $ ;2 do begin
        plot_z[n_read,jth+1,mp,0:NPTS2D-1] = XIONN_m3[jth,0:NPTS2D-1,mp]

;4 Te electron temperature
    plot_z[n_read,0,mp,0:NPTS2D-1] = TE_TI_k[3-1,0:NPTS2D-1,mp]

if ( sw_hr eq 1 ) then $
    plot_z[n_read,2,mp,0:NPTS2D-1] = hrate[4-1,0:NPTS2D-1,mp]

;5 TO+ ion temperature
;    plot_z[n_read,5,mp,0:NPTS2D-1] = TE_TI_k[1-1,0:NPTS2D-1,mp]

;6:O+, flux [m-2 s-1]
;    for jth=0,0 do begin
;      plot_z[n_read,jth+6,mp,0:NPTS2D-1] = XIONN_m3[jth,0:NPTS2D-1,mp] * XIONV_ms1[jth,0:NPTS2D-1,mp]
;  endfor

;7:O+,velocity [m s-1]
;    for jth=0,0 do begin
;      plot_z[n_read,jth+7,mp,0:NPTS2D-1] = XIONV_ms1[jth,0:NPTS2D-1,mp]
;      plot_z[n_read,0,mp,0:NPTS2D-1] = XIONV_ms1[jth,0:NPTS2D-1,mp] ;temporary solution to save memory
;    endfor

;neutral heating rate eV/kg/s
;    plot_z[5,   mp,0:NPTS2D-1] = NHEAT_mks[    0:NPTS2D-1,mp]
;    plot_z[6:11,mp,0:NPTS2D-1] = hrate_mks[0:5,0:NPTS2D-1,mp]

  if ( plot_type eq 0 ) then begin
        for lp=0,NLP-1 do begin
          midpoint = JMIN_IN(lp) + ( JMAX_IS(lp) - JMIN_IN(lp) )/2 -1
          plot_VEXB[n_read,mp,lp] = VEXB[mp,lp]           ;before 2011-11-16.v18:          
;after 2011-11-16.v18:          plot_VEXB[n_read,mp,lp] = VEXB[1,midpoint,mp]           
        endfor
  endif ;( plot_type eq 0 ) then begin

      endfor ;mp=0,NMP-1 do begin

    if ( plot_type eq 2 ) then begin 
; LT-LAT plot
;dbg
;print,plot_type,'n_read',n_read
;    ht_plot = 500.00 ;[km]
     contour_LT_LAT $
  , mp_plot  $ 
  , JMIN_IN,JMAX_IS,Z_km,mlat_deg  $ 
  , plot_z   $
  , UT_hr, LT_hr, plot_DIR $
  , plot_zz,plot_xx,plot_yy,n_read ;,ht_plot
  endif ;plot_type eq 0


; lon-lat plot
    endif else if ( plot_type eq 3 ) then begin 
;     ht_plot = 110.00 ;[km]
     contour_LON_LAT $
  , JMIN_IN,JMAX_IS,Z_km,mlat_deg  $ 
  , je_3d   $
  , UT_hr, plot_DIR $
  , n_read


    endif; plot_type eq 0

  endif ;( sw_save eq 1 ) then begin


;print, 'before plotting',UT_hr , plot_UT
if ( UT_hr ge plot_UT ) AND $
   ( ( (UT_hr-UT_hr_save[0]) MOD freq_plot_hr ) LT 0.00001 ) then begin 

print, 'after plotting',UT_hr , plot_UT

  if ( plot_type eq 0 ) then begin 
     if ( sw_debug eq 1 ) then     print, 'plotting contour: UT=',ut_hr



;dbg
print,'plot_type',plot_type
     contour_plot_2d    $ 
  , JMIN_IN,JMAX_IS,Z_km,mlat_deg  $ 
  , plot_z,plot_VEXB,n_read   $
  , UT_hr, plot_DIR, title_res,rundate,title_test,sw_debug, title_hemi,sw_anim,mp_plot




  endif else if ( plot_type eq 1 ) then begin 
    print, 'plotting ht profile: UT=',ut_hr

plot_type_prof=1L ;0:densities; 1:temperatures
title_hemi='NH'
n_file_plot = 5L ;!caution! n_file_plot=1 does not work!!!
ut_hr_plot = fltarr(n_file_plot)
ut_hr_plot[0:n_file_plot-1] = UT_hr
lt_hr_plot = fltarr(n_file_plot)
 FLDIM_max = FLDIM  ;for mlat_title='38' lp=41
print, 'FLDIM_max', FLDIM_max,'n_file_plot',n_file_plot
 plot_y = fltarr(  FLDIM_max,n_file_plot)
plot_type_max=4L
k_species = 4L
 plot_x = fltarr(plot_type_max, k_species,FLDIM_max,n_file_plot)
     plot_x[*,*,*,*] =-999999999.999999
 FLDIM_plot=LONARR(n_file_plot)
for   mp_plot0=1-1,41-1,40  do begin
  lp_plot0= 8-1L

for i_file = 0,n_file_plot-1 do begin

if (i_file eq 0 ) then begin
  lp_plot=lp_plot0
  mp_plot=mp_plot0
endif else if (i_file eq 1 ) then begin
  lp_plot=lp_plot0+1L
  mp_plot=mp_plot0
endif else if (i_file eq 2 ) then begin
  lp_plot=lp_plot0+2L
  mp_plot=mp_plot0
endif else if (i_file eq 3 ) then begin
  lp_plot=lp_plot0+3L
  mp_plot=mp_plot0
endif else if (i_file eq 4 ) then begin
  lp_plot=lp_plot0+4L
  mp_plot=mp_plot0
endif

;  if (i_file eq 0 ) then $
;    lp_plot=10-1L $  ;idl conversion
;  else if (i_file eq 1 ) then $
;    lp_plot=11-1L $   ;idl conversion
;  else if (i_file eq 2 ) then $
;    lp_plot=12-1L $   ;idl conversion
;  else if (i_file eq 3 ) then $
;    lp_plot=9-1L   

print,'i_file',i_file,'lp_plot',lp_plot,'mp_plot',mp_plot

  lp_title=lp_plot+1 ;=42
;  if ( lp_title eq 40 ) then $
;    mlat_title='39'  $  ;???
;  else if ( lp_title eq 41 ) then $
;    mlat_title='38'  $
;  else if ( lp_title eq 42 ) then $
;    mlat_title='37'  $
;  else if ( lp_title eq 43 ) then $
;    mlat_title='36'  $
;  else if ( lp_title eq 44 ) then $
;    mlat_title='35'  $
;  else if ( lp_title eq 45 ) then $
;    mlat_title='32'  $
;  else if ( lp_title eq 46 ) then $
;    mlat_title='31'  $
;  else if ( lp_title eq 47 ) then $
;    mlat_title='29'   


  lt_hr_plot[i_file] = LT_hr[mp_plot,lp_plot]
  in=JMIN_IN[LP_plot]-1  ;idl conversion
  is=JMAX_IS[LP_plot]-1  ;idl conversion
  FLDIM_plot[i_file] = is-in+1L
print,'FLDIM=',FLDIM_plot[i_file]
  
i_window=0L
  plot_x[i_window,0,0:FLDIM_plot[i_file]-1,i_file] =   ALOG10 ( XIONN_m3[1-1,in:is,MP_plot] * 1.0E-6 )  ;[o+]m-3 --> cm-3
  plot_x[i_window,1,0:FLDIM_plot[i_file]-1,i_file] =   ALOG10 ( XIONN_m3[2-1,in:is,MP_plot] * 1.0E-6 )  ;[h+]
;  plot_x[i_window,2,0:FLDIM_plot[i_file]-1,i_file] =   ALOG10 ( XIONN_m3[3-1,in:is,MP_plot] * 1.0E-6 )  ;[he+]
i_window=1L
  plot_x[i_window,0,0:FLDIM_plot[i_file]-1,i_file] =   TE_TI_k[1-1,in:is,MP_plot] ;Ti
  plot_x[i_window,1,0:FLDIM_plot[i_file]-1,i_file] =   TE_TI_k[3-1,in:is,MP_plot] ;Te
 ; plot_x[i_window,  6,0:FLDIM_plot[i_file]-1,i_file] =   NHEAT_mks[  in:is,MP_plot]

  plot_x[2,0,0:FLDIM_plot[i_file]-1,i_file] =   0.0 ;phion
  plot_x[3,0,0:FLDIM_plot[i_file]-1,i_file] =   0.0 ;eht

;print,i_file,mp_plot,TE_TI_k[3-1,in:is,MP_plot] ;Te

  plot_y[    0:FLDIM_plot[i_file]-1,i_file] =                  Z_km[  in:is]
endfor ;i_file = 0,n_file_plot-1 do begin

sw_fort=168L
     profile_ht_3d,plot_x,plot_y, title_hemi,mlat_title,ut_hr_plot,lt_hr_plot $
;,plot_type_prof
,plot_DIR,FLDIM_plot,mp_plot,sw_debug,sw_fort
endfor   ;mp_plot0=1-1,nmp-1,10  do begin     

  endif ;else if ( plot_type eq 1 ) then begin 
;BREAK ;exit from while loop
endif ;( UT_hr eq plot_UT ) then begin
endwhile                            ; ( EOF(LUN[0]) ne 0 ) then begin

if ( sw_save eq 1 ) then  begin
  save, filename=filename_sav
  print,'saving to a file=',filename_sav
endif

for i = 0, n_file-1  do    FREE_LUN, LUN[i]

print,'pro plot_contour_3d finished successfully!!!'
end ;pro plot_contour_3d
