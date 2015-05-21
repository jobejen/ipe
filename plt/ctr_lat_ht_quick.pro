;20140121: copied from contour_plot_2d to create a quickplot
;TODO
;include parallel V for debug purpose!!!
;20110203: copied from /home/naomi/sandbox/SUPIM/plot_idl/contour_result.pro

 PRO  ctr_lat_ht_quick $
, in2d,is2d,z_km,mlat_deg  $             ;input 
, plot_z,plot_VEXB,n_read   $ ;input
, uthr, plot_DIR, title_res $
;,rundate,title_test $
,sw_debug, title_hemi,sw_anim,mpstart,mpstop,mpstep, lt_hr,fac_window $
, sw_output2file $
, VarType_min $;=8L
, VarType_max $;=8L ;PAR-1
, VarType_step $;=4L
,n_read_max $;
, input_DIR0, TEST, TEST1, TEST2, glon_deg2D, rundir  ;$
;
;VarType_min=3L
;VarType_max=3L ;PAR-1
;VarType_step=4L



sw_arw_vpara=0
fac_arw_para=0.7

;n_read0=0L
sw_plot_grid=0L  ;1: plot grid only
sw_arrow_exb=0L
reference_arrow=40L  ;m/s
;factor_arrow=5.
factor_arrow=5.

lp_step_arrow=7
;lpmax_perp_trans=37;151-1
lpmax_perp_trans=149
;mpstart=mp_plot-5;0
;mpstop=mp_plot;0
;mpstep=1
;debug
for i=mpstart, mpstop  do print,' mp', (i+1),' LT',lt_hr[i]

HTmin=90.  ;min(yy)   ;75.   ;400. ;
HTmax=500.;10000.;800.;700.;190. ;1.000000E+03;700.; 
; plot range
if ( title_hemi eq 'NH' ) then begin
  gLATmax=+83.;+90.;-10.;
  gLATmin=+55.;+50.;-gLATmax;-27.; 
endif else if ( title_hemi eq 'SH' ) then begin
  gLATmax=-55.;+90.;-10.;
  gLATmin=-85.;+50.;-gLATmax;-27.; 
endif else if ( title_hemi eq 'glb' ) then begin
  gLATmax=+50.;-10.;
  gLATmin=-gLATmax;-27.; 
endif else if ( title_hemi eq 'eq' ) then begin
  gLATmax=-15.;+90.;-10.;
  gLATmin=-33.;-gLATmax;-27.;
;  HTmax=1.001E+03 
endif





sw_dif=0L
device_type='png' ;ps';'


size_result = SIZE(in2d)
NLP=size_result[1]
if ( sw_debug eq 1 ) then  print, 'NLP=', NLP
size_result = SIZE(z_km)
NPTS2D=size_result[1]
if ( sw_debug eq 1 ) then  print, 'NPTS2D=', NPTS2D
size_result = SIZE(plot_z)
NPAR = size_result[2]





;lp_strt=1;28-1;  0+1 ;58;0;63 ;1-1L
lp_strt=0+1 ;58;0;63 ;1-1L
;lp_stop=NLP-1-1 ;138L;
lp_stop=NLP-2;138L;


uthr_disp=uthr MOD 24.
;if ( uthr le 0.00 ) then $
;  time_string='00'+STRTRIM(STRING( uthr-24.0, FORMAT='(F8.4)'),1)+'UT' $
;else 
if ( uthr_disp lt 1.0E+01 ) then $
  time_string='00'+STRTRIM(STRING( uthr_disp, FORMAT='(F8.4)'),1)+'UT'  $
else if ( uthr_disp lt 1.0E+02 ) then $
  time_string='0'+STRTRIM(STRING( uthr_disp, FORMAT='(F8.4)'),1)+'UT'  $
else $ ;if ( uthr ge 1.0E+02 ) then $
  time_string=STRTRIM(STRING( uthr_disp, FORMAT='(F8.4)'),1)+'UT'

for mp=mpstart,mpstop, mpstep do begin
if ( sw_debug eq 1 ) then  print, 'mp=',mp

