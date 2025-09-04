## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata)

## Set working directory
setwd("C:/Users/xucar/OneDrive/Desktop/mortality")

    # just seeing what variables are in cleaned NBER data (2017)
        mort2017 = read.csv("data/input/mort2017.csv")
        print(colnames(mort2017)) 

## Read in mortality data for 2017-2020 ------------------------------------
# useful variables:
columns = c("educ2003", "sex", "age", "monthdth", "year", "race", "ucod", 
    paste0("record_", 1:20))

# loop for useful variables only
for (y in 2017:2020) {
    mort.path = paste0("data/input/mort", y, ".csv")
    mort.data = read_csv(mort.path, 
    col_select = any_of(columns), col_types = cols(.default = col_character()),
    show_col_types = FALSE)
    
    write_rds(mort.data, paste0("data/output/mort", y, ".rds"))
    }
    
# 




# 
