###############################
# Exploratory Data Analysis Script - 
#
#this script loads performs an exploratory data analysis on data sets in 
# the processed_data folder.
# All results can be found in the Exploratory Data Analysis folder in the results folder 

#load needed packages. make sure they are installed.
# Visualization

library(readr)
library(dplyr) #for data processing
library(here) #to set paths
library(ggthemes)
library(RColorBrewer)
library(ggplot2)
library(lubridate)
library(table1)

#Load data
data_spot1 <- here::here("data","processed_data","p.dengue.rds") 
data_spot2 <- here::here("data","processed_data","p.stationwk.rds")
data_spot3 <- here::here("data","processed_data","p.population.rds")
data_spot4 <- here::here("data","processed_data","p.NOAAdta.rds")

#load data 
dengue <- read_rds(data_spot1)
stationwk <- read_rds(data_spot2)
population <- read_rds(data_spot3)
NOAAdta <- read_rds(data_spot4)

# NOAA data  --------------------------------------------------------------------------------
# SST Values for region 4 and 3.4
NP1 = ggplot(NOAAdta, aes(x, y), col = group) + 
  geom_line(data = NOAAdta, aes(x = Date, y = NINO4, color="NINO4")) +
  geom_line(data = NOAAdta, aes(x = Date, y = NINO3.4, color="NINO 3.4")) +
  xlab("Dates") +
  ylab("SST") +
  ggtitle("SST in Region 4 & 3.4 from 20") +
  theme_wsj() +
  scale_fill_brewer(palette = "Set1") 
print(NP1)
Figure1 <- here("results", "exploratoryfigures", "EDAfig1.png")
ggsave(filename = Figure1, plot = NP1)


# SOI Values
NP2 = ggplot() + 
  geom_line(data = NOAAdta, aes(x = Date, y = SOI), color = "blue") +
  xlab("Dates") +
  ylab("SOI") +
  ggtitle("SOI Values") +
  theme_wsj() +
  scale_fill_brewer(palette = "Set1")
print(NP2)

Figure2 <- here("results", "exploratoryfigures", "EDAfig2.png")
ggsave(filename = Figure2, plot = NP2)


# Ok, we know the two interact, so lets view them on the same graph
coeff <- 27
NP3 = ggplot(NOAAdta, aes(x = Date), col = group) + 
  geom_line(data = NOAAdta, aes(x = Date, y = NINO4, color="NINO4")) +
  geom_line(data = NOAAdta, aes(x = Date, y = NINO3.4, color="NINO 3.4")) +
  geom_line(data = NOAAdta, aes(x = Date, y = SOI + coeff, color = "SOI")) +
  xlab("Dates") +
  ylab("SST") +
  theme_wsj() +
  scale_fill_brewer(palette = "Set1") +
  scale_y_continuous(sec.axis = sec_axis(~. - coeff), name="SOI") +
  ggtitle("SST in region 4 & 3.4 over time")
print(NP3)
Figure3 <- here("results", "exploratoryfigures", "EDAfig3.png")
ggsave(filename = Figure3, plot = NP3)


# Calendar view of El Nino/ La Nino monthly occurrence by year
NP4 <- ggplot(NOAAdta, aes(x=Month, y=Year)) +
  geom_tile(color = "white",
            lwd = 1.5,
            linetype = 1, aes(fill = ENSO)) +
  labs(title = "El Nino/La Nino Occurance", y = "Year") +
  coord_fixed() +
  scale_fill_gradient2(low = "#075AFF",
                       mid = "#FFFFCC",
                       high = "#FF0000")

print(NP4)
Figure4 <- here("results", "exploratoryfigures", "EDAfig4.png")
ggsave(filename = Figure4, plot = NP4)

    
# Station Data --------------------------------------------------------------------------------

SP1 <- ggplot(stationwk, aes(x, y), col = group) + 
    geom_line(data = stationwk, aes(x = Week, y = MinAT, color = "Min Air Temp")) +
    geom_line(data = stationwk, aes(x = Week, y = MaxAT, color = "Max Air Temp")) +
    geom_line(data = stationwk, aes(x = Week, y = TAvg, color = "Average Temperature")) +
    geom_col(data = stationwk, aes(x = Week, y = Precip, color = "Precipitation")) +
    xlab("Week") +
    ylab("Weather Value") +
    ggtitle("Weather Data by Week") +
    theme_wsj() +
    scale_fill_brewer(palette = "Set1")

print(SP1)
Figure5 <- here("results", "exploratoryfigures", "EDAfig5.png")
ggsave(filename = Figure5, plot = SP1)


            
# Dengue data  --------------------------------------------------------------------------------
str(dengue)
dengue$Week <- as.Date(dengue$Week) 
# Weekly Reported Cases by Serotype
DP1 = ggplot(dengue, aes(x, y), col = group) + 
    geom_col(data = dengue, aes(x = Week, y = Denv1, color = "Denv 1")) +
    geom_col(data = dengue, aes(x = Week, y = Denv2, color = "Denv 2")) +
    geom_col(data = dengue, aes(x = Week, y = Denv3, color = "Denv 3")) +
    geom_col(data = dengue, aes(x = Week, y = Denv4, color = "Denv 4")) +
    geom_col(data = dengue, aes(x = Week, y = Other, color = "Other")) +
    xlab("Week") +
    ylab("# of reported cases") +
    ggtitle("Weekly Reported Cases by Serotype") +
    theme_wsj() +
    scale_fill_brewer(palette = "Set1")
print(DP1)
Figure6 <- here("results", "exploratoryfigures", "EDAfig6.png")
ggsave(filename = Figure6, plot = DP1)

# Now for cumulative incidence by season

DP2 <- dengue %>%
  ggplot(aes(x = WeekNum, y = SeasonCumCases)) +
  geom_point(color = "darkorchid4") +
  facet_wrap( ~ Season, ncol = 3) +
  labs(title = "Cumulative Incidence for Dengue Cases by Season - Iquitos, Peru",
       subtitle = "Data plotted by year",
       y = "# of Reported Cases",
       x = "Week") +
   theme_wsj() 
print(DP2)
Figure7 <- here("results", "exploratoryfigures", "EDAfig7.png")
ggsave(filename = Figure7, plot = DP2)

# I want to get some yearly tables, so lets spit up the date by table
dengue<- dengue %>% dplyr::mutate(year = lubridate::year(Week), 
                        month = lubridate::month(Week), 
                        day = lubridate::day(Week))

-table1::label(dengue$Denv1) <- "Denv1"
table1::label(dengue$Denv2) <- "Denv2"
table1::label(dengue$Denv3) <- "Denv3"
table1::label(dengue$Denv4) <- "Denv4"
table1::label(dengue$Total) <- "Total Cases"
Table1 <- table1::table1(~Denv1 + Denv2 + Denv3 + Denv4 + Total | year, data = dengue)


#save data frame table to file for later use in manuscript
Table1 = here("results","exploratoryfigures", "Table1.RDS")
saveRDS(Table1, file = Table1)

                     
# SST  --------------------------------------------------------------------------------                      
# location to save file
save_data_location <- here::here("data","processed_data","processeddata.rds")
 
                       
                                         
                                             
                    