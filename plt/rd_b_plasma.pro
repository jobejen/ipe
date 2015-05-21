;date: 20140825 does not work? why? MAx MIN locations are never the
;same as the plt-ipe.pro why???
;
pro rd_b_plasma ;, NPTS2D,NMP

NMP=80L
NPTS2D=44514L
n_read_max=97L


vHeadData = READ_BINARY( $
FILEPATH('plasma00', $
ROOT_DIR='/scratch1/portfolios/NCEPDEV/swpc/noscrub/Naomi.Maruyama/r319/trunk/',$
   SUBDIRECTORY=['run', 'ipe_80_24695']), DATA_DIMS=[NPTS2D,NMP,n_read_max] $
  ,DATA_TYPE=4 $
  ,DATA_START=4 $
  ,ENDIAN="little" $
)
;IVOLUME, vHeadData

for i=0,1 do begin
print,i, 'MAX=',MAX(vHeadData[*,*,i],Max_Subscript),Max_subscript
print,i, 'MIN=',MIN(vHeadData[*,*,i],Min_Subscript),Min_subscript
k=0L
for j=0,5 do  print, j,vHeadData[j,k,i]
for j=1109,1114 do  print, j,vHeadData[j,k,i]
endfor

end ;pro rd_b_plasma
