pro read_flip

RUNDATE='20110927'
;READ, RUNDATE,PROMPT='Enter date of the IPE run YYYYMMDD:' 

runLOC='CANB';POK';
;READ, RUNLOC,PROMPT='Enter which location CANB or POK?:'

testID='ts0' ;only for CANB 20110927
READ, testID,PROMPT='Enter which test? ts0--ts6:'

sw_debug=0L

if ( runLOC eq 'POK' ) then begin
  UT_DISCARD=33.73   ;POK
  UT_PLOT =1440.00            ;POK
  UT_PLOT_MAX =1992.00 ;POK
  runYR='2007'
  which_hem='N'

  FLDIM=447L ;POK
  y_min=1.E+4 ;POK
  y_max=5.*1.E+5 ;POK

endif else if ( runLOC eq 'CANB' ) then begin
  UT_DISCARD=13.43
  UT_PLOT =5904.00  ;00UT Sep 4 2005
  UT_PLOT_MAX =6168.00   ;24UT 14 2005$
  runYR='2005'
  which_hem='S';
  FLDIM=403L  ;CAN2005
  y_min=0.0
  y_max=10.
endif
;filename='FR'+runYR+'001-Den-Temp-'+which_hem+'th-'+runLOC+'-HEUVAC-HWM.txt' ;POK
filename='FR'+runYR+'-'+runLOC+'-Den-Temp-'+which_hem+'th-HWM.txt'  ;CANB
RUNDIR='/lfs0/projects/idea/maruyama/sandbox/ipe/run/'+RUNDATE+'.1d.'+runLOC+runYR+testID+'/'
runID=runYR+'-'+runLOC+'.'+testID

;IPE
UT_PLOTi =$
24.0*6.
UT_PLOT_MAXi =$
UT_PLOTi  +(UT_PLOT_MAX-UT_PLOT)

kmax=5000L
   ut_save=fltarr(kmax)
   nmf2_save=fltarr(kmax)
   hmf2_save=fltarr(kmax)

;for IPE
kmaxi=10000L
   ut_savei=fltarr(kmaxi)
   nmf2_savei=fltarr(kmaxi)
   hmf2_savei=fltarr(kmaxi)




    openr, LUN, filename, /GET_LUN

    print,'opening file:',filename, LUN

;line1
   string_tmp='     * * * * * Initial Parameters for this FLIP run in SOUTHERN hemisphere * * * * * * * * * *  '
   readf, LUN, string_tmp
   print,'l1:', string_tmp
;line2
   string_tmp=' '
   readf, LUN, string_tmp
   print,'l2:', string_tmp
;line3
   string_tmp='  YEAR=2005,  DAY=  1,  L-SHELL=   2.148,  F10.7=  75.0,  F10.7A=  89.0,  AP=   9.0'
   readf, LUN, string_tmp
   print,'l3:', string_tmp
;line4
   string_tmp=' '
   readf, LUN, string_tmp
   print,'l4:', string_tmp
;line5
   string_tmp='  Geographic (lat,long):- North ( 57N,  157E)  ,  South ( 35S,  148E)  @   247km altitude'
   readf, LUN, string_tmp
   print,'l5:', string_tmp
;line6
   string_tmp=' '
   readf, LUN, string_tmp
   print,'l6:<blank>', string_tmp
;line7
   string_tmp='   Using HEUVAC EUV. Initial scaling factors: 303.78=  1.0, 284.15=  1.3, 584.33=  1.0, 977.02=  1.0, 1025.72=  1.0'
   readf, LUN, string_tmp
   print,'l7:', string_tmp
;line8
   string_tmp=' '
   readf, LUN, string_tmp
   print,'l8:<blank>', string_tmp
;line9
   string_tmp='     Important parameters in the SOUTHern hemisphere  Ion and Neutrals near alt _Z =     300 km; fluxes (Phi) near   1500 km.'
   readf, LUN, string_tmp
   print,'l9:', string_tmp
;line10
   string_tmp='  Note - For low L values these print altitudes may be set to the field line apex altitude.'
   readf, LUN, string_tmp
   print,'l10:', string_tmp
;line11
   string_tmp=' '
   readf, LUN, string_tmp
   print,'l11:<blank>', string_tmp
;line12
   string_tmp='     UT    LT  SZA  Te  HmF2  Wind   NmF2     min+     PhiH+     PhiO+    PhiHe+    OX_Z     O2_Z     N2_Z     H_Z     He_Z     Tn   PhiN+   TI_Z   TE_Z      O+_Z     H+_Z      min+_Z     RON2     N2vFac'
   readf, LUN, string_tmp
   print,'l12:', string_tmp

k=-1L
WHILE ( EOF(LUN) eq 0 ) DO BEGIN
readf,lun,UT,  LTime,  SZA,  Te,  HmF2,  Wind,   NmF2,     minp,     PhiHp,     PhiOp,    PhiHep $
,    OX_Z,     O2_Z,     N2_Z,     H_Z,     He_Z,     Tn,   PhiNp,   TI_Z,   TE_Z,      Op_Z,     Hp_Z,      minp_Z,     RON2,     N2vFac

print,'UT',UT

;UT=13.43
IF ( UT eq UT_DISCARD ) THEN BEGIN
   string_tmp=' '
   readf, LUN, string_tmp
   print,'!!!DISCARD-1!!!:', string_tmp

   string_tmp='  ********* DISCARD data above this line - too close to initial conditions *********'
   readf, LUN, string_tmp
   print,'!!!DISCARD-2!!!:', string_tmp

 ENDIF ELSE IF ( UT gt UT_DISCARD ) THEN BEGIN

  IF ( UT ge UT_PLOT ) THEN BEGIN
