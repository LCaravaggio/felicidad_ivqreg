clear all
cscript

qui do c:\data\ivqreg.mata

set more off
set seed 12345

use c:\data\LB2020

*Histograma de la satisfacción con la vida
hist p1st if p1st>0

*Generar variable SNU (Social Network Use)
generate SNU = 1 
replace SNU = 0 if s19m_10==1

keep if p1st>0
keep if m_nc>0

*Regresión cuantílica usando Conexión a Internet en el Hogar como IV de SNU
quietly ivqreg2 p1st SNU if edad>18 & edad<25, instruments(SNU m_nc)
estimates store sin_exog
* Cuantíl del 15% más feliz
quietly ivqreg2 p1st s16 s26_h SNU if edad>18 & edad<25 , instruments(s16 s26_h SNU m_nc) q(.15)
estimates store tau15
* Cuantíl del 50%
quietly ivqreg2 p1st s16 s26_h SNU if edad>18 & edad<25, instruments(s16 s26_h SNU m_nc) q(.5)
estimates store tau50
* Cuantíl del 15% menos feliz
quietly ivqreg2 p1st s16 s26_h SNU  if edad>18 & edad<25, instruments(s16 s26_h SNU m_nc) q(.85)
estimates store tau85


* Edad entre 18 y 25
sjlog using output, replace
estout *, cells(b(star fmt(%6.3f)) se(par)) stats(N, fmt(%6.0f)) collabels(none) sty(smcl) var(8) model(8) stard legend  starlevels(* 0.10 ** 0.05 *** 0.01 )
sjlog close, replace


*Regresión cuantílica usando Conexión a Internet en el Hogar como IV de SNU
quietly ivqreg2 p1st SNU if edad>60 , instruments(SNU m_nc)
estimates store sin_exog
* Cuantíl del 15% más feliz
quietly ivqreg2 p1st s16 s26_h SNU if edad>60 , instruments(s16 s26_h SNU m_nc) q(.15)
estimates store tau15
* Cuantíl del 50%
quietly ivqreg2 p1st s16 s26_h SNU if edad>60 , instruments(s16 s26_h SNU m_nc) q(.5)
estimates store tau50
* Cuantíl del 15% menos feliz
quietly ivqreg2 p1st s16 s26_h SNU if edad>60 , instruments(s16 s26_h SNU m_nc) q(.85)
estimates store tau85


* Edad más 60
sjlog using output, replace
estout *, cells(b(star fmt(%6.3f)) se(par)) stats(N, fmt(%6.0f)) collabels(none) sty(smcl) var(8) model(8) stard legend  starlevels(* 0.10 ** 0.05 *** 0.01 )
sjlog close, replace