;042004:
;if ( elhr le 0.00 ) then $
FileID=time_string+'_'+STRTRIM(STRING( lt_hr[mp], FORMAT='(F6.2)'),1)+'LT'+'_mp'+STRTRIM(STRING( (mp+1), FORMAT='(i3)'),1)+'.'+TEST ;mp+1:ipe convention

VarTitle=[ $
'Ne',$
'Te',$ 
'vo+',$;Ti',$ ;dbg20140815
;'O+','H+','He+','N+','NO+','O2+','N2+','O+2D','O+2P' $
;tmp20121128 temporary o+ is assigned to plot_z(6)(n+) instead of 3 for faster debug molecular ions
'O+' $;,'H+' $
;,'He+'$
,'Un'$
,'O+','NO+','O2+','N2+','O+2D','O+2P' $
,'Vo+' $
;'o+flux'$
;'hr4',$
]

VarUnit=[ $
'[log!D10!N cm-3]',$
'[K]', $ ;Te
 '[m/s]', $ ;vo+; Ti;'[K]', $ ;Ti
 '[10^12 m-3]' $;,'[log!D10!N cm-3]' ;,'[log!D10!N cm-3]'$
,'[m/s]'$ ;wind
,'[log!D10!N cm-3]','[log!D10!N cm-3]','[log!D10!N cm-3]','[log!D10!N cm-3]','[log!D10!N cm-3]','[log!D10!N cm-3]' $
;'[m/s]',$
;,'[cm2 s-1]' $
;'[J/kg/s]', $;hrate
,'[m/s]'$
]

if ( n_read eq 0 ) then begin
X_Title='MAGNETIC LATITUDE [deg.]'
Y_Title='ALTITUDE [km]'
endif else begin
X_Title=' '
Y_Title=' '
endelse

;RE=6.3712E+03  ;[km]


lp=0L
ihem=0L   ;0:north; 1:south
istrt=0L
istop=-1L
istep=0L
X=dblarr(4)
Y=dblarr(4)

if ( sw_dif eq 0 ) then begin

   ARY_min0=[ $
1.3,$                
;3.2,$ ;3.,$
;178.8,$
154.,$
154.,$;-50., $; 178.8, $  ;dbg20140815
;0.,0.,0.,$
  0., $ ;0.,
-50., $
 -1.24 ,0.,0.,0.,0.,0., $ ;<190km
; 1.5 ,0.,0.,0.,0.,0., $ ;<700km
;        ,  178.8        ,  178.8  $      ;To+;Te
;        ,  -1.0E+13  $;flux [cm2 s-1]
          -10.  $   
         ] 

ARY_max0=[ $
4.5,$;6.1,$ ;7.,$
;4.,$
;800. ,$
6083. ,$
6083.,$;+50. , $ ;800. ,$  ;dbg20140815
;6.1, 3.5,3.5,$
2.377  , $ ;3.5,
+50. , $
3.5, 3.5, 3.5,3.5,5.3,5.3, $  ;<190km
;6.0, 5.3, 5.3,5.3,5.3,5.3, $ ;<700km
; 7., 7., 7.  $ ;densities
;        ,  3600. ,   3600.  $    ;To+,Te
;        ,  +1.0E+13  $
          +10.     $  ;vel [m s-1]
        ]
endif else if ( sw_dif eq 1 ) then begin
ARY_min0=[ $
           3., 3., 3., 3. $  ;densities
        ,  -1.940E+2        ,  -1.940E+2  $      ;To+;Te
        ,  -1.0E+13  $;flux [cm2 s-1]
        ,  -3500.  $   
         ] 

ARY_max0=[ $
           7., 7., 7., 7.  $ ;densities
        ,  +1.253E+03,  +1.253E+03  $    ;To+,Te
        ,  +1.0E+13  $
        ,  +3500.     $  ;vel [m s-1]
        ]
endif ;( sw_dif eq 1 ) then begin

col_min=0.   +0.3
col_max=256. -0.3
N_LVLs=100  ;intarr(2)       ; number of contour levels




