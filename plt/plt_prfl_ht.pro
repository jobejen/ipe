;20140610: sw_dif: underconstruction
;pro plot_profile_ht
pro plt_prfl_ht
fac_window=1.
sw_dif=0
sw_output2file=1L
TEST0='r336.2'
HOME_DIR='/home/Naomi.Maruyama/wamns/'+TEST0+'/trunk/run'
;CHANGE!!!
TEST2='S'
TEST1='28822'
;TEST-->rundir
rundir=$
;'ipe_80_17352dbg' ;lp=44
;'ipe_80_7459dbg' ;lp=48
'ipe_'+TEST2+'_'+TEST1
plot_UT =2.0
;frequency of plotting in hr
freq_plot_hr=120./3600.;3600./3600.
;READ, freq_plot_hr,PROMPT='Enter frequency of plotting in hour:' 

title_hemi='NH'
;READ, title_hemi,PROMPT="Enter which hemisphere?: NH or SH" 

sw_fort=168L;167L;168L
;READ, sw_fort,PROMPT="Enter which fort?: 167 or 168"


mp_plot=10-1L ;<--read from the 167 file!

n_file=1L
FLDIM0=LONARR(n_file)

;CHANGE!!!
if ( rundir eq 'ipe_80_17352dbg' ) then begin
  lp_title    =44-1L ;<--read from the 167 file!
   mlat_title ='34.37' ;<--read from 167 file! =GL/!PI*180. lp=44
   FLDIM0     =[ 395L ] ;<--read from the 167 file! lp=44
endif else if ( rundir eq 'ipe_80_7459dbg' ) then begin
  lp_title    =48-1L
  mlat_title  ='29.67' ;<--read from 167 file! =GL/!PI*180. lp=48
  FLDIM0     =[ 313L ] ;<--read from the 167 file! lp=48
endif
;mp=10-1, lp=14-1
  lp_title    =14-1L
  mlat_title  ='75.38' ;<--read from 167 file! =GL/!PI*180. lp=48
  FLDIM0     =[ 577L ] ;<--read from the 167 file! lp=48

sw_debug=0L
plot_DIR=$
"~/wamns/fig/prfl/"
;HOME_DIR+'/fig/'+TEST0+'/'
;'../figures/discon/1dnewflipgrid/fort'+STRTRIM( string(sw_fort, FORMAT='(i3)'), 1)+'/'


  LUN  = INTARR(n_file)
 UT_hr = fltarr(n_file)
 LT_hr = fltarr(n_file)
FLDIM_max=MAX(FLDIM0)
    plot_y = fltarr(      FLDIM_max,n_file)
plot_type_max=4L
k_species = 4L
    plot_x = fltarr(plot_type_max, k_species, FLDIM_max,n_file)
FLDIM_plot=LONARR(n_file)

; temporary array just for reading
 UT_hr0 = 0.0
 UT_hr0_save = -99999.
 LT_hr0 = 0.0


;FLDIMphil=401
;opening files
   open_fort168, n_file,LUN,sw_debug,title_hemi,lp_title,sw_fort,rundir,TEST0

n_read=-1L
   while ( EOF(LUN[0]) eq 0 ) do begin
n_read=n_read+1

if n_read eq 1 then STOP

     plot_x[*,*,*,*] =-999999999.999999
     for i = 0, n_file-1  do begin
print,'i',i,'n_file',n_file
FLDIM=FLDIM0[i]
;dbg print,'FLDIM0=',FLDIM0
if ( n_read eq 0 ) then  print,'FLDIM=',FLDIM
FLDIM_plot[i]=FLDIM

     Z0 = fltarr(FLDIM)
if ( sw_fort eq 168 ) then begin
   TNX0 = fltarr(FLDIM)
    UN0 = fltarr(FLDIM) ;cm/s
   NNO0 = fltarr(FLDIM)
 PHION0 = fltarr(FLDIM)
 VOP0   = fltarr(FLDIM) ; O+ field alinged velocity
   EHT0 = fltarr(FLDIM) ; EHT(3,J):e heating rate   
    TI0 = fltarr(3,FLDIM)
     N0 = fltarr(4,FLDIM)
SUMION0 = fltarr(3,FLDIM)  ;SUMION(1,7,J)+SUMION(2,4,J)+SUMION(2,5,J)
 xionn0  = fltarr(4,FLDIM)
 eqn2d0 = fltarr(FLDIM)
