;20141006 TEC in mag coordinate by interpolation
;20140902: n_plt does not work with plot_z[n_read]!!! i dont understand why???
;20131219: hinotori: Vartype in ctr_lon_lat needs to be zero to be able to output Ne. the output files are saved in ~/wamns/hinotori/. ncount at the end of the run should be input to read_hinotori.pro
;20130520UNDERCONSTRUCTION!!!include Tn for leslie
;tmp20121128 temporary o+ is assigned to plot_z(6)(n+) instead of 3 for faster debug molecular ions
;.20120305: renamed from plot_contour_3d_dif.pro-->plt_ipe.pro
;20120228: sw_dif: useed for comparison of two different runs
;20111205: sw_save=2 to save plotting time!!!
;include parallel plasma velocity to help the debug!!!
pro plt_ipe_tec
sw_output2file=0;1'PNG' ;0NONE';
TEST='r319';r345';
TEST2='80';S;640'
sw_output2file_ascii=0
f107=130;165;100;72
TEST1='22905' ;32753dbg'
alt=350.

   if ( f107 eq 165 ) then begin
      TEST1='7563';9445';27725' ;24695';830tril';
      alt=350.
;      alt=410.
   endif else if ( f107 eq 100 ) then begin
      TEST1='24449'
      alt=378.
   endif else if ( f107 eq 72 ) then begin
      TEST1='24695' ;original
;;      TEST1='21994' ;corrected new wind direction
      alt=340.
   endif

luntmp =100L
luntmp1=101L
if ( sw_output2file_ascii eq 1 ) then begin
   chr_title='F107='+STRTRIM( string(f107, FORMAT='(i3)'), 1)
   chr_title1=STRTRIM( string(alt, FORMAT='(F5.0)'), 1)+'km'
   flnmtmp='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/champ/champ_te'+chr_title1+'.'+chr_title+'.dat'
   openw,luntmp,flnmtmp, /GET_LUN
   print, 'champ file created:',flnmtmp

endif ;( sw_output2file_ascii eq 1 ) then begin

;n_plt_max=97L ;for quick plot
n_read_max=$
1;
;97-45+1-4L;1L;21-5+1L;127-108+1
plot_UT    =$
432000.;
;471600.;493200.;54000.;432000. ;+ 3600.*16.;
plot_UT_end=$
518400.;-3600.;plot_UT+3600.*24.;.; [sec]
sw_quickplot=0
;20140117; plot every X hour
sw_hourly_plot=1
plotXhr=1.0 
print, 'plot every',plotXhr,' hour'

title_res= $
'low20120709';
;'td20120709';
;'2xdyn';
;'low'; 'high'

sw_read_wind=1
;difutmin=60./60.;15./60. - 0.00001;=0.24999 ;output_freq=15min
;difutmin=16./60. - 0.00001 ;output_freq=16min
;print,'difutmin=',difutmin
;endif ;( sw_output2file_ascii eq 1 ) then begin
if ( sw_read_wind eq 1 ) then begin
   luntmp7=101
   luntmp3=102
   dirtmp7= $
;'/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/reu/tmp20130717reu/';!input to IPE
      '/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/'+TEST+'/trunk/run/ipe_'+TEST2+'_'+TEST1+'/' ;output from IPE
;input to IPE
;   flnmtmp7=dirtmp7+'ut_input'
;   flnmtmp3=dirtmp7+'wind_input'
   flnmtmp7=dirtmp7+'ut_out4wind' ;fort.6000' ;ut
   flnmtmp3=dirtmp7+'wind_out' ;fort.6001' ;wind

;ut
   openr, luntmp7, flnmtmp7, /GET_LUN
   print,'opening ',flnmtmp7
;wind
   openr, luntmp3, flnmtmp3, /GET_LUN $
          , /F77_UNFORMATTED
   print,'opening ',flnmtmp3
endif                           ;( sw_read_wind eq 1 ) then begin

fac_window=1.0
;!!!CAUTION!!! plot_UT needs to be float (INT has limited digit!!!)
input_DIR0=$
'/home/Naomi.Maruyama/wamns/'+TEST+'/trunk/run/ipe_'+TEST2+'_'+TEST1+'/'
;'/home/Naomi.Maruyama/wamns/'+TEST+'/trunk/tst/runs/zeus_intel_serial.1408558529/run/ipe_'+TEST2+'_'+TEST1+'/';test suite



plot_type=0L ;0:contour; 1:ht profile; 2:LT-LAT contour; 3:LON-LAT contour; 4:refilling: 5:psphere, 6:tec
;if plot_type eq 0 then begin
mppl=LONARR(n_read_max)
mppl[ 0]=56L
;mppl[ 4]=52L ;1ut
;mppl[ 8]=49L ;2ut
;mppl[12]=46L ;3ut
;mppl[16]=43L
;mppl[20]=39L
;mppl[24]=36L
;mppl[28]=33L
;mppl[32]=29L
;mppl[36]=26L
;mppl[40]=23L
;mppl[44]=20L
;mppl[48]=16L
;mppl[52]=13L
;mppl[56]=10L
;mppl[60]= 6L
;mppl[64]= 3L
;mppl[68]=79L
;mppl[72]=76L
;mppl[76]=73L
;mppl[80]=69L
;mppl[84]=66L
;mppl[88]=62L
;mppl[92]=59L
;mppl[96]=56L
;---
  VarType_min=0
  VarType_max=0;11
  VarType_step=1
