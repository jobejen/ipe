pro rd_tec

TEST='r336.2.1'
TEST2='S'
TEST1='8522'



;if n_read eq 48 then begin
; print, 'saving at n_read', n_read
 restore,filename='tec'+TEST+TEST2+TEST1+'.sav'
tec_sew=tec
;endif

;qref
TEST1='30242'
 restore,filename='tec'+TEST+TEST2+TEST1+'.sav'
tec_q=tec

;efield only
TEST1='10402'
 restore,filename='tec'+TEST+TEST2+TEST1+'.sav'
tec_se=tec

;efield+wind only for 108deg lon
TEST1='3281'
 restore,filename='tec'+TEST+TEST2+TEST1+'.sav'
tec_sew2=tec


fac_window=1.

 !P.BACKGROUND=0
  device, decomposed = 0 ,retain=2
  window, 2 ,XSIZE=1000*fac_window,YSIZE=800*fac_window

;TECU=1.0E16 ;[m-2]

print,'MAX TEC',MIN(tec_sew/TECU),MAX(tec_sew/TECU)
Plot, x_dsp0, tec_sew/TECU $
;, yrange=[ 0., 120. ], ystyle=1  $ ;20141119
, yrange=[ 0., 350. ], ystyle=1  $
;, xrange=[ gLATMIN, gLATMAX ], xstyle=1  $
, xrange=[ -50. , +50. ], xstyle=1  $
, TITLE='TEC' $ ;+FileID $
, linestyle=0 $
, THICK    = 6. $
,/NODATA

loadct, 33

oPlot, x_dsp0, tec_sew/TECU $
, linestyle=0 $
, THICK    = 6. $
, color    = 254. ;$


oPlot, x_dsp0, tec_q/TECU $
, linestyle=1 $
, THICK    = 5. ;$


oPlot, x_dsp0, tec_se/TECU $
, linestyle=4 $
, THICK    = 5. ;$

oPlot, x_dsp0, tec_sew2/TECU $
, linestyle=0 $
, THICK    = 5.5 $
, color    = 50. ;$

end ;pro rd_tec
