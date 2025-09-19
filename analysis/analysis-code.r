## ANALYSIS

## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, knitr, ggthemes, lubridate, stringr, readxl, data.table, gdata, readr, arrow)

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
    summarise(n = dplyr::n(), .groups = "drop") %>%
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

# by substance type
