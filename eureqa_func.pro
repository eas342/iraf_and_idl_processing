function eureqa_func,X,P
;; Functional fit using Eureqa
Y = P[0] + P[1] *X^P[2] + P[3] *X + P[4] *sin(P[5] *X^2 - P[6] *X)
return,Y
end