; window size
X_SIZE=27. ;9.7
Y_SIZE=21.
X0= 3.0 ;[cm]
Y0= 3.0 ;
dX= 23.0
dY= 15.0

;color bar
dX1=  7.5
dY1=  0.2
X1=X0+dX-dx1 ;+1.5    ;7.5   ;8.   ;18.1
Y1=Y0+dY+1.3 ;-0.5     ;+ 1.6   ;1.3   ;18.8

xx=dblarr(npts2D)
yy=dblarr(npts2D)
;; plot GLAT v.s. ALT Flux-Tube Distribution
for lp=0,NLP-1 do begin   ;ifl-->lp

  in = IN2D[lp]-1L
  is = IS2D[lp]-1L 
;  print, 'mp',mp,' lp',lp,' in',in,' is',is

  istrt=istop +1
  istop=istrt+(is-in) ;istrt +(iseb(ifl)-ineb(ifl))

;  print,'istrt=',istrt,' istop=',istop

; set up values to be plotted
;!!!!UNDERCONSTRUCTION!!!
  xx[istrt:istop] = mlat_deg[in:is]  ;glatd(ineb(ifl):iseb(ifl), ifl)
  yy[istrt:istop] = z_km[in:is]  ;gpz(  ineb(ifl):iseb(ifl), ifl)
endfor  ;lp=lp_strt,lp_stop do begin




for VarType=VarType_min , VarType_max,  VarType_step   do begin
if (n_read eq 0 ) then print,'vartype',vartype

if ( vartype eq 3 ) then $
  factor_value = 1.0E-12 $
else $;if vartype eq 5 then $
  factor_value = 1.0

N_LDCT=39;70;5;39;33
if ( vartype eq 2 OR vartype eq 4 ) then N_LDCT=70

;if ( VarType eq 2 ) then N_LDCT=69
;print, 'n_ldct', n_ldct
;*** Load color table
LOADCT, N_LDCT

if ( sw_debug eq 1 ) then  print,'plotting ',VarTitle(VarType)
MainTitle=VarTitle(VarType)+' '+VarUnit(VarType)
FILE_DISP=plot_DIR+'quick/'+TEST+'_'+rundir+'_mp'+STRTRIM(STRING( (mp+1), FORMAT='(i3)'),1)+VarTitle(VarType)+'_'+title_res+'.'+'quick.'+device_type
if (n_read eq 0 ) then  print, file_disp
if ( sw_debug eq 1 ) then  print, file_disp

if (n_read eq 0 ) then begin
if ( device_type eq 'ps' ) then begin



  SET_PLOT, 'ps' ;'x'
   ; Open a file in the current directory 
   ; to contain the PostScript plot.
  DEVICE, BITS_PER_PIXEL=24,/COLOR, $
  FILENAME=FILE_DISP, /LANDSCAPE,    $
  SET_FONT='Courier',       /TT_FONT, $
  XSIZE=X_SIZE, YSIZE=Y_SIZE, XOFFSET=0.0, YOFFSET=X_SIZE
endif else  if ( device_type eq 'png' ) then begin



if ( sw_debug eq 1 ) then  print, 'before',!P.BACKGROUND
  !P.BACKGROUND=0 ;255
if ( sw_debug eq 1 ) then  print, 'after',!P.BACKGROUND


; plot height profile
  device, decomposed = 0 ,retain=2
;  window, 0 ,XSIZE=1000*fac_window,YSIZE=800*fac_window
  window, 0 ,XSIZE=1200*fac_window,YSIZE=1200*fac_window

;print, 'X.MARGIN', !X.MARGIN
;print, 'Y.MARGIN', !Y.MARGIN
;!X.MARGIN=[7,5] ;left,right
;!Y.MARGIN=[4,10] ;bottom,top

;  !P.MULTI=[0,4,4,0,1] ;plot goes vertically downward 
  !P.MULTI=[0,6,6,0,0] ;plot goes vertically downward 
;  !P.MULTI=[0,2,2,0] ;plot goes horizontally from left to right
;  ;1:# of plot columns
;  ;2:# of rows


;t  axis_color = 0.0 ;255.99 $
;t  char_size = 1.5

