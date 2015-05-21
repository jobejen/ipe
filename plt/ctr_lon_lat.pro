;20131219: hinotori: Vartype in ctr_lon_lat needs to be zero to be able to output Ne. output files are saved in ~/wamns/hinotori/. sw_plot_contour=0 to run faster by saving plotting time.
pro ctr_lon_lat $
,JMIN_IN,JMAX_IS,Z_km,mlat_deg $
;,je_3d $
, XIONN_m3, TE_TI_k $
, XIONV_ms1 $
,UT_hr, plot_DIR $
,n_read $
,sw_output2file $
,glon_deg,glat_deg,sw_frame $ ;=0 ;mag; 1geo
,fac_window ,TEST $
,sw_debug $
;20131209: output to ascii file
,sw_output2file_ascii,luntmp,ncount $
, Vn_ms1,VEXB,sunlons1 $
,ht_plot,rundir,LUN9001 $
,VarTypeMin,VarTypeMax, VarTypeStep,LUN2013




;read flux
if ( VarTypeMax eq 8 ) then begin
nlp1=40L
lmfl=fltarr(80,nlp1)
rd_fl, 80,nlp1,lmfl,sw_debug
endif 

print, 'ht_plot=', ht_plot

which_hem='NH';SH';

;1:exb; 2:phi the
sw_arrow=1
sw_read_sunlon=1
sw_polar_contour=1
sw_polar_contour_output=0

; X-axis range
;1:0<lon<360
;0:-180<lon<+180
xmax360=0
;note20131209: sw OFF only when sw_output2file_ascii=1 to run faster!!
sw_plot_contour=1
ltimemin=11.
ltimemax=15.
mlatmax=45.
factor=1.0E-11;1.0E-10 ;for density
; remember to modify zmin/max

;debug20140108
fac_wind=1.0;1.0E-2

X0=0.10
X1=0.90
Y0=0.10
Y1=0.79

for VarType=VarTypeMin,VarTypeMax, VarTypeStep do begin

print,'VarType=',VarType
;ht_plot =350.;[km]



sw_range=1L
nano=1.0E-9
unit=['[*10^-11 m-3]',' [K]',' [K]','[m-3]',$
'[m-3]',$
;'[m/s]',$  ;viup
;'[m/s]',$
'[X10^8 cm^2 s^-1 ]',$ ;o+ flux
'[X10^8 cm^2 s^-1 ]',$ ;h+ flux
;'[m/s]',$
;'[*10^-11 m-3]',$
'[log10 cm-3]',$ ;nmf2
;'[km]'] ;[nA/m2]'];[nA/m2]' ;20140108
'[X10^8 cm^2 s^-1 ]']

 sw_plot_grid=2 ;1:retangular, 2:polar
; get n_read_max, ny_max
size_result = SIZE(JMIN_IN)
if ( sw_debug eq 1 ) and ( n_read eq 0 ) then  print,'NLP',size_result
NLP = size_result[1]
ny_max =NLP*2
if  ( sw_debug eq 1 ) and ( n_read eq 0 ) then $
   print,'NLP',NLP,'ny_max',ny_max

size_result = SIZE(XIONN_m3) ;je_3d)
if  ( sw_debug eq 1 ) and ( n_read eq 0 ) then  print,'NMP',size_result
ISPEC=size_result[1]
NPTS2D=size_result[2]
NMP = size_result[3]
nx_max =size_result[3]    ;NMP=80
if  ( sw_debug eq 1 ) and ( n_read eq 0 ) then $
  print,'NMP=',NMP,' nx_max=',nx_max,' ISPEC=',ispec,' NPTS2D=',NPTS2D


mlon_deg_min=0. ;default
dmlon=4.50 ;deg
mlon_deg=findgen(NMP)*dmlon
for mp=0,nmp-1 do begin
  if ( mlon_deg[mp] lt mlon_deg_min ) then  mlon_deg[mp]=mlon_deg[mp]+360.
endfor

plot_zz=fltarr(nx_max,ny_max)
plot_yy=fltarr(nx_max,ny_max)
plot_xx=fltarr(nx_max,ny_max)
;nm20140701
if ( sw_arrow ge 1 ) then begin
   plot_u=fltarr(nx_max,ny_max)
   plot_v=fltarr(nx_max,ny_max)
endif

;VarTitle=['Ne','Te','Ti','o+','NO+','O2+','Vpar_o+','NmF2','HmF2']
VarTitle=['Ne','Te','Ti','o+',$
;'NO+',$
'Vi!DUP!N',$
;'UN',$
;'Vi!DE!N',$
;'VN',$
'o+ flux',$
'h+ flux',$
;'Vi!DEQ!N',$
'NmF2',$
'flux'] ;20140108
;'HmF2'] ;20140108
;VarTitle=['Ne','Te','Ti','N(NO+)','Vpar_o+']
;VarTitle=['Ne','Te','Ti','N(O2+)','Vpar_o+']
;VarTitle=['Ne','Te','Ti','N(N2+)','Vpar_o+']


