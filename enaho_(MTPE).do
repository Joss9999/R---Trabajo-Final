clear all

cd "K:\DPEM\1. Encargos Regulares\27. Empleo Informal RMV\BASES DE DATOS - STATA"

use "K:\DPEM\1. Encargos Regulares\27. Empleo Informal RMV\BASES DE DATOS - STATA\Enaho-2016-500_Variables-MTPE.dta", clear
set more off


*********Urbano*********************************************************************************************
*Urbano: areas con más de 400 viviendas.
gen urbano=0 if estrato>=6 & estrato<=8
replace urbano=1 if estrato<6 
replace urbano=. if estrato==.
label variable urbano "Ambito geografico"
label define urbano 0 "Rural" 1 "Urbano" 
label values urbano urbano


*********Dominios geográficos****************************************************************************
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


***********Departamentos**********************************************************************************
destring ubigeo, g(ubigeo1)
g departamento=int(ubigeo1/10000)
label variable departamento "Departamento"
label define departamento 1 "Amazonas" 2 "Ancash" 3 "Apurimac" 4 "Arequipa" 5 "Ayacucho" 6 "Cajamarca" 7 "Callao" 8 "Cusco" 9 "Huancavelica" ///
 10 "Huanuco" 11 "Ica" 12 "Junin" 13 "La Libertad" 14 "Lambayeque" 15 "Lima" 16 "Loreto" 17 "Madre de Dios" 18 "Moquegua" 19 "Pasco" 20 "Piura" ///
 21 "Puno" 22 "San Martin" 23 "Tacna" 24 "Tumbes" 25 "Ucayali"
label values departamento departamento

******************Actividad laboral: CIIU4****************************************************************
g ciiu4=int(p506r4/100) 

g sectortrab=.
replace sectortrab=1 if ciiu4==1 
replace sectortrab=2 if ciiu4==2
replace sectortrab=3 if ciiu4==3
replace sectortrab=4 if ciiu4>=5 & ciiu4<=9
replace sectortrab=5 if ciiu4>=10 & ciiu4<=32
replace sectortrab=6 if ciiu4>=41 & ciiu4<=43
replace sectortrab=7 if ciiu4==45 | ciiu4==46 | ciiu4==47   
replace sectortrab=8 if ciiu4>=49 & ciiu4<=53 
replace sectortrab=9 if ciiu4==55 | ciiu4==56   
replace sectortrab=10 if ciiu4==85 
replace sectortrab=11 if ciiu4==97| ciiu4==98 
replace sectortrab=12 if ciiu4~=45& ciiu4~=46& ciiu4~=47& ciiu4~=85 & ciiu4~=97& ciiu4~=98 & ciiu4~=55& ciiu4~=56& (ciiu4>=35 & ciiu4<41|ciiu4>57)

label variable sectortrab "Sector Economico de trabajo"
label define sectortrab 1 "Agricultura" 2 "Silvicultura" 3 "Pesca" 4 "Mineria" 5 "manufactura" 6 "construccion" 7 "comercio" 8 "transporte" 9 "restaurante y hoteles" 10 "Enseñanza" 11 "servicios domesticos" 12 "otros servicios"
label value sectortrab sectortrab


******************Actividad laboral: CIIU3****************************************************************
g ciiu3=v05RamActRev3

g sectortrab1=.
replace sectortrab1=1 if ciiu3==1 
replace sectortrab1=2 if ciiu3==2
replace sectortrab1=3 if ciiu3==5
replace sectortrab1=4 if ciiu3>=10 & ciiu3<=14
replace sectortrab1=5 if ciiu3>=15 & ciiu3<=37
replace sectortrab1=6 if ciiu3==45
replace sectortrab1=7 if ciiu3==50 & ciiu3<=52   
replace sectortrab1=8 if ciiu3>=60 & ciiu3<=64 
replace sectortrab1=9 if ciiu3==55 
replace sectortrab1=10 if ciiu3==80 
replace sectortrab1=11 if ciiu3==95
replace sectortrab1=12 if ciiu3==40 & ciiu3==41 & (ciiu3>=65|ciiu3<=67) & (ciiu3>=70|ciiu3<=74) & ciiu3==75 & ciiu3==85 & (ciiu3>=90|ciiu3<=93)& ciiu3==99

label variable sectortrab1 "Sector Economico de trabajo"
label define sectortrab1 1 "Agricultura" 2 "Silvicultura" 3 "Pesca" 4 "Mineria" 5 "manufactura" 6 "construccion" 7 "comercio" 8 "transporte" 9 "restaurante y hoteles" 10 "Enseñanza" 11 "servicios domesticos" 12 "otros servicios"
label value sectortrab1 sectortrab1

tab sectortrab  [iw=fac500a]
tab sectortrab1 [iw=fac500a]


*****************************************************************
* TRABAJADORES EN EL SECTOR PÚBLICO Y PRIVADO
*****************************************************************

* Método 1: agrego todo VA

