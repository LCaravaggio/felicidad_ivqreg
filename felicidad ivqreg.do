* Felicidad IVQREG
* INICIO
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

* Elimino las no respuestas de satisfacción con la vida, smartphone ownership, nivel de estudios, y si posee agua caliente de cañería
keep if p1st>0
keep if s26_l>0
keep if s16>0 
keep if s26_h>0

* OLS 
quietly reg p1st SNU
estimates store m_solo
quietly reg p1st SNU s16 s26_h 
estimates store todo1
quietly reg p1st SNU s16 s26_h if (edad>18 & edad<25)
estimates store m1825
quietly reg p1st SNU s16 s26_h if edad>60
estimates store más60
quietly reg p1st SNU s16 s26_h s26_b edad reg
estimates store todo2

estimates table m_solo todo1 m1825 más60 todo2, b(%9.4f) star stats(N r2) title(OLS)



* Chequeo smartphone ownership como IV
quietly reg p1st SNU s26_l
estimates store OLS1
quietly reg SNU s26_l
estimates store OLS2

* 2SLS
quietly reg SNU s26_l
estimates store twoSLS1
predict SNU_hat
quietly reg p1st SNU_hat
estimates store twoSLS2

estimates table OLS1 OLS2 twoSLS1 twoSLS2, b(%9.4f) star stats(N r2) title(OLS)

* Estimación con IV y Test de Kleibergen-Paap
ivreg2 p1st s16 s26_h (SNU=s26_l), robust


*Regresión cuantílica usando Smartphone ownership como IV de SNU
* Cuantíl del 15% más feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU  , instruments(SNU s26_l  s26_h s26_b s1) q(.25)
estimates store tau25
* Cuantíl del 50%
quietly ivqreg2 p1st  s26_h s26_b s1 SNU , instruments(SNU s26_l  s26_h s26_b s1) q(.5)
estimates store tau50
* Cuantíl del 15% menos feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU  , instruments(SNU s26_l  s26_h s26_b s1) q(.75)
estimates store tau75


* Irrestricto
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Irrestricto)


*Regresión cuantílica usando Smartphone ownership como IV de SNU. Casa propia y 
* Cuantíl del 15% más feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if (edad>18 & edad<25) , instruments(SNU s26_l s26_h s26_b s1) q(.25)
estimates store tau25
* Cuantíl del 50%
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if (edad>18 & edad<25), instruments(SNU s26_l  s26_h s26_b s1) q(.5)
estimates store tau50
* Cuantíl del 15% menos feliz
quietly ivqreg2 p1st  s26_h s26_b s1  SNU  if (edad>18 & edad<25), instruments(SNU s26_l  s26_h s26_b s1) q(.75)
estimates store tau75


* Edad entre 18 y 25
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Entre 18 y 25)


*Regresión cuantílica usando Conexión a Internet en el Hogar como IV de SNU
* Cuantíl del 15% más feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.25)
estimates store tau25
* Cuantíl del 50%
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.5)
estimates store tau50
* Cuantíl del 15% menos feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.75)
estimates store tau75


* Edad más 60
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Mayores de 60)


* Smoothed IV quantile regression
quietly sivqr p1st  s26_h s26_b s1 (SNU=s26_l) , quantile(.25)
estimates store tau25
quietly sivqr p1st s26_h s26_b s1 (SNU=s26_l) , quantile(.5)
estimates store tau50
quietly sivqr p1st  s26_h s26_b s1 (SNU=s26_l) , quantile(.75)
estimates store tau75

* Smoothed IV quantile regression
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(SIVQR)


* Generar felicidad alternativa
gen fel=0
replace fel=fel+4 if p1st==1 
replace fel=fel+3 if p1st==2 
replace fel=fel+2 if p1st==3 
replace fel=fel+1 if p1st==4 

replace fel=fel+5 if p4stgbs==1
replace fel=fel+4 if p4stgbs==2
replace fel=fel+3 if p4stgbs==3
replace fel=fel+2 if p4stgbs==4
replace fel=fel+1 if p4stgbs==5

replace fel=fel+2 if p2st==1
replace fel=fel+1 if p2st==2

replace fel=fel+5 if p7stgbs==1
replace fel=fel+4 if p7stgbs==2
replace fel=fel+3 if p7stgbs==3
replace fel=fel+2 if p7stgbs==4
replace fel=fel+1 if p7stgbs==5

replace fel=fel+2 if p9stgbs==1


* OLS 
quietly reg fel SNU
estimates store m_solo
quietly reg fel SNU s16 s26_h 
estimates store todo1
quietly reg fel SNU s16 s26_h if (edad>18 & edad<25)
estimates store m1825
quietly reg fel SNU s16 s26_h if edad>60
estimates store más60
quietly reg fel SNU s16 s26_h s26_b edad reg
estimates store todo2

estimates table m_solo todo1 m1825 más60 todo2, b(%9.4f) star stats(N r2) title(OLS)



* Chequeo smartphone ownership como IV
quietly reg fel SNU s26_l
estimates store OLS1
quietly reg SNU s26_l
estimates store OLS2

* 2SLS
quietly reg SNU s26_l
estimates store twoSLS1
predict SNU_hat_fel
quietly reg fel SNU_hat_fel
estimates store twoSLS2

estimates table OLS1 OLS2 twoSLS1 twoSLS2, b(%9.4f) star stats(N r2) title(OLS)

* Estimación con IV y Test de Kleibergen-Paap
ivreg2 fel s16 s26_h (SNU=s26_l), robust


*Regresión cuantílica usando Smartphone ownership como IV de SNU
* Cuantíl del 15% más feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU  , instruments(SNU s26_l  s26_h s26_b s1) q(.25)
estimates store tau25
* Cuantíl del 50%
quietly ivqreg2 fel  s26_h s26_b s1 SNU , instruments(SNU s26_l  s26_h s26_b s1) q(.5)
estimates store tau50
* Cuantíl del 15% menos feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU  , instruments(SNU s26_l  s26_h s26_b s1) q(.75)
estimates store tau75


* Irrestricto
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Irrestricto)


*Regresión cuantílica usando Smartphone ownership como IV de SNU. Casa propia y 
* Cuantíl del 15% más feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU if (edad>18 & edad<25) , instruments(SNU s26_l s26_h s26_b s1) q(.25)
estimates store tau25
* Cuantíl del 50%
quietly ivqreg2 fel  s26_h s26_b s1 SNU if (edad>18 & edad<25), instruments(SNU s26_l  s26_h s26_b s1) q(.5)
estimates store tau50
* Cuantíl del 15% menos feliz
quietly ivqreg2 fel  s26_h s26_b s1  SNU  if (edad>18 & edad<25), instruments(SNU s26_l  s26_h s26_b s1) q(.75)
estimates store tau75


* Edad entre 18 y 25
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Entre 18 y 25)


*Regresión cuantílica usando Conexión a Internet en el Hogar como IV de SNU
* Cuantíl del 15% más feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.25)
estimates store tau25
* Cuantíl del 50%
quietly ivqreg2 fel  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.5)
estimates store tau50
* Cuantíl del 15% menos feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.75)
estimates store tau75


* Edad más 60
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Mayores de 60)


* Smoothed IV quantile regression
quietly sivqr fel  s26_h s26_b s1 (SNU=s26_l) , quantile(.25)
estimates store tau25
quietly sivqr fel s26_h s26_b s1 (SNU=s26_l) , quantile(.5)
estimates store tau50
quietly sivqr fel  s26_h s26_b s1 (SNU=s26_l) , quantile(.75)
estimates store tau75

* Smoothed IV quantile regression
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(SIVQR)