endif                           ;if ( device_type eq 'ps' ) then begin
endif                           ; (n_read eq 0 ) then begin

LOADCT, 0;N_LDCT

;if ( sw_plot_grid eq 1 ) then begin ;20120328
;LOADCT, 0
Plot, xx(0:istop), yy(0:istop)     $
, Xstyle = 1, Xrange = [ gLATmin, gLATmax]  $
, Ystyle = 1, Yrange = [ HTmin, HTmax]      $
;, TITLE = MainTitle+'   '+FileID, SUBTitle =' ' $   ;FileID $
, TITLE =time_string+' '+STRTRIM(STRING( lt_hr[mp], FORMAT='(F6.2)'),1)+'LT' $
, SUBTitle =' ' $   ;FileID $
, XTITLE = X_Title,    YTITLE = Y_Title  $
, PSYM =  3,  SYMSIZE=1.0  $
;, Color = col_min  $
;, CharSize = 1.5 $
;, THICK    = 1.0 $
;20140121 , Pos = [X0/X_SIZE, Y0/Y_SIZE, (X0+dX)/X_SIZE, (Y0+dY)/Y_SIZE]  $
,/NODATA

LOADCT, N_LDCT
;if ( sw_output2file eq 1 ) then begin
;  print,'output to file=',plot_DIR+'ipe_grid.'+device_type
;  output_png,plot_DIR+'ipe_grid.v2.'+device_type
;endif
;LOADCT, N_LDCT
;RETURN

;endif ;( sw_plot_grid ne 1 ) then begin ;20120328


;tmp20110414: plot grid only
;if ( sw_plot_grid ne 1 ) then begin

ARY_minZ=ARY_max0(VarType)
ARY_maxZ=ARY_min0(VarType)
;print, '0ARY_minZ', ARY_minZ
;print, '0ARY_maxZ', ARY_maxZ

for lp=lp_strt , lp_stop do begin

;d if ( sw_debug ) then $
;if ( (lp+1) ge 148 ) AND ( (lp+1) le 155 ) then $
;d  print,'lp=', lp, in2d[lp], mlat_deg[ in2d[lp] ]

; midpoint = JMIN_IN(lp) + ( JMAX_IS(lp) - JMIN_IN(lp) )/2
  midpoint =      IN2D[lp]+ (     IS2D[lp] -    IN2D[lp]    )/2  -1 

;d if ( sw_debug ) then $
;if ( (lp+1) ge 148 ) AND ( (lp+1) le 155 ) then $
;d print,(lp+1),midpoint,'mlat',mlat_deg[ midpoint ]  ,'midpoint z', z_km[ midpoint ],' max z',MAX( z_km[ IN2D[lp]:IS2D[lp] ] )


  for ihem=0,1   do begin

    istrt=midpoint
    if ( ihem eq 0 ) then begin ;North
      istep= -1
      istop=in2d[lp]-1 ;-istep 
      factor=+1.0
    endif else if ( ihem eq 1 ) then begin   ;South
      istep= +1
      istop=is2d[lp]-1 ;-istep 
      factor=-1.0
    endif


;if ( mlat_deg[ is2d[lp]-1 ] ge -66. ) AND ( mlat_deg[ is2d[lp]-1 ] lt -62. ) THEN  begin
;print,'check mlat!', is2d[lp], lp ,  mlat_deg[ is2d[lp]-1 ]
;stop
;endif


;if ( lp ge 50 ) then $
  ;dXX=0.7; (mlat_deg[ in2d[lp-1] ]-mlat_deg[ in2d[lp] ])*0.95*factor ;nm20121130
  dXX=(mlat_deg[ in2d[lp-1] ]-mlat_deg[ in2d[lp] ])*0.9*factor ;nm20121130
;  dXX=(mlat_deg[ in2d[lp-1] ]-mlat_deg[ in2d[lp] ])*0.95*factor
;else $
;  dXX=1.00

    for ipts=istrt,istop,istep   do begin
