;20141114 example copied from the idl website
pro ts_wdvelovect

nx=30L
ny=20L

x=findgen(nx) * (!PI*2.)/(nx)
y=findgen(ny)

; Create some random data:
U = RANDOMN(S, nx, ny)
V = RANDOMN(S, nx, ny)
; Plot the vector field:
;VELOVECT, U, V
;VELOVECT, U, V, x, y
;WDVELOVECT, U, V  , x, y ;nm20141113

mag=SQRT(u^2 + v^2)
ang = ATAN(v,u)  ;atan2
;sinth = v/mag
;for i=0,nx-1 do begin
;   for j=0,ny-1 do begin
;      if sinth[i,j] ge 0 and sinth[i,j] le 1 then begin ;0<=theta<pi;;

;         if u[i,j] ge 0. then  $
;            angle[i,j] = ASIN(sinth[i,j]) $
;         else $
;            angle[i,j] = !PI - ASIN(sinth[i,j])
;         
;      endif else begin          ;pi<thetat<2pi
;         
;         if u[i,j] le 0. then  $
;            angle[i,j] = - ASIN(sinth[i,j]) + !PI $
;         else $
;            angle[i,j] = !PI*2. + ASIN(sinth[i,j])
;         
;      endelse;
;
;      print, sinth[i,j], angle[i,j]/!PI*180.
;   endfor                       ;j=0,ny-1 do begin
;endfor                          ;i=0,nx-1 do begin

;xrange=0.5
;yrange=0.5
WDVELOVECT, mag, ang  , x, y  $;nm20141113
, POLAR=POLAR ;$
;,/POLAR
;, XRANGE=xrange, YRANGE=yrange
; Plot the field, using dots to represent vectors with values 
; greater than 18:
;t VELOVECT, U, V, MISSING=18, /DOTS
; Plot with a title. Note that the XTITLE keyword is passed
; directly to the PLOT procedure:
;t VELOVECT, U, V, MISSING=18, /DOTS, XTITLE='Random Vectors'
end; pro