nplsrd0 = fltarr(FLDIM)

if ( sw_dif eq 1 ) then begin
     N1 = fltarr(4,FLDIM)
    TI1 = fltarr(3,FLDIM)
 PHION1 = fltarr(FLDIM)
    UN1 = fltarr(FLDIM) ;cm/s
SUMION1 = fltarr(3,FLDIM)  ;SUMION(1,7,J)+SUMION(2,4,J)+SUMION(2,5,J)
endif

endif else if ( sw_fort eq 167 ) then begin
SL = fltarr(FLDIM)
GL = fltarr(FLDIM)
BM = fltarr(FLDIM)
GR = fltarr(FLDIM)
SZA = fltarr(FLDIM)
O0 = fltarr(FLDIM)
H0 = fltarr(FLDIM)
N20 = fltarr(FLDIM)
O20 = fltarr(FLDIM)
HE0 = fltarr(FLDIM)
N4S0 = fltarr(FLDIM)
endif

;print, 'i', i,FLDIM
if ( i eq 0 ) then sw_version = 1  else $
if ( i eq 1 ) then sw_version = 3  else $
if ( i eq 2 ) then sw_version = 3  else $
if ( i eq 3 ) then sw_version = 3
;dbg print,' sw_version=', sw_version

;       if ( i ge 0 and i le 1) then $
;if ( sw_fort eq 168L ) then $
;         read_fort168, LUN[i],UT_hr0,LT_hr0,Z0,TNX0,UN0,NNO0,EHT0,TI0,N0,PHION0,VOP0,SUMION0,sw_version,sw_debug $
;         ,xionn0, eqn2d0, nplsrd0 $
if ( sw_fort eq 167L ) then $
         read_fort167, LUN[i],UT_hr0,LT_hr0,Z0,SL,GL,BM,GR,SZA,O0,H0,N20,O20,HE0,N4S0,sw_debug,title_hemi $

;       else if ( i ge 1 ) then begin 

;         if ( i eq 1 ) then begin 
;           mp_read=4-1L
;           read_fort168_3d, LUN[i],UT_hr0,LT_hr0,Z0,TNX0,UN0,NNO0,EHT0,TI0,N0,PHION0,VOP0,mp_plot,mp_read,sw_debug   
;       else if ( i ge 2 and i le 3) then begin 
else if ( sw_fort eq 168L ) then begin
           mp_read=1-1L
           read_fort168_3d, LUN[i],UT_hr0,LT_hr0,Z0,TNX0,UN0,NNO0,EHT0,TI0,N0,PHION0,VOP0,SUMION0,sw_version,mp_plot,mp_read,sw_debug,n_read   
if ( sw_dif eq 1 ) then  read_fort168_3d, LUN[i],UT_hr0,LT_hr0,Z0,TNX0,UN1,NNO0,EHT0,TI1,N1,PHION1,VOP0,SUMION1,sw_version,mp_plot,mp_read,sw_debug    
endif
;         endif ;else if ( i eq 2 ) then begin 
;       endif ;else if ( i ge 1 ) then begin 

;this is necessary if reading Phil's output
;else $
;if ( i eq 1 ) then $
;read_fort168phil, LUN[i],UT_hr0,LT_hr0,Z0,TNX0,UN0,NNO0,EHT0,TI0,N0,PHION0,sw_debug

       UT_hr[i] = UT_hr0
if ( i eq 0 and UT_hr0_save le -99999. ) then  begin
  UT_hr0_save = UT_hr0
  print, 'UT_hr0_save=',UT_hr0_save , UT_hr0
endif

       LT_hr[i] = LT_hr0
       plot_y[    0:FLDIM-1,i] =    Z0[    0:FLDIM-1]

if ( sw_fort eq 168 ) then begin
i_window=0L
       plot_x[i_window,  0,0:FLDIM-1,i] =   ALOG10 ( N0[1-1,0:FLDIM-1] ) ;[o+]
       plot_x[i_window,  1,0:FLDIM-1,i] =   ALOG10 ( N0[2-1,0:FLDIM-1] ) ;[h+]
     if ( sw_version eq 3 ) then $  ;yet 20110810another new version
       plot_x[i_window,  2,0:FLDIM-1,i] =   ALOG10 ( XIONN0[3-1,0:FLDIM-1] ) $ ;[he+]
     else $
       plot_x[i_window,  2,0:FLDIM-1,i] =   ALOG10 ( N0[4-1,0:FLDIM-1] ) ;[he+]
       plot_x[i_window,  3,0:FLDIM-1,i] =   ALOG10 ( N0[3-1,0:FLDIM-1] ) ;[Min+]