;endif ;plot_type eq 0 then begin


sw_debug=0L
;0:mag; 1:geo; 2:LT-maglat
sw_frame=2L
sw_dif=0L
sw_hr=0L
sw_3DJ=0L
sw_anim=0L
; freq_plot_hr = (60.*12.)/60. ;frequency of plotting in hr
output_freq=900
freq_plot_hr=output_freq/3600.
;READ, freq_plot_hr,PROMPT='Enter frequency of plotting in hour:'
sw_save=0L ;0:no save; 1:save; 2:restore
;sw_save option does not work for plot_type=1
;READ, sw_save,PROMPT='Enter switch for saving readin data 0or1:'
htstrt=400.
htstop=400.
htstep=200.
;;;!WARNING conflict with vartype_min/max for plot_type=0
Varstrt=0
Varstop=0

STOP_TIME='230406'
rundate='20121121'
TEST0='trans'
title_test=TEST0+'.'+TEST  ;trans.'+TEST
title_hemi='glb';SH';glb';SH'eq';

version='3d'

;HOME_DIR='/lfs0/projects/idea/maruyama/sandbox/ipe/run/'
HOME_DIR=$
;'/Users/naomi/sandbox/ipe/run/' ;mac
;'/home/Naomi.Maruyama/wamsv/tmp20120723ipe/run/' ;zeus
;'/home/Naomi.Maruyama/wamsv/' ;zeus
'/home/Naomi.Maruyama/wamns/' ;zeus
;'/home/Naomi.Maruyama/ptmp/' ;zeus
fig_DIR=$
'/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/' ;zeus
;'/home/Naomi.Maruyama/iper/' ;zeus
n_file=17L;6L;13L;
input_flnm=['','','','','','' $
,'','','','' $
,'','','','','','','']
input_DIR =input_flnm
;input_DIR[*]=rundate+'.'+version+'.'+title_test+'/';backup20120223mpall/';But'+STOP_TIME+'error/'
input_DIR[*]=$
input_DIR0
;'ipe4gsd/run_naomi/'
;TEST+'/bkup19/'
input_DIR[1]=$
;'../plt/' ;mac
'/home/Naomi.Maruyama/ipe/trunk/plt/' ;zeus
LUN  = INTARR(n_file)
sw_LUN  = INTARR(n_file)
sw_lun[0:1]=1
sw_lun[2]=1 ;o+
sw_lun[6]=1 ;h+
sw_lun[8]=1 ;he+
sw_lun[9]=1 ;n+
sw_lun[10]=1 ;no+
sw_lun[11]=1 ;o2+
sw_lun[12]=1 ;n2+
sw_lun[13]=1 ;o+(2D)
sw_lun[14]=1 ;o+(2P)
sw_lun[3]=0 ;Te
sw_lun[7]=0 ;Ti
sw_lun[4]=0 ;vo+
sw_lun[5]=0 ;vexbup
sw_lun[15]=0 ;vexbe
sw_lun[16]=0 ;vexbth
if ( sw_dif eq 1 ) then begin
LUNq  = INTARR(n_file)
   input_flnmq =input_flnm
   input_DIRq =input_flnmq
   rundateq='20120217'
   TESTq='v46'
   title_testq=TEST0+'.'+TESTq
   input_DIRq[*]=$
TESTq+'/'
;rundateq+'.'+version+'.'+title_testq+'/';backup20120223/'
   input_DIRq[1]=input_DIR[1]
endif




plot_DIR= $
;fig_DIR+'fig/sarah/'+TEST1+'/'
fig_DIR+'fig/'+TEST+'/' ;+TEST1+'/'
;fig_DIR+'fig/'
; fig_DIR+'fig/'+TEST+'/'+TEST1+'/'
;if ( sw_dif eq 1 ) then $
;  plot_DIR=plot_DIR+'dif/'
print,' plot_DIR=', plot_DIR
if ( sw_frame eq 0 ) then $
title_frame='mag' $
else if ( sw_frame eq 1 ) then $
title_frame='geo' $
else if ( sw_frame eq 2 ) then $
title_frame='lt'
filename_sav=plot_DIR+rundate+'_'+version+'.'+title_res+title_frame+'.sav'

if title_res eq 'low' then begin
  NLP=170L;low res
  NPTS2D=44438L ;low res
endif else if title_res eq 'low20120709' OR title_res eq 'td20120709' then begin
  NLP=170L;low res
  NPTS2D=44514L ;low res
endif else if title_res eq 'high' then  begin
  NLP=209L;high res
  NPTS2D=165717L ;high res
endif else if title_res eq '2xdyn' then  begin
  NLP=93L;
  NPTS2D=31287L ;high res
endif else if title_res eq 'dyn' then  begin
  NLP=45L;
  NPTS2D=15857L ;high res
endif

NMP=80L ;=mpstop in IPE.inp
ISPEC=9L
ISPEV=4L
MaxFluxTube=1115L ;=FLDIM
FLDIM=927L  ;???used when plot_type=1

  
  sunlons1 =  -1.92900  ;tmp20140701 i will need to read in every time within the loop
  UT_hr = 0.00D0
  UT_hr_save = fltarr(n_read_max)
