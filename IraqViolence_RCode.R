#Attribution and Purpose of Code====
# Code by Keelin Haynes (hayneskd@miamioh.edu, Political Science Major, Miami University, Oxford, OH USA, GEO 460: Open Source Geospatial
# 
# Code created December 2017 using free version of RStudio v 3.4.1 Single Candle on PC
#
# Purpose of Code: Create copy of Excel spreadsheet that only includes desired information, 
# Query out events in spreadsheet to select specified events ('Assaults Against Civilians'), 
# Create a buffer around roads in Iraq to select specific events ('Assaults Against 
# Civilians'), and visualize incidents in map of country
#
#
#




#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PREPARATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%----



#Required Data====

#This section covers the required data. For in-depth explanation of how to acquire and prepare data, look to accompanying manual
#
#Required Data:
#IRQ_roads.shp
#IRQ_adm.shp
#ACLED Acts of Violence CSV
#
#ACLED data is found at the following link. 
#LINK: https://www.acleddata.com
#Additionally, for those curious about ACLED and thier work, follow this link.
#LINK: https://www.acleddata.com/wp-content/uploads/2017/01/ACLED_User-Guide-for-Humanitarians_2017.pdf
#Egyptian admin and roads data is found at the following link.
#LINK: http://www.diva-gis.org/gdata





#Installing packages and libraries====

#The following code requires the following packages and libraries to be downloaded to your computer

#Install packages for code
#
install.packages("sp")
install.packages("rgdal")
install.packages("geosphere")
install.packages("rgeos")
install.packages("sf")
install.packages("dplyr")
#install.packages("cluster")
#install.packages("tidyverse")
#install.packages("factoextra")
#install.packages("raster")
#install.packages("readxl")
#install.packages("osmar")
#
#Download libraries for code
#
library(sp)
library(rgdal)
library(readxl)
library(gstat)
library(rgeos)
library(geosphere)
library(sf)
library(dplyr)
#library(tidyverse)  # data manipulation
#library(cluster)    # clustering algorithms
#library(factoextra) # clustering algorithms & visualization
#library(raster)

#library(stats)
#library(mailR)
#
#




#setting Working Directory====
#In order for this code to work, the proper working directory must be set
# Working directory in this code is ("C:/Users/hayneskd/Documents/GEO460FinalProject")
#Be sure to set your own working directory
### SET PARAMS ###
setwd("C:\\Users\\Mine\\Documents\\Iraq_RCode") # Set your working directory
localDir <- getwd() # This  is where all of our data will be stored
#coords <- CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0") 
coords <- "+init=epsg:32636" # CRS to be used by all projected data from now on
# CRS is UTM 36N  or epsg 32636 for Iraq
#
# 





#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SETTING UP AOI AND ROADS NETWORK #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%----





#LOADING STATE BOUNDARIES TO CREATE AREA OF INTEREST (AOI)====

#This line unzips the data contained within your working directory
unzip("IRQ_adm.zip", exdir = localDir)
#These next few lines sets a variable for the dataset, reads it into R as a shapefile and plots it using selected parameters
layerName <- "IRQ_adm0"
bounds <- readOGR(dsn = localDir, layer = layerName)
bounds <- spTransform(bounds, CRS = coords)
bounds <- readOGR(dsn = localDir, layer = layerName)
plot(bounds, col = "navajowhite1", bg = "powderblue")


#LOADING ROADS SHAPEFILE TO CREATE THE TRANSPORTATION NETWORK UNDER INSPECTION====

#This line unzips the data contained within your working directory
unzip("IRQ_rds.zip", exdir = localDir)
#These next few lines sets a variable for the dataset, reads it into R as a shapefile and plots it using selected parameters
layerName <-"IRQ_roads"
roads <- readOGR(dsn = localDir, layer = layerName)
plot(roads, add = TRUE, col = "red4")





#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% READING, FILTERING, CONVERTING, AND DISPLAYING VIOLENCE DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%----




#Reading Data====

