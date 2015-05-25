function vradial_approx,a,x,sigma
;; The radial function that integrated along one axis results in Voigt
;; function
;; This uses the approximate Voigt function from Liu et al 2001
;; 666 J. Opt. Soc. Am. B/Vol. 18, No. 5/May 2001
;; It also uses Riccardo's nice work in helping me solve the
;; integral equation to arrive at this (method Fourier transform both
;; sides of the equation)

GHW = sigma * 1.17741 ;; Gaussian Half Width at Half Max
LHW = GHW * a ;; Lorentzian Half width at Half Max
sigV = 0.5346E * LHW + sqrt(0.2166E * LHW^2 + GHW^2)

d = (a - 1E)/(a + 1E)
cL = 0.68188 + 0.61293 * d - 0.18384 * d^2 - 0.11568 * d^3
cG = 0.32460 - 0.61825 * d + 0.17681 * d^2 + 0.12109 * d^3

;; Lorentzian Component
f = cL * sigV^3/(X^2 + sigV^2)^(1.5E)
ExpArgument =-0.693147E * X^2/sigV^2  ;; coefficient is Log[2]
smallP = where(ExpArgument GT -18E)
if smallP NE [-1] then begin
   ;; Gaussian Component only applied to points that are within
   ;; e^(-18) the rest are assumed to be zero
   f[smallP] = f[smallP] + cG * 0.693147E * exp(expArgument[smallP])
endif

norm = 6.28319E * (cG + cL) * sigV^2; (2pi * (cG + cL) sigV^2)

return,f
end
