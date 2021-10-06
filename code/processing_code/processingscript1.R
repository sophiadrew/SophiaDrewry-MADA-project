###############################
# processing script
#
#this script loads the raw data, processes and cleans it 
#and saves it as Rds file in the processed_data folder

#load needed packages. make sure they are installed.

library(readr) #for loading Excel files & txt files
library(readxl)
library(dplyr) #for data processing
library(here) #to set paths
library(read.xlsx)
library(lubridate) #to arrange date form of data
install.packages("weathermetrics")
library(weathermetrics) # Conversion
library(reshape2) # Reshaping data structure
library(zoo)
library(ggthemes)
library(RColorBrewer)
library(ggplot2)

#path to data
here("/Users/sophiadrewry/Documents/School/Fall 2021/MADA/SophiaDrewry-MADA-project/")
here::here("Users", "sophiadrewry", "Documents", "School", "Fall 2021", "MADA", "SophiaDrewry-MADA-project")
#note the use of the here() package and not absolute paths

#From Dengue Forecasting Project
data_spot <- here::here("data","raw_data","Iquitos_Weather.xlsx") # Climate data from Iquitos, Peru: station PE000084377; Lat = -3.783; Long = -73.3; Elevation = 126; Start = 1973; End = 2015
data_spot1 <- here::here("data","raw_data","Iquitos_Dengue.csv") # Dengue data
data_spot2 <- here::here("data","raw_data","Iquitos_Population_Data.csv") # Population data by year

# From NOAA
data_spot3 <- here::here("data","raw_data","noa.soi.txt") # SOI values
data_spot4 <- here::here("data","raw_data","noaa.sst.txt") # SST values
data_spot5 <- here::here("data","raw_data","elninoyrs.txt") # El nino/ la nina years


#load data 
station <- read_excel(data_spot)
dengue <- read.csv(data_spot1)
population <- read.csv(data_spot2)

#NOAA data is stored as txt files
  
soi <- read.delim(data_spot3, sep = "" , header = T)
# This data set is a bit funky and includes anomalies and well as standardized SOI values. 
# According to [this](https://www.cpc.ncep.noaa.gov/data/indices/Readme.index.shtml#SOICALC) Calculation FAQ by NOAA, I only need the standardized SOI values
sst <- read.delim(data_spot4, sep = "" , header = T)
ninoyr <- read.delim(data_spot5, sep = "" , header = F)

#Phew that is a lot of data. Lets lake a look at all the variables and start merging sets together
#take a look at the data one by one, starting with the dengue incidence data because it will dictate how we treat the rest of the data
summary(dengue)
str(dengue)
View(dengue)
tail(dengue)
# Dates range from 2001-2009
# Looks like we are going to have to put the dates in a more readable format
# Reports are weekly

# Weather data
summary(station)
str(station)
head(station)
tail(station)
# Couple things we need to fix
# Looks like the first 2 columns are the column titles, but when R read the CSV, it counted the units columns as observations. 
# To fix this, In excel I deleted the 2rd column which contains the units of measurement. I noted them below for future reference
# -minimum_air_temperature(K)	 -maximum_air_temperature(K)	-precipitation_amount(kg m-2)	-TDTR(K)	-TAVG(K)
# All variable need to be turned into weekly averages 2001-2009 instead of the given range of 1979-2015
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

# Population
summary(population)
str(population)

# This one has population number by year in integer form. Pretty straight forward here, no addition cleaning needed

#Now to check out the NOAA data, they are small so we can take a glimpse at each

# SOI
dplyr::glimpse(soi)
# Ok we need to make this in long data form so we will be able to merge with other data sets
tail(soi)
soi<- soi[-c(70:80), ] # First lets get rid of the last 10 rows  
# Renaming columns
colnames(soi) <- c('Year', '1', '2','3','4','5','6','7','8','9','10','11','12')
# Now we convert to long format
soi<-melt(soi, id.vars = c("Year"))
colnames(soi) <- c('Year', 'Month', 'SOI')
soi$Month = as.numeric(soi$Month)
soi<- dcast(soi, Year + Month~...)
colnames(soi) <- c('Year', 'Month', 'SOI')



