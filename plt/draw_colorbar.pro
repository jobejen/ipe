;040604: copied from ctip/plot_idl/sub_draw_figure.pro
;       var_type was removed from the argument -> VarType was added
;       N_LVLs is changed from array to scalar
; CATEGORY: sub routine program
; STATE   : underconstruction
; DATE    : Oct.25 2001
; FILE NAME: draw_colorbar.pro
; NAME    : Draw_Colorbar
; VERSION : original
;PURPOSE  : draw a colorbar
; INPUT   :
; NOTE    :


PRO Draw_Colorbar, ARY_min1, ARY_max1, N_LVLs $
   , col_min, col_max, X0, Y0, dX, dY, X_SIZE, Y_SIZE, VarType, text_color

char_size=1.2
; prepare display parameters
main_TITLE=' '

if ( VarType eq 0 ) then $
  X_TICKFORMAT='(F5.2)'  $
else if ( VarType eq 1 ) or ( VarType eq 2 ) then $
  X_TICKFORMAT='(F5.0)'  $
else if ( VarType ge 4 ) and ( VarType ge 5 ) then $
  X_TICKFORMAT='(F5.0)'  $
else if ( VarType eq 6 ) then $
  X_TICKFORMAT='(E6.0)'  $
else if ( VarType eq 7 ) then $
  X_TICKFORMAT='(F5.0)'

;tmp20111202 temporary for Te
;if ( VarType eq 0 ) then X_TICKFORMAT='(F5.0)'

    ; prepare colorbar
N_colorbar_LVLs=5


; set up axis values
x=fltarr(N_colorbar_LVLs)
x=findgen(N_colorbar_LVLs)*(ARY_max1-ARY_min1)/(N_colorbar_LVLs-1) + ARY_min1
y=findgen(2)


col_data=fltarr(N_colorbar_LVLs,2)
for i=0, N_colorbar_LVLs-1      do  col_data(i,*)=i*col_max/(N_colorbar_LVLs-1)


contour, col_data, x,y $
,min_value=col_min, max_value=col_max $
,levels=findgen(N_LVLs+1)*(col_max-col_min)/N_LVLs + col_min $
,charsize = char_size $
;,TITLE=main_TITLE   $
;,SUBTITLE=sub_TITLE $
;,XTITLE=X_axis, YTITLE=Y_axis  $
;,xmargin=9, ymargin=5  $
,xstyle=1, ystyle=4  $
,XRANGE=[ARY_min1, ARY_max1] $
,XTICKFORMAT=X_TICKFORMAT  $
,XTICKLEN=0.5  $
,XTICKS=5  $
, /CLOSED $
, /FILL   $
, /NOERASE   $
, c_colors=INDGEN(N_LVLs+1)*col_max/N_LVLs $
, pos=[X0/X_SIZE, Y0/Y_SIZE, (X0+dX)/X_SIZE, (Y0+dY)/Y_SIZE] $
, COLOR=text_color

end
