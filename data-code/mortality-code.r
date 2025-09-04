# Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata)

# Set working directory
setwd("C:/Users/xucar/OneDrive/Desktop/mortality")

# Read in mortality data for 2017-2020 ------------------------------------
for (y in 2017:2020) {
    mort.path = paste0("data/input/mort", y, ".csv")
    mort.data = read.csv(mort.path, skip = 1)
    }

mort2017 = read.csv("data/input/mort2017.csv")
print(colnames(mort2017))

