## notes :o
- NBER files refer to the same code book, unclear what was changed from original NVSS data??
- 2021 link does not work 
- Entity axis is raw data on death certificates; record axis is cleaned by NVSS. Kept all "record_1...20" columns

## Columns (CDC/NCHS codebook)
### Demographics:
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

### ICD-10-CM Codes (Overdose)
https://www.cdc.gov/nchs/dhcs/drug-use/icd10-codes.htm

- All Opioids: 
    - F11.120-F11.129, F11.220-F11.229, F11.920-F11.929, T40.0X1A-T40.0X4S, T40.1X1A-T40.1X4S, T40.2X1A-T40.2X4S, T40.3X1A-T40.3X4S, T40.411A-T40.414S, T40.421A-T40.424S, T40.491A-T40.494S, T40.601A-T40.604S, T40.691A-T40.694S
- Benzodiazepines:
    - F13.120-F13.129, F13.220-F13.229, F13.920-F13.929, T42.4X1A-T42.4X4S
- Cannabis: 
    - F12, P04.81, T40.711A-T40.726S
- Fentanyl: 
    - T40.411A-T40.414S
- Heroin: 
    - T40.1X1A-T40.1X4S
- Stimulants: 
    - F14.120-F14.129, F14.220-F14.229, F14.920-F14.929, F15.120-F15.129, F15.220-F15.229, F15.920-F15.929, T40.5X1A-T40.5X4S, T43.601A-T43.604S, T43.611A-T43.614S, T43.621A-T43.624S, T43.631A-T43.634S, T43.641A-T43.644S, T43.651A-T43.654S, T43.691A-T43.694S






