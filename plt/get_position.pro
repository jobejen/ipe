pro get_position $
, iplot, iwindow $
, X0 , Y0 , X1 , Y1 

;print, "!p.multi", !p.multi


X00=0.03
if ( iwindow eq 0 ) then begin
  Y01=0.500  ;0.550
  Y02=0.050  ;0.060
   dY=0.280  ;0.34
endif else if ( iwindow eq 1 ) then begin
  Y01=0.110 ;0.060
  Y02=0.060
   dY=0.580  ;0.30*2.

endif else if ( iwindow eq 2 ) then begin
  Y01=0.060
  Y02=0.060
   dY=0.30*2.

endif

dX=0.28
dX_margin=0.05

; [X0 , Y0 , X1 , Y1 ] $
if ( iplot eq 0 ) then  begin
  X0=X00
  Y0=Y01

 endif else if ( iplot eq 1 ) then begin
  X0 = X00 + (dX+dX_margin)
  Y0 = Y01

 endif else if ( iplot eq 2 ) then  begin
  X0 = X00 +  (dX+dX_margin)* 2.
  Y0 = Y01

 endif else if ( iplot eq 3 ) then  begin

  X0 = X00
  Y0 = Y02

 endif else if ( iplot eq 4 ) then  begin

  X0=X00 + (dX+dX_margin)
  Y0=Y02

 endif else if ( iplot eq 5 ) then  begin

  X0 = X00 + (dX+dX_margin) * 2.
  Y0 = Y02

endif

  X1=X0+dX
  Y1=Y0+dY
end
