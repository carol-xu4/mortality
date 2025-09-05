## ANALYSIS

## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, readr)

# underlying cause of death 
ucod_counts = mort %>%
    count(ucod, sort = TRUE)
View(ucod_counts)
