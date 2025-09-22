## ANALYSIS

## Preliminarie --------------------------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, knitr, ggthemes, stringr, data.table, gdata, readr, tidyr, arrow, scales, purrr) 

## Set working directory
setwd("C:/Users/xucar/Desktop/mortality")

# pulling output files using arrow
records = paste0("record_", 1:20)
columns = c("sex", "age", "monthdth", "year", "race", "ucod", records)

strings = schema(!!!setNames(rep(list(utf8()), length(columns)), columns))

data = arrow::open_dataset("data/output", format = "csv", skip = 1,
    schema = strings, 
    convert_options = csv_convert_options(null_values = c("", "NA"),
    strings_can_be_null = TRUE))

# standardizing values for demographic columns --------------------------------------------------------
# filter overdose deaths only
overdose =  c("X40", "X41", "X42", "X43", "X44",
    "X60", "X61", "X62", "X63", "X64",
    "X85", 
    "Y10", "Y11", "Y12", "Y13", "Y14")
    
# sex was coded as 1/2, prior to 2003 when it was changed to M/F
sexes = c(
    "1" = "Male", 
    "2" = "Female", 
    "M" = "Male", 
    "F" = "Female")

races = c(
    "1" = "White",
    "2" = "Black",
    "3" = "American Indian",
    "4" = "Chinese",
    "5" = "Japanese", 
    "6" = "Hawaiian",
    "7" = "Filipino",
    "18" = "Asian Indian",
    "28" = "Korean",
    "38" = "Samoan",
    "48" = "Vietnamese",
    "58" = "Guamanian",
    "68" = "Other AAPI",
    "78" = "Other AAPI")

data = data %>%
    filter(ucod %in% overdose) %>%
    select(ucod, year, sex, age, monthdth, race, all_of(records)) %>%
    collect() %>%
    mutate(sex = dplyr::recode(sex, !!!sexes), race = dplyr::recode(race, !!!races)) 


# Population ------------------------------------------------------------------------------------------

    # NVSS age is coded as first digit = unit (1=years, 2=months, 4=days, 5=hours, 6=minutes, 9=unknown)
    # last 3 digits = value
data = data %>%
  mutate(
    age = as.numeric(age),
    age_unit  = floor(age / 1000),   # first digit
    age_value = age %% 1000,         # last 3 digits
    age_years = case_when(
      age_unit == 1 ~ age_value,          # already in years
      age_unit == 2 ~ floor(age_value / 12),   # months → years
      age_unit == 4 ~ floor(age_value / 365),  # days → years
      age_unit == 5 ~ 0L,                     # hours → 0 years
      age_unit == 6 ~ 0L,                     # minutes → 0 years
      TRUE ~ NA_integer_                      # missing
    )
  ) %>%
  filter(!is.na(age_years), age_years <= 120)

data <- data %>% mutate(age_years = ifelse(substr(age, 1, 1) == "1", as.numeric(substr(age, 2, 4)), NA))

ggplot(data %>%
    filter(!is.na(age_years), age_years <= 120),
    aes(x = age_years)) +
    geom_histogram(binwidth = 5, fill = "royalblue2", color = "black") +
    labs(title = "Overdose Deaths Age Distribution",
         x = "Age", y = "Count (in thousands)") +
    scale_x_continuous(breaks = seq(0, 120, by = 20)) +
    scale_y_continuous(  limits = c(0, 120000),   # force top at 120k
    breaks = seq(0, 120000, by = 20000),   # ticks at 0,20k,…,120k
    labels = label_number(scale = 1e-3)) +
  theme_stata() +
  theme(
    plot.title = element_text(size = 35, face = "bold"),
    axis.title  = element_text(size = 25, face = "bold"),
    axis.text   = element_text(size = 20),
    axis.text.y = element_text(angle = 0),
    plot.background = element_rect(fill = "white"))
ggsave("results/age.png",
    width = 12, height = 8)


sex_counts = data %>%
    count(sex) %>%
    mutate(prop = n / sum(n),
    label = paste0(sex, "\n", n, "(", round(prop*100, 1), "%)"))

ggplot(sex_counts, aes(x = "", y = n, fill = factor(sex))) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar(theta = "y") +
    geom_text(aes(label = label),
        position = position_stack(vjust = 0.5),
        color = "white", size = 8, fontface = "bold") +
    scale_fill_manual(values = c("Male" = "royalblue2", "Female" = "violetred2")) +
    labs(title = "Overdose Deaths Sex Distribution", x = NULL, y = NULL) +
    theme_stata() +
    theme(
        plot.title = element_text(size = 35, face = "bold"),
        axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.line = element_blank(),
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "white"),
        legend.position = "none") +
    scale_y_continuous(expand = c(0,0), labels = NULL, breaks = NULL)
ggsave("results/sex.png",
    width = 12, height = 8)

# Overdose Counts 
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

icdplot = icd_counts %>%
    filter(icd_code %in% top_icd)