#SST
dplyr::glimpse(sst)
# Ok this is our long data golden format
sst = sst[c("YR", "MON", "NINO4","NINO3.4")]
colnames(sst) <- c("Year", "Month", "NINO4","NINO3.4")

# ENSO Classification
dplyr::glimpse(ninoyr)
# Same problem as before. We need to transform the data
# Renaming columns
colnames(ninoyr) <- c('Year', '1', '2','3','4','5','6','7','8','9','10','11','12')
# Now we convert to long format
ninoyr<-melt(ninoyr, id.vars = c("Year"))
colnames(ninoyr) <- c('Year', 'Month', 'ENSO')
ninoyr$Month = as.numeric(ninoyr$Month)
ninoyr<- dcast(ninoyr, Year + Month~...)
colnames(ninoyr) <- c('Year', 'Month', 'ENSO')
# For this dataset, +1 = El Nino month, -1 = La Nina month. -9 = N/A
# I may make 2 different columns, one categorical column or keep as is but..
# I am not sure how I will need to analyze this, so it will be left "as is" for now





# Phew.. lets take a break before we start merging sets. 
# If only you knew how many google tabs I have open that are along the lines of "how do you do xyz in r"






# Merging

#Ok I am going to start with the NOAA data, because it is the smallest

try1 <- merge(soi,sst,by=c("Year","Month")) # Success! Now for another!
NOAAdta <- merge(try1,ninoyr,by=c("Year","Month"))
str(NOAAdta)
NOAAdta$SOI <- as.numeric(NOAAdta$SOI)
NOAAdta$Month <- as.numeric(NOAAdta$Month)
NOAAdta$Date <- as.yearmon(paste(NOAAdta$Year, NOAAdta$Month), "%Y %m")
#Still loading as "1 10 11 12 2 3 4 5 6 7", working on getting it resolved


# NOAAdta SOI, SST & ENSO data are all monthly
# Dengue incidence data is weekly
# Weather data is weekly as well
# Population is yearly

# Keeping these data sets as-is unless analysis requires more conversion


# Visualization

# NOAA data first over time
# SST

NP1 = ggplot(NOAAdta, aes(x, y), col = group) + 
  geom_line(data = NOAAdta, aes(x = Date, y = NINO4, color="NINO4")) +
  geom_line(data = NOAAdta, aes(x = Date, y = NINO3.4, color="NINO 3.4")) +
  xlab("Dates") +
  ylab("SST") +
  ggtitle("SST in region 4 & 3.4 over time") +
  theme_wsj() +
  scale_fill_brewer(palette = "Set1") 

print(NP1)

NP2 = ggplot() + 
  geom_line(data = NOAAdta, aes(x = Date, y = SOI), color = "blue") +
  xlab("Dates") +
  ylab("SOI") +
  ggtitle("SOI Values") +
  theme_wsj() +
  scale_fill_brewer(palette = "Set1")
print(NP2)

Ok, we know the two interact, so lets view them on the same graph

NP3 = ggplot(NOAAdta, aes(x = Date), col = group) + 
  geom_line(data = NOAAdta, aes(x = Date, y = NINO4, color="NINO4")) +
  geom_line(data = NOAAdta, aes(x = Date, y = NINO3.4, color="NINO 3.4")) +
  geom_line(data = NOAAdta, aes(x = Date, y = SOI), color = "blue") +
  xlab("Dates") +
  ylab("SST") +
  theme_wsj() +
  scale_fill_brewer(palette = "Set1")
scale_y_continuous(name = "SST", sec.axis = sec_axis(~.*coeff, name="SOI")) +
  ggtitle("SST in region 4 & 3.4 over time")


# location to save file
save_data_location <- here::here("data","processed_data","processeddata.rds")

saveRDS(processeddata, file = save_data_location)


