* Felicidad IVQREG
* INICIO
clear all
cscript

qui do c:\data\ivqreg.mata

set more off
set seed 12345

use c:\data\LB2020

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


*Histograma de la satisfacción con la vida y felicidad alternativa
histogram fel, discrete normal kdensity
histogram p1st, discrete normal kdensity



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
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("m_solo") append
quietly reg p1st SNU s16 s26_h 
estimates store todo1
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("todo1") append
quietly reg p1st SNU s16 s26_h if (edad>18 & edad<25)
estimates store m1825
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("m18-25") append
quietly reg p1st SNU s16 s26_h if edad>60
estimates store más60
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("mas60") append
quietly reg p1st SNU s16 s26_h s26_b edad reg
estimates store todo2
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("todo2") append

estimates table m_solo todo1 m1825 más60 todo2, b(%9.4f) star stats(N r2) title(OLS)



* Chequeo smartphone ownership como IV
quietly reg p1st SNU s26_l
estimates store OLS1
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("OLS1") append
quietly reg SNU s26_l
estimates store OLS2
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("OLS2") append

* 2SLS
quietly reg SNU s26_l
estimates store twoSLS1
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("twoSLS1") append
predict SNU_hat
quietly reg p1st SNU_hat
estimates store twoSLS2
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("twoSLS2") append

estimates table OLS1 OLS2 twoSLS1 twoSLS2, b(%9.4f) star stats(N r2) title(OLS)

* Estimación con IV y Test de Kleibergen-Paap
ivreg2 p1st s16 s26_h (SNU=s26_l), robust
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivreg2") append


*Regresión cuantílica usando Smartphone ownership como IV de SNU
* Cuantíl del 15% más feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU  , instruments(SNU s26_l  s26_h s26_b s1) q(.25)
estimates store tau25
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivq25") append
* Cuantíl del 50%
quietly ivqreg2 p1st  s26_h s26_b s1 SNU , instruments(SNU s26_l  s26_h s26_b s1) q(.5)
estimates store tau50
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivq50") append
* Cuantíl del 15% menos feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU  , instruments(SNU s26_l  s26_h s26_b s1) q(.75)
estimates store tau75
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivq75") append


* Irrestricto
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Irrestricto)


*Regresión cuantílica usando Smartphone ownership como IV de SNU. Casa propia y 
* Cuantíl del 15% más feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if (edad>18 & edad<25) , instruments(SNU s26_l s26_h s26_b s1) q(.25)
estimates store tau25
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivq25 18-25") append
* Cuantíl del 50%
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if (edad>18 & edad<25), instruments(SNU s26_l  s26_h s26_b s1) q(.5)
estimates store tau50
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivq50 18-25") append
* Cuantíl del 15% menos feliz
quietly ivqreg2 p1st  s26_h s26_b s1  SNU  if (edad>18 & edad<25), instruments(SNU s26_l  s26_h s26_b s1) q(.75)
estimates store tau75
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivq75 18-25") append


* Edad entre 18 y 25
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Entre 18 y 25)


*Regresión cuantílica usando Conexión a Internet en el Hogar como IV de SNU
* Cuantíl del 15% más feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.25)
estimates store tau25
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivq25 mas60") append
* Cuantíl del 50%
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.5)
estimates store tau50
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivq50 mas60") append
* Cuantíl del 15% menos feliz
quietly ivqreg2 p1st  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.75)
estimates store tau75
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("ivq75 mas60") append


* Edad más 60
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Mayores de 60)


* Smoothed IV quantile regression
quietly sivqr p1st  s26_h s26_b s1 (SNU=s26_l) , quantile(.25)
estimates store tau25
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("sivq25") append
quietly sivqr p1st s26_h s26_b s1 (SNU=s26_l) , quantile(.5)
estimates store tau50
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("sivq50") append
quietly sivqr p1st  s26_h s26_b s1 (SNU=s26_l) , quantile(.75)
estimates store tau75
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("sivq75") append

* Smoothed IV quantile regression
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(SIVQR)