ggplot(icdplot, aes(x = year, y = n/1000, color = icd_code)) +
    geom_line(size = 2) +
    geom_point(size = 2) +
    labs(title = "10 Most Frequent ICD-10 Codes (1999-2020)",
    x = "Year",
    y = "Number of Occurrances (in thousands)",
    color = "ICD-10 Code") +
    scale_y_continuous(
        limits = c(0, 60),
        breaks = seq(0, 60, 10)) +
   theme_stata() + 
    theme(
        plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        axis.text = element_text(size = 12),
        axis.text.y = element_text(angle = 0),
        plot.background = element_rect(fill = "white"),
        legend.position = "right") +
    guides(color = guide_legend(direction = "vertical"))
ggsave("results/topicd.png", width = 12, height = 8)


# clean multiple cause columns and add row number (id column)
# each row is now one occurrance of an ICD-10 code on a death certificate!!!
data_stacked = data %>%
    filter(ucod %in% overdose) %>%
    select(year, sex, age, monthdth, race, all_of(records)) %>%
    collect() %>%
    mutate(id = row_number(),
    year = as.integer(year)) %>%
    pivot_longer(cols = all_of(records),
        names_to = "record",
        values_to = "icd_code",
        values_drop_na = TRUE) %>%
    mutate(icd_code = trimws(icd_code)) %>%
    filter(icd_code != "")


## Opioids --------------------------------------------------------------------------------------
opioids = list(
    opium = "T400",
    heroin = "T401",
    other = "T402",      # morphine and codeine
    methadone = "T403",
    fentanyl = "T404")

opioid_data = data %>%
    mutate(across(starts_with("record_"), ~str_sub(., 1, 4))) %>%
    mutate(
    op_opium       = if_any(starts_with("record_"), ~ . %in% opioids$opium),
    op_heroin      = if_any(starts_with("record_"), ~ . %in% opioids$heroin),
    op_other       = if_any(starts_with("record_"), ~ . %in% opioids$other),
    op_methadone   = if_any(starts_with("record_"), ~ . %in% opioids$methadone),
    op_fentanyl   = if_any(starts_with("record_"), ~ . %in% opioids$fentanyl),
    )

opioids_year = opioid_data %>%
    group_by(year) %>%
    summarize(
        opium = sum(op_opium, na.rm = TRUE),
        heroin = sum(op_heroin, na.rm = TRUE),
        other = sum(op_other, na.rm = TRUE),
        methadone = sum(op_methadone, na.rm = TRUE),
        fentanyl = sum(op_fentanyl, na.rm = TRUE)) %>%
    tidyr::pivot_longer(-year, names_to = "opioid_type", values_to = "deaths")

opioids_year = opioids_year %>%
  mutate(
    year   = as.integer(trimws(year)),
    deaths = as.numeric(deaths),
    opioid_type = as.factor(opioid_type)) %>%
  filter(!is.na(year), !is.na(deaths)) %>%
  arrange(opioid_type, year)

ggplot(opioids_year, aes(x = year, y = deaths, color = opioid_type, group = opioid_type)) +
    geom_line(size = 2) +
    labs(title = "Opioid-Related Overdose Deaths, 1999-2020",
    x = "Year", y = "Number of Deaths (in thousands)", color = "Opioid Type") + 
    scale_y_continuous(labels = label_number(scale = 1e-3),
        limits = c(0, 60e3), 
        breaks = seq(0, 60e3, 10e3)) +
    scale_x_continuous(breaks = seq(1999, 2020, by = 2)) +
    theme_stata() +
    theme(plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        axis.text = element_text(size = 12),
        axis.text.y = element_text(angle = 0),
        plot.background = element_rect(fill = "white"),
    legend.position = "right")

ggsave("results/opioids.png", width = 12, height = 8)

# Stimulants ------------------------------------------------------------------------------------------
stimulants = list(
    cocaine = "T405",
    methamphetamine = "T436")

stimulant_data = data %>%
    mutate(across(starts_with("record_"), ~str_sub(., 1, 4))) %>%
    mutate(
    stim_cocaine       = if_any(starts_with("record_"), ~ . %in% stimulants$cocaine),
    stim_meth      = if_any(starts_with("record_"), ~ . %in% stimulants$methamphetamine))

stimulants_year = stimulant_data %>%
    group_by(year) %>%
    summarize(
        cocaine = sum(stim_cocaine, na.rm = TRUE),
        methamphetamine = sum(stim_meth, na.rm = TRUE)) %>%
    tidyr::pivot_longer(-year, names_to = "stimulant_type", values_to = "deaths")

stimulants_year = stimulants_year %>%
  mutate(
    year   = as.integer(trimws(year)),
    deaths = as.numeric(deaths),
    stimulant_type = as.factor(stimulant_type)) %>%
  filter(!is.na(year), !is.na(deaths)) %>%
  arrange(stimulant_type, year)