for mp=0,NMP-1 do begin
for lp=0,NLP-1 do begin


  in = JMIN_IN[lp]-1L
  is = JMAX_IS[lp]-1L
  midpoint = IN + ( IS - IN )/2
;NH  
  nel = fltarr(NPTS2D)*0.0000
  istep=+1
  for i=in,midpoint, istep  do begin

   if ( VarType lt 7 ) then begin
    if ( z_km[i] le ht_plot ) AND ( z_km[i+istep] gt ht_plot ) then begin


      if ( VarType eq 0 ) then $ 
        for jth=0,ISPEC-1 do  plot_zz[mp,lp]=plot_zz[mp,lp]+XIONN_m3[jth,i,mp] * factor $
      else if ( VarType eq 1 ) then $
        plot_zz[mp,lp] = TE_TI_k[3-1,i,mp] $;[K] ;Te
      else if ( VarType eq 2 ) then $
        plot_zz[mp,lp] = TE_TI_k[1-1,i,mp] $;[K] ;Ti
      else if ( VarType eq 3 ) then $
        plot_zz[mp,lp] = XIONN_m3[1-1,i,mp]*factor  $ ;o+
      else if ( VarType eq 4 ) then $
        plot_zz[mp,lp] =$
VEXB[mp,lp,2] $;[m/s] ;UPward  ;20141104
; XIONN_m3[4,i,mp]*factor  $ ;no+
      else if ( VarType eq 5 ) then $
        plot_zz[mp,lp] =$
;VEXB[mp,lp,0] $;[m/s] ;eastward  ;20141104
;Vn_ms1[1-1,i,mp]*fac_wind $;[m/s] ;eastward  ;20140108
; XIONN_m3[5,i,mp]*factor  $ ;o2+
XIONN_m3[0,i,mp]*1.E-6 * XIONV_ms1[0,i,mp]*1.E+2 *1.E-8 $;o+ flux: o+ * V//o+[m/s]--> X10^8 cm^2 s^-1
      else if ( VarType eq 6 ) then $
        plot_zz[mp,lp] =$
;VEXB[mp,lp,1] ;[m/s] ;southward,equatorward  ;20141104
;Vn_ms1[2-1,i,mp]*fac_wind ;[m/s] ;northward ;20140108
XIONN_m3[1,i,mp]*1.E-6 * XIONV_ms1[1,i,mp]*1.E+2 *1.E-8 ;h+ flux: o+ * V//o+[m/s]--> X10^8 cm^2 s^-1
 
      if ( sw_frame eq 0 ) then begin ;magnetic
         plot_yy[mp,lp] = mlat_deg[i]


;if (mp eq 0) and (lp eq 46) then begin
;print,'check mlat', mlat_deg[i]
;STOP
;endif

         plot_xx[mp,lp] = mlon_deg[mp]
         if (xmax360 eq 0) AND (mlon_deg[mp] ge +180.) then plot_xx[mp,lp]=mlon_deg[mp]-360.
      endif else if ( sw_frame eq 1 ) then begin ;geographic
         plot_yy[mp,lp] = glat_deg[i,mp]
         plot_xx[mp,lp] = glon_deg[i,mp]
         if (xmax360 eq 0 ) AND (glon_deg[i,mp] ge +180.) then plot_xx[mp,lp]=glon_deg[i,mp]-360.
      endif ;( sw_frame eq 0 ) then begin ;magnetic
      BREAK ;exit from the i loop 
    endif                       ;( z_km[i] le ht_plot ) AND ( z_km[i+istep] gt ht_plot ) then begin

;20131209output to file
;20140808ipe 1st paper
       if ( sw_output2file_ascii eq 1 ) AND ( ABS( mlat_deg[i]) le mlatmax ) then begin
          ltime=UT_hr + glon_deg[i,mp]/15.
          if ( ltime ge 24. ) then ltime = ( ltime MOD 24. )
          if ( ltime ge ltimemin) AND ( ltime le ltimemax ) then begin
             ncount=ncount+1
             printf, luntmp, UT_hr, plot_zz[mp,lps], TE_TI_k[3-1,i,mp], TE_TI_k[1-1,i,mp],mlat_deg[i], glon_deg[i,mp], ltime 
          endif                 ;( ltime ge 11.) AND ( ltime le 15. ) then begin
       endif                    ;( sw_output2file_ascii eq 1 ) then 

;nm20130523: added nmf2/hmf2
  endif else begin  ;( VarType ge 7 ) then begin
     for jth=0,ISPEC-1 do  nel[i]=nel[i]+XIONN_m3[jth,i,mp]

     if ( i eq midpoint ) then begin
       result = MAX( nel,Max_Subscript ) ;find NmF2
;       print,'NH: NmF2', result,Max_Subscript, nel[Max_Subscript],Z_km[Max_Subscript],mp,lp
       if ( VarType eq 7 ) then $
         plot_zz[mp,lp] = $