* OLS 
quietly reg fel SNU
estimates store m_solo
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel solo") append
quietly reg fel SNU s16 s26_h 
estimates store todo1
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel todo1") append
quietly reg fel SNU s16 s26_h if (edad>18 & edad<25)
estimates store m1825
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel 18-25") append
quietly reg fel SNU s16 s26_h if edad>60
estimates store más60
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel mas60") append
quietly reg fel SNU s16 s26_h s26_b edad reg
estimates store todo2
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel todo2") append

estimates table m_solo todo1 m1825 más60 todo2, b(%9.4f) star stats(N r2) title(OLS)



* Chequeo smartphone ownership como IV
quietly reg fel SNU s26_l
estimates store OLS1
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ols1") append
quietly reg SNU s26_l
estimates store OLS2
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ols2") append

* 2SLS
quietly reg SNU s26_l
estimates store twoSLS1
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel twosls1") append
predict SNU_hat_fel
quietly reg fel SNU_hat_fel
estimates store twoSLS2
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel twosls2") append

estimates table OLS1 OLS2 twoSLS1 twoSLS2, b(%9.4f) star stats(N r2) title(OLS)

* Estimación con IV y Test de Kleibergen-Paap
ivreg2 fel s16 s26_h (SNU=s26_l), robust
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivreg") append


*Regresión cuantílica usando Smartphone ownership como IV de SNU
* Cuantíl del 15% más feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU  , instruments(SNU s26_l  s26_h s26_b s1) q(.25)
estimates store tau25
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivq25") append
* Cuantíl del 50%
quietly ivqreg2 fel  s26_h s26_b s1 SNU , instruments(SNU s26_l  s26_h s26_b s1) q(.5)
estimates store tau50
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivq50") append
* Cuantíl del 15% menos feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU  , instruments(SNU s26_l  s26_h s26_b s1) q(.75)
estimates store tau75
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivq75") append


* Irrestricto
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Irrestricto)


*Regresión cuantílica usando Smartphone ownership como IV de SNU. Casa propia y 
* Cuantíl del 15% más feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU if (edad>18 & edad<25) , instruments(SNU s26_l s26_h s26_b s1) q(.25)
estimates store tau25
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivq25 18-25") append
* Cuantíl del 50%
quietly ivqreg2 fel  s26_h s26_b s1 SNU if (edad>18 & edad<25), instruments(SNU s26_l  s26_h s26_b s1) q(.5)
estimates store tau50
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivq50 18-25") append
* Cuantíl del 15% menos feliz
quietly ivqreg2 fel  s26_h s26_b s1  SNU  if (edad>18 & edad<25), instruments(SNU s26_l  s26_h s26_b s1) q(.75)
estimates store tau75
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivq75 18-25") append


* Edad entre 18 y 25
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Entre 18 y 25)


*Regresión cuantílica usando Conexión a Internet en el Hogar como IV de SNU
* Cuantíl del 15% más feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.25)
estimates store tau25
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivq25 mas60") append
* Cuantíl del 50%
quietly ivqreg2 fel  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.5)
estimates store tau50
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivq50 mas60") append
* Cuantíl del 15% menos feliz
quietly ivqreg2 fel  s26_h s26_b s1 SNU if edad>60 , instruments(SNU s26_l s26_h s26_b s1) q(.75)
estimates store tau75
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel ivq75 mas60") append


* Edad más 60
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(Mayores de 60)


* Smoothed IV quantile regression
quietly sivqr fel  s26_h s26_b s1 (SNU=s26_l) , quantile(.25)
estimates store tau25
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel sivq25") append
quietly sivqr fel s26_h s26_b s1 (SNU=s26_l) , quantile(.5)
estimates store tau50
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel sivq50") append
quietly sivqr fel  s26_h s26_b s1 (SNU=s26_l) , quantile(.75)
estimates store tau75
outreg2 using "c:\data\salida felicidad.xls", excel ctitle("fel sivq75") append

* Smoothed IV quantile regression
estimates table tau25 tau50 tau75, b(%9.4f) star stats(N) title(SIVQR)