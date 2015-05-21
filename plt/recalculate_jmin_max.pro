;20140528: need to recalculate IN, IS for the new plasma grid output
; because jacques changed the definition of IN/IS 20121131.
pro recalculate_jmin_max, JMIN_IN, JMAX_IS, NLP,sw_debug

in_old = JMIN_IN
is_old = JMAX_IS

;initialization
in_new = in_old
is_new = is_old

;calculate the old way of IN, IS before jacques changed...

for lp=1,nlp-1 do begin

  in_new[lp] = is_new[lp-1] + in_old[lp]
  is_new[lp] = in_new[lp] + is_old[lp] -1

endfor ;lp=0,nlp-1 do begin

if  sw_debug eq 1 then begin
  print, 'IN_new', in_new
  print, 'IS_new', is_new
endif

JMIN_IN = in_new
JMAX_IS = is_new

print, 'sub- recalculate_jmin_max finished'
end ;pro recalculate_jmin_max
