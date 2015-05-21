function hat,xin
; hat function, between 0 and 1

x = xin mod 1

; print,' x =',x

l=size(x)

if (l(0) eq 0) then begin
  l(1) = 1
endif

;print,' length =',l(1)

yout = fltarr(l(1))

for i=0,l(1)-1 do begin

 if(x(i) le 0.5)then begin
  yout(i) = 2.0*x(i)
 endif else begin
  yout(i) = 1.0 - 2*(x(i) - 0.5)
 endelse

endfor

return, yout

end 
