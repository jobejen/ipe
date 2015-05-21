pro      ctr_plt_psphere    $ 
  , IN2d,IS2d,Z_km,mlat_deg  $ 
  , plot_z,plot_VEXB,n_read   $
  , UThr, plot_DIR, title_res,rundate,title_test,sw_debug, title_hemi,sw_anim,mp_plot, lt_hr, fac_window $
  , sw_output2file

size_result = SIZE(in2d)
NLP=size_result[1]
;if ( sw_debug eq 1 ) then  
print, 'NLP=', NLP
size_result = SIZE(z_km)
NPTS2D=size_result[1]
;if ( sw_debug eq 1 ) then  
print, 'NPTS2D=', NPTS2D
N_LDCT=39
Re_m=6.3712E+06 ;.. Earth radius [meter]

nmax=npts2D *2
xx=dblarr(nmax)
yy=dblarr(nmax)
n_count=-1L
for mp=mp_plot,mp_plot+40,40 do begin
;; plot GLAT v.s. ALT Flux-Tube Distribution
for lp=0,NLP-1 do begin   ;ifl-->lp

  in = IN2D[lp]-1L
  is = IS2D[lp]-1L 
  for i=in,is do begin
     n_count=n_count+1
if (sw_debug eq 1) then     print, 'mp',mp,' lp',lp,' i',i,' n_count',n_count

;  istrt=istop +1
;  istop=istrt+(is-in) ;istrt +(iseb(ifl)-ineb(ifl))

     theta_rad = +!PI*0.50 - mlat_deg[i]*!PI/180.0  
     r_meter = Z_km[i] * 1.0E+3  + Re_m
     if ( mp eq mp_plot ) then $
        factor=1.0 $
     else if ( mp eq (mp_plot+40) ) then $
        factor=-1.0

     xx[n_count] = r_meter*SIN(theta_rad)*factor /  Re_m
     yy[n_count] = r_meter*COS(theta_rad) /  Re_m
 endfor ;i=in,is do begin
endfor  ;lp=lp_strt,lp_stop do begin
endfor ;mp
nmax=n_count


X_min=-6.0
X_max=6.0
Y_min=-6.0
Y_max=6.0




; include contour_plot_2d.pro

n_read0=0L
sw_plot_grid=0L  ;1: plot grid only
sw_arrow_exb=0L
reference_arrow=40L  ;m/s
factor_arrow=5.
lp_step_arrow=7
lpmax_perp_trans=37;151-1
mpstart=mp_plot;0
mpstop=mp_plot+40;0
mpstep=40;1


HTmin=-6.;   90.  ;min(yy)   ;75.   ;400. ;
HTmax=+6.;1.500000E+03;700.; 
; plot range
;if ( title_hemi eq 'NH' ) then begin
  gLATmax=+6.;+65.;+90.;-10.;
  gLATmin=-6.;+50.;-gLATmax;-27.; 
;endif else if ( title_hemi eq 'SH' ) then begin
;  gLATmax=-5.;+90.;-10.;
;  gLATmin=-65.;+50.;-gLATmax;-27.; 
;endif else if ( title_hemi eq 'glb' ) then begin
;  gLATmax=+60.;+90.;-10.;
;  gLATmin=-60.;+50.;-gLATmax;-27.; 
;endif else if ( title_hemi eq 'eq' ) then begin
;  gLATmax=+30.;+90.;-10.;
;  gLATmin=-0.5;+50.;-gLATmax;-27.;
;  HTmax=1.001E+03 
;endif




;title_test='trans'
sw_dif=0L
device_type='png' ;ps';'



N_LDCT=39;33
lp_strt=1;28-1;  0+1 ;58;0;63 ;1-1L
lp_stop=NLP-1-1 ;138L;
VarType_min=0L
VarType_max=0L ;PAR-1
VarType_step=1L



;if ( uthr le 0.00 ) then $
;  time_string='00'+STRTRIM(STRING( uthr-24.0, FORMAT='(F8.4)'),1)+'UT' $
;else 
if ( uthr lt 1.0E+01 ) then $
  time_string='00'+STRTRIM(STRING( uthr, FORMAT='(F8.4)'),1)+'UT'  $
