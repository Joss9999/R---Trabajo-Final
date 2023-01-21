****2007***

** Primero trabaja con base de empleo
clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2007-500.dta", clear
quietly destring *, replace 
*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save "P:\Enaho\BASES\base_empleo_2007.dta", replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2007-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2007, replace


***Unimos ambas bases****
use base_empleo_2007, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2007
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2007, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 

*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1

gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace 

*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2007_2.dta", replace

snapshot save, label("empleo formal 2007")

********************************************************************************
**************************************2008**************************************

** Primero trabaja con base de empleo

clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2008-500.dta", clear
quietly destring *, replace 
*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save base_empleo_2008, replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2008-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2008, replace


***Unimos ambas bases****
use base_empleo_2008, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2008
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2008, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 

*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1

gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace 

*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2008_2.dta", replace

snapshot save, label("empleo formal 2008")

********************************************************************************
**************************************2009**************************************

** Primero trabaja con base de empleo

clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2009-500.dta", clear
quietly destring *, replace 

*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save base_empleo_2009, replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2009-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2009, replace


***Unimos ambas bases****
use base_empleo_2009, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2009
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2009, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 

*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1

gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace 

*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2009_2.dta", replace

snapshot save, label("empleo formal 2009")

********************************************************************************
**************************************2010**************************************

** Primero trabaja con base de empleo

clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2010-500.dta", clear
quietly destring *, replace 

*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save base_empleo_2010, replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2010-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2010, replace


***Unimos ambas bases****
use base_empleo_2010, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2010
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2010, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 
*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1

gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace 

*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2010_2.dta", replace

snapshot save, label("empleo formal 2010")

********************************************************************************
**************************************2011**************************************

** Primero trabaja con base de empleo

clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2011-500.dta", clear
quietly destring *, replace 

*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save base_empleo_2011, replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2011-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2011, replace


***Unimos ambas bases****
use base_empleo_2011, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2011
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2011, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 

*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1

gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace 

*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2011_2.dta", replace

snapshot save, label("empleo formal 2011")

********************************************************************************
**************************************2012**************************************

** Primero trabaja con base de empleo

clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2012-500.dta", clear
quietly destring *, replace 

*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu500==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save base_empleo_2012, replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2012-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2012, replace


***Unimos ambas bases****
use base_empleo_2012, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2011
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2012, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 

*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1

gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace 

*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2012_2.dta", replace

snapshot save, label("empleo formal 2012")
********************************************************************************
**************************************2013**************************************

** Primero trabaja con base de empleo

clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2013-500.dta", clear
quietly destring *, replace 

*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu500==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save base_empleo_2013, replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2013-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2013, replace


***Unimos ambas bases****
use base_empleo_2013, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2013
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2013, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 
*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1

gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace 

*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2013_2.dta", replace

snapshot save, label("empleo formal 2013")

********************************************************************************
**************************************2014**************************************

** Primero trabaja con base de empleo

clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2014-500.dta", clear
quietly destring *, replace 

*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu500==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save base_empleo_2014, replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2014-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2014, replace


***Unimos ambas bases****
use base_empleo_2014, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2014
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2014, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 

*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1


gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace
*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2014_2.dta", replace

snapshot save, label("empleo formal 2014")

********************************************************************************
**************************************2015**************************************

** Primero trabaja con base de empleo

clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2015-500.dta", clear
quietly destring *, replace 

*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu500==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save base_empleo_2015, replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2015-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2015, replace


***Unimos ambas bases****
use base_empleo_2015, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2014
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2015, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 

*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1


gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace
*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2015_2.dta", replace

snapshot save, label("empleo formal 2015")


********************************************************************************
**************************************2016**************************************

** Primero trabaja con base de empleo

clear all

cd P:\Enaho\BASES
*****Base empleo*****
use "P:\Enaho\BASES\enaho01a-2016-500.dta", clear
quietly destring *, replace 

*********Urbano
*Urbano: areas con más de 400 viviendas.

gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano

*********Dominios geográficos
gen newdominio=1 if dominio==8
replace newdominio=2 if [dominio==1 | dominio==2 | dominio==3] &  urbano==1
replace newdominio=3 if [dominio==1 | dominio==2 | dominio==3] &  urbano==0
replace newdominio=4 if [dominio==4 | dominio==5 | dominio==6] &  urbano==1
replace newdominio=5 if [dominio==4 | dominio==5 | dominio==6] &  urbano==0
replace newdominio=6 if [dominio==7] &  urbano==1
replace newdominio=7 if [dominio==7] &  urbano==0
label variable newdominio "Nuevo dominio"
label define newdominio 1 "Lima Met." 2 "Costa urbana" 3 "costa rural" 4 "sierra urbana" 5 "sierra rural" 6 "selva urbana" 7 "selva rural"
label values newdominio newdominio

