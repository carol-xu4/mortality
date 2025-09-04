# Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata)

# Read in mortality data for 2020-2023 ------------------------------------
# build file path
for (y in 2020:2023) {
    mort_path = paste0("data/input/VS", substr(y, 3, 4), "MORT.DUSMCPUB_r*.csv")

# finding the file (release dates?)
mort_year = Sys.glob(mort_path)

# actually reading in the data
mort_data = read_csv(mort_year)
} 


# Set working directory
setwd("C:/Users/xucar/OneDrive/Desktop/mortality/data/input")

mort2017 = read_csv("mort2017.csv")
print(colnames(mort2017))
head(mort2017)


