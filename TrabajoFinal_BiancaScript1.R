#______________________________________________________________________________
#                         TRABAJO FINAL INTEGRADOR----
#______________________________________________________________________________

## Integrantes----

# Joselin Chavez Martinez (20102168)
# Alexis Flores Cadillo (H0000801)
# Lady Fiorentino Martinez (20132766)
# Bianca Luzón Cueva (20130006)

#______________________________________________________________________________


## Herramientas preliminares ----

# Limpiamos la memoria para proceder a importar los datos
rm(list=ls()) 

# Detectamos el directorio donde se trabaja y se asigna una carpeta de trabajo
#compuname = Sys.info()["nodename"]
#if(compuname=="JOSELIN"){setwd("~/Desktop/QLAB/Intro a R Studio/Trabajo Final - G3")}

# Instalamos los paquetes necesarios para poder trabajar los datos

library(pacman)

p_load("lubridate","VIM","DEoptimR","minqa","nloptr","simputation", "mice", 
       "tidyverse", "DMwR2","naniar","Hmisc", "readr","gganimate","transformr",
       "readxl", "reshape2")


## Base de Datos ----
### a) Importar Hojas de Archivo Excel ----

Base<-read_xlsx("Base_empleo.xlsx",1)     #Se abre primera hoja. 
Inf_reg<-read_xlsx("Base_empleo.xlsx",2)  #Se abre segunda hoja.
Pob_reg<-read_xlsx("Base_empleo.xlsx",3)  #Se abre tercera hoja.

View(Base)
# Base: cuenta con 14 filas correspondientes a los años del 2011 al 2022 y con 28 columnas correspondientes a 
#año, tasa de informalidad, tasa de informalidad rural, tasa de informalidad urbana, tasa de informalidad hombres, tasa de 
#tasa de informalidad mujeres, población informal de 14 a 24 años, población informal de 25 a 44 años, población informal de 45 a 64 años, 
#población informal de 65 años a más, población informal en microempresas, población informal en pequeña empresa, 
#población informal de mediana y grande empresa,PEA, PEA ocupada, PEA ocupada urbana, PEA ocupada hombres, población de 14 a 24 años. 
#población de 25 a 44 años, población de 45 a 64 años, población de 65 años a más, población en microempresas, población en pequeñas empresas, 
#población en mediana y grande empresa, NEP(población que trabaja en empresas), ingresos promedio mensuales, ingresos promedio mensuales formales, 
#ingresos promedios mensuales informales. 

View(Inf_reg)
#Inf_reg: presenta la tasa de informalidad por departamento. Se cuenta con 14 filas correspondientes a los años del 2011 al 2022 
#y con 28 columnas correspondientes a las regiones del Perú.  

View(Pob_reg)
#Pob_reg: presenta la cantidad de población por departamento. Se cuenta con 14 filas correspondientes a los años del 2011 al 2022 
#y con 28 columnas correspondientes a las regiones del Perú. 

### b) Obteniendo variables faltantes ----

#Se crea la PEA ocupada femenina
Base$PEA_o_m <- Base$PEA_ocu - Base$PEA_o_h

#Se crea la PEA desocupada
Base$PEA_des <- Base$PEA - Base$PEA_ocu


#Se crea la PEA ocupada rural
names (Base)[16] <- "PEA_o_urb" #renombramos a PEA _o_urb porque tenía un espacio en blanco.
Base$PEA_o_rural <- Base$PEA_ocu - Base$PEA_o_urb

#Ahora se procede a crear las tasas de informalidad para las respectivas distribuciones
# Por edades:
Base$Tasa_Pob_inf_14 <- Base$Pob_inf_14/Base$`14_a_24`*100

Base$Tasa_Pob_inf_25 <- Base$Pob_inf_25/Base$`25_a_44`*100

Base$Tasa_Pob_inf_45 <- Base$Pob_inf_45/Base$`45_a_64`*100

Base$Tasa_Pob_inf_65 <- Base$Pob_inf_65/Base$`65_a_más`*100

