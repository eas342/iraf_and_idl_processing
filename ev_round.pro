function ev_round,x,r
;; Like round, but can be done into groups of n
if n_elements(r) EQ 0 then r=1
div = float(x)/float(r)
rdiv = round(div)
return,rdiv * r
end