; nel[Max_Subscript] * factor $ ;NmF2
 ALOG10(nel[Max_Subscript] * 1.0E-6 ) $ ;NmF2 m-3-->cm-3
       else if ( VarType eq 8 ) then $

if ( lp lt nlp1 ) then         plot_zz[mp,lp] = $
lmfl[mp,lp] ;limiting flux
;Z_km[Max_Subscript]    ;hmF2

       if ( sw_frame eq 0 ) then begin ;magnetic
          plot_yy[mp,lp] = mlat_deg[Max_Subscript]
          plot_xx[mp,lp] = mlon_deg[mp]
          if (xmax360 eq 0) AND (mlon_deg[mp] ge +180.) then plot_xx[mp,lp]=mlon_deg[mp]-360.
       endif else if ( sw_frame eq 1 ) then begin ;geographic
          plot_yy[mp,lp] = glat_deg[Max_Subscript,mp]
          plot_xx[mp,lp] = glon_deg[Max_Subscript,mp]
          if (xmax360 eq 0) AND (glon_deg[Max_Subscript,mp] ge +180.) then plot_xx[mp,lp]=glon_deg[Max_Subscript,mp]-360.
       endif ;( sw_frame eq 0 ) then begin ;magnetic
  
    endif;     if ( i eq midpoint ) then 
  endelse ;( VarType lt 7 ) then begin

;nm20140701 NH
if ( sw_arrow ge 1 ) then begin
   plot_u[mp,lp]=VEXB[mp,lp,0] ;+east
   plot_v[mp,lp]=VEXB[mp,lp,1] ;+southward, equatorward

if ( sw_debug eq 1 ) then  print,mp,lp,' NH U=',  plot_u[mp,lp],'V=',  plot_v[mp,lp]
endif



  endfor ;i=in,midpoint, istep  do begin

;SH  
  lps = NLP-1 + (NLP-1-lp)
  nel = fltarr(NPTS2D)*0.0000
  istep=-1 
  for i=is,midpoint, istep  do begin
   
    if ( VarType lt 7 ) then begin
      if ( z_km[i] le ht_plot ) AND ( z_km[i+istep] gt ht_plot )  then begin 


;       plot_zz[mp,lps] = XIONN_m3[VarType,i,mp] ;[m-3]  je_3d[VarType,i,mp]/nano
      if ( VarType eq 0 ) then $ 
        for jth=0,ISPEC-1 do  plot_zz[mp,lps]=plot_zz[mp,lps]+XIONN_m3[jth,i,mp]*factor $
      else if ( VarType eq 1 ) then $
        plot_zz[mp,lps] = TE_TI_k[3-1,i,mp] $;[K]
      else if ( VarType eq 2 ) then $
        plot_zz[mp,lps] = TE_TI_k[1-1,i,mp] $;[K]
      else if ( VarType eq 3 ) then $
        plot_zz[mp,lps] = XIONN_m3[1-1,i,mp]*factor $
      else if ( VarType eq 4 ) then $
        plot_zz[mp,lps] =$
VEXB[mp,lp,2] $;[m/s] ;UPward  ;20141104
; XIONN_m3[4,i,mp]*factor $
      else if ( VarType eq 5 ) then $
        plot_zz[mp,lps] =$
;VEXB[mp,lp,0] $;[m/s] ;eastward  ;20141104
;Vn_ms1[1-1,i,mp]*fac_wind $;[m/s] ;eastward  ;20140108
; XIONN_m3[5,i,mp]*factor $
XIONN_m3[0,i,mp]*1.E-6 * XIONV_ms1[0,i,mp]*1.E+2 *1.E-8 $ ;o+ flux: o+ * V//o+[m/s]--> X10^8 cm^2 s^-1
      else if ( VarType eq 6 ) then $
        plot_zz[mp,lps] = $
;VEXB[mp,lp,1]*(-1.) ;[m/s] ;converted to northward,equatorward  ;20141104
;Vn_ms1[2-1,i,mp]*fac_wind ;[m/s] ;northward ;20140108
XIONN_m3[1,i,mp]*1.E-6 * XIONV_ms1[1,i,mp]*1.E+2 *1.E-8 ;h+ flux: h+ * V//h+[m/s]--> X10^8 cm^2 s^-1

       if ( sw_frame eq 0 ) then begin ;magnetic
          plot_yy[mp,lps] = mlat_deg[i]
          plot_xx[mp,lps] = mlon_deg[mp]
          if (xmax360 eq 0) AND (mlon_deg[mp] ge +180.) then plot_xx[mp,lps]=mlon_deg[mp]-360.
       endif else if ( sw_frame eq 1 ) then begin ;geographic
          plot_yy[mp,lps] = glat_deg[i,mp]
          plot_xx[mp,lps] = glon_deg[i,mp]
          if (xmax360 eq 0) AND (glon_deg[i,mp] ge +180.) then plot_xx[mp,lps]=glon_deg[i,mp]-360.
       endif ;( sw_frame eq 0 ) then begin ;magnetic

