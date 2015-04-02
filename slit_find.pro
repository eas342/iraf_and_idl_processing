function slit_find,a,slitbox,yfunc=yfunc,showplot=showplot
;; Finds the slit and plots a line through the middle and ends
;; a is the image file
;; slitbox is a guess as to where the slit is and defines the starting
;; and ending points in the search
;; showplot shows fits to the slit

startp = round(min(slitbox[*,1]))
endP = round(max(slitbox[*,1]))

nx = n_elements(a[*,0])
xplot = findgen(nx)
leftGuess = [min(slitbox[*,0])]
rightGuess = [max(slitbox[*,0])]


;; It takes too long to fit each row, so it's better to do
;; groups of rows
if n_elements(ngroups) EQ 0 then ngroups = 20
subRegSize = floor(float(endP-startp)/ngroups)
subRegStarts = findgen(ngroups) * subRegSize

slitCen = fltarr(ngroups)
slitWidth = fltarr(ngroups)
yrow = subRegStarts + float(subRegSize)/2E

for i=0,ngroups-1l do begin
   topP = min([nx-1l,subRegStarts[i] + subRegSize-1l])
   subRegion = median(a[*,subRegStarts[i]:topP],dimension=2)
   slitGuess = [leftGuess,rightGuess,5,$
                median(subRegion[0:leftGuess]),median(subRegion[leftGuess:rightGuess])]

   slitP = ev_robust_poly(xplot,subRegion,0,$
                          start=slitguess,showplot=showplot,$
                          customfunc='slit_model(X,P)',$
                          nsig = 25E,/quiet)
   slitCen[i] = mean(slitP[0:1])
   slitWidth[i] = mean(slitP[1] - slitP[0])
   
endfor

nYlength = n_elements(a[0,*])
allY = findgen(nYlength)
fitMod = ev_robust_poly(yrow,slitCen,2)
yfunc = fitMod
if keyword_set(showSlitFit) then begin
   plot,yrow,slitCen
   oplot,yrow,eval_poly(yrow,fitmod),color=mycol('yellow')
endif

;; Find the slit angle
DeltaY = float(nYlength-1l)
DeltaX = eval_poly(float(nYlength-1l),fitmod) - $
         eval_poly(0E,fitmod)
slitAngle = atan(deltaY,deltaX) * 180E/!PI
return,slitAngle
   
end
