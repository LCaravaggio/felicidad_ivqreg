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


*Regresión cuantílica usando Conexión a Internet en el Hogar como IV de SNU
ivqreg p1st (SNU = m_nc), robust

*Variables independientes: sexo, nivel de estudios y posee auto
ivqreg p1st sexo s16 s26_g (SNU = m_nc), robust