;20131209output to file
       if ( sw_output2file_ascii eq 1 ) AND ( ABS( mlat_deg[i]) le mlatmax ) then begin
	  ltime=UT_hr + glon_deg[i,mp]/15.
          if ( ltime ge 24. ) then ltime = ( ltime MOD 24. )
          if ( ltime ge ltimemin) AND ( ltime le ltimemax ) then begin
	    ncount=ncount+1
	    printf, luntmp,UT_hr, plot_zz[mp,lps], TE_TI_k[3-1,i,mp], TE_TI_k[1-1,i,mp],mlat_deg[i], glon_deg[i,mp], ltime 
          endif ;( ltime ge 11.) AND ( ltime le 15. ) then begin
       endif ;( sw_output2file_ascii eq 1 ) then 


       BREAK; exit from the i loop
    endif; ( z_km[i] le ht_plot ) AND ( z_km[i+istep] gt ht_plot )  then begin 

;nm20130523: SH added nmf2/hmf2
   endif else begin ; ( VarType ge 7 ) then begin
     for jth=0,ISPEC-1 do  nel[i]=nel[i]+XIONN_m3[jth,i,mp]

     if ( i eq midpoint ) then  begin
       result = MAX( nel,Max_Subscript ) ;find NmF2
;       print,'SH: NmF2', result,Max_Subscript, nel[Max_Subscript],Z_km[Max_Subscript],mp,lp
       if ( VarType eq 7 ) then $
         plot_zz[mp,lps] = $
       ;nel[Max_Subscript] * factor  $ ;NmF2
 ALOG10(nel[Max_Subscript] * 1.0E-6 ) $ ;NmF2 m-3-->cm-3
       else if ( VarType eq 8 ) then $
;dbg20150323: flux data not available for now..for SH
;t          plot_zz[mp,lps] = $
;t lmfl[mp,lps] ;limiting flux
;Z_km[Max_Subscript]    ;hmF2

       if ( sw_frame eq 0 ) then begin ;magnetic
          plot_yy[mp,lps] = mlat_deg[Max_Subscript]
          plot_xx[mp,lps] = mlon_deg[mp]
          if (xmax360 eq 0) AND (mlon_deg[mp] ge +180.) then plot_xx[mp,lps]=mlon_deg[mp]-360.
       endif else if ( sw_frame eq 1 ) then begin ;geographic
          plot_yy[mp,lps] = glat_deg[Max_Subscript,mp]
          plot_xx[mp,lps] = glon_deg[Max_Subscript,mp]
          if (xmax360 eq 0) AND (glon_deg[Max_Subscript,mp] ge +180.) then plot_xx[mp,lps]=glon_deg[Max_Subscript,mp]-360.
       endif ;( sw_frame eq 0 ) then begin ;magnetic
  
    endif;     if ( i eq midpoint ) then 
  endelse ;( VarType lt 7 ) then begin


;nm20140701
; is lp  or lps???: VEXB does not have dimension as big as lps 
if ( sw_arrow ge 1 ) then begin
   plot_u[mp,lps]=VEXB[mp,lp,0] ;+east
   plot_v[mp,lps]=VEXB[mp,lp,1]*(-1.) ;converted to +NORTHward, equatorward
;print,'SH U=',  plot_u[mp,lps],'V=',  plot_v[mp,lps]
endif



 endfor                         ; i=is,midpoint, istep  do begin

endfor ;lp=0,NLP-1 do begin
endfor ;mp=0,NMP-1 do begin


;(2) when time = time_max 
; plotting
if ( sw_range eq 1 ) then begin
      if ( VarType eq 0 ) then begin 
;f107-180
;        zmin=-8.0E+10
        zmin=0.;1.e+10
;        zmax=7.5e+11
;        zmax=2.5e+1 ;E-region
        zmax=18.;2.e+12 ;F-region
;        zmax=9.0E+11 ;dbg200km
;        zmax=5.58e+12
;92km
;        zmax=2.00e+11
;        zmin=1.00e+04
;f107-80
;        zmin=1.e+10
;        zmax=1.77e+12
      endif else if ( VarType ge 1 ) AND (VarType le 2 ) then begin 
        zmin=700.
        zmax=2500.
      endif else if ( VarType ge 3 ) AND ( VarType lt 5 ) then begin 
;        zmin=0.
;        zmax=8.
;        zmin=1.
;        zmax=2.5e+1
        zmin=-100.;0.0
        zmax=+100.;1.28 ;F-region
      endif else if ( VarType eq 5 ) then begin 
;        zmin=-300.;zonal
;        zmax=+300.
        zmin=-1.;o+ flux
        zmax=+1.
      endif else if ( VarType eq 6 ) then begin 