;dYY=(z_km[ipts+1]-z_km[ipts] )*1.0 ;
;dYY=5.;1.6;(z_km[ipts+1]-z_km[ipts] )*0.9 ;nm20121130
dYY=(z_km[ipts+1]-z_km[ipts] )*0.9 ;nm20121130

if ( z_km(ipts  ) gt HTmin ) and ( z_km(ipts) lt (HTmax-dYY) ) then begin
if ( mlat_deg(ipts ) gt gLATmin ) and ( mlat_deg(ipts) lt gLATmax ) then begin

;if ( mlat_deg[ipts] gt -37. ) AND (z_km[ipts] lt 300. ) then $
if (z_km[ipts] gt 301. ) AND (z_km[ipts] lt 303. ) then $
print, 'lp=',lp,ipts, mlat_deg[ipts],z_km[ipts]

Xa=mlat_deg(ipts) ;-dXX*.5
Xb=mlat_deg(ipts) ;-dXX*.5   ;glatd(ipts  ,ifl)+dLAT  ;
Xc=mlat_deg(ipts)+dXX ;*.5  ;Xb  ;
Xd=mlat_deg(ipts)+dXX ;*.5  ;Xa  ;
Ya=z_km(ipts) ;-dYY*.5
Yb=z_km(ipts)+dYY ;*.5 ;Ya ;
Yc=z_km(ipts)+dYY ;*.5 ;Ya+dHT ;
Yd=z_km(ipts) ;-dYY*.5   ;Yc     ;




 X=[Xa, Xb, Xc, Xd]  ;glat [deg]
 Y=[Ya, Yb, Yc, Yd]  ;altitude [km]

if ( VarType eq 0 ) OR ( VarType ge 3 ) then begin

  
  density=plot_z[n_read,VarType, 0,ipts] * 1.0E-6  ;m-3 --> cm-3
  if ( density gt 0.0 ) then $
     Value= ALOG10( density ) $
  else $ 
     Value= ALOG10( 0.1 )

;20131204debug
Value=plot_z[n_read,VarType, 0,ipts] * factor_value


endif else if ( VarType eq 1 ) or ( VarType eq 2 ) then $ ;Te/i
  Value = plot_z[n_read,VarType,0,ipts] ;



; save actual MIN & MAX values
if ( Value lt ARY_minZ ) then  ARY_minZ=Value

if ( Value gt ARY_maxZ ) then begin
 ARY_maxZ=Value
; print,'ARY_maxZ',ARY_maxZ,' z_km',z_km(ipts),' mlat',mlat_deg(ipts)
endif

ColorData=(col_max-col_min)*(Value-ARY_min0(VarType))/(ARY_max0(VarType)-ARY_min0(VarType)) + col_min


;061904: for fancy looking
if ( ColorData lt col_min ) then  ColorData=col_min
if ( ColorData gt col_max ) then  ColorData=col_max

;091604: debug
;091604: if ( (ipts MOD 2)  eq 0 ) then $
POLYFILL, X , Y       $      ;[, Z]]
, FILL_PATTERN=0      $      ; solid fill
, COLOR=ColorData    ;$
;[, IMAGE_COORD=array]
;[, /IMAGE_INTERP] 
;[, /LINE_FILL] 
;[, PATTERN=array] 
;[, SPACING=centimeters] 
;[, TRANSPARENT=value]
;[, CLIP=[X 0 , Y 0 , X 1 , Y 1 ]] 
;[, /DATA | , /DEVICE | , /NORMAL] 
;[, LINESTYLE={0 | 1 | 2 | 3 | 4 | 5}] 
;[, /NOCLIP] 
;[, ORIENTATION=ccw_degrees_from_horiz] 
;[, /T3D] 
;[, THICK=value] 
;[, Z=value]

if ( sw_arw_vpara eq 1 ) AND $
 ( (lp MOD lp_step_arrow) eq 2 ) AND $
 ( (ipts MOD 10) eq 0 ) then begin