gen sp=. 
replace sp=0 if p510==1 | p510==2 | p510==3 
replace sp=1 if p510==5 | p510==6  | p510==7   | p507==1  | p507==2 | p507==5  | p507==6 
label variable sp "Sector"
label define sp 0 "Público" 1 "Privado" 
label values sp sp

tab sp [iw=fac500a]

* Método 2: usa p510

gen sp2=. 
replace sp2=0 if p510==1 | p510==2 | p510==3 
replace sp2=1 if p510==5 | p510==6  | p510==7  
label variable sp2 "Sector"
label define sp2 0 "Público" 1 "Privado" 
label values sp2 sp2

tab sp [iw=fac500a]
tab sp2 [iw=fac500a]

 
*****************************************************************
* SITUACIÓN LABORAL
*****************************************************************
*v03ConAct: condición de actividad
*v04GruOcu: grupo ocupacional  (ocu. principal)
*v08CatOcu categoria ocupacional (ocu. principal)
*v08CatOcuRec: categoria ocupacional (ocu. principal)

g ocu=1 if ocu500==1 & p507==2		
replace ocu=2 if ocu500==1 & p507~=2	
replace ocu=3 if ocu500==2 | ocu500==3 
replace ocu=4 if ocu500==4

label variable ocu "Situacion en el mercado laboral"
label define ocu 1 "Independiente" 2 "Dependiente" 3 " Desempleado" 4 "No PEA"
label value ocu ocu

*Mejor usar OCU
tab ocu [iw=fac500]
tab v03ConAct [iw=fac500]

tab v08CatOcu [iw=fac500]
tab v08CatOcuRec [iw=fac500]


***********************************************************************
*=====================TAMAÑO DE EMPRESA===========================*

*************************************************************************
g tamano=p512b
g empresa=0 if ocu==1   //* Independientes
replace empresa=1 if ocu==2 & tamano>=1 &tamano<=10 //* Micro
replace empresa=2 if ocu==2 & tamano>10 & tamano<=50  //*Pequeña
replace empresa=3 if ocu==2 & tamano>50 & tamano<=100 //* Mediana
replace empresa=4 if ocu==2 & tamano>100 //* Grande

label define empresa 0 "Independientes" 1 "Micros" 2 "Pequeñas" 3 "Medianas" 4 "Grandes"
label value empresa empresa

***************************************************************************
g empresa2=1 if (ocu==2 | ocu==1) & tamano>=1 &tamano<=10 //* Micro
replace empresa2=2 if (ocu==2 | ocu==1)  & tamano>10 & tamano<=50  //*Pequeña
replace empresa2=3 if (ocu==2 | ocu==1)  & tamano>50 & tamano<=100 //* Mediana
replace empresa2=4 if (ocu==2 | ocu==1) & tamano>100 //* Grande

label define empresa2 1 "Micros" 2 "Pequeñas" 3 "Medianas" 4 "Grandes"
label value empresa2 empresa2

tab empresa sp [iw= fac500]  
tab empresa2 sp2 [iw= fac500]  

tab empresa2  sp [iw= fac500]  

 *PEA
g pea=1 if ocu==3
replace pea=2 if ocu==1 | ocu==2

label variable pea "PEA TOTAL"
label define pea 1 "desempleado" 2 "PEA ocupada"
label value pea pea

tab pea [iw=fac500]

tab empresa pea [iw=fac500] 
tab empresa2 pea [iw=fac500] 





****************************************************************************************
*Informalidad
gen formalidad=0 if ocupinf == 1 //informal 
replace formalidad=1 if ocupinf==2   //formal 
replace formalidad=. if ocupinf ==.
label variable formalidad "Formalidad"
label define formalidad 0 "Informal" 1 "Formal" 
label values formalidad formalidad

tab formalidad [iw=fac500a]

*por default, sólo ocupados
tab empresa formalidad [iw=fac500] 
tab empresa2 formalidad [iw=fac500]


gen secempleo=0 if emplpsec == 1 //Empleo informal en el sector informal 
replace secempleo=1 if emplpsec == 2   //Empleo en el sector informal fuera del sector informal
replace secempleo=. if emplpsec ==.
label variable secempleo "Empleo por sector"
label define secempleo 0 "Informal" 1 "Infenformal" 
label values secempleo secempleo

tab secempleo [iw=fac500a]
 

*********************************************************************
*Calificacion

*v02NivEdu = Nivel educativo desagregado
*v02NivEduAlc = Nivel educativo agregado

gen calificacion=. 
replace calificacion=. if v02NivEduAlc==6
replace calificacion=0 if v02NivEduAlc>=1 & v02NivEduAlc<=3
replace calificacion=1 if v02NivEduAlc>=4 & v02NivEduAlc<=5
label variable calificacion "Calificacion"
label define calificacion 0 "No calificado" 1 "Calificado" 
label values calificacion calificacion

tab pea calificacion [iw=fac500]

************Ingreso*******************************************************************************************
*=============================================== VERSIÓN 1

*Ingreso principal:
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

*Ingreso secundario:
recode p541a .=0
g ingreso_sec=.
replace ingreso_sec=p541a if ocu500==1 &  p507==2
replace ingreso_sec=. if ingreso==999999
label variable ingreso_sec "Ingreso por ocup. secundaria"