;  LT_hr = fltarr(  NMP,NLP)
NPAR   = 5L;12L;
;i should be aware of the memory limit!!!
if ( plot_type eq 0 ) or ( plot_type eq 2 ) or ( plot_type eq 4 ) then begin
;  plot_z = fltarr(n_read_max,NPAR, NMP,NPTS2D)
  plot_z = fltarr(n_read_max,NPAR, 1 ,NPTS2D) ;to save memory!!!
  if ( plot_type eq 0 ) then $
  plot_VEXB = fltarr(n_read_max,NMP,NLP)
endif

if ( sw_3DJ eq 1 ) then $
  je_3d=fltarr(2,NPTS2D,NMP)

if ( sw_hr eq 1 ) then $
  hrate=fltarr(7,NPTS2D,1) ;  hrate=fltarr(7,NPTS2D,NMP)


if ( sw_read_wind eq 1 ) then $
   Vn_ms1=fltarr(3,NPTS2D,NMP)
; Un_ms1=fltarr(MaxFluxTube,NLP,NMP)
XIONN_m3 =fltarr(ISPEC,NPTS2D,NMP)
XIONV_ms1=fltarr(1,NPTS2D,NMP) ;fltarr(ISPEV,NPTS2D,NMP)
TE_TI_k  =fltarr(3,NPTS2D,NMP)
VEXB=fltarr(NMP,NLP,3) ;before2011-11-16.v18 only meridional transport version
;after 2011-11-16.v18: VEXB=fltarr(2,NPTS2D,NMP) ;zonal transport version
;NHEAT_mks=dblarr(      NPTS2D,NMP)
;hrate_mks=dblarr(    6,NPTS2D,NMP)

if ( sw_dif eq 1 ) then begin
   XIONN_m3q =fltarr(3,NPTS2D,NMP) ;fltarr(ISPEC,NPTS2D,NMP)
   XIONV_ms1q=fltarr(1,NPTS2D,NMP) ;fltarr(ISPEV,NPTS2D,NMP)
   TE_TI_kq  =fltarr(3,NPTS2D,NMP)
   VEXBq=fltarr(NMP,NLP)
endif

n_read_max2=n_read_max
if ( plot_type eq 2 ) then begin
;  n_read_max2 = (133106-61106)/300 +1 ;=289
  plot_zz = fltarr(n_read_max2,NLP*2L)
  plot_xx = fltarr(n_read_max2,NLP*2L)
  plot_yy = fltarr(n_read_max2,NLP*2L)
endif

z_km =fltarr(NPTS2D) ;,NMP)
mlat_deg  =fltarr(NPTS2D) ;,NMP) ;GL_rad
JMIN_IN=lonarr(NLP)
JMAX_IS=lonarr(NLP)
glon_deg=fltarr(NPTS2D,NMP)
glat_deg=fltarr(NPTS2D,NMP)
;glon=[ $
;  288.3167, 288.3167, 288.3167, 299.8955, 288.3167 $ ;0-4
;, 288.3167, 288.3167, 318.7912, 288.3167, 288.3167 $ ;5-9
;, 288.3167, 288.3167, 288.3167, 288.3167, 288.3167 $ ;10-14
;, 288.3167, 288.3167, 288.3167,   7.1758,  11.7843 $ ;15-19
;,  11.7843,  11.7843,  11.7843,  11.7843,  11.7843 $ ;20-24
;,  11.7843,  11.7843,  11.7843,  11.7843,  11.7843 $ ;25-29
;,  11.7843,  11.7843,  11.7843,  11.7843,  11.7843 $ ;30-34
;,  11.7843,  11.7843,  11.7843,  11.7843, 103.8842 $ ;35-39
;, 103.8842, 103.8842, 103.8842, 103.8842, 103.8842 $ ;40-44
;, 103.8842, 103.8842, 103.8842, 103.8842, 103.8842 $ ;45-49
;, 103.8842, 103.8842, 103.8842, 103.8842, 103.8842 $ ;50-54
;, 103.8842, 103.8842, 103.8842, 103.8842, 194.2077 $ ;55-59
;, 194.2077, 194.2077, 194.2077, 194.2077, 194.2077 $ ;60-64
;, 194.2077, 194.2077, 194.2077, 194.2077, 194.2077 $ ;65-69
;, 194.2077, 194.2077, 194.2077, 194.2077, 194.2077 $ ;70-74
;, 194.2077, 194.2077, 194.2077, 194.2077, 283.8234 ] ;75-79


if ( sw_save eq 2 ) then begin
  sw_save_old=sw_save
  plot_type_old=plot_type
sw_output2file_old=sw_output2file
  restore, filename=filename_sav
  print,'restoring the file=',filename_sav
  sw_save=sw_save_old
  plot_type=plot_type_old
sw_output2file=sw_output2file_old
endif

;opening files
if ( sw_save le 1 ) then $
open_file,  input_DIR, LUN,version,input_flnm $
,sw_3DJ,sw_hr, sw_lun,title_res $
,sw_debug