;        zmin=-300.;southward
;        zmax=+300.
        zmin=-1.;h+ flux
        zmax=+1.
      endif else if ( VarType eq 7 ) then begin 
        zmin=5.5;5.5;5.;0.23;1.0e+10
        zmax=6.1;5.95;5.98;6.2;17.30;18.40;1.983e+12
      endif else if ( VarType eq 8 ) then begin 
;hmf2
;        zmin=100.
;        zmax=500.
zmin=0.001
zmax=0.5393
      endif

	where_result=where ( plot_zz gt zmax, count ) 
;	print, '1. where_result', where_result,'count',count
	for i=0,count-1 do $
	  plot_zz[ where_result[i] ]=zmax
;  	where_result=where ( plot_zz gt zmax, count ) 
;	print, '2. where_result', where_result,'count',count

endif else if ( sw_range eq 0 ) then begin
zmax = max(plot_zz)
zmin = min(plot_zz)
endif
;if ( sw_debug eq 1 ) then   
print,'max=',MAX(plot_zz),' min=',MIN(plot_zz)

MAX_xymin=zmax ;1.0E+3
n_levels=100L

if ( xmax360 eq 1 ) then begin
  X_max=+360.
  X_min=+  0.
endif else if ( xmax360 eq 0 ) then begin
  X_max=-60.;+180.
  X_min=-130.;-X_max
endif
Y_max=60.;+90.0
Y_min=20.;-Y_max
if ( sw_frame eq 0 ) then $
  MAG_GEO='magnetic' $
else if ( sw_frame eq 1 ) then $
  MAG_GEO='geographic'

X_TITLE=MAG_GEO+' longitude[deg]'
Y_TITLE=MAG_GEO+' latitude[deg]'

if ( sw_plot_contour eq 1 ) then begin
	text_color=255.
char_size=1.0
char_thick=1.0
n_ldct=39;5;39
	iwindow=1L
	DEVICE, RETAIN=2, DECOMPOSED=0
	WINDOW,iwindow,XSIZE=500*fac_window,YSIZE=500*fac_window ;*0.7
	!p.multi=[0,1,1,0]
	loadct,n_ldct ;20141112
;redblue ;20141112
endif ;( sw_plot_contour eq 1 ) then begin



;debug
;mp=0
;print,'mp==',mp
;for l=0,nlp-1 do print,plot_zz(mp,l),plot_xx(mp,l),plot_yy(mp,l)

;20140701: here i should output mlon.dat, mlat,dat, u.dat, v.dat...
if ( sw_polar_contour eq 1 ) then begin

if ( sw_polar_contour_output eq 1 ) then begin
   flnmtmp='inp.dat'
   luntmp=100
   openw,luntmp,flnmtmp, /GET_LUN
   print, '0. polar contour file created:',flnmtmp
   print,          ny_max,NMP,ht_plot,ut_hr
   printf, luntmp, ny_max,NMP,ht_plot,ut_hr
   FREE_LUN, luntmp

   flnmtmp='mlon'+STRTRIM( string(ht_plot, FORMAT='(F6.0)'),1 )+'_'+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+'.dat'
   luntmp=100
   openw,luntmp,flnmtmp, /GET_LUN
   print, '1. polar contour file created:',flnmtmp
   printf, luntmp, plot_xx[0:NMP-1,0]
   FREE_LUN, luntmp

   flnmtmp='mlat'+STRTRIM( string(ht_plot, FORMAT='(F6.0)'),1 )+'_'+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+'.dat'
   luntmp=100
   openw,luntmp,flnmtmp, /GET_LUN
   print, '2. polar contour file created:',flnmtmp
   printf, luntmp, plot_yy[0,0:ny_max-1]
   FREE_LUN, luntmp

  flnmtmp='ne'+STRTRIM( string(ht_plot, FORMAT='(F6.0)'),1 )+'_'+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+'.dat'
   luntmp=100
   openw,luntmp,flnmtmp, /GET_LUN
   print, '3. polar contour file created:',flnmtmp
   printf, luntmp, plot_zz[0:NMP-1,0:ny_max-1]
   FREE_LUN, luntmp
;
;u: eastward drift
  flnmtmp='ve'+STRTRIM( string(ht_plot, FORMAT='(F6.0)'),1 )+'_'+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+'.dat'
   luntmp=100
   openw,luntmp,flnmtmp, /GET_LUN
   print, '4. polar contour file created:',flnmtmp
   printf, luntmp, plot_u[0:NMP-1,0:ny_max-1]
   FREE_LUN, luntmp
;
;v: southward drift
  flnmtmp='vth'+STRTRIM( string(ht_plot, FORMAT='(F6.0)'),1 )+'_'+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+'.dat'
   luntmp=100
   openw,luntmp,flnmtmp, /GET_LUN
   print, '5. polar contour file created:',flnmtmp
   printf, luntmp, plot_v[0:NMP-1,0:ny_max-1]
   FREE_LUN, luntmp
endif ;( sw_polar_contour_output eq 1 ) then begin

