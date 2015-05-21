;opening files
pro open_fort168, n_file,LUN,sw_debug,title_hemi,lp_title,sw_fort,rundir,TEST0

HOME_DIR=$
'/home/Naomi.Maruyama/wamns/'+TEST0+'/trunk/run/'
;'/home/Naomi.Maruyama/iper/'
;'/lfs0/projects/idea/maruyama/sandbox/ipe/run/'

input_DIR=['','','','']
rundate='20110817'
rundate1='20110813'
versionD='1d'
;test='high'
test1='low'
;blue lp10
input_DIR[0]=$
rundir+'/'
;rundate+'.'+versionD+'.lp'+STRTRIM( string(   lp_title,     FORMAT='(i2)'),1)+'.'+test1+'/'
;red  lp11
input_DIR[1]=rundate+'.'+versionD+'.lp'+STRTRIM( string(  (lp_title+1),  FORMAT='(i2)'),1)+'.'+test1+'/'
;green lp12
input_DIR[2]=rundate+'.'+versionD+'.lp'+STRTRIM( string(  (lp_title+2),  FORMAT='(i2)'),1)+'.'+test1+'/'
;orange lp9
input_DIR[3]=rundate+'.'+versionD+'.lp'+STRTRIM( string(  (lp_title-1),  FORMAT='(i1)'),1)+'.'+test1+'/'


input_flnm=['','','','']

if ( sw_fort eq 168L ) then begin
  if ( title_hemi eq 'NH' ) then  lun_no='168' else $
  if ( title_hemi eq 'SH' ) then  lun_no='171'
endif else if ( sw_fort eq 167L ) then begin
  if ( title_hemi eq 'NH' ) then  lun_no='167' else $
  if ( title_hemi eq 'SH' ) then  lun_no='170'
endif 

input_flnm[0:3]  ='fort.'+lun_no
;input_flnm[2:3]='fort'+lun_no

  for i = 0, n_file-1  do begin

    openr, LUNi, HOME_DIR+input_DIR[i]+input_flnm[i], /GET_LUN
    LUN[i]=LUNi
    print,title_hemi,' opening file:',HOME_DIR+input_DIR[i]+input_flnm[i], LUN[i]

  endfor ;i = 0, n_file-1  do begin
end ;pro open_fort168
