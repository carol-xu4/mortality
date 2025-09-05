## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata)

## Set working directory
setwd("C:/Users/xucar/OneDrive/Desktop/mortality")

    # ignore this - just seeing what variables are in cleaned NBER data (2017)
         mort2017 = read.csv("data/input/mort2017.csv")
         print(colnames(mort2017)) 

## Read in mortality data for 2017-2020 ------------------------------------
# useful variables:
columns = c("educ2003", "sex", "age", "monthdth", "year", "race", "ucod", 
    paste0("record_", 1:20))

# loop for .rds containing useful variables only
for (y in 2017:2020) {
    mort.path = paste0("data/input/mort", y, ".csv")
    mort.data = read_csv(mort.path, 
    col_select = any_of(columns), col_types = cols(.default = col_character()),
    show_col_types = FALSE)
    
    write_rds(mort.data, paste0("data/output/mort", y, ".rds"))
    }

# final data [count = 11,918,140] 
mort2017 = read_rds("data/output/mort2017.rds")
mort2018 = read_rds("data/output/mort2018.rds")
mort2019 = read_rds("data/output/mort2019.rds")
mort2020 = read_rds("data/output/mort2020.rds")

mort = bind_rows(mort2017, mort2018, mort2019, mort2020)

## Exploratory Analysis -----------------------------------------------------
# freq table
ucod_counts = mort %>% 
count(ucod, sort = TRUE)
