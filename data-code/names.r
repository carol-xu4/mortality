# ignore this!!! just seeing what columns are in NBER data (2017 vs. 1999)

# original (input) files
m2017 = read.csv("data/input/mort2017.csv")
print(colnames(m2017)) 

m1999 = read.csv("data/input/mort1999.csv")
print(colnames(m1999))

m2020 = read.csv("data/input/mort2020.csv")
print(colnames(m2020))

print(head(m2020$enicon_2))
names(m2020)

# rewritten (output) files
m1999 = read.csv("data/output/mort1999.csv.gz")
print(colnames(m1999))

m2007 = read.csv("data/output/mort2007.csv.gz")
print(colnames(m2007))

m2020 = read.csv("data/output/mort2007.csv.gz")
print(colnames(m2020))
