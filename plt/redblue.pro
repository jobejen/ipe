pro redblue
ncolors=!d.table_size
x=findgen(ncolors)/float(ncolors-1)
grnvec=byte(hat(x)*255.0)
;redvec=byte(hat(x)*255.0)
;bluvec=byte(hat(x)*255.0)
bluvec=replicate(255B,ncolors)
redvec=replicate(255B,ncolors)

bluvec(0:ncolors/2-1) = byte(255*hat(x(0:ncolors/2-1)))
redvec(ncolors/2-1:ncolors-1) = byte(255*hat(x(ncolors/2-1:ncolors-1)))

bluvec(ncolors-1)=byte(ncolors-1)
redvec(ncolors-1)=byte(ncolors-1)
grnvec(ncolors-1)=byte(ncolors-1)
bluvec(0)=byte(0)
redvec(0)=byte(0)
grnvec(0)=byte(0)

tvlct,redvec,grnvec,bluvec
end