;        !.. Sum minor ions N+, NO+, O2+, N2+ for electron density at low altitudes
;         N(3,J)=XIONN(4,J)+XIONN(5,J)+XIONN(6,J)+XIONN(7,J)+XIONN(8,J)

;       plot_x[0,  4,0:FLDIM-1,i] =   ALOG10 ( NNO[   0:FLDIM-1] ) ;[NO]
if ( sw_dif eq 1 ) then begin 
       plot_x[i_window,  0,0:FLDIM-1,i] =   ALOG10 ( N1[1-1,0:FLDIM-1] ) - ALOG10 ( N0[1-1,0:FLDIM-1] )  ;[o+]
       plot_x[i_window,  1,0:FLDIM-1,i] =   ALOG10 ( N1[2-1,0:FLDIM-1] ) - ALOG10 ( N0[2-1,0:FLDIM-1] ) ;[h+]
;     if ( sw_version eq 3 ) then $  ;yet 20110810another new version
;       plot_x[i_window,  2,0:FLDIM-1,i] =   ALOG10 ( XIONN0[3-1,0:FLDIM-1] )  $ ;
;     else $
       plot_x[i_window,  2,0:FLDIM-1,i] =   ALOG10 ( N1[4-1,0:FLDIM-1] ) - ALOG10 ( N0[4-1,0:FLDIM-1] ) ;[he+]
       plot_x[i_window,  3,0:FLDIM-1,i] =   ALOG10 ( N1[3-1,0:FLDIM-1] ) - ALOG10 ( N0[3-1,0:FLDIM-1] ) ;[Min+]
endif ;( sw_dif eq 1 ) then 

i_window=1L
       plot_x[i_window,  0,0:FLDIM-1,i] =   TI0[1-1,0:FLDIM-1] ;Ti
       plot_x[i_window,  1,0:FLDIM-1,i] =   TI0[3-1,0:FLDIM-1] ;Te
if ( sw_dif eq 1 ) then begin
       plot_x[i_window,  0,0:FLDIM-1,i] =   TI1[1-1,0:FLDIM-1] - TI0[1-1,0:FLDIM-1] ;Ti
       plot_x[i_window,  1,0:FLDIM-1,i] =   TI1[3-1,0:FLDIM-1] - TI0[3-1,0:FLDIM-1] ;Te
endif
;       plot_x[1,  2,0:FLDIM-1,i] =   TNX0[   0:FLDIM-1] ;Tn

;       plot_x[2,  0,0:FLDIM-1,i] =   VOP0[0:FLDIM-1] *1.E-01
;       plot_x[2,  1,0:FLDIM-1,i] =   UN0[ 0:FLDIM-1]
;       plot_x[2,  2,0:FLDIM-1,i] =   N0[1-1,0:FLDIM-1] * VOP0[0:FLDIM-1] * 1.E-06

       plot_x[2,  0,0:FLDIM-1,i] =   PHION0[0:FLDIM-1]

if ( sw_dif eq 1 ) then $
       plot_x[2,  0,0:FLDIM-1,i] =   PHION1[0:FLDIM-1] - PHION0[0:FLDIM-1]

;       plot_x[3,  0,0:FLDIM-1,i] =   EHT0[  0:FLDIM-1]
       plot_x[3,  0,0:FLDIM-1,i] =   UN0[  0:FLDIM-1]*1.0E-2 ;cm-1-->m-s

if ( sw_dif eq 1 ) then $
       plot_x[3,  0,0:FLDIM-1,i] =   UN1[  0:FLDIM-1]*1.0E-2 - UN0[  0:FLDIM-1]*1.0E-2 ;cm-1-->m-s

;dbg print ,'check Un',MAX(UN0),MIN(UN0)
if ( sw_version ge 1 ) then begin
       plot_x[2,  1,0:FLDIM-1,i] =   SUMION0[0,0:FLDIM-1]  ;SUMION(1,7,J)