x2= (mlat_deg[ipts+1]-mlat_deg[ipts])*(mlat_deg[ipts+1]-mlat_deg[ipts])
y2= (z_km[ipts+1]-z_km[ipts])*(z_km[ipts+1]-z_km[ipts])
dr=SQRT( x2 + y2 )
cosI=SQRT( x2 ) / dr
sinI=SQRT( y2 ) / dr
;
X0_arrow = mlat_deg[ipts]
Y0_arrow = z_km[ipts]
Vpara    = plot_z[n_read,VarType,mp,ipts]*fac_arw_para
dX_arrow = Vpara *cosI
dY_arrow = Vpara *sinI
X1_arrow = X0_arrow + dX_arrow
Y1_arrow = Y0_arrow + dY_arrow

LOADCT, 0
head_thick=2.0
head_size=!D.X_SIZE / 64.*0.5 
if ( sw_debug ) then $
 print, 'head_size', head_size
;
  ARROW, X0_arrow, Y0_arrow, X1_arrow, Y1_arrow  $
, /DATA       $ ;???
, /NORMALIZED $
, HSIZE=head_size $
, COLOR=col_max  $ ;index] $
, HTHICK=head_thick $ ;value] $
;, /SOLID] $
, THICK=3 ;value]
LOADCT, N_LDCT
endif ;( sw_arw_vpara ) then begin


endif ;( glatd(ipts  ,ifl-1) gt gLATmin ) and ( glatd(ipts  ,ifl-1) lt gLATmax) thenbegin
endif  ;( gpz(ipts  ,ifl-1) gt HTmin ) then begin
endfor  ;ipts=istrt,istop,istep   do begin
endfor  ;ihem=1,1   do begin



;draw arrow of EXB drift at midpoint

if ( z_km[midpoint] le HTmax ) AND ( z_km[midpoint] ge HTmin ) then  begin

if ( sw_arrow_exb eq 1 ) AND (lp le lpmax_perp_trans) then begin
if ( lp le 46 ) $ ;mlat-30 boundary
OR ( lp eq lpmax_perp_trans ) $ ;transport boundary
OR ( (lp MOD lp_step_arrow) eq 2  ) then begin

;print, 'check exb!',n_read,mp,lp,plot_VEXB[n_read,mp,lp], z_km[midpoint]

X0_arrow = mlat_deg[midpoint]
Y0_arrow = z_km[midpoint]
dX_arrow = 0.
dY_arrow = plot_VEXB[n_read,mp,lp] * factor_arrow
X1_arrow = X0_arrow + dX_arrow
Y1_arrow = Y0_arrow + dY_arrow

LOADCT, 0
head_thick=2.0
head_size=!D.X_SIZE / 64.*0.5 
if ( sw_debug ) then $
 print, 'head_size', head_size
  ARROW, X0_arrow, Y0_arrow, X1_arrow, Y1_arrow  $
, /DATA       $ ;???
, /NORMALIZED $
, HSIZE=head_size $
, COLOR=col_max  $ ;index] $
, HTHICK=head_thick $ ;value] $
;, /SOLID] $
, THICK=3 ;value]
LOADCT, N_LDCT
endif ;( (lp MOD lp_step_arrow) eq 0  ) then begin
endif ;( sw_arrow_exb ) then begin

endif ;( z_km[midpoint] lt ) then  begin


endfor  ;lp=lp_strt,lp_stop do begin


;draw arrow of reference for 50m/s
if ( sw_arrow_exb eq 1 ) then begin
X0_arrow = gLATmax +  2.0
Y0_arrow = HTmin   - 60.
dX_arrow = 0.
dY_arrow = reference_arrow * factor_arrow
;dY_arrow = reference_arrow * fac_arw_para
X1_arrow = X0_arrow + dX_arrow
Y1_arrow = Y0_arrow + dY_arrow

LOADCT, 0
head_thick=2.0
head_size=!D.X_SIZE / 64.*0.5 
if ( sw_debug ) then $
 print, 'head_size', head_size
  ARROW, X0_arrow, Y0_arrow, X1_arrow, Y1_arrow  $
, /DATA       $ ;???
, /NORMALIZED $
, HSIZE=head_size $
, COLOR=col_max  $ ;index] $
, HTHICK=head_thick $ ;value] $
;, /SOLID] $
, THICK=3 ;value]