if ( sw_dif eq 1 ) then $
   open_file,  input_DIRq, LUNq,version,input_flnmq $
,sw_3DJ,sw_hr, sw_lun,title_res $
,sw_debug

;need to debug when sw_save=2 
for ht_plot=340., 340., htstep  do begin
for VarType=1, 1  do begin

if ( sw_save eq 2 ) then begin
plot_zz[*,*]=0.0
plot_yy[*,*]=0.0
plot_xx[*,*]=0.0
endif


if ( plot_type eq 6 ) then begin
  NX=19L
  NY=121L
  TEC3d =fltarr(n_read_max,nx,nmp)
  glat3d=fltarr(n_read_max,nx,nmp)
  glon3d=fltarr(n_read_max,nx,nmp)
endif ;( plot_type eq 6 ) then begin

ncount=-1L
n_read=-1L
;n_plt=-1L
;if ( sw_save lt 2 ) then $
;  check_value=EOF(LUN[1]) $
;else if ( sw_save eq 2 ) then $
;  check_value=n_read-n_read_max2

  ;while ( check_value le 0 ) do begin
  while ( n_read lt n_read_max-1 ) do begin
  n_read = n_read+1
  if ( sw_debug eq 1 ) then $
 print,'n_read=',n_read,n_read_max2


;nm20141008
  mp_plot=0;mppl[n_read];56L; longitude sector to plot
mpstart=mp_plot
mpstop=mpstart
mpstep=1
print,'n_read', n_read,' mp_plot=',mp_plot,mpstart,mpstop,mpstep


  if ( sw_save le 1 ) then begin

  if ( n_read eq 0 ) then  read_grid,LUN,JMIN_IN,JMAX_IS,Z_km,mlat_deg,sw_debug,glat_deg,glon_deg,title_res
  read_plasma_bin,LUN,UT_hr,XIONN_m3,XIONV_ms1,TE_TI_k,VEXB,sw_debug $
,sw_3DJ,je_3d,sw_hr,hrate, sw_dif, sw_lun $
,NMP
  UT_hr_save[n_read]=UT_hr

;d print,'call read_wind: JMIN_IN',JMIN_IN
  if ( sw_read_wind eq 1 ) then $
     read_wind, UT_hr $
                ,Vn_ms1 $       ;input to IPE
;,Un_ms1 $ ;output to IPE
                , luntmp7, luntmp3 $
                , MaxFluxTube, nlp, nmp, JMIN_IN,JMAX_IS ,sw_debug





;print, n_read,'ut_hr_save[n_read]', ut_hr_save[n_read]
;dbg20130519
;mpd=27-1
;lpd=10-1
;for ipts=9991, 10006  do begin
;print, mlat_deg[ipts],z_km[ipts], JMIN_IN[lpd],JMAX_IS[lpd],glat_deg[ipts,mpd],glon_deg[ipts,mpd]
;endfor
;STOP


  if ( sw_dif eq 1 ) then  begin
     read_plasma_bin,LUNq,UT_hrq,XIONN_m3q,XIONV_ms1q,TE_TI_kq,VEXBq,sw_debug $
,sw_3DJ,je_3d,sw_hr,hrate, sw_dif, sw_lun



if ( sw_dif eq 1 ) and ( UT_hr ne UT_hrq ) then begin
print,'!STOP INVALID UT! UThr', UT_hr,' UTq', UT_hrq
stop
endif

IF ( UT_hr lt plot_UT/3600. ) THEN CONTINUE


  endif
  
endif ;( sw_save eq 1 ) then begin

if ( plot_type eq 0 ) or ( plot_type eq 2 ) or ( plot_type eq 4 )  then begin
   ipts=0L
   if ( sw_save le 1 ) then begin


    for mp=mpstart,mpstop do begin ;NMP-1 do begin
;for mp=72,78 do begin ;NMP-1 do begin

;0: Ne electron density[m-3]
      k=0L
      if ( sw_lun[2] eq 1 ) then begin
        for ipts=0L,NPTS2D-1L do begin 
          for jth=0,ISPEC-1L do begin
            plot_z[n_read,k,0,ipts] = plot_z[n_read,k,0,ipts] + XIONN_m3[jth,ipts,mp] 
          endfor;jth
        endfor ;ipts
      endif

;1 Te electron temperature
      jth=3-1
      k=1L
      if ( sw_lun[3] eq 1 ) then $
        for ipts=0L,NPTS2D-1L do  plot_z[n_read,k,0,ipts] = TE_TI_k[jth,ipts,mp]
    

;2 TO+ ion temperature; dbg20140815 vo+
      jth=1-1
      k=2L                    
      if ( sw_lun[4] eq 1 ) then $
        for ipts=0L,NPTS2D-1L do  $
 plot_z[n_read,k,0,ipts] = TE_TI_k[jth,ipts,mp] 
;plot_z[n_read,k,0,ipts] = XIONV_ms1[0,ipts,mp] ;dbg20140815 vo+


;3-11  ion densities 
;for k=3,3+8 do begin
if ( sw_lun[2] eq 1 ) then begin
;  for k=3,11 do begin
for k=3,3 do begin  ;dbg20140815
    jth=k-3
