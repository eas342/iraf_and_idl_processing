function poly_and_sine,X,P,Np
;; Evaluates a specified number of polynomial terms and then some
;; sinusoidal stuff that depends on the polynomial
;; X is the input array
;; P is the array of parameters (beginning with polynomial ones)
;; Np the order of the polynomial

fpoly1 = eval_poly(X,P[0:Np-1])
fpoly2 = eval_poly(X,P[Np:(Np *2-1)])
fpoly3 = eval_poly(X,P[(Np *2):(Np * 3)-1])
y = fpoly1 + cos(fpoly2) * P[Np * 3] + P[Np *3+1] * cos(fpoly3)

return,y

end