xyouts, (X0+dX-0.4)/X_SIZE, (Y0-0.7)/Y_SIZE, STRTRIM(STRING(reference_arrow , FORMAT='(I2)'),1)+'m/s'  $
, charsize=1.0, charthick=1.0, /norm, /noclip
LOADCT, N_LDCT

endif ;( sw_arrow_exb ) then begin



;20140121 
;print,'n_read=', n_read , n_read_max
  if ( n_read eq n_read_max-1 ) then begin
;Draw_Colorbar, ARY_min0(VarType), ARY_max0(VarType), N_LVLs $
;, col_min, col_max, X1, Y1, dX1, dY1, X_SIZE, Y_SIZE, VarType
charsize_colorbar=3.0
format_colorbar='(E9.1)'
font=1 ;true-type 
;20140130 i dont understand why vertical keyword doesnt work???
position=[0.20, 0.17, 0.80, 0.18] ;for horizontal bar
COLORBAR, BOTTOM=bottom, CHARSIZE=charsize_colorbar, COLOR=color, DIVISIONS=divisions $
        , FORMAT=format_colorbar, POSITION=position $
, MAXRANGE=ARY_max0[VarType] $
, MINRANGE=ARY_min0[VarType] $
        , NCOLORS=ncolors,TITLE=title,VERTICAL=vertical,TOP=top,RIGHT=right $
        , MINOR=minor, RANGE=range, FONT=font, TICKLEN=ticklen $
        , _EXTRA=extra, INVERTCOLORS=invertcolors, TICKNAMES=ticknames
endif ;( n_read eq n_read_max-1 ) then begin

;LT
;xyouts, (X0-2.)/X_SIZE, (Y0+dY+2.45)/Y_SIZE, STRTRIM(STRING( zthr, FORMAT='(F5.2)'),1)+'LT'  $
;, charsize=1.0, charthick=1.0, /norm, /noclip


print,'MIN',ary_minz,' MAX',ary_maxz
; add MIN & MAX values
;20140121 xyouts, (X0-0.8)/X_SIZE, (Y0+dY+0.6)/Y_SIZE, 'MIN='+STRTRIM(STRING( ARY_minZ, FORMAT='(E11.3)'),1)+' MAX='+STRTRIM(STRING( ARY_maxZ, FORMAT='(E11.3)'),1)  $
;, charsize=1.0, charthick=1.0, /norm, /noclip


;20140121 
  if ( n_read eq n_read_max-1 ) then begin
x_xyouts=0.8
y_xyouts=0.1
dy_xyo=0.03
xyouts, 0.75, 0.10 $
, MainTitle+' mp'+STRTRIM(STRING( (mp+1), FORMAT='(i3)'),1)+' glon'+STRTRIM(STRING( glon_deg2D[mp], FORMAT='(i4)'),1)+'[deg]' $ ;mp+1:ipe convention
, charsize=0.85, charthick=0.8, /norm, /noclip

xyouts, 0.5, 0.070 $
;, TEST+'_ipe_'+TEST2+'_'+TEST1 $
, input_DIR0 $
, charsize=0.85, charthick=0.8, /norm, /noclip
endif ;( n_read eq n_read_max-1 ) then begin


;STOP

if ( sw_debug eq 1 ) then  print, VarTitle(VarType), '  ARY_minZ=', ARY_minZ, ' ARY_maxZ=', ARY_maxZ
;endif ;( sw_plot_grid ne 1 ) then begin


    ; Close the "OUTPUT_DEVICE".
if ( device_type eq 'ps' ) then $
  DEVICE, /CLOSE $
else if ( device_type eq 'png' ) then begin

  if ( sw_anim eq 1 ) then FILE_DISP=plot_DIR+'anim/'+STRTRIM( string( (n_read+1), FORMAT='(i3)'), 1)+'.'+device_type

  if ( n_read eq n_read_max-1 ) AND (sw_output2file eq 1 ) then  output_png, FILE_DISP
endif


endfor  ;VarType=0,1 do begin  ;0,NPAR-1


endfor ;mp=0,40, 40 do begin



end