***********Departamentos
gen departamento=int(ubigeo/10000)
label variable departamento "Departamentos"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" 21 "Puno" 22 "San Martín" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

***tipo de contrato
g tcontrato=p511a
recode tcontrato 3=8
recode tcontrato 4=8
recode tcontrato 5=8
replace tcontrato=9 if p507==5                                // TFNR
recode tcontrato .=10 if ocu500==1                               // independiente 
replace tcontrato=. if ocu500!=1 

label variable tcontrato "Tipo de contrato de trabajo"
label define tcontrato 1 "Indefinido" 2 "Plazo fijo" 6 "Locacion / No personales" 7 "Sin contrato" 8 "Otro" 9 "TFNR" 10 "Independiente"
label value tcontrato tcontrato

save base_empleo_2015, replace

*******Empleo formal: empresas de diez a más trabajadores y que tienen seguro de salud 
*******(pagado por trabajador o empleador) o afiliado a sistema previsional.

****Base Salud****
clear all

*Defino la base de salud
use "P:\Enaho\BASES\enaho01a-2016-400.dta", clear
quietly destring *, replace

g essalud=1 if p4191==1 
replace essalud=0 if p4191==0 

g sps=1 if p4192==1 
replace sps=0 if p4192==0 

g eps=1 if p4193==1 
replace eps=0 if p4193==0 

g ffaa=1 if p4194==1 
replace ffaa=0 if p4194==0 

g sis=1 if  p4195==1
replace sis=0 if  p4195==0

g segurosalud=1 if essalud==1 | sps==1 | eps==1 | ffaa==1
replace segurosalud=0 if essalud==0 & sps==0 & eps==0 & ffaa==0 

keep conglome vivienda hogar codperso segurosalud
sort conglome vivienda hogar codperso
save base_salud_2015, replace


***Unimos ambas bases****
use base_empleo_2015, clear
merge 1:1 conglome vivienda hogar codperso using base_salud_2015
tab _merge 
keep if _merge==3 // modulo de salud: todas las personas del hogar, modulo de empleo: mayores de 14 años. 
save base_formal_2015, replace

***empleo formal: con derechos laborales. con contrato, seguro de salud, sistema de pensiones, salario minimo. 
**con contrato.
g contrato=.
replace contrato=1 if ocu500==1 & p511a<7		//trabaja y tiene contrato 
replace contrato=0 if ocu500==1 & (p511a>=7 | p507==1 | p507==2)   //trabaja y no tiene contrato o es patrono o independiente.

*afiliacion a sistema de pensiones
g pensiones=.
replace pensiones=1 if p558a5==0 & p558b2>=p500d1-1  //que haya aportado recientemente.
replace pensiones=0 if p558a5==5 | p558b2<p500d1-1

****situacion en el mercado laboral
g ocu=1 if ocu500==1 & p507==2		//trabaja y es independiente
replace ocu=2 if ocu500==1 & p507~=2	//trabaja y no es independiente
replace ocu=3 if ocu500==2 | ocu500==3 	//desempleado abierto u oculto.
replace ocu=4 if ocu500==4			//No PEA.

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*tamaño de empresa
g tamano=p512b
g mype=0 if ocu==1
replace mype=1 if ocu==2 & tamano<=10 //* Micro
replace mype=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña 
replace mype=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace mype=4 if ocu==2 & tamano>100 //* Grande

label define mype 0 "Independiente" 1 "Micro" 2 "Pequeña" 3 "Mediana" 4 "Grande"
label value mype mype 

*ingreso
recode p524a1 .=0
recode p530a .=0
g ingreso=.
replace ingreso=p524a1*26 if p523==1 & ocu500==1 & p507~=2
replace ingreso=p524a1*4 if p523==2 & ocu500==1 & p507~=2
replace ingreso=p524a1*2 if p523==3 & ocu500==1 & p507~=2
replace ingreso=p524a1*1 if p523==4 & ocu500==1 & p507~=2
replace ingreso=p530a if p507==2 & ocu500==1
replace ingreso=. if ingreso==999999
label variable ingreso "Ingreso laboral mensual"

*** Esto es formal (que tenga seguro de salud pagado por empleador o esta afiliado a AFP y pague) ***

g formal=.
replace formal=1 if ocu500==1 & (segurosalud==1 & pensiones==1 & tcontrato==1 | tcontrato==2 | tcontrato==6) 
replace formal=0 if ocu500==1 & (segurosalud==0 & pensiones==0)  	
replace formal=. if ocu500!=1


gen dum=1
table dum if urbano==1 & ocu500==1 & formal==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 [iw=fac500a]
table dum if urbano==1 & ocu500==1 & formal==1 & (ingreso>2000 | ingreso<7000) [iw=fac500a]

quietly destring *, replace
*keep if p203==1
drop _m
save "P:\Enaho\BASES\base_formal_2016_2.dta", replace

snapshot save, label("empleo formal 2016")