*Ingreso total:
egen ingreso_total=rowtotal( ingreso ingreso_sec), missing

label variable ingreso_total "Ingreso total"

mean ingreso_total [iw=fac500a]

*=============================================== VERSIÓN 2

* v06IngLab: ingreso laboral mensual (ocupación principal y secundaria)
* v06IngLabOcuPrin: Ingreso laboral mensual (ocupación principal)
mean v06IngLab v06IngLabOcuPrin [iw=fac500a]

*Ingreso Promedio Mensual (S/) de la PEA ocupada
sum v06IngLab [iw=fac500a] if v03ConAct==1 & v06IngLab >0 & v08CatOcuRec !=5
table empresa  sp [iw=fac500a] if v03ConAct==1 & v06IngLab >0 & v08CatOcuRec !=5 , c(mean v06IngLab)
table empresa2  sp [iw=fac500a] if v03ConAct==1 & v06IngLab >0 & v08CatOcuRec !=5 , c(mean v06IngLab)

table empresa  formalidad [iw=fac500a] if v03ConAct==1 & v06IngLab >0 & v08CatOcuRec !=5 , c(mean v06IngLab)
table empresa2  formalidad [iw=fac500a] if v03ConAct==1 & v06IngLab >0 & v08CatOcuRec !=5 , c(mean v06IngLab)



*=============================================== VERSIÓN 3: INGRESO y RMV
*v08CatOcuRec !=5: Trabajador familiar no remunerado
*v06IngLab >0:  ingreso mayor a 0
*v03ConAct==1: ocupados


*local ingreso_total2  v06IngLab  // `ingreso_total2'

g rmv= .
replace rmv = 1 if v06IngLab <= 850
replace rmv= 2 if v06IngLab > 850  &  v06IngLab  <= 2*850
replace rmv = 3 if v06IngLab > 2*850 
label variable rmv "RMV"
label define rmv  1 "hasta 1 RMV"  2 " 1 hasta 2 RMV" 3 "+ 2 RMV" 
label values rmv rmv

table rmv [iw=fac500a]

table  empresa rmv [iw=fac500a] if v03ConAct==1 & v06IngLab >0 & v08CatOcuRec !=5  & sp==1
table  empresa2 rmv [iw=fac500a] if v03ConAct==1 & v06IngLab >0 & v08CatOcuRec !=5 & sp==1

table empresa  rmv    [iw=fac500a] if v03ConAct==1 & v06IngLab >0  & v08CatOcuRec !=5  , c(mean v06IngLab)
table empresa2 rmv  [iw=fac500a] if v03ConAct==1 & v06IngLab >0 & v08CatOcuRec !=5  ,  c(mean v06IngLab)



*****************Relaciones*******************************************************************************
*DEPARTAMENTO ACTIVIDAD
tab  departamento sectortrab [iw=fac500a] if sectortrab==3

*INGRESO ACTIVIDAD
table sectortrab [iw=fac500a], c(mean ingreso_total)

*DEPARTAMENTO ACTIVIDAD Y SITUACIÓN LABORAL
table departamento sectortrab v08CatOcu [iw=fac500a] if sectortrab==1

*EDAD
gen edad=.
replace edad=1 if p208a >= 14 & p208a < 25 
replace edad=2 if p208a >= 25 & p208a < 45 
replace edad=3 if p208a >= 45

label variable edad "Edad"
label define edad 1 "14 a 24 años" 2 "25 a 44 años" 3 "44 a más" 
label values edad edad


***********************************************************************
*=============================TABLAS================================*

g uit= .
replace uit = 1 if v06IngLab <= 4150
replace uit = 2 if v06IngLab > 4150
label variable uit "UIT"
label define uit  1 "hasta 2 UIT"  2 "+ 2 UIT" 
label values uit uit

table uit pea [iw=fac500a] if pea==2



g uit2= .
replace uit2 = 1 if v06IngLab <= 3950
replace uit2 = 2 if v06IngLab > 3950
label variable uit2 "UIT"
label define uit2  1 "hasta 2 UIT"  2 "+ 2 UIT" 
label values uit2 uit2

table uit2 pea [iw=fac500a] if pea==2

table pea uit2  [iw=fac500a] if v03ConAct==1 & v06IngLab >0 & v08CatOcuRec !=5  ,  c(mean v06IngLab)




gen edad=.
replace edad=1 if p208a >= 14 & p208a < 26 
replace edad=2 if p208a >= 26 & p208a < 36 
replace edad=3 if p208a >= 36 & p208a < 46 
replace edad=4 if p208a >= 46 & p208a < 56 
replace edad=5 if p208a >= 56 & p208a < 66 
replace edad=6 if p208a >= 66

label variable edad "Edad"
label define edad 1 "14 a 25 años" 2 "26 a 35 años" 3 "36 a 45 años" 4 "46 a 55 años" 5 "56 a 65 años" 6 "66 a más" 
label values edad edad

