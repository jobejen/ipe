pro plt_tec

;xloadct

filename='/home/Naomi.Maruyama/iper/fig/v65.2/20120424_3d.lowgeo.sav'
print,'restoreing file=',filename
restore,file=filename
;xloadct

size_result=SIZE(tec3d)
n_read_max=size_result[1]
;for n=0,n_read_max-1 do begin
n=0L
zz=tec3d[n,*,*]
xx=glon3d[n,*,*]
yy=glat3d[n,*,*]

loadct,39
contour,zz,xx,yy $
,/irregular $
,/fill
end
