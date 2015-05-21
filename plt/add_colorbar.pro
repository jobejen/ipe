pro add_colorbar $
, X0, X1, Y1 $
,value_max, value_min $
, iwindow $
,charsize,format
;print, "!p.multi", !p.multi

;dbg  print,charsize,format

;if ( iwindow eq 0 ) then  charsize=3.25 else $
;if ( iwindow eq 1 ) then  charsize=3.4 else $
;  charsize=3.4
title=' ';colorbar title'
font=1  ;True-Type: 1.

;if ( iwindow eq 0 ) then  format='(f6.1)' else $
;if ( iwindow eq 1 ) then  format='(f6.2)' else $
;format='(f6.2)'
 ;(f5.2)' ;I5)'   ;010405:
;if ( value_max lt 1.0 ) then format='(f6.2)'
;[, POSITION=[X 0 , Y 0 , X 1 , Y 1 ]]
;position=[0.88, 0.10, 0.95, 0.90] ;for a vertical bar 
;position=[0.10, 0.88, 0.90, 0.95] ;for a horizontal bar.

if !p.multi[2] gt 0  then begin
  Y_cmargin=0.070*2./!p.multi[2]
  dYc=0.012*2./!p.multi[2]
endif else begin 
Y_cmargin=0.070*2.
dYc=0.012*2.
endelse

;if ( iplot eq 0 ) then  $
position=[X0, Y1+Y_cmargin, X1, Y1+Y_cmargin+dYc]  ;$ ;for a
;horizontal bar.

;print, 'dbg081809',X0, Y1+Y_cmargin, X1, Y1+Y_cmargin+dYc
;else if ( iplot eq 1 ) then $
;  position=[0.50, 0.88, 0.90, 0.95]  $
;else if ( iplot eq 2 ) then $
;  position=[0.001, 0.002, 0.003, 0.004]  


; add colorbar
COLORBAR, BOTTOM=bottom, CHARSIZE=charsize, COLOR=color, DIVISIONS=divisions $
        , FORMAT=format, POSITION=position, MAXRANGE=value_max, MINRANGE=value_min $
        , NCOLORS=ncolors, TITLE=title, VERTICAL=vertical, TOP=top, RIGHT=right $
        , MINOR=minor, RANGE=range, FONT=font, TICKLEN=ticklen $
        , _EXTRA=extra, INVERTCOLORS=invertcolors,  TICKNAMES=ticknames

end ;add_colorbar
