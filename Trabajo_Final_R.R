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

# Detectamos el directorio donde se trabajará
directorio = dirname(rstudioapi::getSourceEditorContext()$path)
setwd(directorio)
dirmother = dirname(getwd())


### a) Instalamos los paquetes necesarios ----
library(pacman)
p_load("tidyverse", "readr","gganimate", "readxl", "reshape2", "sf", "purrr", 
       "ggrepel", "reshape2", "Hmisc", "gganimate", "transformr", "zoo",
       "DEoptimR","minqa","nloptr","simputation", "mice","DMwR2","naniar",
       "plotly")


### b) Importamos la base de datos del Archivo Excel ----

Base <- read_xlsx("Base_empleo.xlsx",1)     #Se abre primera hoja. 
Inf_reg <- read_xlsx("Base_empleo.xlsx",2)  #Se abre segunda hoja.
Pob_reg <- read_xlsx("Base_empleo.xlsx",3)  #Se abre tercera hoja.

### c) Descripción de la base de datos ----
View(Base)
# Base: cuenta con 12 filas correspondientes a los años del 2011 al 2022 y con 28 columnas 
# correspondientes a la tasa de informalidad, tasa de informalidad rural, tasa de informalidad 
# urbana, tasa de informalidad hombres, tasa de informalidad mujeres, población ocupada informal de 
# 14 a 24 años, población ocupada informal de 25 a 44 años, población ocupadada informal de 45 
# a 64 años, población ocupada informal de 65 años a más, población ocupada informal en 
# microempresas, población ocupada informal en pequeñas empresas, población ocupada informal 
# en medianas y grandes empresas, PEA total, PEA ocupada, PEA ocupada urbana, PEA ocupada hombres,
# población ocupada de 14 a 24 años, población ocupada de 25 a 44 años, población ocupada de 
# 45 a 64 años, población ocupada de 65 años a más, población ocupada en microempresas, 
# población ocupada en pequeñas empresas, población ocupada en mediana y gran empresa, 
# NEP (población ocuapada que trabaja en empresas no identificadas), ingresos promedio mensuales, 
# ingresos promedio mensuales de trabajadores formales, ingresos promedios mensuales de 
# trabajadores informales. 

View(Inf_reg)
#Inf_reg: presenta la tasa de informalidad por departamento. Se cuenta con 12 filas correspondientes
# a los años del 2011 al 2022 y con 28 columnas correspondientes a las regiones del Perú (que
# incluye la Provincia Constitucional del Callao y la desagregación de Lima en Lima Metropolitana
# y Lima Provincias).

View(Pob_reg)
#Pob_reg: presenta la cantidad de población ocupada por departamento. Se cuenta con 12 filas 
# correspondientes a los años del 2011 al 2022 y con 28 columnas correspondientes a las
# regiones del Perú (que incluye la Provincia Constitucional del Callao y la desagregación 
# de Lima en Lima Metropolitana y Lima Provincias).

## Construcción de variables relevantes ----

# Procedemos a construir las variables relevantes para el análisis que no han sido incorporadas
# de manera preliminar: 

# Se crea la PEA ocupada femenina
Base$PEA_o_m <- Base$PEA_ocu - Base$PEA_o_h

# Se crea la PEA desocupada
Base$PEA_des <- Base$PEA - Base$PEA_ocu

# Se crea la PEA ocupada rural
Base$PEA_o_rural <- Base$PEA_ocu - Base$PEA_o_urb

#Ahora se procede a crear las tasas de informalidad para las respectivas distribuciones: 
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

# Verificamos nuevamente los datos ahora con 39 variables (incluyendo los años)
View(Base)

## Inspección de los datos: ----

# En principio con la verificación previa no notamos alguna inconsistencia en los
# datos debido a la extensión (es una base pequeña de inspección sencilla). Sin
# embargo, generamos algunas estadísticas descriptivas para entender la base de 
# datos:

class(Base)
class(Inf_reg)
class(Pob_reg)

str(Base)
str(Inf_reg)
str(Pob_reg)

describe(Base)
describe(Inf_reg)
describe(Pob_reg)