;t      for ipts=0L,NPTS2D-1L do $ 
;t       plot_z[n_read,k,0,ipts] = XIONN_m3[jth,ipts,mp] 
   endfor                       ;k
endif ;( sw_lun[2] eq 1 ) then begin
;tmp20140130 temporary assign Vn_ms1 (field aligned wind) to k=5
; Vn_ms1=fltarr(3,NPTS2D,NMP)
if ( sw_read_wind eq 1 ) then begin
k=4L
jth=2-1
      for ipts=0L,NPTS2D-1L do $ 
;need to convert north-->southward as vo+ is positive southwrd
       plot_z[n_read,k,0,ipts] = (-1.)*Vn_ms1[jth,ipts,mp] 
endif ;( sw_read_wind eq 1 ) then begin
;tmp20121128 temporary o+ is assigned to 6(n+) instead of 3 for faster debug molecular ions
;      for ipts=0L,NPTS2D-1L do $ 
;       plot_z[n_read,6,mp,ipts] = XIONN_m3[0,ipts,mp] 

;12:O+,velocity [m s-1]
k=12
;      for ipts=0L,NPTS2D-1L do $ 
;        plot_z[n_read,k,mp,ipts] = XIONV_ms1[1-1,ipts,mp]

;6:O+, flux [m-2 s-1]
;    for jth=0,0 do begin
;      plot_z[n_read,jth+6,mp,0:NPTS2D-1] = XIONN_m3[jth,0:NPTS2D-1,mp] * XIONV_ms1[jth,0:NPTS2D-1,mp]
;  endfor


;neutral heating rate eV/kg/s
if ( sw_hr eq 1 ) then begin 
  for jth=1,7 do begin
    plot_z[n_read,jth+1,mp,0:NPTS2D-1] = hrate[jth-1,0:NPTS2D-1,mp]
  endfor
endif
;    plot_z[5,   mp,0:NPTS2D-1] = NHEAT_mks[    0:NPTS2D-1,mp]
;    plot_z[6:11,mp,0:NPTS2D-1] = hrate_mks[0:5,0:NPTS2D-1,mp]

  if ( plot_type eq 0 ) then begin
        for lp=0,NLP-1 do begin
          midpoint = JMIN_IN(lp) + ( JMAX_IS(lp) - JMIN_IN(lp) )/2 -1
          plot_VEXB[n_read,mp,lp] = VEXB[mp,lp,2]           ;before 2011-11-16.v18:          
;after 2011-11-16.v18:          plot_VEXB[n_read,mp,lp] = VEXB[1,midpoint,mp]           
        endfor
  endif ;( plot_type eq 0 ) then begin

      endfor ;mp=0,NMP-1 do begin
  endif ;( sw_save eq 1 ) then begin

    if ( plot_type eq 2 ) then begin 
; LT-LAT plot
;dbg
;print,plot_type,'n_read',n_read
     ctr_LT_LAT $
  , mp_plot  $ 
  , JMIN_IN,JMAX_IS,Z_km,mlat_deg  $ 
  , plot_z   $
  , UT_hr_save, LT_hr, plot_DIR $
  , plot_zz,plot_xx,plot_yy,n_read $
  , VarType $
,ht_plot,sw_output2file $
,glon_deg,glat_deg,sw_frame $
, plot_UT
  endif ;plot_type eq 0


; lon-lat plot
    endif else if ( plot_type eq 3 ) then begin 


;20130523 houly plot

;print, ut_hr
;print, sw_hourly_plot
;print, (UT_hr MOD plotXhr)




IF ( UT_hr lt plot_UT/3600. ) THEN CONTINUE
;    fut_hr=FIX(UT_hr)*1.0000
;    difut=UT_hr-fut_hr
;print,'fut_hr',fut_hr,' difut',difut,' difutmin',difutmin
;    if ( sw_hourly_plot eq 1 ) AND ( difut gt difutmin ) THEN CONTINUE
;20140117; plot every X hour
if  (sw_hourly_plot eq 1) AND ( (UT_hr MOD plotXhr) ge 0.25 ) then continue
;     ht_plot = 110.00 ;[km]

rundir='ipe_'+TEST2+'_'+TEST1;'ipe_80_24695'
;n_plt = n_plt + 1
;dbg20140901: NOTE! n_plt does not work for plot_z[n_read,,,,]!!!
if ( sw_quickplot eq 0 ) then $
       ctr_lon_lat $
  , JMIN_IN,JMAX_IS,Z_km,mlat_deg  $ 
;  , je_3d   $
  , XIONN_m3, TE_TI_k $
  , XIONV_ms1 $
  , UT_hr, plot_DIR $
  , n_read $
  , sw_output2file $
  ,glon_deg,glat_deg,sw_frame,fac_window, TEST $
  , sw_debug $
;20131209: output to ascii file
, sw_output2file_ascii,luntmp,ncount $
, Vn_ms1,VEXB, sunlons1 $
, alt,rundir $
else if ( sw_quickplot eq 1 ) then $
       ctr_lon_lat_quick $
  , JMIN_IN,JMAX_IS,Z_km,mlat_deg  $ 
;  , je_3d   $
  , XIONN_m3, TE_TI_k $
  , XIONV_ms1 $
  , UT_hr, plot_DIR $
  , n_read $
  , sw_output2file $
  ,glon_deg,glat_deg,sw_frame,fac_window, TEST $
  , sw_debug $