#This code reads in the csv file
datafile <- read.csv("1900-01-01-2018-04-17-Iraq.csv")





#Filter Data====

#The data set is very large, containing 10s of thousands of records
#It must be filtered down
#To do this, I relied upon the techniques contained on this page:
#LINK: https://stat.ethz.ch/pipermail/r-help/2010-April/234905.html
#For more information on subsetting, look here
#LINK: https://www.r-bloggers.com/5-ways-to-subset-a-data-frame-in-r/
#It contains both columns and rows that can be dicarded

#First we will discard the excessive columns
#To do this, select the columns that you want to keep
#These five lines of code set variables for the number of the columns that we want to work with
col5 = 5;
col8 = 8;
col17 = 17;
col22 = 22;
col23 = 23;
col28 = 28;
#This line creates a data frame that contains just the five selected columns 
viol = datafile[,c(col5, col8, col17, col22, col23, col28)];
#This line shows the dimensions of the dataframe
#This line is not necessary to the code, it is just a helpful step to ensure everything is correct
dim(viol)
#This line shows the names of the columns of the dataframe
#This line is not necessary to the code, it is just a helpful step to ensure everything is correct
names(viol)

#These lines are unneccesary, as their function ahs been accomplished by above code, but they have been left in for historocal sake
#Now we will further filter our data, this time by discarding unneeded rows
#We only need rows that that value "Egypt" in the column "Country"
#This line creates a subset of our data
#It selects out the rows that have the value "Iraq" in the column "Country"
##viol2 <- subset(viol, COUNTRY == "Iraq")
#This line shows the dimensions of the dataframe
#This line is not necessary to the code, it is just a helpful step to ensure everything is correct
##dim(viol2)
#This line shows the names of the columns of the dataframe
#This line is not necessary to the code, it is just a helpful step to ensure everything is correct
##names(viol2)
#This line prints the dataframe just so we can see it
#This line is not necessary to the code, it is just a helpful step to ensure everything is correct
##viol2





#Convert the data to a visual format (shapefile)====

#This line creates a dataframe ("violsf") that contains the st_as_sf function
#More info on it can be found here: http://www.datacarpentry.org/R-spatial-raster-vector-lesson/10-vector-csv-to-shapefile-in-r/
#For this function, we have to list the dataframe that contains our filtered data
#We also have to set the coords by selecting the relevant columns in the dataframe
violsf <- st_as_sf(viol, coords = c("longitude", "latitude"))





#Display the data====

#The next few lines plot the data
#For more information on plotting, look herre:
#http://stat.ethz.ch/R-manual/R-devel/library/graphics/html/plot.html
#http://stat.ethz.ch/R-manual/R-devel/library/graphics/html/title.html
#http://www.endmemo.com/program/R/pchsymbols.php
#https://www.statmethods.net/advgraphs/parameters.html
#https://www.stat.berkeley.edu/classes/s133/saving.html


plot(violsf$geometry, add = TRUE, pch = 20)
title("Violence Against Civilians in Iraq from Jan 1, 2018- Mar 3, 2018", col="red", col.main="red", font.main=3, cex.main = 2)
title(sub="The Relationship Between Transportation Networks and Violence", col.sub="blue", cex.sub = 1.5)



#AVERAGE NUMBER OF FATALITIES PER INCIDENT====
mean(viol$fatalities)



#PLOT FATALITIES SUMMARY====
days <- group_by(viol, event_date)
fatals <- summarise(days, mean(fatalities, na.rm = TRUE))
summarise(viol, avgfatalities = mean(fatalities, na.rm = TRUE))
plot(fatals)



#PLOT FATALITIES SUMMARY ACCOUTNING FOR OUTLIERS====

days <- group_by(viol2, EVENT_DATE)
fatals <- summarise(days, mean(FATALITIES, na.rm = TRUE))
summarise(viol2, avgfatalities = mean(FATALITIES, na.rm = TRUE))
plot(fatals, ylim=c(0, 20))