;       plot_x[3,  2,0:FLDIM-1,i] =   SUMION0[1,0:FLDIM-1] 
;       plot_x[3,  3,0:FLDIM-1,i] =   SUMION0[2,0:FLDIM-1]

if ( sw_dif eq 1 ) then $
       plot_x[2,  1,0:FLDIM-1,i] =   SUMION1[0,0:FLDIM-1] - SUMION0[0,0:FLDIM-1]  ;SUMION(1,7,J)
endif 

;if ( sw_debug eq 1 ) then $

;if ( i ge 2 and i le 3 ) then $
;print, 'i=',i,'MAX phion',MAX(phion0[0:FLDIM-1]), MAX(eht0[0:FLDIM-1]) ;,MAX(sumion0[0,0:FLDIM-1]), MAX(sumion0[1,0:FLDIM-1]), MAX(sumion0[2,0:FLDIM-1])
endif else if ( sw_fort eq 167 ) then begin

       plot_x[0,  0,0:FLDIM-1,i] =   ALOG10( SL[   0:FLDIM-1] )

       plot_x[1,  0,0:FLDIM-1,i] =   GL[ 0:FLDIM-1] *180./!PI ;geolat
       plot_x[1,  1,0:FLDIM-1,i] =   SZA[0:FLDIM-1] *180./!PI ;sza

;print,'min',MIN(SZA[0:FLDIM-1] *180./!PI) ,' max',MAX(SZA[0:FLDIM-1] *180./!PI) 

       plot_x[2,  0,0:FLDIM-1,i] =   BM[0:FLDIM-1]             ;1,39E+00
       plot_x[2,  1,0:FLDIM-1,i] =   GR[ 0:FLDIM-1]*1.0E-3     ;-9.5E+2

       plot_x[3,  0,0:FLDIM-1,i] =   ALOG10( O0[  0:FLDIM-1] )
       plot_x[3,  1,0:FLDIM-1,i] =   ALOG10( H0[  0:FLDIM-1] + HE0[ 0:FLDIM-1]  )
       plot_x[3,  2,0:FLDIM-1,i] =   ALOG10( N20[ 0:FLDIM-1] + O20[ 0:FLDIM-1] )
       plot_x[3,  3,0:FLDIM-1,i] =   ALOG10( N4S0[ 0:FLDIM-1] )
   endif

;print, 'O+',MIN(plot_x[0,0,*,i]), MAX(plot_x[0,0,*,i])
;print, 'Ti',MIN(plot_x[1,0,*,i]), MAX(plot_x[1,0,*,i])

     endfor ;i = 0, n_file-1 do begin




print,'before plotting: ', ( (UT_hr[0]-UT_hr0_save) MOD freq_plot_hr ), (UT_hr[0]-UT_hr0_save), ' freq=',freq_plot_hr, ' UT=',UT_hr[0], ' UT0=', UT_hr0_save


IF (  ((UT_hr[0]-UT_hr0_save) MOD freq_plot_hr) GE 0.08 ) then continue

print,'UT_hr[0]',UT_hr[0],'plot_UT',plot_UT

     if ( UT_hr[0] ge plot_UT ) $
;AND  ( ((UT_hr[0]-UT_hr0_save) MOD freq_plot_hr) LT 0.0001 )$
 then begin


print,'plotting UT', ( (UT_hr[0]-UT_hr0_save) MOD freq_plot_hr ), (UT_hr[0]-UT_hr0_save), freq_plot_hr, UT_hr[0], UT_hr0_save

;dbg print,'plt_prfl',sw_output2file ;debug

;title_hemi='NH' ;requirement for j0/j1
;dbg print, rundir
;       profile_ht_3d $
       prfl_ht $
,plot_x,plot_y, title_hemi,mlat_title,ut_hr,lt_hr,plot_DIR,FLDIM_plot,mp_plot,sw_debug,sw_fort $
,sw_dif,sw_output2file,n_file,fac_window, TEST0,rundir

;dbg20140828 BREAK ;exit from the while loop

;STOP
;JUMP1:
     endif ;( UT_hr[0] eq plot_UT ) then begin

 endwhile                       ; ( EOF(LUN168) ne 0 ) then begin
;print, '!dbg20140610 endwhile'

;JUMP1: 
for i = 0, n_file-1  do    FREE_LUN, LUN[i]
print, 'plt_prfl_ht finished successfully!'
end ;pro plot_profile_ht
;end ;pro plt_prfl_ht
