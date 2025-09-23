## notes :o
- NBER files refer to the same code book, unclear what was changed from original NVSS data??
- 2021 link does not work 
- Entity axis is raw data on death certificates; record axis is cleaned by NVSS. Kept all "record_1...20" columns
- Ran into some issues with age and race

## Columns (CDC/NCHS codebook)
### Demographics/Descriptive Stats:
- "sex"
- "age"
- "monthdth" -> month of death
- "year" -> year of death
- "race"

### Variables:
- "ucod" -> Underlying Cause of Death 
    - X40-44: unintentional / accidental poisoning by and exposure to drugs and other biological substances
    - X60-64: suicide / intentional self-poisoning by and exposure to drugs and other biological susbstances
    - X85: assault / homicide by drugs, biological substances and other and unspecified noxious substances 
    - Y10-14: - undetermined intent, poisoning by and exposure to drugs and biological substances
- "record_1...20" -> specific substances?

## Population
- n = 936,279 total overdose deaths (1999-2020)
- <img width="3600" height="2400" alt="image" src="https://github.com/user-attachments/assets/317f0734-3382-4097-b6d6-fc2f009908f3" />

### ICD-10-CM Codes (Overdose)
https://www.cdc.gov/nchs/dhcs/drug-use/icd10-codes.htm

https://icd.who.int/browse10/2019/en#/T40.4

## Substances of Interest (ICD-10 Codes)

| Code  | Substance                                       |
|-------|-------------------------------------------------|
| **Opioids** | |
| T40.0 | Opium                                           |
| T40.1 | Heroin                                          |
| T40.2 | Other opioids (morphine, codeine)               |
| T40.3 | Methadone                                       |
| T40.4 | Synthetic narcotics (pethidine, fentanyl, etc.) |
| **Stimulants** | |
| T40.5 | Cocaine                                         |
| T43.6 | Methamphetamine / other psychostimulants        |
| **Depressants (non-opioid) / Sedatives** | |
| T42.3 | Barbiturates                                    |
| T42.4 | Benzodiazepines                                 |
| **Other** | |
| T40.7 | Cannabis (derivatives)                          |
