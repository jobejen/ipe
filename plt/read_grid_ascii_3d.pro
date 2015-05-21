pro read_grid_ascii_3d,mp,IN2D,IS2D,z_km,mlat_deg

;NLP=209L
;NPTS2D=165717L
;mp=0L
;IN2D=lonarr(NLP)
;IS2D=lonarr(NLP)
;z_km    =dblarr(NPTS2D)
;mlat_deg=dblarr(NPTS2D)
input_DIR='/lfs0/projects/idea/maruyama/sandbox/ipe/source/20110203_grid/'
input_flnm='fort.100' ;the file has all 3d information (1:NMP)

openr, LUN100, input_DIR+input_flnm , /GET_LUN
  readf, LUN100,  mp
print, 'mp=',mp
  readf, LUN100,  IN2D
print, 'IN2D=',IN2D[0:3]
  readf, LUN100,  IS2D
print, 'IS2D=',IS2D[0:3]
  readf, LUN100,  z_km
print, 'z_km=',z_km[0:3]
  readf, LUN100,  mlat_deg
print, 'mlat_deg=',mlat_deg[0:3]
FREE_LUN, LUN100
end;pro read_grid_ascii_3d
