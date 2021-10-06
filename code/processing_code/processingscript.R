###############################
# Processing Script Processing Script #1 - Dengue Forecasting Project
#
#this script loads the raw data from the Dengue Forecasting Project.
#processes and cleans it and saves it as Rds file in the processed_data folder

#load needed packages. make sure they are installed.

library(readr) #for loading Excel files & txt files
library(readxl)
library(here) #to set paths
library(dplyr) #for data processing
library(lubridate) #to arrange date form of data
library(weathermetrics) # Conversion
library(reshape2) # Reshaping data structure

#path to data
#note the use of the here() package and not absolute paths

#From Dengue Forecasting Project
data_spot1 <- here::here("data","raw_data","Iquitos_Weather.xlsx") # Climate data from Iquitos, Peru: station PE000084377; Lat = -3.783; Long = -73.3; Elevation = 126; Start = 1973; End = 2015
data_spot2 <- here::here("data","raw_data","Iquitos_Dengue.csv") # Dengue data
data_spot3 <- here::here("data","raw_data","Iquitos_Population_Data.csv") # Population data by year

#load data 
station <- read_excel(data_spot1)
dengue <- read.csv(data_spot2)
population <- read.csv(data_spot3)

#Dengue data   --------------------------------------------------------------------------------
#Lets lake a look at all the variables and start merging sets together
#take a look at the data one by one, starting with the dengue incidence data because it will dictate how we treat the rest of the data
summary(dengue)
str(dengue)
View(dengue)
tail(dengue)
# Dates range from 2001-2009
# Reports are weekly
# Adding cumulative column for season
dengue = dengue %>% group_by(season) %>% mutate(csum = cumsum(total_cases))
# Renaming columns
colnames(dengue) <- c('Season', 'WeekNum', 'Week', 'Denv1', 'Denv2', 'Denv3', 'Denv4', 'Other', 'Total', 'SeasonCumCases')



# Weather data  --------------------------------------------------------------------------------
summary(station)
str(station)
head(station)
tail(station)
# Couple things we need to fix
# Looks like the first 2 columns are the column titles, but when R read the CSV, it counted the units columns as observations. 
# To fix this, in excel I deleted the 2rd column which contains the units of measurement. I noted them below for future reference
# -minimum_air_temperature(K)	 -maximum_air_temperature(K)	-precipitation_amount(kg m-2)	-TDTR(K)	-TAVG(K)
# First I will create a new column combining the month day and year so we can easily separate by week
station$date<-as.Date(with(station,paste(Year,Month,Day,sep="-")),"%Y-%m-%d")
# Now I am going to use lubridate package to separate by week
# Since I want to merge with the dengue data, I need to match their week definition
options(lubridate.week.start = 6) # Their weeks start on Saturdays
station$week <- floor_date(station$date, "week")
# Note, I am not converting to season_week that dengue data has because they calculated it oddly 
# Next using dpylr we will find mean values by week
stationwk <- station %>% group_by(week) %>% summarize(min_air_temp = mean(minimum_air_temperature), 
    max_air_temp = mean(maximum_air_temperature),
    precip = mean(precipitation_amount),
    tavg = mean(TAVG))
# Note- TDTR stands for Total Daily Temperature range. This variable is not needed since we will be converting to Celsius, thus we will leave it out
# Ok now lets convert Kelvin into Celsius
stationwk$min_air_temp <- kelvin.to.celsius(stationwk$min_air_temp)
stationwk$max_air_temp <- kelvin.to.celsius(stationwk$max_air_temp)
stationwk$tavg <- kelvin.to.celsius(stationwk$tavg)
# All variable need to be turned into weekly averages 2001-2009 instead of the given range of 1979-2015
stationwk<-stationwk %>%filter(week >= as.Date("2000-07-015") & week <= as.Date("2009-06-25"))
str(stationwk)
# Renaming columns
colnames(stationwk) <- c('Week', 'MinAT', 'MaxAT', 'Precip', 'TAvg')

# Population  --------------------------------------------------------------------------------
summary(population)
str(population)
# This one has population number by year in integer form. Pretty straight forward here, no addition cleaning needed



# Save   --------------------------------------------------------------------------------
# location to save file
save_data_location1 <- here::here("data","processed_data","p.dengue.rds")
save_data_location2 <- here::here("data","processed_data","p.stationwk.rds")
save_data_location3 <- here::here("data","processed_data","p.population.rds")

saveRDS(dengue, file = save_data_location1)
saveRDS(stationwk, file = save_data_location2)
saveRDS(population, file = save_data_location3)


