;20110803! CAUTION! SH does not work!!!
;24 Mar 2011
;copied from plot_ptofile_ht.pro extracted plotting part only...
;20120305: PRO  profile_ht_3d $  renamed for shorter/easier names
PRO  prfl_ht $
,plot_x,plot_y, title_hemi,mlat_title,ut_hr,lt_hr $
,plot_DIR,FLDIM_plot,mp_plot,sw_debug,sw_fort $
,sw_dif,sw_output2file,n_file,fac_window,TEST,rundir

print,'prfl_ht',sw_output2file ;debug

y_min =90.;1.0E+2; 90.
y_max =1300.;2.E+4;800.
if ( sw_debug eq 1 ) then  print, "y_max=", y_max

if ( sw_fort eq 168L ) then begin
;x_min=[-15.,   +100.,     0. ,     0.]
;x_min=[-1.,    +400.,     0. ,     -25.]
x_min=[-1.,    +150.,     0. ,     -30.]
x_max=[ 7.,  +2400.,  +1000. ,    +25.]
;x_max=[+6.1,  +17000.,  +1600. ,    +30.] ;dbg20141208
;x_max=[+6.1,  +3500.,  +1600. ,    +30.]
;x_max=[ 4.0,  +1300.,  +700. , +7000.]
endif else if ( sw_fort eq 167L ) then begin
x_min=[ 5.2,  + 0.,   -1. ,   0.]
x_max=[ 11.,  +180.,   +0.6, +14.]
endif


;get FLDIM and n_file
size_result=SIZE(plot_x)
if ( sw_debug eq 1 ) then  print,size_result
plot_type_max=size_result[1]
k_species    =size_result[2]
FLDIM        =size_result[3]
;n_file       =size_result[4] !this does not work when n_file=1
;if ( sw_debug eq 1 ) then  $
  print,'plot_type_max',plot_type_max,'k_species',k_species," FLDIM=",FLDIM," n_file=",n_file


; set up plot parameters
i_plot=INTarr(n_file)
  i_plot[0]=0 ;file[0]
if ( n_file ge 2 ) then  i_plot[1]=1 ;file[1]
if ( n_file ge 3 ) then  i_plot[2]=2 ;file[2]
if ( n_file ge 4 ) then  i_plot[3]=3 ;file[3]
if ( n_file ge 5 ) then  i_plot[4]=4 ;file[3]
line_color=INTarr(n_file)
line_color[ i_plot[0]  ] =  55. ;blue
if ( n_file ge 2 ) then  line_color[ i_plot[1]  ] = 250. ;red
if ( n_file ge 3 ) then  line_color[ i_plot[2]  ] = 150. ;green
if ( n_file ge 4 ) then  line_color[ i_plot[3]  ] = 200. ;orange
if ( n_file ge 5 ) then  line_color[ i_plot[4]  ] = 100. ;orange

line_thick=[4.5,3.5,3.5,2.5,2.5]

;k_species = 4
;k_plot    =INTarr(k_species)
line_style=INTarr(k_species)

;title_var=['O+/H+/He+/Min+', 'Ti/Te/Tn', 'Vo+/Un/fo+', 'PHION/EHT']
if ( sw_dif eq 0 ) then begin
   if ( sw_fort eq 168L ) then  title_var=$
['O+/H+/He+/MIN+', 'Ti/Te', 'PHION/SUMION', 'UN'] else $
;['O+/H+/He+/N+', 'Ti/Te', 'PHION/SUMION', 'EHT'] else $
   if ( sw_fort eq 167L ) then  title_var=['SL', 'GL/SZA', 'BM/GR', 'O/H+He/N2+O2/N4S']
endif else if ( sw_dif eq 1 ) then begin
   if ( sw_fort eq 168L ) then  title_var=['dif:O+/H+', 'dif:Ti/Te', 'PHION/SUMION', 'EHT'] else $
   if ( sw_fort eq 167L ) then  title_var=['SL', 'GL/SZA', 'BM/GR', 'O/H+He/N2+O2/N4S']
endif
;title_type='NTW'
line_style=[ 1,2,3,0 ]


!P.MULTI=[0,2,2,0,1]
;1:# of plot columns
;2:# of rows

;print, 'before',!P.BACKGROUND
!P.BACKGROUND=255
;print, 'after',!P.BACKGROUND

; plot height profile
  device, decomposed = 0 ,retain=2
;  window, 0 ,XSIZE=800,YSIZE=550
  window, 0 ,XSIZE=800*fac_window,YSIZE=750*fac_window
  n_ldct=39
  loadct, n_ldct ;=39

  axis_color = 0.0 ;255.99 $
  char_size = 1.5