;...save data
   k=k+1L
   ut_save[k]=UT
   nmf2_save[k]=nmf2
   hmf2_save[k]=hmf2
   IF ( UT ge UT_PLOT_MAX ) THEN BREAK
  ENDIF ;( UT ge UT_PLOT ) THEN BEGIN
ENDIF ;( UT gt UT_DISCARD ) THEN BEGIN

ENDWHILE
FREE_LUN, LUN
k_max=k
print,'k_max',k_max,' UT',UT,UT_PLOT_MAX


;read ipe
if ( which_hem eq 'N' ) then  lun_no='168' else $
if ( which_hem eq 'S' ) then  lun_no='171'
filename=RUNDIR+'fort.'+lun_no
;filename=runLOC+runYR+which_hem+'-ipe' ;168
;'CANB05SH-ipe' ;171

; temporary array just for reading

 UT_hr0 = 0.0
 LT_hr0 = 0.0
     Z0 = dblarr(FLDIM)
   TNX0 = dblarr(FLDIM)
    UN0 = dblarr(FLDIM)
   NNO0 = dblarr(FLDIM)
 PHION0 = dblarr(FLDIM)
   EHT0 = dblarr(3,FLDIM)   
    TI0 = dblarr(3,FLDIM)
     N0 = dblarr(4,FLDIM)

NHEAT=dblarr(FLDIM)
SUMION=dblarr(3,FLDIM)
sw_version=0L
mp_plot=0L ;mp=51
mp_read=0L

   openr, LUN, filename, /GET_LUN
    print,'IPE: opening file:',filename, LUN
   k=-1L
   while ( EOF(LUN) eq 0 ) do begin
      read_fort168_3d, LUN,UT_hr0,LT_hr0,Z0,TNX0,UN0,NNO0,EHT0,TI0,N0,PHION0 $
,NHEAT,SUMION,sw_version,mp_plot,mp_read,sw_debug



      IF ( UT_hr0 ge UT_ploti ) THEN begin

;---         get_hmf2,z0,N0,nmf2,hmf2

elden = dblarr(FLDIM)
;dimension_total=0
for i=0,FLDIM-1 do  elden[i]=N0[0,i]+N0[1,i]+N0[2,i]+N0[3,i]
midpoint=(FLDIM/2)+1 -1
for i=midpoint-1,+2 , -1 do begin
  if ( elden[i] gt elden[i+1] ) and ( elden[i] gt elden[i-1] ) then begin
    nmf2=elden[i]
    hmf2=Z0[i]
    BREAK ;exit from for i loop
  endif else begin
    IF ( i eq 0 ) THEN BEGIN
print,'!STOP! INVALID profile',i,elden[i-1:i+1]
STOP
    ENDIF
  endelse

endfor;i
;===
         k=k+1L
         UT_savei[k] = UT_hr0
         nmf2_savei[k] =nmf2
         hmf2_savei[k] =hmf2
          IF ( UT_hr0 ge UT_plot_maxi ) THEN BREAK
       ENDIF ;( UT_hr0 ge UT_ploti ) THEN begin
   ENDwhile ;( EOF(LUN[0]) eq 0 ) do begin
FREE_LUN, LUN
k_maxi=k
print,'IPE: k_max',k_maxi,' UT',UT,UT_PLOT_MAXi
;dbg
for i=0,k_maxi do  print ,i,ut_savei[i],hmf2_savei[i],nmf2_savei[k]
;STOP


y_min1=200.0
y_max1=400.0

x_min=UT_PLOT
x_max=UT_PLOT_MAX
;plot UT variations
;!P.BACKGROUND=255
!P.MULTI=[0,1,2,0,1]
;1:# of plot columns
;2:# of rows
  device, decomposed = 0 ,retain=2
  window, 0 ,XSIZE=600,YSIZE=400 
  n_ldct=39
  loadct, n_ldct


plot,ut_save[0:k_max],hmf2_save[0:k_max],title=runID+' hmF2', yrange=[y_min1,y_max1], ystyle=1 , xrange=[x_min,x_max], xstyle=1 
;ipe
oplot,(ut_savei[0:k_maxi]-UT_PLOTi+UT_PLOT), hmf2_savei[0:k_maxi],linestyle=5, color=245, thick=2.


if ( runLOC eq 'POK' ) then begin
  plot,ut_save[0:k_max],nmf2_save[0:k_max],/YLOG,title='NmF2 [cm-3]', yrange=[y_min,y_max], ystyle=1 , xrange=[x_min,x_max], xstyle=1  ;POK
  oplot,(ut_savei[0:k_maxi]-UT_PLOTi+UT_PLOT), nmf2_savei[0:k_maxi],linestyle=5, color=245, thick=2. ;POK

endif else if ( runLOC eq 'CANB' ) then begin
  plot,ut_save[0:k_max],(nmf2_save[0:k_max]*1.0E-5),title='NmF2 *10^-5 [cm-3]',yrange=[y_min,y_max], ystyle=1 , xrange=[x_min,x_max], xstyle=1  ;CANB
oplot,(ut_savei[0:k_maxi]-UT_PLOTi+UT_PLOT), (nmf2_savei[0:k_maxi]*1.0E-5),linestyle=5, color=245, thick=2. ;CANB
endif


filename_plot=runID+'.ipe.png'
output_png, filename_plot

print,'read_flip finished successfully!!!'
end ;read_flip
