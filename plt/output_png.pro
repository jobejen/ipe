;050305: read image from the current display and write it to the png file

PRO output_png, Filename_png


; readin the current WINDOW as image
thisImage= TVRD( $
;[X 0 [, Y 0 [, N x [, N y [, Channel]]]]] [, CHANNEL=value] [,
;/ORDER] [ $
  TRUE=1  $ ;{1 | 2 | 3}]  ;110904!CAUTION! 2or3 did not work!!! 
;[, /WORDS] $
)

;check if the image was properly read
;WINDOW,3,XSIZE=900,YSIZE=700
;tv, thisImage


; output to file
 WRITE_PNG  $
 , Filename_png $
 , thisImage   ;[, R, G, B] 
;[, /ORDER] [, /VERBOSE] [, TRANSPARENT=array]


 end ;PRO output_png
