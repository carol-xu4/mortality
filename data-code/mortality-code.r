## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, readr)

## Set working directory
setwd("C:/Users/xucar/OneDrive/Desktop/mortality")

    # ignore this!!! just seeing what columns are in NBER data (2017 vs. 1999)
         m2017 = read.csv("data/input/mort2017.csv")
         print(colnames(m2017)) 

        m1999 = read.csv("data/input/mort1999.csv")
        print(colnames(m1999))

        m1999 = read.csv("data/output/mort1999.csv.gz")
        print(colnames(m1999))

        m2007 = read.csv("data/output/mort2007.csv.gz")
        print(colnames(m2007))


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

# final data [count = 56,911,051  ] 
mort.path2 = paste0("data/output/mort", 1999:2020, ".csv.gz")
mort = vroom::vroom(mort.path2,
    col_types = vroom::cols(.default = "c"),
    progress = TRUE
    )
dim(mort)

## Descriptive stats  -----------------------------------------------------
# underlying cause of death freq table
ucod_counts = mort %>%
    count(ucod, sort = TRUE)
View(ucod_counts)









#########################################