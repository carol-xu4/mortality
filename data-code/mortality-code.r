## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, readr)

## Set working directory
setwd("C:/Users/xucar/OneDrive/Desktop/mortality")

    # ignore this!!! just seeing what columns are in NBER data (2017 vs. 1999)
         mort2017 = read.csv("data/input/mort2017.csv")
         print(colnames(mort2017)) 

        mort1999 = read.csv("data/input/mort1999.csv")

        print(colnames(mort1999))

## Read in mortality data for 2017-2020 ------------------------------------
# useful variables:
columns = c("educ2003", "sex", "age", "monthdth", "year", "race", "ucod", 
    paste0("record_", 1:20))

# loop for .rds containing useful variables only
for (y in 1999:2020) {
    mort.path = paste0("data/input/mort", y, ".csv")
    mort.data = read_csv(mort.path, 
    col_select = any_of(columns), col_types = cols(.default = col_character()),
    show_col_types = FALSE)
    
    write_rds(mort.data, paste0("data/output/mort", y, ".rds"), compress = "xz")
    }

# Atomic write: write to a temp file, then rename
tmp <- paste0(rds, ".tmp")
write_rds(mort, tmp, compress = "xz")   # you can use "gzip" if xz keeps causing issues
file.rename(tmp, rds)

# final data [count = 11,918,140] 
mort1999 = read_rds("data/output/mort1999.rds")
mort2000 = read_rds("data/output/mort2000.rds")
mort2001 = read_rds("data/output/mort2001.rds")
mort2002 = read_rds("data/output/mort2002.rds")
mort2003 = read_rds("data/output/mort2003.rds")
mort2004 = read_rds("data/output/mort2004.rds")
mort2005 = read_rds("data/output/mort2005.rds")
mort2006 = read_rds("data/output/mort2006.rds")
mort2007 = read_rds("data/output/mort2007.rds")
mort2008 = read_rds("data/output/mort2008.rds")
mort2009 = read_rds("data/output/mort2009.rds")
mort2010 = read_rds("data/output/mort2010.rds")
mort2011 = read_rds("data/output/mort2011.rds")
mort2012 = read_rds("data/output/mort2012.rds")
mort2013 = read_rds("data/output/mort2013.rds")
mort2014 = read_rds("data/output/mort2014.rds")
mort2015 = read_rds("data/output/mort2015.rds")
mort2016 = read_rds("data/output/mort2016.rds")
mort2017 = read_rds("data/output/mort2017.rds")
mort2018 = read_rds("data/output/mort2018.rds")
mort2019 = read_rds("data/output/mort2019.rds")
mort2020 = read_rds("data/output/mort2020.rds")

    #error with mort2010
mort_data = bind_rows(mort2000, mort2001, mort2002, mort2003, mort2004, mort2005, 
    mort2006, mort2007, mort2008, mort2009, mort2011, mort2012, mort2013, 
    mort2014, mort2015, mort2016, mort2017, mort2018, mort2019, mort2020) 

saveRDS(mort_data, "data/output/mort.rds", compress = "xz")

## Descriptive stats  -----------------------------------------------------
# underlying cause of death freq table
ucod_counts = mort_data %>%
    count(ucod, sort = TRUE)
View(ucod_counts)













