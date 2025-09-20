## ANALYSIS

## Preliminaries --------------------------------------------------------------------------
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

# filtering underlying cause of death = overdose -------------------------------------------
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

# by substance type & year (INCLUDING DUPLICATES / POLY SUBSTANCE) --------------------------
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

            # sanity checks for icd_counts ??? ignore this
            dim(icd_counts) # 27815 x 3 ("year", "icd_code", "n")

            icd_counts %>% summarize(n_distinct(year)) # 22!
            sort(unique(icd_counts$year))

            icd_counts %>% summarize(n_distinct(icd_code)) # 3405

# top 20 icd codes in each year
icd1999 = icd_counts %>% filter(year==1999) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd1999, format = "markdown"), "results/top_icd-10_tables/1999.md")

icd2000 = icd_counts %>% filter(year==2000) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2000, format = "markdown"), "results/top_icd-10_tables/2000.md")

icd2001 = icd_counts %>% filter(year==2001) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2001, format = "markdown"), "results/top_icd-10_tables/2001.md")

icd2002 = icd_counts %>% filter(year==2002) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2002, format = "markdown"), "results/top_icd-10_tables/2002.md")

icd2003 = icd_counts %>% filter(year==2003) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2003, format = "markdown"), "results/top_icd-10_tables/2003.md")

icd2004 = icd_counts %>% filter(year==2004) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2004, format = "markdown"), "results/top_icd-10_tables/2004.md")

icd2005 = icd_counts %>% filter(year==2005) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2005, format = "markdown"), "results/top_icd-10_tables/2005.md")

icd2006 = icd_counts %>% filter(year==2006) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2006, format = "markdown"), "results/top_icd-10_tables/2006.md")

icd2007 = icd_counts %>% filter(year==2007) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2007, format = "markdown"), "results/top_icd-10_tables/2007.md")

icd2008 = icd_counts %>% filter(year==2008) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2008, format = "markdown"), "results/top_icd-10_tables/2008.md")

icd2009 = icd_counts %>% filter(year==2009) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2009, format = "markdown"), "results/top_icd-10_tables/2009.md")

icd2010 = icd_counts %>% filter(year==2010) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2010, format = "markdown"), "results/top_icd-10_tables/2010.md")

icd2011 = icd_counts %>% filter(year==2011) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2011, format = "markdown"), "results/top_icd-10_tables/2011.md")

icd2012 = icd_counts %>% filter(year==2012) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2012, format = "markdown"), "results/top_icd-10_tables/2012.md")

icd2013 = icd_counts %>% filter(year==2013) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2013, format = "markdown"), "results/top_icd-10_tables/2013.md")

icd2014 = icd_counts %>% filter(year==2014) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2014, format = "markdown"), "results/top_icd-10_tables/2014.md")

icd2015 = icd_counts %>% filter(year==2015) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2015, format = "markdown"), "results/top_icd-10_tables/2015.md")

icd2016 = icd_counts %>% filter(year==2016) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2016, format = "markdown"), "results/top_icd-10_tables/2016.md")

icd2017 = icd_counts %>% filter(year==2017) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2017, format = "markdown"), "results/top_icd-10_tables/2017.md")

icd2018 = icd_counts %>% filter(year==2018) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2018, format = "markdown"), "results/top_icd-10_tables/2018.md")

icd2019 = icd_counts %>% filter(year==2019) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2019, format = "markdown"), "results/top_icd-10_tables/2019.md")

icd2020 = icd_counts %>% filter(year==2020) %>% arrange(desc(n)) %>% head(20)
    write_lines(knitr::kable(icd2020, format = "markdown"), "results/top_icd-10_tables/2020.md")

# top 10 icd 10 codes over time
top_icd = icd_counts %>%
    group_by(icd_code) %>%
    summarize(total = sum(n), .groups = "drop") %>%
    arrange(desc(total)) %>%
    head(10) %>% pull(icd_code) 
top_icd

