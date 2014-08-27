function slit_model,X,P
;; A simple trapezoid model for a slit
y = fltarr(n_elements(X))
leftP = where(X LT P[0] - P[2])
interML = where(X GE P[0] - P[2] and X LT P[0])
midP = where(X GE P[0] and X LT P[1])
interMR = where(X GE P[1] and X LT P[1] + P[2])
rightP = where(X GE P[1] + P[2])
if leftP NE [-1] then y[leftP] = P[3]
if interML NE [-1] then y[interML] = P[3] + (P[4] - P[3]) $
                                     * (X[interML] - P[0] + P[2])/(P[2] + 1E-8)
if rightP NE [-1] then y[rightP] = P[3]
if interMR NE [-1] then y[interMR] = P[4] + (P[3] - P[4]) $
                                     * (X[interMR] - P[1])/(P[2] + 1E-8)
if midP NE [-1] then y[midP] = P[4]

return,y

end
