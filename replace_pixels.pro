function replace_pixels,inimage,badp,showP=showP
;; Replaces pixels with bi-linear interpolation
;; inimage - input image
;; badp - pixels to replace indexed in absolute numbers (not x,y
;;        coordinates)
;; showP - show a plot of the bad pixel flags and replacement

sizes = size(inimage)
xlength = sizes[1]
ylength = sizes[2]
outimage = inimage
nbad = n_elements(badp)
badmask = intarr(xlength,ylength)

edge=0 ;; are we at the edge of the array or bad pixels?
nNeighb = 4 ;; number of neighbors to do interpolation on
dir = [[1,0],[-1,0],[0,1],[0,-1]] ;; directions to search for neighbors

if badp NE [-1] then begin
   badxy = array_indices(inimage,badp)
   badmask[badp] = 1 ;; mask of bad pixels
   dofix = intarr(nbad) + 1 ;; start by trying to fix all
   ;; Start the neighbors at the bad pixels and spread them until they
   ;; are no longer touching bad pixels
   neighborsXY = rebin(badxy,2,nbad,4)

   for i=0l,nbad-1l do begin
      for j=0l,nNeighb-1l do begin
         ;; Find 4 nearest neighbors (top,bottom,left,right)
         while edge EQ 0 do begin
            neighborsXY[*,i,j] = neighborsXY[*,i,j] + dir[*,j]

            if (neighborsXY[0,i,j] GT xlength-1l OR $
                neighborsXY[0,i,j] LT 0 OR $
                neighborsXY[1,i,j] GT ylength-1l OR $
                neighborsXY[1,i,j] LT 0) then begin
               dofix[i] = 0 ;; skip the ones where we get to the edge
               edge = 1
            endif else begin
               if badmask[neighborsXY[0,i,j],neighborsXY[1,i,j]] EQ 0 then edge = 1
            endelse
         endwhile
         edge = 0
      endfor
   endfor
   fixpix = where(dofix EQ 1)
   if fixpix NE [-1] then begin
      ;; Do an average of interpolations in two directions;; See research
      ;; notes 8/6/14
      ;; only do the points that are not on the edges
      ;; point 0 is right, 1 is left, 2 is top, 3 is bottom
      xr = neighborsXY[0,fixpix,0] ; right
      yr = neighborsXY[1,fixpix,0] ; right
      fr = inimage[xr,yr]
      xl = neighborsXY[0,fixpix,1] ; left
      yl = neighborsXY[1,fixpix,1] ; left
      fl = inimage[xl,yl]
      xt = neighborsXY[0,fixpix,2] ; top
      yt = neighborsXY[1,fixpix,2] ; top
      ft = inimage[xt,yt]
      xb = neighborsXY[0,fixpix,3] ; bottom
      yb = neighborsXY[1,fixpix,3] ; bottom
      fb = inimage[xb,yb]
      xi = badxy[0,fixpix]
      yi = badxy[1,fixpix]
      
      horizontalEst = float(xi - xl)/float(xr - xl) * fr + $
                      float(xr - xi)/float(xr - xl) * fl
      verticalEst = float(yi - yb)/float(yt - yb) * ft + $
                    float(yt - yi)/float(yt - yb) * fb
      outimage[badp[fixpix]] = (horizontalEst + verticalEst)/2E
   endif
   
   if keyword_set(showP) then begin
      plotimage,inimage,range=threshold(inimage)
      stop
      oplot,badxy[0,*],badxy[1,*],color=mycol('red'),psym=4,thick=2
      stop
      plotimage,outimage,range=threshold(inimage)
      stop
   endif
   
endif

return,outimage
end
