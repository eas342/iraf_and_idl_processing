function eval_poly_integral,X,C
;; This evaluates the integral of a polynomial over a range X[0] to X[1]
nterms = n_elements(C)
Y = [0E,0E]
for i=0l,nterms-1l do begin
    Y = Y + X^(i+1) * C[i]/float(i+1)
endfor

return,Y[1] - Y[0]
end
