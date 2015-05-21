;20130724 copied from plt_ipe.pro, created to save idl.sav for faster plotting/debugging
pro sav_ipe
TEST=$
'sarah'
;'r292.1'
TEST1='20090121';
TEST2='640';S';640';
n_read_max=(102-6+1) ;86400*2/output_freq +1L
;HOME_DIR=$
;'/home/Naomi.Maruyama/wamsv/tmp20120723ipe/run/' ;zeus
input_DIR0=$
;'/home/Naomi.Maruyama/wamns/'+TEST+'/ipe/trunk/run/ipe_'+TEST2+'_'+TEST1+'/'
'/scratch2/portfolios/BMC/idea/Sarah.Millholland/IPE_runs/r292.3/trunk/run/ipe_640_14080/'
filename_sav='ipe_640_14080.sav'
title_res='low20120709';2xdyn';low';low20120709';low';dyn';'low' ; 'high'

sw_debug=1L
sw_dif=0L
sw_3DJ=0L
sw_hr=0L
n_file=15L;6L;13L;
input_flnm=['','','','','','' $
,'','','','' $
,'','','','',''] ;,'','']
input_DIR =input_flnm
input_DIR[*]=input_DIR0
input_DIR[1]=$
'/home/Naomi.Maruyama/ipe/trunk/plt/' ;zeus
LUN  = INTARR(n_file)
sw_LUN  = INTARR(n_file)
sw_lun[0:1]=1
sw_lun[2]=1 ;o+
sw_lun[3]=1 ;Te
sw_lun[4]=0 ;vo+
sw_lun[5]=0 ;vexb
sw_lun[6]=1 ;h+
sw_lun[7]=1 ;ti
sw_lun[8]=1 ;he+
sw_lun[9]=1 ;n+
sw_lun[10]=1 ;no+
sw_lun[11]=1 ;o2+
sw_lun[12]=1 ;n2+
sw_lun[13]=1 ;o+(2D)
sw_lun[14]=1 ;o+(2P)

if title_res eq 'low' then begin
  NLP=170L;low res
  NPTS2D=44438L ;low res
endif else if title_res eq 'low20120709' then begin
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

NMP=80L;1L ;80L
ISPEC=9L
ISPEV=4L
FLDIM = 1115L



UT_hr = 0.00D0
UT_hr_save = fltarr(n_read_max)
NPAR = 9L
npts2d1=23964L
data_save=fltarr(NPAR,nmp,npts2d1,n_read_max)
NPAR1=2L
grid2d_save=fltarr(NPAR1,    npts2d1)
grid3d_save=fltarr(NPAR1,nmp,npts2d1)
XIONN_m3   = fltarr(ISPEC,NPTS2D,NMP)
XIONV_ms1  = fltarr(1,NPTS2D,NMP) ;fltarr(ISPEV,NPTS2D,NMP)
TE_TI_k    = fltarr(3,NPTS2D,NMP)
z_km       = fltarr(NPTS2D) ;,NMP)
mlat_deg   = fltarr(NPTS2D) ;,NMP) ;GL_rad
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
itop=lonarr(2,nlp)
itop[*,*]=-999 ;those equatorial flux tubes below z_km_max will have these initial values...

;opening files
open_file,  input_DIR, LUN,version,input_flnm $
,sw_3DJ,sw_hr, sw_lun,title_res $
,sw_debug

n_read=-1L

  while ( n_read lt n_read_max-1 ) do begin
  n_read = n_read+1
  if ( sw_debug eq 1 ) then $
 print,'n_read=',n_read,n_read_max


  if ( n_read eq 0 ) then  read_grid,LUN,JMIN_IN,JMAX_IS,z_km,mlat_deg,sw_debug,glat_deg,glon_deg,title_res
  read_plasma_bin,LUN,UT_hr,XIONN_m3,XIONV_ms1,TE_TI_k,VEXB,sw_debug $
,sw_3DJ,je_3d,sw_hr,hrate, sw_dif, sw_lun $
,NMP

  UT_hr_save[n_read]=UT_hr

z_km_max=902.0001;km ;note! 902 did not work!!!
for mp=0,NMP-1 do begin
   ipts1 = -1L
   for lp = 0,NLP-1  do begin
      for ipts = JMIN_IN[lp]-1, JMAX_IS[lp]-1  do begin;IDL convension
         if ( z_km[ipts] le z_km_max ) then begin
            ipts1 = ipts1 + 1 

            tmp = 0.0D0
            for jth=0,ISPEC-1L do  tmp = tmp + XIONN_m3[jth,ipts,mp]
;0: Ne electron density[m-3]
            data_save[0,mp,ipts1,n_read] = tmp

;1 Te
            data_save[1,mp,ipts1,n_read] = TE_TI_k[3-1,ipts,mp]

;2 TO+ 
            data_save[2,mp,ipts1,n_read] = TE_TI_k[1-1,ipts,mp]

;3-11  ion densities 
            for k=3,(NPAR-1) do $
               data_save[k,mp,ipts1,n_read] = XIONN_m3[k-3,ipts,mp]

;grid
            if (n_read eq 0 ) then begin
               if ( mp eq 0 ) then begin
                  grid2d_save[0,   ipts1] = z_km[ipts]
                  grid2d_save[1,   ipts1] = mlat_deg[ipts]
               endif         
               grid3d_save[0,mp,ipts1] = glon_deg[ipts,mp]
               grid3d_save[1,mp,ipts1] = glat_deg[ipts,mp]


;dbg
;print, mp,lp,ipts,ipts1,z_km[ipts],z_km_max, ABS(z_km[ipts]-z_km_max)

               if ( mp eq 0 ) then begin
                 if (  ABS(z_km[ipts]-z_km_max) lt 0.00100 ) then begin

;dbg
print,lp,'check z_km_max: ipts=',ipts,ipts1, z_km[ipts], z_km_max, ABS(z_km[ipts]-z_km_max)
;0NH
                  if ( mlat_deg[ipts] gt 0. ) then k=0 $
;1SH
                  else k=1  ;if ( mlat_deg[ipts] le 0. ) then
                  itop[k,lp] = ipts

                 endif            ;( z_km[ipts] eq z_km_max ) then begin
              endif  ;m==0
            endif               ;(n_read eq 0 ) then begin          




         endif                  ;( z_km[ipts] le z_km_max ) then begin 
      endfor                    ;ipts
print,lp,mp,'ipts1=',ipts1
  endfor                          ;lp = 0,NLP-1  do begin
endfor                          ;mp=0,NMP-1 do begin

endwhile ;( n_read lt n_read_max-1 ) do begin


  for i = 0, n_file-1  do   if ( sw_lun[i] eq 1 ) then   FREE_LUN, LUN[i]

print,'sav_ipe: finished successfluly!'

SAV_DIR='/home/Naomi.Maruyama/wamns/'
  print,'saving to a file=';,filename_sav
  save, FILENAME = SAV_DIR+'ts_sav0.sav', grid2d_save,grid3d_save $
, JMIN_IN, JMAX_IS, itop $
, UT_hr_save, data_save
  print,'saving finished 0'
;  save, FILENAME = SAV_DIR+'ts_sav1.sav', grid2d_save;,grid3d_save,itop
;  print,'saving finished 1'
;  save, FILENAME = 'ts_sav1.sav', data_save
;  print,'saving finished 1'
;  save, FILENAME = 'ts_sav2.sav', grid2d_save,grid3d_save,itop


end ;pro sav_ipe