ggplot(stimulants_year, aes(x = year, y = deaths, color = stimulant_type, group = stimulant_type)) +
    geom_line(size = 2) +
    labs(title = "Stimulant-Related Overdose Deaths, 1999-2020",
    x = "Year", y = "Number of Deaths (in thousands)", color = "Stimulant Type") + 
    scale_y_continuous(labels = label_number(scale = 1e-3),
        limits = c(0, 30e3), 
        breaks = seq(0, 30e3, 10e3)) +
    scale_x_continuous(breaks = seq(1999, 2020, by = 2)) +
    theme_stata() +
    theme(plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        axis.text = element_text(size = 12),
        axis.text.y = element_text(angle = 0),
        plot.background = element_rect(fill = "white"),
    legend.position = "right")

ggsave("results/stimulants.png", width = 12, height = 8)

# Depressants -------------------------------------------------------------------------------------------
depressants = list(
    barbiturates   = "T423",
    benzodiazepines = "T424")

depressant_data = data %>%
    mutate(across(starts_with("record_"), ~str_sub(., 1, 4))) %>%
    mutate(
        dep_barb  = if_any(starts_with("record_"), ~ . %in% depressants$barbiturates),
        dep_benzo = if_any(starts_with("record_"), ~ . %in% depressants$benzodiazepines))

depressants_year = depressant_data %>%
    group_by(year) %>%
    summarize(
        barbiturates   = sum(dep_barb,  na.rm = TRUE),
        benzodiazepines = sum(dep_benzo, na.rm = TRUE)) %>%
    tidyr::pivot_longer(-year, names_to = "depressant_type", values_to = "deaths")

depressants_year = depressants_year %>%
  mutate(
    year   = as.integer(trimws(year)),
    deaths = as.numeric(deaths),
    depressant_type = as.factor(depressant_type)) %>%
  filter(!is.na(year), !is.na(deaths)) %>%
  arrange(depressant_type, year)

ggplot(depressants_year, aes(x = year, y = deaths, color = depressant_type, group = depressant_type)) +
    geom_line(size = 2) +
    labs(title = "Depressant-Related Overdose Deaths, 1999-2020",
         x = "Year", y = "Number of Deaths (in thousands)", color = "Depressant Type") + 
    scale_y_continuous(labels = scales::label_number(scale = 1e-3),
        limits = c(0, 15e3), 
        breaks = seq(0, 15e3, 5e3)) +
    scale_x_continuous(breaks = seq(1999, 2020, by = 2)) +
    theme_stata() +
    theme(
        plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 14, face = "bold"),
        axis.text = element_text(size = 12),
        axis.text.y = element_text(angle = 0),
        plot.background = element_rect(fill = "white"),
        legend.position = "right")

ggsave("results/depressants.png", width = 12, height = 8)

# Cannabis
cannabis_code = "T407" 

cannabis_data = data %>%
  mutate(across(starts_with("record_"), ~str_sub(., 1, 4))) %>%
  mutate(can = if_any(starts_with("record_"), ~ . %in% cannabis_code))

cannabis_year = cannabis_data %>%
  group_by(year) %>%
  summarize(cannabis = sum(can, na.rm = TRUE)) %>%
  tidyr::pivot_longer(-year, names_to = "substance", values_to = "deaths")

cannabis_year = cannabis_year %>%
  mutate(
    year   = as.integer(trimws(year)),
    deaths = as.numeric(deaths),
    substsance = as.factor(substance)
  ) %>%
  filter(!is.na(year), !is.na(deaths)) %>%
  arrange(substance, year)

ggplot(cannabis_year, aes(x = year, y = deaths, color = substance, group = substance)) +
  geom_line(size = 2) +
  labs(title = "Cannabis-Related Overdose Deaths, 1999-2020",
       x = "Year", y = "Number of Deaths", color = "Substance") + 
  scale_y_continuous(
    labels = scales::comma,
    limits = c(0, 1200),                   
    breaks = seq(0, 1200, by = 200)
  ) +
  scale_x_continuous(breaks = seq(1999, 2020, by = 2)) +
  theme_stata() +
  theme(
    plot.title = element_text(size = 20, face = "bold"),
    axis.title = element_text(size = 14, face = "bold"),
    axis.text  = element_text(size = 12),
    axis.text.y = element_text(angle = 0),
    plot.background = element_rect(fill = "white"),
    legend.position = "none")

ggsave("results/cannabis.png", width = 12, height = 8)

# POLYSUBSTANCE ANALYSIS
poly_data = data %>%
    mutate(
    opioid_any = if_any(starts_with("record_"), ~ . %in% c("T400","T401","T402","T403","T404")),
    stimulant_any = if_any(starts_with("record_"), ~ . %in% c("T405","T436")),
    depressant_any = if_any(starts_with("record_"), ~ . %in% c("T423","T424")),
    cannabis = if_any(starts_with("record_"), ~ . %in% c("T407")))

poly_data = poly_data %>%
    mutate(substance_type = opioid_any + stimulant_any + depressant_any + cannabis)

    # substance_type= 0 -> no listed drug, substance_type = 1 -> single substance death, subtance_type = 2 -> two substsances death

poly_summary = poly_data %>%
    group_by(year, substance_type) %>%
    summarize(deaths = n(), .groups = "drop")

combos = 