# Las bases son dataframes, y podemos notar que el dataframe Base las 38 variables son
# numéricas, de manera similar con las otras bases (tenemos solo variables numéricas).
# Asimismo, podemos notar que en los años elegidos (2011-2022), el promedio de la 
# tasa de informalidad es de 73.73% de alrededro de 16 millones de trabajadores en
# todo el Perú. Asimismo, en promedio la tasa de desempleo ha sido en promedio 5%
# en los últimos 11 años, llegando hasta un máximo de 7.4% registrado en el periodo 
# de la pandemia (2020). 

# En esta línea, el promedio del salario mensual en el mismo periodo es de 1,279 soles;
# sin embargo, en promedio un trabajador formal ha tenido un salario promedio de
# 1,841, mientras que un trabajador informal de 663 soles al mes.

# Por otro lado, revisando posibles problemas con los datos, checamos los missing values:
any_na(Base)
any_na(Inf_reg)
any_na(Pob_reg)

View(miss_var_summary(Base))
View(miss_var_summary(Inf_reg))
View(miss_var_summary(Pob_reg))

# Notamos que el dataframe Base no contiene missing values; no obstante las bases
# asociadas a las regiones o departamentos contienen valores perdidos que corresponden
# a la desagregación de la región Lima (Lima Metropolitana + Lima Provincias), lo
# cual no resulta en un problema dado que para el comparativo entre las regiones 
# podemos omitir la desagregación y trabajar con el agregado de Lima que no contiene
# valores perdidos.



## Elaboración de los gráficos para el análisis de resultados ----

# En primer lugar, para poder hacer lo gráficos requerimos que nuestras variables
# se encuentren correctamente adecuadas para utilizar el comando ggplot, por lo que 
# acomodamos su estructura con la función "melt" del paquete "reshape":
data_grafico0<- melt(Base, id.var = c('Año'))
View(data_grafico0)

# Elaboramos y construimos las medidas adecuadas para cada gráfico:

### Tasa de informalidad ----
G0 <- data_grafico0 |>
  filter(variable == 'tasa_inf') |>
  ggplot(aes(x = as.factor(Año), y = value, fill = value)) +
  geom_col() +
  theme_minimal() +
  coord_cartesian(ylim = c(60, 80)) +
  scale_fill_distiller(palette = "Blues", direction = 1) +
  labs(title = "Evolución de la tasa de informalidad en Perú del 2011 al 2022",
       caption = "Fuente: Enaho",
       x = 'Año', y = 'Tasa de informalidad') +
  transition_states(Año) +
  theme_light() +
  shadow_mark() 

animate(GO, renderer = gifski_renderer())


### PEA Ocupada y Desocupada ----
data_grafico0 |>
  filter(variable %in% c('PEA_des','PEA_ocu')) |>
  ggplot() +
  geom_col(aes(x = as.factor(Año), y = value/1000, fill = variable)) +
  labs(title = "Población Económicamente Activa ocupada y desocupada (en miles)",
       caption = "Fuente: Enaho", 
       x = 'Año', 
       y = 'Número de personas') +
  scale_fill_hue(labels = c("PEA Ocupada", "PEA Desocupada"), 
                 guide_legend(title = "PEA"))+
  scale_y_continuous(breaks=seq(0,20000,2000))


### Tasa de desempleo ----
G1 <- data_grafico0 |>
  filter(variable == 'Tasa_desempleo') |>
  ggplot(aes(x = as.factor(Año), y = value, group = 1)) +
  geom_line(size = 1.3, col = "firebrick", linetype = "dashed") +
  labs(title = "Evolución de la tasa de desempleo en Perú del 2011 al 2022",
       caption = "Fuente: Enaho",
       x = 'Año', y = 'Tasa de Desempleo') +
  geom_point(col = "gold4") +
  theme_light() +
  transition_reveal(Año) +
  shadow_mark(0.8) 

animate(G1, renderer = gifski_renderer())


