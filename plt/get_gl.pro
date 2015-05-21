pro get_gl, mlat90_1,title_res,sw_debug

;title_res='low'
path='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/grid/plt/'
;20140221 filename_grid_sav='grd/plasma_grid.'+title_res+'.sav'
filename_grid_sav=path+'plasma_grid.'+title_res+'.sav'
restore, filename=filename_grid_sav
print,'restoring the grid file=',filename_grid_sav

;if sw_debug eq 1 then 
print,'mlat_deg',mlat_deg[0],mlat_deg[1114:1115]


;openr, LUN6, input_DIR+'fort.2006', /GET_LUN
;string='GL'
;readf, LUN6 , string
;print, string
mp=0
mlat=fltarr(2,nlp_all)
for i=1-1,nlp_all-1 do begin
;readf, LUN6, ii,lat,  FORMAT=formatF1
;NH
in_i=JMIN_IN[i,mp]-1
mlat(0,i)=mlat_deg[in_i] ;NH
;readf, LUN6, ii,lat,  FORMAT=formatF1
;SH
is_i=JMAX_IS[i,mp]-1
mlat(1,i)=mlat_deg[is_i] ;SH
endfor

if sw_debug eq 1 then begin 
print,'mlat90_N',mlat[0,*]
print,'mlat90_S',mlat[1,*]
endif

;mlat90_1=fltarr(nlp_all*2)
ii=-1
for i=1-1,nlp_all-1 do begin
  ii=ii+1
  mlat90_1[ii]=mlat[1,i]
endfor
for i=nlp_all-1, 1-1, -1 do begin
  ii=ii+1
  mlat90_1[ii]=mlat[0,i]
endfor
if sw_debug eq 1 then $
  print,ii

if sw_debug eq 1 then $
   print,'mlat90_1=',mlat90_1
print,'get_gl finished!'

end;
