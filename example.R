source("life-expectancy.R")

library(readxl)
library(dplyr)
library(ggplot2)


# Load in the data
LE_input <- read_excel("data/example_data.xlsx", sheet = 2)
HLE_input <- read_excel("data/example_data.xlsx", sheet = 3)

# Calculate basic life expectancy
LE <- life_exp(LE_input)
output <- health_life_exp(LE, HLE_input)

print(head(output %>% select(c(xi, Life_Expectancy,
                               Life_Expectancy_lower, Life_Expectancy_upper))))

ggplot(output, aes(xi, Life_Expectancy)) +
  geom_line(aes(color = "Life Expectancy"), size = 1) +
  geom_line(data = output, 
            aes(xi, HLE, color = "Healthy Life Expectancy"), size = 1) +
  xlab("Age at start of interval") +
  ylab("Life Expectancy") +
  theme_bw() + 
  theme(legend.title = element_blank(),
        legend.spacing.y = unit(0, "mm"), 
        panel.border = element_rect(colour = "black", fill=NA),
        #aspect.ratio = 1, 
        #axis.text = element_text(colour = 1, size = 12),
        legend.background = element_blank(),
        legend.box.background = element_rect(colour = "black"),
        legend.position = c(0.8, 0.9))

