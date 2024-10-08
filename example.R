source("life-expectancy.R")

library(readxl)
library(dplyr)
library(ggplot2)


# Load in the data
LE_input <- read_excel("data/example_data.xlsx", sheet = 2)
HLE_input <- read_excel("data/example_data.xlsx", sheet = 3)

# Calculate basic life expectancy
LE <- life_exp(LE_input)

print(head(LE %>% select(c(xi, 
                               Life_Expectancy,
                               LE_LowerCI, 
                               LE_UpperCI))))

# Calculate healthy life expectancy
HLE <- healthy_life_exp(LE, HLE_input)
print(head(HLE %>% select(c(xi, 
                               HLE,
                               HLE_LowerCI,
                               HLE_UpperCI))))

# plot result
ggplot(HLE, aes(xi, Life_Expectancy)) +
  geom_line(aes(color = "Life Expectancy"), linewidth = 1) +
  geom_line(aes(xi, HLE, color = "Healthy Life Expectancy"), size = 1) +
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
        legend.position = "inside",
        legend.position.inside = c(0.8, 0.85))