;20131209: output to ascii file
, sw_output2file_ascii,luntmp,luntmp1,ncount $
, Vn_ms1 $
, n_read_max,input_DIR0 $
, alt,rundir $
, VarType_max, VarType_min, VarType_step

    endif else if ( plot_type eq 6 ) then begin 

;IF ( UT_hr lt plot_UT/3600. ) THEN CONTINUE


for mp=0,nmp-1 do begin
print,'plot_type=',plot_type,' mp=',mp

;interpolate Ne from 
ipdim=1115L
elden=fltarr(3,NPTS2D)
for i=1-1,NPTS2D-1 do begin
  for jth=0,ISPEC-1 do  elden[0,i]=elden[0,i]+XIONN_m3[jth,i,mp] 
  elden[1,i]=glat_deg[i,mp] 
  elden[2,i]=glon_deg[i,mp] 
endfor

;loadct,39
;xloadct
;stop
fxht_var=fltarr(3,nx,ny)
intrp2fixht $
,jmin_in,jmax_is,z_km $
,ut_hr $ 
,elden $
,ipdim,nlp,mlat_deg $
,fxht_var,fxht_x,fxht_y
;xloadct
;STOP
;calculate tec
TEC2d=fltarr(nx)
cal_tec $
,fxht_var,fxht_x,fxht_y $
,tec2d
;xloadct
tec3d[ n_read,0:nx-1,mp]=   tec2d[  0:nx-1]
print,'glat3d MIN=',MIN(fxht_var[1,0:nx-1,0]),'MAX',MAX(fxht_var[1,0:nx-1,0])
glat3d[n_read,0:nx-1,mp]=fxht_var[1,0:nx-1,0]
glon3d[n_read,0:nx-1,mp]=fxht_var[2,0:nx-1,0]
print,mp, MIN(tec2d[0:nx-1]), MAX(tec2d[0:nx-1])

;loadct,39
;lclr=(255/nmp) * mp
;print,'lclr',lclr
;if ( mp eq 0 ) then $
;  plot,  fxht_x,tec2d $
;,yrange=[ 12.,+15.], ystyle=1 $
;,xrange=[-60.,+60.], xstyle=1 $
;,color=lclr $
;else $ ;if ( mp eq 0 ) then $
;  oplot,  fxht_x,tec2d $
;,color=lclr ;$
;plt_tec, tec3d, fxht_x; , mlon???

endfor ;mp=0,nmp-1 do begin

    endif; plot_type eq 0

;dbg  endif ;( sw_save eq 1 ) then begin



;20130529: WHY these IF statements are not working!!!
;IF ( UT_hr lt plot_UT/3600. ) THEN CONTINUE
IF ( UT_hr gt plot_UT_end/3600. ) THEN BREAK
IF ( UT_hr ge plot_UT/3600. ) THEN BEGIN 

;
;



;
;if ( sw_debug eq 1 ) then  
;print, 'after plotting',UT_hr , plot_UT/3600. ;why this print sentence does not work???


;IF ( ( (UT_hr-UT_hr_save[0]) MOD freq_plot_hr ) LT 0.24 ) THEN BEGIN  ;20120223! need debug! does not work!!!


;glon_deg=fltarr(NPTS2D,NMP)
;jicamarca

if ( title_res eq 'low') OR ( title_res eq 'low20120709' ) OR ( title_res eq 'td20120709' )  then $
  lp=129L $;low
else if title_res eq '2xdyn' then $
  lp=70L $;2xdyn
else if title_res eq 'dyn' then $
  lp=34L ;dyn

midpoint= JMIN_IN[lp] + ( JMAX_IS[lp] - JMIN_IN[lp] ) /2

lt_hr2D=fltarr(NMP)
glon_deg2D=fltarr(NMP)
for mp=0,NMP-1 do begin
  lt_hr2D[mp]=UT_hr + glon_deg[midpoint,mp]/15.
  if ( lt_hr2D[mp] ge 24. ) then lt_hr2D[mp]=lt_hr2D[mp] MOD 24.
  glon_deg2D[mp]=glon_deg[midpoint,mp]
endfor

  if ( plot_type eq 0 ) then begin 
     if ( sw_debug eq 1 ) then     print, 'plotting contour: UT=',ut_hr



;dbg
if( sw_debug eq 1 ) then  print,'plot_type',plot_type

;20130523 houly plot
;tmp20140217 IF ( UT_hr lt plot_UT/3600. ) THEN CONTINUE
;IF ( UT_hr gt plot_UT_end/3600. ) THEN BREAK
;fut_hr=FIX(UT_hr)*1.0000
;difut=UT_hr-fut_hr
;print,'plot_type',plot_type,fut_hr,difut
;if( difut gt 0.24999 ) THEN CONTINUE
if  (sw_hourly_plot eq 1) AND ( (UT_hr MOD plotXhr) ge 0.25 ) then continue

print, ut_hr, plotxhr, (UT_hr MOD plotXhr) , n_read
;20140130 every 2 hours starting at 1UT
;tmp20140217 ut_hr1=ut_hr MOD 24.
;tmp20140217 if ( (ut_hr1 MOD 2.) ne 1. ) then continue