# Por  tamaños de empresa:
Base$Tasa_Pob_inf_1 <- Base$Pob_inf_1/Base$`1_a_10`*100

Base$Tasa_Pob_inf_11 <- Base$Pob_inf_11/Base$`11_a_50`*100

Base$Tasa_Pob_más_50 <- Base$Pob_inf_50/Base$`50_más`*100

# Y la tasa de desempleo:
Base$Tasa_desempleo <- Base$PEA_des/Base$PEA*100

#Verificamos los datos 
View(Base)

### c) Conversión a series de tiempo ----

library(reshape2)

data_grafico0<- melt(Base, id.var = c('Año'))
                     
View(data_grafico0)

## Gráficos de prueba ----

data_grafico0 |>
  filter(variable == 'Tasa_desempleo') |>
  ggplot(mapping = aes(x = Año,y = value) ) + 
  geom_col() +
  labs(x = 'Años', y = 'Tasa de Desempleo')


data_grafico0 |>
  filter(variable == 'Tasa_desempleo') |>
  ggplot(mapping = aes(x = Año,y = value, group=1) ) + 
  geom_point() +
  labs(x = 'Años', y = 'Tasa de Desempleo') + 
  geom_line()

data_grafico0 |>
  filter(variable == 'tasa_inf') |>
  ggplot(mapping = aes(x = Año,y = value) ) + 
  geom_col() +
  labs(x = 'Años', y = 'tasa_inf')

data_grafico0 |>
  filter(variable %in% c('tasa_inf_rural','tasa_inf_urb')) |>
  ggplot( ) + 
  geom_line(aes(x=Año, y=value, group=variable, color=variable)) +
  labs(x = 'Años', y = 'Tasa informalidad urbana y rural')

data_grafico0 |>
  filter(variable %in% c('tasa_inf_rural','tasa_inf_urb')) |>
  ggplot() + 
  geom_bar(aes(x=Año, fill=value, group=variable, color=variable), position="dodge") +
  labs(x = 'Años', y = 'Tasa informalidad urbana y rural')


data_grafico0 |>
  filter(variable %in% c('tasa_inf_rural','tasa_inf_urb')) |>
  ggplot( ) + 
  geom_col(aes(x=Año, y=value, group=variable, color=variable)) +
  labs(x = 'Años', y = 'Tasa informalidad urbana y rural')

data_grafico0 |>
  filter(variable %in% c('Tasa_Pob_inf_1','Tasa_Pob_inf_11', 'Tasa_Pob_más_50')) |>
  ggplot( ) + 
  geom_line(aes(x=Año, y=value, group=variable, color=variable)) +
  labs(x = 'Años', y = 'Tasas')

----------------
#Grafico 1: Tasa de Informalidad por Años (lineas)
  
  data_grafico0 |>
  filter(variable == 'Tasa_desempleo') |>
  ggplot(mapping = aes(x = Año,y = value, group=1) ) + 
  geom_point() +
  labs(x = 'Años', y = 'Tasa de Desempleo') + 
  geom_line()
  
#Grafico 2: Tasa de Informalidad urbano / rural por Años (2 barras por año) - Alexis
  
#Gráfico 3: Tasa de informalidad hombre/mujer por Años (2 barras por año) - Alexis
  
#Gráfico 4: Tasa de Población Informal por Edades por Años (lineas) - Alexis
  
#Grafico 5: Tasa de Población Informal en micro, pequeñas y mediana/grande empresa (lineas) - Aly 
  
#Grafico 6: PEA ocupada y desocupada por Años (2 barras por año) - Aly 

#Grafico 7: PEA hombre y mujer por Años (2 barras por año) - Aly 

#Grafico 8: PEA urbana y rural por Años (2 barras por año) - Bianca

#Graifco 9: Tasa de desempleo por Años (lineas) - Bianca

#Gráfico 10: Ingresos mensuales totales, formales e informales (lineas) - Bianca

#Mapa1: Tasa de informalidad por regiones 2019 y 2022. 



  
  
