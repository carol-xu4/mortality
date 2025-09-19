## ANALYSIS

## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, knitr, lubridate, stringr, readxl, data.table, gdata, readr, arrow)

## Set working directory
setwd("C:/Users/xucar/OneDrive/Desktop/mortality")

# filtering underlying cause of death = overdose
data = arrow::open_dataset("data/output", format = "csv")

overdose =  c("X40", "X41", "X42", "X43", "X44",
    "X60", "X61", "X62", "X63", "X64",
    "X85", 
    "Y10", "Y11", "Y12", "Y13", "Y14")

od_counts = data %>%
    filter(ucod %in% overdose) %>%
    group_by(year) %>%
    summarise(n = dplyr::n(), .groups = "drop") 

od_counts_results = knitr::kable(od_counts, format = "markdown")
write_lines(od_counts_results, "results/od_counts")
