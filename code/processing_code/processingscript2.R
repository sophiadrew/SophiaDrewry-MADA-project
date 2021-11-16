###############################
# Processing Script Processing Script #2 - NOAA Data
#
#this script loads the raw data from NOAA.
#processes and cleans it and saves it as Rds file in the processed_data folder

#load needed packages. make sure they are installed.

library(readr) #for loading Excel files & txt files
library(readxl)
library(here) #to set paths
library(dplyr) #for data processing
library(lubridate) #to arrange date form of data
library(weathermetrics) # Conversion
library(reshape2) # Reshaping data structure
library(zoo)

#path to data
#note the use of the here() package and not absolute paths


# From NOAA
data_spot4 <- here::here("data","raw_data","noa.soi.txt") # SOI values
data_spot5 <- here::here("data","raw_data","noaa.sst.txt") # SST values
data_spot6 <- here::here("data","raw_data","elninoyrs.txt") # El nino/ la nina years
data_spot7 <- here::here("data","processed_data","p.DFP.rds") #For future merging

#load data 
#NOAA data is stored as txt files

soi <- read.delim(data_spot4, sep = "" , header = T)
# This data set is a bit funky and includes anomalies and well as standardized SOI values. 
# According to [this](https://www.cpc.ncep.noaa.gov/data/indices/Readme.index.shtml#SOICALC) Calculation FAQ by NOAA, I only need the standardized SOI values
sst <- read.delim(data_spot5, sep = "" , header = T)
ninoyr <- read.delim(data_spot6, sep = "" , header = F)
DFP <- read_rds(data_spot7)



# SOI  --------------------------------------------------------------------------------
dplyr::glimpse(soi)
# Ok we need to make this in long data form so we will be able to merge with other data sets
tail(soi)
soi<- soi[-c(70:80), ] # First lets get rid of the last 10 rows because they contain data from the future and are in different formats
# Renaming columns
colnames(soi) <- c('Year','1', '2','3','4','5','6','7','8','9','10','11','12')
# Now we convert to long format
soi<-melt(soi, id.vars = c("Year"))
# Check data type
str(soi)
soi$variable<-as.integer(soi$variable)
soi$Year<-as.numeric(soi$Year)
soi$value<-as.numeric(soi$value)
# Change names
colnames(soi) <- c('Year', 'Month', 'SOI')
#Put in order by year then month
soi<- dcast(soi, Year + Month~...)
colnames(soi) <- c('Year', 'Month', 'SOI')

#SST   --------------------------------------------------------------------------------
dplyr::glimpse(sst)
# Ok this is our long data golden format
sst = sst[c("YR", "MON", "NINO4","NINO3.4")]
colnames(sst) <- c("Year", "Month", "NINO4","NINO3.4")
# Check data type
str(soi)


# ENSO Classification   --------------------------------------------------------------------------------
dplyr::glimpse(ninoyr)
# Same problem as before. We need to transform the data
# Renaming columns
colnames(ninoyr) <- c('Year', '1', '2','3','4','5','6','7','8','9','10','11','12')
# Now we convert to long format
ninoyr<-melt(ninoyr, id.vars = c("Year"))
colnames(ninoyr) <- c('Year', 'Month', 'ENSO')
# Check data type
str(ninoyr)
ninoyr$Month = as.numeric(ninoyr$Month)
#Put in order by year then month
ninoyr<- dcast(ninoyr, Year + Month~...)
colnames(ninoyr) <- c('Year', 'Month', 'ENSO')
# For this dataset, +1 = El Nino month, -1 = La Nina month. -9 = N/A


# Merging
try1 <- merge(soi,sst,by=c("Year","Month")) # Success! Now for another!
NOAAdta <- merge(try1,ninoyr,by=c("Year","Month"))
str(NOAAdta)
NOAAdta$SOI <- as.numeric(NOAAdta$SOI)
NOAAdta$Month <- as.numeric(NOAAdta$Month)
# Adding a date column for graphing
NOAAdta$Date <- as.yearmon(paste(NOAAdta$Year, NOAAdta$Month), "%Y %m")
#Put in order by year then month
NOAAdta<-NOAAdta[order(NOAAdta$Date), ]

# Data summary
# NOAAdta (SOI, SST & ENSO) data are all monthly
# Dengue incidence data is weekly
# Weather data is weekly as well
# Population is yearly

# Merging all  --------------------------------------------------------------------------------
finaldata<-left_join(DFP, NOAAdta, by = c("Year","Month"))

# Creating Weekly Incidence Rate variable so we can compare across years
finaldata <- finaldata %>% mutate(
  IR = Total * 100000/Estimated_population)

# Save   --------------------------------------------------------------------------------
# location to save file
save_data_location1 <- here::here("data","processed_data","Finaldata.rds")
save_data_location2 <- here::here("data","processed_data","p.NOAAdta.rds")
saveRDS(finaldata, file = save_data_location1)
saveRDS(NOAAdta, file = save_data_location2)



