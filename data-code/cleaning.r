## Preliminaries -----------------------------------------------------------
if (!require("pacman")) install.packages("pacman")
pacman::p_load(tidyverse, ggplot2, dplyr, lubridate, stringr, readxl, data.table, gdata, readr)

## Set working directory
setwd("C:/Users/xucar/Desktop/mortality")

## Read in mortality data for 2017-2020 ------------------------------------
# Loop for output files containing selected columns only & rewrite to output folder
records = paste0("record_", 1:20)
years = 1999:2020

columns = c("sex", "age", "monthdth", "year", "race", "ucod", 
  "hispanic", "educ1989", "educ2003", "educ", "marstat", records)

for (y in 1999:2020) {
    mort.path = paste0("data/input/mort", y, ".csv")
    mort.data = read_csv(mort.path, 
    col_select = any_of(columns), col_types = cols(.default = col_character()),
    show_col_types = FALSE)
    write_csv(mort.data, paste0("data/output/mort", y, ".csv.gz"))}

#################################################################################
# educ2003 and educ1989 are coded differently
final_cols = c("sex", "age", "monthdth", "year", "race", "ucod", 
  "hispanic", "educ", "marstat", records)

for (y in years) {
  in_path  <- sprintf("data/input/mort%d.csv", y)
  out_path <- sprintf("data/output/mort%d.csv.gz", y)

  raw = read_csv(
    in_path,
    col_select = any_of(c(
      "sex","age","monthdth","year","race","ucod","hispanic","marstat",
      "educ2003","educ1989","educ","educr",
      records
    )),
    col_types = cols(.default = col_character()),
    show_col_types = FALSE,
    progress = FALSE
  )
  for (v in c("educ2003","educ1989","educ","educr")) {
    if (!v %in% names(raw)) raw[[v]] <- NA_character_
  }
cleaned <- raw %>%
    mutate(
      year_int  = suppressWarnings(as.integer(year)),
      educ_any  = coalesce(educ2003, educ, educ1989, educr)
    )
cleaned <- cleaned %>%
    mutate(
      # pad old 1989 codes to 2 chars when year < 2003
      educ_pad = if_else(year_int < 2003, str_pad(educ_any, 2, pad = "0"), educ_any),

      educ = case_when(
        # ---- 2003 revision (1–9) ----
        year_int >= 2003 & educ_any %in% c("1","2") ~ "<HS",
        year_int >= 2003 & educ_any == "3"          ~ "HS/GED",
        year_int >= 2003 & educ_any %in% c("4","5") ~ "Some college/Associate",
        year_int >= 2003 & educ_any == "6"          ~ "Bachelor",
        year_int >= 2003 & educ_any %in% c("7","8") ~ "Graduate",
        year_int >= 2003 & educ_any == "9"          ~ "Unknown",

        # ---- 1989 revision (00–17, 99) ----
        year_int <  2003 & educ_pad %in% c("00","01","02","03","04","05","06",
                                           "07","08","09","10","11") ~ "<HS",
        year_int <  2003 & educ_pad == "12" ~ "HS/GED",
        year_int <  2003 & educ_pad %in% c("13","14","15") ~ "Some college/Associate",
        year_int <  2003 & educ_pad == "16" ~ "Bachelor",
        year_int <  2003 & educ_pad == "17" ~ "Graduate",
        year_int <  2003 & educ_pad == "99" ~ "Unknown",

        TRUE ~ "Unknown"
      )
    )
cleaned <- cleaned %>%
    select(
      sex, age, monthdth, year, race, ucod,
      hispanic, educ, marstat,
      all_of(records)
    )
 miss <- setdiff(final_cols, names(cleaned))
  if (length(miss)) cleaned[miss] <- NA_character_
  cleaned <- cleaned[final_cols]
write_csv(cleaned, out_path)
  message(sprintf("Wrote %s | %d rows, %d cols", out_path, nrow(cleaned), ncol(cleaned)))
}





######################

