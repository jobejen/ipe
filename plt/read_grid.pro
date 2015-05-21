;20121025: make sure to prepare the grid file (binary) in
;ipe/plt/grd/plasma_grid.XXX
pro read_grid,LUN,JMIN_IN,JMAX_IS,Z_km,mlat_deg,sw_debug,glat_deg,glon_deg,title_res


;20121025: .save did not save too much time as compared to the
;original binary file.....
sw_save_grid=0
filename_grid_sav='grd/plasma_grid.'+title_res+'.sav'

if ( sw_save_grid eq 2 ) then  begin
  LUN_old=LUN
  sw_debug_old=sw_debug
  title_res_old=title_res

  restore, filename=filename_grid_sav
  print,'restoring the grid file=',filename_grid_sav

  LUN=LUN_old
  sw_debug=sw_debug_old
  title_res=title_res_old
  RETURN
endif

     mp=41-1L

if sw_debug eq 1 then  print,'size jmin',SIZE(jmin_in)
if sw_debug eq 1 then  print,'size jmax',SIZE(jmax_is)




;if sw_debug eq 1 then  $
print,'size z_km',SIZE(Z_km)


if sw_debug eq 1 then  print,'size mlat_deg ',SIZE(mlat_deg)

NMP0=0L
NMP1=0L
NMP_all=0L
NLP_all=0L
NPTS2D_dum=0L
; read plasma_grid
if ( title_res eq 'dyn' ) OR ( title_res eq 'low20120709' ) OR ( title_res eq '2xdyn' ) $
;OR ( title_res eq 'td20120709' ) $
then begin
   readu, LUN[1], NMP0
if sw_debug eq 1 then    print,'NMP0',NMP0
   readu, LUN[1], NMP1
if sw_debug eq 1 then    print,'NMP1',NMP1
endif

    readu, LUN[1], NMP_all
if sw_debug eq 1 then print,'NMP_all',NMP_all
    readu, LUN[1], NLP_all
if sw_debug eq 1 then print,'NLP_all',NLP_all
    readu, LUN[1], NPTS2D_dum
if sw_debug eq 1 then print,'NPTS2D_dum',NPTS2D_dum


lpj=0L

    readu, LUN[1], JMIN_IN ;(1:NLP_all)
if sw_debug eq 1 then print,' lpj=',lpj,' JMIN_IN(lpj)=',JMIN_IN;[0:5]
    readu, LUN[1], JMAX_IS ;(1:NLP_all)
if sw_debug eq 1 then print,'JMAX_IS(lpj)',JMAX_IS;[0:5],JMIN_IN[lpj+1]

if ( title_res eq 'td20120709' ) then  recalculate_jmin_max, JMIN_IN, JMAX_IS, NLP_ALL,sw_debug

;lpj=129L ;low
;lpj=34L ;dyn
;ipts=JMIN_IN(75)-1
ipts=JMAX_IS(75)-1

    dum = fltarr( NMP_all+1 ) ;!rad
    readu, LUN[1], dum ;( 1: NMP_all+1 ) !rad
if sw_debug eq 1 then print,'mlon[deg]',dum[mp]*180./!PI
;for i=0,nmp_all-1 do print,'mlon[deg]',(i+1),dum[i]*180./!PI
;for i=40,50 do print,'mlon[deg]',(i+1),dum[i]*180./!PI


    dum = Z_km
    readu, LUN[1], dum ;(     1:NPTS2D_dum) !meter
     Z_km     = dum * 1.0E-3
if sw_debug eq 1 then print,lpj,ipts,' z_km',z_km[ipts]
    dum  = mlat_deg
    readu, LUN[1], dum ;(    1:NPTS2D_dum) !rad
     mlat_deg = ( !PI*0.50 - dum ) * 180.0 / !PI
if sw_debug eq 1 then print,'mlat_deg',mlat_deg[ipts]
;for lp=0,40,2 do begin 
;print, lp, mlat_deg[jmin_in[lp]-1]
;for i=jmin_in[lp]+75 , jmin_in[lp]+85,1  do print, i, (i-jmin_in[lp]-1),z_km(i)
;endfor ;lp
;stop


    dum=fltarr(NPTS2D_dum, NMP_all)
    readu, LUN[1], dum
    glat_deg = ( !PI*0.50 - dum ) * 180.0 / !PI
if sw_debug eq 1 then print,mp,'GCOLAT-deg',90.-dum[ipts, mp]*180./!PI


    dum=fltarr(NPTS2D_dum, NMP_all)
    readu, LUN[1], dum
    glon_deg = ( dum ) * 180.0 / !PI
if sw_debug eq 1 then print,'GLON_rad-deg',dum[ipts, mp]*180./!PI  


;d print,'GLON_rad-deg: mp=',mp,dum[ipts, mp]*180./!PI  
;d stop

;latres=fltarr(nlp_all)
;for lp=18,18 do begin
;j0=jmin_in[lp-1]-1
;j =jmin_in[lp]-1
;j =jmax_is[lp]-1
;print, (lp+1),(j+1), mlat_deg[j] , glat_deg[j,0], glon_deg[j,0]
;for i=200,0,-1  do print, (i+1),z_km[i-j]
;latres[lp]=(mlat_deg[j0] - mlat_deg[j])
;print, lp,mlat_deg[j], latres[lp], TOTAL( latres[1:lp] )/(FIX(lp-1+1))
;endfor
;stop




;for mp=0,nmp_all do begin
;lpj=129;jicamarca
;midpoint = JMIN_IN(lpj) + ( JMAX_IS(lpj) - JMIN_IN(lpj) )/2 -1
;print,'mp=',(mp+1),' GLON-deg',dum[midpoint, mp]*180./!PI  
;endfor
;stop

;for lpj=34,40L do begin
;ipts=JMAX_IS(lpj)-1 - 50
;print, lpj, ipts,z_km[ipts]
;for j=49,51,1 do print, j,glat_deg[ipts,j],glon_deg[ipts,j]
;endfor 
;STOP

;     readu, LUN[1], JMIN_IN,JMAX_IS,Z_meter,GL_rad


if sw_debug eq 1 then begin
for lp=0, nlp_all-1 do begin
i=jmin_in[lp]
print,(lp+1),mlat_deg[i]
endfor
endif
;20140106debug
;lp=NLP_all-1L
;if sw_debug eq 1 then  print,lp,'plasma0: IN=',JMIN_IN[lp],' IS=',JMAX_IS[lp],' #grid points=',(JMAX_IS[lp]-JMIN_IN[lp]+1),' z_km=',Z_km[lp],' mlat=',mlat_deg[lp]
;STOP


if ( sw_save_grid eq 1 ) then  begin
  print,'saving grid to a file=',filename_grid_sav
  save, filename=filename_grid_sav
  print,'saving grid finished'
endif

;20140815
;STOP

END ;PRO read_grid