;mlat
mp=16;10-1
lp=21;14-1
krmax =$
;16L ;73.11
;19L ;63.11
;24L ;63.11
; 29L; 55.88
39L ;NLP ; 40.27deg mlat
;38 40.8670

if ( which_hem eq 'NH' ) then $
  jj=krmax-1 $
else if ( which_hem eq 'SH' ) then $
  jj=ny_max-2-krmax+1

   rim_lat = plot_yy[mp,jj]
;dbg   rim_lat = plot_yy[mp,krmax]
print,krmax,' rim_lat[deg]=', rim_lat

;dbg20141203
;dbg for i=1-1,krmax-1 do print, i, plot_yy[0,i]
;dbg for i=ny_max-2,ny_max-2-krmax+1, -1 do print, i, plot_yy[0,i], (ny_max-2-i)
;stop

comlat = fltarr(krmax)
if ( which_hem eq 'NH' ) then begin
   jmin=1-1
   jmax=krmax-1
   jstep=+1
endif else if ( which_hem eq 'SH' ) then begin
      jmin=(ny_max-2)
      jmax=jmin-krmax+1
      jstep=-1
endif

   for j=jmin,jmax, jstep    do begin 
;dbg   for j=0,krmax-1    do begin 

      if ( which_hem eq 'NH' ) then begin
         jj = j 
         comlat[jj] = 90. - plot_yy[mp,j] ;[deg]
      endif else if ( which_hem eq 'SH' ) then  begin
         jj = jmin-j 
         comlat[jj] = 90. + plot_yy[mp,j] ;[deg] ;degrees measured from South Pole
      endif
;dbg      comlat[j] = 90. - plot_yy[mp,j] ;[deg]
;if ( j eq lp ) then $
    ;dbg print,j,jj,' comlat', comlat[jj], ' mlat=',(90.- comlat[jj])
   endfor


;nm20150310 read sunlons
if sw_read_sunlon eq 1 then begin
 print, 'before sunlons1=', sunlons1
 read_sunlons,sunlons1,TEST,rundir,LUN2013,n_read
 print, 'after sunlons1=', sunlons1
endif

;mlt
mlt = fltarr(nx_max)
for i=0,nx_max-1   do begin
   mlt[i]    = mlon_deg[i]/15.0D0 - sunlons1 * 12.0D0 / !PI   +12.0 ;[hr] !CORRECT!
  if ( mlt[i] lt  0. ) then  mlt[i] = mlt[i] MOD 24.
  if ( mlt[i] ge 24. ) then  mlt[i] = mlt[i] - 24.

;if ( i eq mp ) then 
; print,i,' mlt', mlt[i]
endfor

mlt = mlt*!PI/12.0D0   ;MLT_hr --> THETA[rad]

;print,mp,' mlt(mp)', mlt[mp]
;shift the MLT so that 00MLT comes at the bottom of the plot!
;clockwise 90deg rotation
mlt = mlt - !PI*0.50D0       ;(radian)
print,mp,' mlt(mp)', mlt[mp]
print,mp,lp,' plot_zz', plot_zz[mp,lp]

;
plot_zz_plr = fltarr(nx_max,krmax)
zzmax=-10000.
zzmin=+10000.

if ( which_hem eq 'NH' ) then begin
   kmin=0
   kmax=krmax-1
   kstep=+1

endif else if ( which_hem eq 'SH' ) then begin

   kmin=ny_max-2
   kmax=kmin-krmax+1
   kstep=-1

endif                           ;( which_hem eq 'NH' ) then begin

for i=0,nx_max-1  do begin
   for j=kmin,kmax   ,kstep  do begin
;dbg print, kmin,kmax   ,kstep



      if ( which_hem eq 'NH' ) then $
         jj=j $
      else if ( which_hem eq 'SH' ) then $
         jj=kmin-j 

      plot_zz_plr[i,jj] = plot_zz[i,j]
;dbg      plot_zz_plr[i,j] = plot_zz[i,j]
      if( plot_zz[i,j] gt zzmax ) then begin
         zzmax=plot_zz[i,j]
         imax=i
         jmax=j
      endif
      if( plot_zz[i,j] lt zzmin ) then begin
         zzmin=plot_zz[i,j]
         imin=i
         jmin=j
      endif

   endfor
endfor
print, 'ZZMAX',zzmax,imax,jmax
print, 'ZZMIN',zzmin,imin,jmin

col_min = 0.00
col_max = 255.999