else if ( uthr lt 1.0E+02 ) then $
  time_string='0'+STRTRIM(STRING( uthr, FORMAT='(F8.4)'),1)+'UT'  $
else $ ;if ( uthr ge 1.0E+02 ) then $
  time_string=STRTRIM(STRING( uthr, FORMAT='(F8.4)'),1)+'UT'

for mp=mpstart,mpstop, mpstep do begin
if ( sw_debug eq 1 ) then  print, 'mp=',mp

;042004:
;if ( elhr le 0.00 ) then $
FileID=time_string+'_'+STRTRIM(STRING( lt_hr, FORMAT='(F6.2)'),1)+'LT'+'_mp'+STRTRIM(STRING( (mp+1), FORMAT='(i3)'),1) ;mp+1:ipe convention

VarTitle=[ $
'Ne',$
'Te',$ 
'No+',$
'hr4',$;'NH+',$
'NHe+','Te','To+','o+flux','Vo+']

VarUnit= $
[ $
'[K]', $ ;Te
'[log!D10!N cm-3]',$
'[J/kg/s]', $;hrate
'[log!D10!N cm-3]','[log!D10!N cm-3]','[log!D10!N cm-3]' $
,'[K]','[K]' $
,'[cm2 s-1]' $
,'[m/s]']

X_Title='MAGNETIC LATITUDE [deg.]'
Y_Title='ALTITUDE [km]'

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
           1.,$;3.,$
178.8, $
0.,$ ;hrate
 3., 3., 3. $  ;densities
        ,  178.8        ,  178.8  $      ;To+;Te
        ,  -1.0E+13  $;flux [cm2 s-1]
        ,  -3500.  $   
         ] 

