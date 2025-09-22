## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, readr)

## Set working directory
setwd("C:/Users/xucar/Desktop/mortality")

## Read in mortality data for 2017-2020 ------------------------------------
# useful variables:
columns = c("sex", "age", "monthdth", "year", "race", "ucod", 
    paste0("record_", 1:20))

# Loop for output files containing useful variables only
for (y in 1999:2020) {
    mort.path = paste0("data/input/mort", y, ".csv")
    mort.data = read_csv(mort.path, 
    col_select = any_of(columns), col_types = cols(.default = col_character()),
    show_col_types = FALSE)
    write_csv(mort.data, paste0("data/output/mort", y, ".csv.gz"))
    }

# stacking final data [rows = 56,911,051, columns = 26] 
mort.path2 = paste0("data/output/mort", 1999:2020, ".csv.gz")
mort = vroom::vroom(mort.path2,
    col_types = vroom::cols(.default = "c"),
    progress = TRUE
    )
dim(mort)
names(mort)
#########################################