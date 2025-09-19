## ANALYSIS

## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, knitr, ggthemes, lubridate, stringr, data.table, gdata, readr, arrow)

## Set working directory
setwd("C:/Users/xucar/OneDrive/Desktop/mortality")

# pulling output files using arrow
records = paste0("record_", 1:20)
columns = c("sex", "age", "monthdth", "year", "race", "ucod", records)

strings = schema(!!!setNames(rep(list(utf8()), length(columns)), columns))

data = arrow::open_dataset("data/output", format = "csv",
    schema = strings, 
    convert_options = csv_convert_options(null_values = c("", "NA"),
    strings_can_be_null = TRUE))

# filtering underlying cause of death = overdose
overdose =  c("X40", "X41", "X42", "X43", "X44",
    "X60", "X61", "X62", "X63", "X64",
    "X85", 
    "Y10", "Y11", "Y12", "Y13", "Y14")

od_counts = data %>%
    filter(ucod %in% overdose) %>%
    group_by(year) %>%
    summarize(n = dplyr::n(), .groups = "drop") %>%
    collect() %>% 
    mutate(year = as.integer(year),
    n = as.numeric(n)) %>%
    arrange(year)

od_counts_table = knitr::kable(od_counts, format = "markdown") |> as.character()
write_lines(od_counts_table, "results/od_counts")

ggplot(od_counts, aes(x = year, y = n/1000)) +
    geom_line(size = 2, color = "royalblue2") + 
    labs (title = "Total U.S. Overdose Deaths by Year",
    x = "Year", y = "Number of Deaths (in thousands)") +
    scale_y_continuous(
        limits = c(0, 100),
        breaks = seq(0,100, 25)) +
    theme_stata() + 
    theme(
        plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        axis.text = element_text(size = 12),
        axis.text.y = element_text(angle = 0),
        plot.background = element_rect(fill = "white")
    )
ggsave("results/overdose_deaths_by_year.png",
    width = 12, height = 8)

# by substance type & year
icd_counts = data %>%
    filter(ucod %in% overdose) %>%
    select(year, all_of(records)) %>%
    collect() %>%
    mutate(
        year = as.integer(year),
        across(all_of(records), \(x) {
            x = as.character(x)
            x = trimws(x) # remove white space?
            na_if(x, "") # replace empty strings with "NA"
            })  
    ) %>%
    pivot_longer(cols = all_of(records),
        names_to = "record",
        values_to = "icd_code", 
        values_drop_na = TRUE) %>%
    group_by(year, icd_code) %>%
    summarize(n = n(), .groups = "drop") %>%
    arrange(year, desc(n))




 