for plot_type=0,plot_type_max-1  do begin
;if ( plot_type eq 0 ) then   k_plot    =[ 0,1,3]  else $ ;O+  ;H+ ;Min+; He+ ;NNO
;if ( plot_type eq 1 ) then   k_plot    =[ 4,5,6]         ;Ti  ;Te ;Tn
;if ( plot_type eq 2 ) then   k_plot    =[ 4,5,6]         ;Vo+ ;Un ;o+flux
;if ( plot_type eq 3 ) then   k_plot    =[ 4,5,6]         ;phion ;eht


if ( sw_debug eq 1 ) then  print,'plot_type=',plot_type," x_min=", x_min[plot_type]," x_max=", x_max[plot_type]




i=0
format_ut='(f8.3)'
title_plot=TEST+'_'+title_hemi+': mlat[deg]='+mlat_title+'  UT[hrs]='+STRTRIM( string(ut_hr[i_plot[i]], FORMAT=format_ut), 1)+'  LT[hrs]='+STRTRIM( string(lt_hr[i_plot[i]], FORMAT=format_ut), 1)

;plotting NH only
;if ( title_hemi eq 'NH' ) then begin
  j0=0L
  j1=FLDIM_plot[0]/2 -1L
;endif else if ( title_hemi eq 'SH' ) then begin
;  j0=FLDIM_plot[0]/2
;  j1=FLDIM_plot[0] -1L
;endif

;dbg 
;d  if ( plot_type eq 0 ) then for j=j0,j1  do print,'plot_type=',plot_type,' i=',i,'!debug plot: j=',j,plot_x[plot_type,0,j,i_plot[i]],plot_y[j,i_plot[i]]
;frame only
if ( plot_type eq 0 ) then begin  ;densities
  plot, plot_x[plot_type,0,j0:j1,i_plot[i]], plot_y[j0:j1,i_plot[i]] $;, /xlog $ 
  ,xrange=[x_min[plot_type],x_max[plot_type]], xstyle=1  $
  ,yrange=[y_min,y_max], ystyle=1 $
,/YLOG $  ;nm20141028
  ,title=title_var[plot_type] $;+': '+title_plot  $
  ,linestyle = 0 $
  ,color=axis_color $
  ,charsize=char_size $
  ,/NODATA

endif else if ( plot_type ge 1 ) then begin  ;temperatures


  plot, plot_x[plot_type,0,j0:j1,i_plot[i]], plot_y[j0:j1,i_plot[i]] $
  ,xrange=[x_min[plot_type],x_max[plot_type]], xstyle=1  $
  ,yrange=[y_min,y_max], ystyle=1  $
,/YLOG $  ;nm20141028
  ,title=title_var[plot_type] $
  ,linestyle = 0 $
  ,color=axis_color $
  ,charsize=char_size $
  ,/NODATA

endif

for k=0,k_species-1 do begin
  for i=0,n_file-1 do begin
;d print,'check i=',i,n_file
;dbg20110803
;d   if i ge 3 then continue


;if ( title_hemi eq 'NH' ) then begin
  j0=0L
  j1=FLDIM_plot[i]/2-1L
;endif else if ( title_hemi eq 'SH' ) then begin
;  j0=FLDIM_plot[i]/2
;  j1=FLDIM_plot[i]-1L
;endif

if ( sw_debug eq 1 ) then  print, i, i_plot[i], line_color[i_plot[i]]
;if ( sw_debug eq 1 ) then  print, plot_x[plot_type,k,j0:j1,i_plot[i]]

;dbg20141028
if ( plot_type eq 1 ) then print, k,'check Te',MAX(plot_x[plot_type,k,j0:j1,i_plot[i]]),MIN(plot_x[plot_type,k,j0:j1,i_plot[i]])



    oplot, plot_x[plot_type,k,j0:j1,i_plot[i]], plot_y[j0:j1,i_plot[i]] $ 
    ,linestyle = line_style[k] $
    ,color=line_color[i_plot[i]] $
    ,thick=line_thick[i]
 endfor ;i
endfor ;k

endfor ;plot_type=0,2 do begin

xyouts, 0.10, 0.5, title_plot  $
, charsize=1.0, charthick=1.0, color=axis_color, /norm, /noclip

if ( sw_dif eq 0 ) then $
   title_dif='.png' $
else if ( sw_dif eq 1 ) then $
   title_dif='dif.png'

if ( sw_output2file eq 1 ) then begin
   filename=plot_DIR+'prfl'+STRTRIM( string(sw_fort, FORMAT='(i3)'), 1)+TEST+'.'+rundir+'.mlat'+mlat_title+'_UT'+STRTRIM( string(ut_hr[0], FORMAT=format_ut), 1)+'_'+title_hemi+'_mp'+STRTRIM( string((mp_plot+1), FORMAT='(i2)'), 1)+'.v4'+title_dif

print,filename ;dbg
   output_png, filename
endif




end ;PRO  prfl_ht $