### Tasa de informalidad urbano rural ----
data_grafico0 |>
  filter(variable %in% c('tasa_inf_rural','tasa_inf_urb')) |>
  ggplot() +
  aes(x = as.factor(Año), y = value) +
  scale_y_continuous(breaks=seq(0,100,10)) + 
  scale_fill_discrete(labels = c("Rural","Urbano"),guide_legend(title = "Zona")) + 
  aes(fill=variable) + 
  ylab("Tasa de informalidad") + 
  xlab("Año") + 
  labs(title="Tasa de Informalidad por tipo de zona",caption = "Fuente: Enaho") + 
  geom_bar(width = 0.9,stat="identity",position = position_dodge())


### Tasa de informalidad hombres y mujeres ----
data_grafico0 |>
  filter(variable %in% c('tasa_inf_h','tasa_inf_m')) |>
  ggplot() +
  geom_line(aes(x = as.factor(Año), y = value,group=variable, color=variable)) +
  labs(title = "Tasa de Informalidad en hombres y mujeres",
       caption = "Fuente: Enaho", 
       x = 'Año', 
       y = 'Tasa de informalidad') +
  scale_color_discrete(labels = c("Hombres", "Mujeres"), 
                       guide_legend(title = "Informalidad"))


### PEA informal por grupos de edades ----

g4=Base[,c("Año","Pob_inf_14","Pob_inf_25","Pob_inf_45","Pob_inf_65")]
names(g4)=c("Año","14 a 24 años","25 a 44 años","45 a 64 años","65 a más")
#se muestra las 6 primeras observaciones
head(g4)


#la funcion melt unificará en una sola columna
#dicho resultado se almacena en g44
g44<- melt(g4, id.vars ="Año")

#Se observa las 6 primeras observaciones
head(g44)
#Se coloca los nombres de las variables adecuadamente 
names(g44)=c("Año","Edad","cant")

#Se añade la columna cantidad en millones
g44$CantMM=round(g44$cant/1000000,2)
head(g44)
View(g44)

## Tipo 1: Líneas
g44 |>
  ggplot() +
  aes(x = Año) + # Se define los valores del eje X
  aes(y = CantMM)+ # Se define  los valores del eje Y
  scale_x_continuous(breaks=2011:2022)+ # Se define  los valores del eje Y
  scale_y_continuous(breaks=seq(0,100,10))+ #se define los valores para eje y
  aes(color=Edad)+
  ylab("PEA informal")+ #se coloca el nombre del eje vertical
  geom_line(lwd=2)+ #se grafica lineas de tamaño 2
  geom_point(lwd=4)+ #se grafican puntos de tamaño 4
  geom_text_repel(aes(label=CantMM,x=Año, y=CantMM),colour="black",size=4)+
  labs(title="PEA informal por grupo etario (en millones)") # se coloca el titulo



### Tasa de informalidad empresa ----
# No se incluyó en el Rmd
data_grafico0 |>
  filter(variable %in% c("Tasa_Pob_inf_1","Tasa_Pob_inf_11", "Tasa_Pob_más_50")) |>
  ggplot() +
  aes(x = as.factor(Año), y = value) +
  scale_y_continuous(breaks=seq(0,100,10)) + 
  scale_fill_discrete(labels = c("Microempresa","Pequeña", "Mediana y grande"),
                      guide_legend(title = "Tamaño empresa")) + 
  aes(fill=variable) + 
  ylab("Tasa de informalidad") + 
  xlab("Año") + 
  labs(title="Tasa de Informalidad por tamaño de empresa",caption = "Fuente: Enaho") + 
  geom_bar(width = 0.9,stat="identity",position = position_dodge())


### PEA informal por tamaño de empresa  ----
data_grafico0 |>
  filter(variable %in% c("Pob_inf_1","Pob_inf_11", "Pob_inf_50")) |>
  ggplot() +
  aes(x = as.factor(Año), y = value/1000) +
  scale_y_continuous(breaks=seq(0,14000,1000)) + 
  scale_fill_discrete(labels = c("Microempresa","Pequeña", "Mediana y grande"),
                      guide_legend(title = "Tamaño empresa")) + 
  aes(fill=variable) + 
  ylab("PEA informal") + 
  xlab("Año") + 
  labs(title="PEA informal por tamaño de empresa (en miles)",caption = "Fuente: Enaho") + 
  geom_bar(width = 0.9,stat="identity")