; mlat-mlon (regular) only for the moment
POLAR_CONTOUR_qhull  $
, plot_zz_plr, mlt, comlat  $  ;NH
  , xstyle = 5, ystyle = 5  $
  , levels = findgen(n_levels)*(zmax-zmin)/float(n_levels-1) + zmin $
  , charsize = char_size, charthick = char_thick                 $
  , TITLE=which_hem+' : '+VarTitle[VarType]+unit[VarType]+'  UT:'+STRTRIM( string(ut_hr,  FORMAT='(F7.3)') ,1)+' [hrs]' $
  , SUBTITLE = 'MAX:'+STRTRIM( string(MAX(plot_zz_plr),  FORMAT='(E12.4)') ,1)+' MIN:'+STRTRIM( string(MIN(plot_zz_plr),  FORMAT='(E12.4)') ,1)+'   PERIMLAT:'+STRTRIM( string(rim_lat,  FORMAT='(F6.2)') ,1)  $
  , /FILL   $
  , c_color = INDGEN(n_levels)*col_max/n_levels $
  , pos = [X0, Y0, X1, Y1] $
,sw_debug

;20141112 test velovect
if  sw_arrow ge 1 then begin 
loadct, 0
;ArrowCol=255
u=fltarr(nx_max,krmax)
v=fltarr(nx_max,krmax)
for j=0,krmax-1 do begin
  for i=0,nx_max-1 do begin
    u[i,j]= plot_u[i,j]
;print, 'check u=',u[i,j],i,j
    v[i,j]= plot_v[i,j]
  endfor ;i
endfor ;j

if  sw_arrow eq 1 then $ 
;plot VEXB
  draw_arrow_test, u, v, mlt, comlat, rim_lat, sw_debug $
else if  sw_arrow eq 2 then $ 
;plot phi and theta for validation
  draw_arrow_test1, u, v, mlt, comlat $
,rim_lat,sunlons1,nmp,nlp,sw_debug $
,TEST,rundir,LUN9001,n_read



;redblue
loadct,n_ldct
endif ; sw_arrow eq 1 then begin 

;debug20140703: find the MIN Nmf2, MAX Te?
print, 'MAX ZZ=', MAX (plot_zz_plr, I)
print, 'subscript of the MAX=',I
IX = I MOD nx_max
IY = I/nx_max
if sw_debug eq 1 then print, 'the maximum value of ZZ is at location ('+STRTRIM(IX, 1) $
+ ', ' + STRTRIM(IY, 1) + ')'

if sw_debug eq 1 then print, 'MIN ZZ=', MIN (plot_zz_plr, I)
if  sw_debug eq 1 then print, 'subscript of the MIN=',I
IX = I MOD nx_max
IY = I/nx_max
if sw_debug eq 1 then print, 'the minimum value of ZZ is at location ('+STRTRIM(IX, 1) $
+ ', ' + STRTRIM(IY, 1) + ')'


mp=14;10-1;imin
lp=18-1;jmin
;debug20140703: identify where is (mp,lp) flux tube is located?
oplot, /POLAR,  comlat[lp-1:lp], mlt[mp-1:mp] $
, THICK=8.0, LINESTYLE = 0  $
, COLOR = 150. ;MIN
;, COLOR = 40. ;MAX

print, 'MIN mlat',plot_yy[mp,lp]


print,'TEST=',TEST, ' rundir=', rundir
xyouts, 0.70, 0.05, TEST+' '+rundir $
, charsize=.9, charthick=.9, /norm, /noclip

endif else begin ;( sw_polar_contour eq 0 ) then begin


;d if ( sw_plot_contour eq 1 ) then begin-->need to move to much earlier...
contour,plot_zz,plot_xx,plot_yy $
,/irregular $
,/fill $
,levels=findgen(n_levels)*(zmax-zmin)/float(n_levels-1) +zmin $
,xrange=[X_min,X_max], /xstyle $
,yrange=[Y_min,Y_max], /ystyle $
,XTITLE=X_TITLE,YTITLE=Y_TITLE $
,TITLE=VarTitle[VarType]+unit[VarType]+' ht'+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'km  UT[hr]='+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+'_'+TEST+'_'+rundir $
,POSITION=[X0,Y0,X1,Y1] $
,COLOR=text_color $
,charsize=char_size,charthick=char_thick $
,MAX_VALUE= MAX_xymin 


if ( sw_arrow eq 1 ) then begin
loadct, 0
ArrowMax=300.
velovect, plot_u, plot_v, plot_xx, plot_yy $
,/irregular $
;, min_value=-WINDMX, max_value=WINDMX $
;, xmargin=9, ymargin=5  $
;, pos=[X0/X_SIZE, Y0/Y_SIZE, (X0+dX)/X_SIZE, (Y0+dY)/Y_SIZE] $
, xstyle=5, ystyle=5 $
;, MISSING=WINDMX $
, length=15. $ ;factor ArrowLength $
, /overplot $
, color=0 $ ;ArrowCol $
,        CLIP=clip $
, MAXMAG=ArrowMax, ArrowMax_saved ;110904: added by naomi
endif


if ( sw_debug eq 1 ) then  print,'MAX=',MAX(plot_zz),' MIN=',MIN(plot_zz)
; add MIN & MAX values
xyouts, 0.5, 0.84 $
, 'MIN='+STRTRIM(STRING( MIN(plot_zz), FORMAT='(E10.3)'),1)+' MAX='+STRTRIM(STRING( MAX(plot_zz), FORMAT='(E10.3)'),1)  $
, charsize=1.2, charthick=1.2, /norm, /noclip



