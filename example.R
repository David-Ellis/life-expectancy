source("life-expectancy.R")

library(readxl)
library(dplyr)
library(ggplot2)

# Load in the data
input <- read_excel("data/example_data.xlsx", sheet = 2)
# Calculate basic life expectancy
output <- life_exp(input)
# print output
print(head(output %>% select(c(xi, Life_Expectancy, 
                               Life_Expectancy_lower, Life_Expectancy_upper))))

ggplot(output, aes(xi, Life_Expectancy)) +
  geom_ribbon(aes(ymin = Life_Expectancy_lower, 
                  ymax = Life_Expectancy_upper,
                  fill = "95% CI")) +
  geom_line() +
  xlab("Age at start of interval") +
  ylab("Life Expectancy") +
  theme_bw()