;dbg20140121: n_plt does not work!
;n_plt = n_plt+1
if ( sw_quickplot eq 0 ) then $
;tmp20141006     contour_plot_2d    $ 
     ctr_lat_ht_tec    $  ;tmp20141006
  , JMIN_IN,JMAX_IS,Z_km,mlat_deg  $ 
  , plot_z,plot_VEXB,n_read   $
  , UT_hr, plot_DIR, title_res $
;,rundate,title_test $
,sw_debug, title_hemi,sw_anim,mpstart,mpstop,mpstep, lt_hr2D, glon_deg2D, fac_window $
  , sw_output2file, TEST, TEST2,TEST1 $
,VarType_min $
,VarType_max $
,VarType_step $
,luntmp $
;, input_DIR0,TEST,  TEST1, TEST2 $
else if ( sw_quickplot eq 1 ) then begin;$
rundir = 'ipe_'+TEST2+'_'+TEST1
print,'rundir',rundir
     ctr_lat_ht_quick    $ 
  , JMIN_IN,JMAX_IS,Z_km,mlat_deg  $ 
  , plot_z,plot_VEXB,n_read   $
  , UT_hr, plot_DIR, title_res $
;,rundate,title_test $
,sw_debug, title_hemi,sw_anim,mpstart,mpstop,mpstep, lt_hr2D, fac_window $
  , sw_output2file $
,VarType_min $
,VarType_max $
,VarType_step $
,n_read_max $
, input_DIR0,TEST,  TEST1, TEST2, glon_deg2D, rundir ;$
endif






  endif else if ( plot_type eq 1 ) then begin 
    print, 'plotting ht profile: UT=',ut_hr

plot_type_prof=0L ;0:densities; 1:temperatures
title_hemi='NH'
n_file_plot =1L
ut_hr_plot = fltarr(n_file_plot)
ut_hr_plot[0:n_file_plot-1] = UT_hr
lt_hr_plot = fltarr(n_file_plot)
 FLDIM_max = FLDIM  ;for mlat_title='38' lp=41
if ( sw_debug eq 1 ) then  print, 'FLDIM_max', FLDIM_max,'n_file_plot',n_file_plot
 plot_y = fltarr(  FLDIM_max,n_file_plot)
plot_type_max=4L
k_species = 4L
plot_x = fltarr(plot_type_max, k_species,FLDIM_max,n_file_plot)


;dbg
;d print,'n_file_plot',n_file_plot
;d print,'size(plot_x)',size(plot_x)
;d print,'size(plot_y)',size(plot_y)

     plot_x[*,*,*,*] =-999999999.999999
 FLDIM_plot=LONARR(n_file_plot)
for   mp_plot0=mp_plot,mp_plot,1  do begin
  lp_plot0= 58-1L

for i_file = 0,n_file_plot-1 do begin

if (i_file eq 0 ) then begin
  lp_plot=lp_plot0
;d  mp_plot=mp_plot0
endif else if (i_file eq 1 ) then begin
  lp_plot=136-1 ;lp_plot0-1L
;d  mp_plot=mp_plot0
endif else if (i_file eq 2 ) then begin
  lp_plot=lp_plot0+0L
;d  mp_plot=mp_plot0
endif else if (i_file eq 3 ) then begin
  lp_plot=lp_plot0+1L
;d  mp_plot=mp_plot0
endif else if (i_file eq 4 ) then begin
  lp_plot=lp_plot0+2L
;d  mp_plot=mp_plot0
endif

;  if (i_file eq 0 ) then $
;    lp_plot=10-1L $  ;idl conversion
;  else if (i_file eq 1 ) then $
;    lp_plot=11-1L $   ;idl conversion
;  else if (i_file eq 2 ) then $
;    lp_plot=12-1L $   ;idl conversion
;  else if (i_file eq 3 ) then $
;    lp_plot=9-1L   

print,'i_file',i_file,'lp_plot',lp_plot,'mp_plot0',mp_plot0

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



  in=JMIN_IN[LP_plot]-1  ;idl conversion
  is=JMAX_IS[LP_plot]-1  ;idl conversion
  FLDIM_plot[i_file] = is-in+1L
  midpoint = JMIN_IN(lp_plot) + ( JMAX_IS(lp_plot) - JMIN_IN(lp_plot) )/2 -1
;  lt_hr_plot[i_file] = LT_hr ;[mp_plot,lp_plot]
  lt_hr_plot[i_file] = ut_hr + glon_deg[midpoint,mp_plot]/15.

print,'FLDIM=',FLDIM_plot[i_file],in,is,' mlat[deg]',mlat_deg[in]
mlat_title=STRTRIM( string(mlat_deg[in], FORMAT='(f8.3)'), 1)

factor=1.0E-11
  if( sw_dif eq 0 ) then begin  
     i_window=0L
