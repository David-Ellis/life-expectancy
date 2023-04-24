source("life-expectancy.R")

library(readxl)
library(dplyr)

# Load in the data
input <- read_excel("data/example_data.xlsx", sheet = 2)
# Calculate basic life expectancy
output <- life_exp(input)
# print output
print(head(output %>% select(c("xi", "Life Expectancy"))))