endelse ;if ( sw_polar_contour eq 0 ) then begin

charsize_colorbar=1.5
format_colorbar='(E9.1)'
font=1 ;true-type 
position=[0.10, 0.95, 0.90, 0.98] ;for horizontal bar
COLORBAR, BOTTOM=bottom, CHARSIZE=charsize_colorbar, COLOR=color, DIVISIONS=divisions $
        , FORMAT=format_colorbar, POSITION=position, MAXRANGE=zmax,MINRANGE=zmin $
        , NCOLORS=ncolors,TITLE=title,VERTICAL=vertical,TOP=top,RIGHT=right $
        , MINOR=minor, RANGE=range, FONT=font, TICKLEN=ticklen $
        , _EXTRA=extra, INVERTCOLORS=invertcolors, TICKNAMES=ticknames

if ( sw_output2file eq 1 ) then begin
   if ( sw_frame eq 0 ) then $  ;magnetic
      title_frame='mag' $
   else if ( sw_frame eq 1 ) then $ ;geographic
      title_frame='geo'

   if ( sw_polar_contour eq 0 ) then $  ;rectangular
      title_plr='rec' $
   else if ( sw_polar_contour eq 1 ) then $ ;polar
      title_plr='plr'+which_hem

Filename_png=plot_DIR+VarTitle[VarType]+'_ht'+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'_ut'+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+title_frame+'.'+title_plr+rundir+'v2.png'
output_png, Filename_png
endif ;( sw_output2file eq 1 ) then begin

;endif ;( sw_plot_contour eq 1 ) then begin-->need to move???



if ( sw_plot_grid ge 1 ) then begin
loadct,0

if ( sw_plot_grid eq 1 ) then begin
   oplot,plot_xx,plot_yy $
;,xrange=[X_min,X_max], xstyle=1 $
;,yrange=[Y_min,Y_max], ystyle=1  $
;,XTITLE=X_TITLE,YTITLE=Y_TITLE $
;,TITLE=VarTitle[VarType]+unit[VarType]+'  ht='+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'km  UT[hr]='+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 )+'.'+TEST $
;,POSITION=[X0,Y0,X1,Y1] $
,COLOR=0.$;text_color $
;,charsize=char_size,charthick=char_thick $
,PSYM=3, SYMSIZE=5.5 ;$
title_plr='ret'

endif  else if ( sw_plot_grid eq 2 ) then begin
;      plot_yy[mp,lp] = mlat_deg[i]
LPmax = krmax
rmax=90.- plot_yy[0,LPmax]
print, 'rmax=',rmax
r=fltarr(NMP,LPmax)
theta=fltarr(NMP,LPmax)
for mp=0,NMP-1 do begin
for lp=0,LPmax-1 do begin
r[mp,lp] = 90.- plot_yy[mp,lp] ;degrees from the North mag pole
theta[mp,lp] =  plot_xx[mp,lp] * !PI /180.
if ( r[mp,lp] gt rmax ) then  begin
  r[mp,lp]=0.
  theta[mp,lp]=0.
endif
endfor
endfor
oplot,/POLAR, r, theta $
;,XSTY=4, YSTY=4 $
;,xrange=[X_min,X_max], xstyle=1 $
;,yrange=[Y_min,Y_max], ystyle=1  $
;,XTITLE=X_TITLE,YTITLE=Y_TITLE $
;,TITLE='POLAR PLOT in MAGNETIC COORDINATE' $ ;VarTitle[VarType]+unit+'  ht='+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+'km  UT[hr]='+STRTRIM( string(ut_hr, FORMAT='(F6.2)'),1 ) $
;,POSITION=[X0,Y0,X1,Y1] $
,COLOR=0.$;text_color $ ;black
;,charsize=char_size,charthick=char_thick $
,PSYM=3, SYMSIZE=5.5 ;$


AXIS, 0,0,XAX=0 $
,Xrange=[-rmax,+rmax], Xstyle=1
AXIS, 0,0,YAX=0 $
,Yrange=[-rmax,+rmax], Ystyle=1
title_plr='plr'

endif  ;else if ( sw_plot_grid eq 2 ) then begin

if ( sw_output2file eq 1 ) then begin

   if ( sw_frame eq 0 ) then $  ;magnetic
      title_frame='mag' $
   else if ( sw_frame eq 1 ) then $ ;geographic
      title_frame='geo'

Filename_png=plot_DIR+'ipe_grid_ht'+STRTRIM( string(ht_plot, FORMAT='(F4.0)'),1 )+title_plr+'.'+title_frame+'.png'
print,'output to file=',filename_png
output_png, Filename_png
endif

LOADCT, n_ldct


endif ;( sw_plot_grid eq 1 ) then begin


endfor ;VarType=1,1 do begin
end ;pro contour_lon_lat