;     plot_x[i_window,0,0:FLDIM_plot[i_file]-1,i_file] =$
;1.
;TOTAL ( XIONN_m3[*,in:is,MP_plot],1 )* factor ;Ne
;   ALOG10 ( XIONN_m3[1-1,in:is,MP_plot] * 1.0E-6 ) ;[o+]m-3 --> cm-3
;XIONN_m3[1-1,in:is,MP_plot] * factor ;[o+]m-3 X10^11
;     plot_x[i_window,1,0:FLDIM_plot[i_file]-1,i_file] =$
;2.
;TOTAL ( XIONN_m3[*,in:is,MP_plot],1 )* factor ;Ne
;   ALOG10 ( XIONN_m3[2-1,in:is,MP_plot] * 1.0E-6 ) ;[h+]
;t XIONN_m3[2-1,in:is,MP_plot] * factor ;[h+]
;     plot_x[i_window,2,0:FLDIM_plot[i_file]-1,i_file] =$
;   ALOG10 ( XIONN_m3[3-1,in:is,MP_plot] * 1.0E-6 ) ;[he+]
;XIONN_m3[3-1,in:is,MP_plot] * factor ;[he+]
;     plot_x[i_window,3,0:FLDIM_plot[i_file]-1,i_file] =$
;   ALOG10 ( XIONN_m3[4-1,in:is,MP_plot] * 1.0E-6 ) ;[N+]
; XIONN_m3[4-1,in:is,MP_plot] * factor ;[N+]
     plot_x[i_window,0,0:FLDIM_plot[i_file]-1,i_file] =$
; ALOG10 ( XIONN_m3[1-1,in:is,MP_plot] * 1.0E-6 ) ;STORM [o+]m-3 -->
; cm-3
ALOG10 ( XIONN_m3[1-1,in:is,MP_plot] * 1.0E-6 ) ;[o+]m-3 --> cm-3
     plot_x[i_window,1,0:FLDIM_plot[i_file]-1,i_file] =$
ALOG10 ( XIONN_m3[2-1,in:is,MP_plot] * 1.0E-6 ) ;[h+]
     plot_x[i_window,2,0:FLDIM_plot[i_file]-1,i_file] =$
ALOG10 ( XIONN_m3[3-1,in:is,MP_plot] * 1.0E-6 ) ;[he+]

print, 'check He+', XIONN_m3[3-1,in:is,MP_plot]

     plot_x[i_window,3,0:FLDIM_plot[i_file]-1,i_file] =$
ALOG10 ( TOTAL( XIONN_m3[*,in:is,MP_plot],1) * 1.0E-6 ) ;[Ne]
     i_window=1L
     plot_x[i_window,0,0:FLDIM_plot[i_file]-1,i_file] =   TE_TI_k[1-1,in:is,MP_plot] ;STORM Ti
     plot_x[i_window,1,0:FLDIM_plot[i_file]-1,i_file] =   TE_TI_k[1-1,in:is,MP_plot] ;QUIET Ti
     plot_x[i_window,2,0:FLDIM_plot[i_file]-1,i_file] =   TE_TI_k[3-1,in:is,MP_plot] ;STORM Te
     plot_x[i_window,3,0:FLDIM_plot[i_file]-1,i_file] =   TE_TI_k[3-1,in:is,MP_plot] ;QUIET Te
  endif 

  plot_y[    0:FLDIM_plot[i_file]-1,i_file] =                  Z_km[  in:is]
;endif
endfor                     ;i_file = 0,n_file_plot-1 do begin

sw_fort=168L
;20120305:     profile_ht_3d $
     prfl_ht $
,plot_x,plot_y, title_hemi,mlat_title,ut_hr_plot,lt_hr_plot $
;,plot_type_prof
,plot_DIR,FLDIM_plot,mp_plot0,sw_debug,sw_fort $
,sw_dif,sw_output2file,n_file_plot,fac_window,TEST
endfor   ;mp_plot0=1-1,nmp-1,10  do begin     

  endif ;else if ( plot_type eq 1 ) then begin 
;BREAK ;exit from while loop

  if ( UT_hr ge plot_UT_end/3600. ) and ( plot_type eq 4 ) then begin

;20120322UNDERCONSTRUCTION!!!
    plt_refil, mlat_deg, JMIN_IN,JMAX_IS, plot_z,mp_plot,n_read_max,ut_hr_save,fac_window, plot_UT,plot_UT_end, TEST

  endif ;( plot_type eq 4 ) then 

endif ;( UT_hr eq plot_UT ) then begin
endwhile                            ; ( EOF(LUN[0]) ne 0 ) then begin
endfor ;VarType=1,7 do begin
endfor ;ht_plot=200.00,400.00, 100.00  do begin

if ( sw_save eq 1 ) then  begin
  print,'saving to a file=',filename_sav
  save, filename=filename_sav
  print,'saving finished'
endif

if ( sw_save le 1 ) then begin 
  for i = 0, n_file-1  do   if ( sw_lun[i] eq 1 ) then   FREE_LUN, LUN[i]
  if ( sw_dif eq 1 ) then $
    for i = 0, n_file-1  do   if ( sw_lun[i] eq 1 ) then   FREE_LUN, LUNq[i]
endif

;tif ( sw_output2file_ascii eq 1 ) then begin
  FREE_LUN, luntmp ;openw,luntmp,flnmtmp, /GET_LUN
;t  print, 'ncount', ncount
;t endif

print,'plt_ipe_tec: finished successfully!'
end ;pro plt_ipe_tec
