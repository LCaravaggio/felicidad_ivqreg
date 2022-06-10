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

*Regresión cuantílica usando Conexión a Internet en el Hogar como IV de SNU
ivqreg p1st (SNU = m_nc) if edad>60 , robust band(1.059)
estimates store todo
*Variables independientes: nivel de estudios y posee agua caliente de cañeria
ivqreg p1st s16 s26_h (SNU = m_nc) if edad>60 , robust  band(1.059)
estimates store iv
* Cuantíl del 15% más feliz
ivqreg p1st s16 s26_h (SNU = m_nc) if edad>60 , robust q(.15) band(1.059)
estimates store tau15
* Cuantíl del 15% menos feliz
ivqreg p1st s16 s26_h (SNU = m_nc) if edad>60 , robust q(.85) band(1.059)
estimates store tau85


sjlog using output, replace
estout *, cells(b(star fmt(%6.3f)) se(par)) stats(N, fmt(%6.0f)) collabels(none) sty(smcl) var(8) model(8) stard legend  starlevels(* 0.10 ** 0.05 *** 0.01 )
sjlog close, replace
