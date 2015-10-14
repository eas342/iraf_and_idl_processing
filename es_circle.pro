pro es_circle,X,Y,R,npoints=npoints,ccolor=ccolor
;; Draws a circle at coordinates x,y with radius r

if n_elements(npoints) EQ 0 then npoints=128l
if n_elements(ccolor) EQ 0 then ccolor=mycol('green')

theta = 2E * !PI * findgen(npoints-1l) / float(npoints - 1l)
theta = [theta,0E]

xpos = float(R) * cos(theta) + X
ypos = float(R) * sin(theta) + Y
oplot,xpos,ypos,color=ccolor

end