### Ingresos mensuales formales e informales  ----
data_grafico0 |>
  filter(variable %in% c('Ing_prom_men_f','Ing_prom_men_i')) |>
  ggplot() +
  geom_line(aes(x = as.factor(Año), y = value, group=variable, color=variable)) +
  labs(title = "Ingresos promedio mensuales (soles)",
       caption = "Fuente: Enaho", 
       x = 'Año', 
       y = 'Ingresos promedio mensuales') +
  scale_color_discrete(labels = c("Formales", "Informales"),
                       guide_legend(title = "Ingresos promedio"))


## Gráficos de mapas ----
# Localizamos el set path donde guardamos los archivos que nos permiten graficar el 
# mapa de Perú por departamentos (shapefile)

dirmapas <- "~/Desktop/QLAB/Intro a R Studio/Trabajo Final - G3/Departamentos" 
setwd(dirmapas)
peru_mapa <- st_read("DEPARTAMENTOS.shp")

# Sabemos que los datos en la base Inf_reg no estan estructurados para poder utilizar 
# el paquete "ggplot", por lo que acomodamos su estructura con la función "melt" del
# paquete "reshape":

data_mapa <- melt(Inf_reg, id.var = c('Año'),
                    variable.name = 'NOMBDEP')

# Ahora cambiamos el nombre a la variable value equivalente a la tasa de informalidad
colnames(data_mapa)[3] <- "Informalidad"

# Asimismo, para poder agregar las etiquetas de datos en el mapa generamos primero
# una nueva variable llamada centroid que permite crear el punto central en cada
# departamento dentro del mapa y de esta manera colocar los nombres de manera correcta
# (siguiendo a https://rstudio-pubs-static.s3.amazonaws.com/619184_9b3a19cf00d543a183674bb332bed5b0.html):
peru_mapa <- peru_mapa |> 
  mutate(centroid = map(geometry, st_centroid), coords = map(centroid, st_coordinates), 
         coords_x = map_dbl(coords, 1), coords_y = map_dbl(coords,2))


# Finalmente juntamos ambas bases de datos a través de la variable "NOMBDEP"
# la cual contiene el nombre de cada uno de los departamentos
data_mapa2 <- peru_mapa |> 
  left_join(data_mapa, by= "NOMBDEP")


# Para poder realizar el mapa final con la tasa de informalidad a nivel de 
# departamentos necesitamos primero seleccionar a todos los departamentos con 
# excepción de Lima Metropolitana y Lima provincias, dado que se encuentran ya
# dentro del departamento de Lima, así como el año para el cual graficaremos:

### a) Mapa prepandemia ----
data_mapa2 |> 
  filter(NOMBDEP != "LIMA_METROPOLITANA" & NOMBDEP != "LIMA_PROVINCIAS") |>
  filter(Año == "2019") |>
  ggplot() +
  geom_sf(aes(fill = Informalidad), color = "white") +
  theme_bw() +
  labs(title = "Tasa de informalidad por departamento (2019)",
       caption = "Fuente: Enaho (2019)",
       x="",
       y="") +
  scale_fill_continuous(guide_legend(title = "Informalidad")) +
  geom_text_repel(mapping = aes(coords_x, coords_y, label = NOMBDEP), size = 2.25) +
  coord_sf(datum = NA)


### b) Mapa durante pandemia ----
data_mapa2 |> 
  filter(NOMBDEP != "LIMA_METROPOLITANA" & NOMBDEP != "LIMA_PROVINCIAS") |>
  filter(Año == "2021") |>
  ggplot() +
  geom_sf(aes(fill = Informalidad), color = "white") +
  theme_bw() +
  labs(title = "Tasa de informalidad por departamento (2021)",
       caption = "Fuente: Enaho (2021)",
       x="",
       y="") +
  scale_fill_continuous(guide_legend(title = "Informalidad")) +
  geom_text_repel(mapping = aes(coords_x, coords_y, label = NOMBDEP), size = 2.25) +
  coord_sf(datum = NA)