ARY_max0=[ $
           4.,$;7.,$
4657. ,$
77.,$ ;hrate
 7., 7., 7.  $ ;densities
        ,  3600. ,   3600.  $    ;To+,Te
        ,  +1.0E+13  $
        ,  +3500.     $  ;vel [m s-1]
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
;*** Load color table
LOADCT, N_LDCT



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








for VarType=VarType_min , VarType_max,  VarType_step   do begin
if ( sw_debug eq 1 ) then  print,'plotting ',VarTitle(VarType)
MainTitle=VarTitle(VarType)+' '+VarUnit(VarType)
FILE_DISP=plot_DIR+device_type+'/'+title_hemi+'/'+FileID+'_'+VarTitle(VarType)+'_'+title_res+'.'+STRTRIM( string(rundate, FORMAT='(i8)'), 1)+title_test+'.'+title_hemi+'.psphere.'+device_type
if ( sw_debug eq 1 ) then  print, file_disp
if ( device_type eq 'ps' ) then begin



  SET_PLOT, 'ps' ;'x'
   ; Open a file in the current directory 
   ; to contain the PostScript plot.
  DEVICE, BITS_PER_PIXEL=24,/COLOR, $
  FILENAME=FILE_DISP, /LANDSCAPE,    $
  SET_FONT='Courier',       /TT_FONT, $
  XSIZE=X_SIZE, YSIZE=Y_SIZE, XOFFSET=0.0, YOFFSET=X_SIZE
endif else  if ( device_type eq 'png' ) then begin

if ( mp eq mpstart ) then begin
  !P.MULTI=[0,2,2,0,1]
  ;1:# of plot columns
  ;2:# of rows

if ( sw_debug eq 1 ) then  print, 'before',!P.BACKGROUND
  !P.BACKGROUND=0 ;255
if ( sw_debug eq 1 ) then  print, 'after',!P.BACKGROUND

; plot height profile
  device, decomposed = 0 ,retain=2
  window, 0 ,XSIZE=500*fac_window,YSIZE=500*fac_window
endif ;( mp eq mpstart ) then begin

;t  axis_color = 0.0 ;255.99 $
;t  char_size = 1.5

endif

LOADCT, N_LDCT

;if ( sw_plot_grid eq 1 ) then begin ;20120328
;LOADCT, 0
if ( mp eq mpstart ) then $
Plot, xx(0:nmax), yy(0:nmax)     $
, Xstyle = 1, Xrange = [ X_min, X_max]  $
, Ystyle = 1, Yrange = [ Y_min, Y_max]      $
, TITLE = MainTitle+'   '+FileID, SUBTitle =' ' $   ;FileID $
, XTITLE = X_Title,    YTITLE = Y_Title  $
, PSYM =  3,  SYMSIZE=1.0  $
;, Color = col_min  $
;, CharSize = 1.5 $
;, THICK    = 1.0 $
, Pos = [X0/X_SIZE, Y0/Y_SIZE, (X0+dX)/X_SIZE, (Y0+dY)/Y_SIZE]  ;$
;,/NODATA
;,/NO_ERASE


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

if ( sw_debug ) then $
;if ( (lp+1) ge 148 ) AND ( (lp+1) le 155 ) then $
 print,'lp=', lp, in2d[lp], mlat_deg[ in2d[lp] ]

; midpoint = JMIN_IN(lp) + ( JMAX_IS(lp) - JMIN_IN(lp) )/2
  midpoint =      IN2D[lp]+ (     IS2D[lp] -    IN2D[lp]    )/2  -1 

if ( sw_debug ) then $
;if ( (lp+1) ge 148 ) AND ( (lp+1) le 155 ) then $
 print,(lp+1),midpoint,'mlat',mlat_deg[ midpoint ]  ,'midpoint z', z_km[ midpoint ],' max z',MAX( z_km[ IN2D[lp]:IS2D[lp] ] )


  for ihem=0,1   do begin

    istrt=midpoint
    if ( ihem eq 0 ) then begin ;North
      istep=-1
      istop=in2d[lp]-istep 
;      factor=+1.0
    endif else if ( ihem eq 1 ) then begin   ;South
      istep=+1
      istop=is2d[lp]-istep 
;      factor=-1.0
    endif



;if ( lp ge 50 ) then $
;  dXX= (mlat_deg[ in2d[lp-1] ]-mlat_deg[ in2d[lp] ])*0.95*factor
;else $
;  dXX=1.00

    for ipts=istrt,istop,istep   do begin

     theta_rad = +!PI*0.50 - mlat_deg[ipts]*!PI/180.0  
     r_meter = Z_km[ipts] * 1.0E+3  + Re_m

     if ( mp eq mp_plot ) then $
        factor=1.0 $
     else if ( mp eq (mp_plot+40) ) then $
        factor=-1.0

     xx = r_meter*SIN(theta_rad)*factor /  Re_m
     yy = r_meter*COS(theta_rad) /  Re_m

;if ( lp eq 80 ) then print,mp,lp,ipts,theta_rad,r_meter,xx,yy

;dYY=(z_km[ipts+1]-z_km[ipts] )*1.0 ;
     dXX = 0.05
     dYY = dXX

;if ( yy gt HTmin ) and ( yy lt (HTmax-dYY) ) then begin
;if ( xx gt gLATmin ) and ( xx lt gLATmax ) then begin

;if ( mlat_deg[ipts] gt -37. ) AND (z_km[ipts] lt 300. ) then $
;print, lp,mlat_deg[ipts],z_km[ipts]

Xa=xx
Xb=xx   ;glatd(ipts  ,ifl)+dLAT  ;
Xc=xx+dXX  ;Xb  ;
Xd=xx+dXX  ;Xa  ;
Ya=yy
Yb=yy+dYY ;Ya ;
Yc=yy+dYY ;Ya+dHT ;
Yd=yy    ;Yc     ;



 X=[Xa, Xb, Xc, Xd]  ;glat [deg]
 Y=[Ya, Yb, Yc, Yd]  ;altitude [km]

if ( VarType ge 0 ) AND ( VarType le 3 ) then begin

;;temporary 0Te, 
;if ( VarType eq 0 ) or ( VarType eq 2 ) then $
;  Value = plot_z[n_read,VarType,mp,ipts] $
;else begin

;for 1[O+]
  density = $
plot_z[n_read,VarType, mp,ipts] * 1.0E-6  ;m-3 --> cm-3
;(plot_z[n_read,VarType, mp,ipts] - plot_z[n_read0,VarType, mp,ipts]) * 1.0E-6  ;m-3 --> cm-3 ;dif
  if ( density gt 0.0 ) then $
    Value= ALOG10( density ) $
  else $ 
    Value= ALOG10( 0.1 )
;endelse

endif else if ( VarType ge 4 ) then $
  Value = plot_z[n_read,VarType,mp,ipts] $

;flux
else if ( VarType eq 6 ) then $
  Value = (plot_z[n_read,VarType,mp,ipts] - plot_z[n_read0,VarType,mp,ipts] )* 1.0E-4  $ ;m2 -->cm2  

;velocity
else if ( VarType eq 7 ) then $
  Value = plot_z[n_read,VarType,mp,ipts] - plot_z[n_read0,VarType,mp,ipts]


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

;endif ;( glatd(ipts  ,ifl-1) gt gLATmin ) and ( glatd(ipts  ,ifl-1) lt gLATmax) thenbegin
;endif  ;( gpz(ipts  ,ifl-1) gt HTmin ) then begin
endfor  ;ipts=istrt,istop,istep   do begin
endfor  ;ihem=1,1   do begin



;draw arrow of EXB drift at midpoint
if ( sw_arrow_exb eq 1 ) AND (lp le lpmax_perp_trans) then begin
if ( lp le 46 ) $ ;mlat-30 boundary
OR ( lp eq lpmax_perp_trans ) $ ;transport boundary
OR ( (lp MOD lp_step_arrow) eq 2  ) then begin
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

endfor  ;lp=lp_strt,lp_stop do begin


;draw arrow of reference for 50m/s
if ( sw_arrow_exb eq 1 ) then begin
X0_arrow = gLATmax +  2.0
Y0_arrow = HTmin   - 60.
dX_arrow = 0.
dY_arrow = reference_arrow * factor_arrow
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


if ( mp eq mpstop ) then $
Draw_Colorbar, ARY_min0(VarType), ARY_max0(VarType), N_LVLs $
, col_min, col_max, X1, Y1, dX1, dY1, X_SIZE, Y_SIZE, VarType

;LT
;xyouts, (X0-2.)/X_SIZE, (Y0+dY+2.45)/Y_SIZE, STRTRIM(STRING( zthr, FORMAT='(F5.2)'),1)+'LT'  $
;, charsize=1.0, charthick=1.0, /norm, /noclip


; add MIN & MAX values
if ( mp eq mpstop ) then $
xyouts, (X0-0.8)/X_SIZE, (Y0+dY+0.6)/Y_SIZE, 'MIN='+STRTRIM(STRING( ARY_minZ, FORMAT='(E11.3)'),1)+' MAX='+STRTRIM(STRING( ARY_maxZ, FORMAT='(E11.3)'),1)  $
, charsize=1.0, charthick=1.0, /norm, /noclip




if ( sw_debug eq 1 ) then  print, VarTitle(VarType), '  ARY_minZ=', ARY_minZ, ' ARY_maxZ=', ARY_maxZ
;endif ;( sw_plot_grid ne 1 ) then begin




endfor  ;VarType=0,1 do begin  ;0,NPAR-1
endfor ;mp=0,40, 40 do begin

    ; Close the "OUTPUT_DEVICE".
if ( device_type eq 'ps' ) then $
  DEVICE, /CLOSE $
else if ( device_type eq 'png' ) then begin

  if ( sw_anim eq 1 ) then FILE_DISP=plot_DIR+'anim/'+STRTRIM( string( (n_read+1), FORMAT='(i3)'), 1)+'.'+device_type

  if ( sw_output2file eq 1 ) then  output_png, FILE_DISP
endif




 print,'finished      ctr_plt_psphere '
;STOP
end ;
