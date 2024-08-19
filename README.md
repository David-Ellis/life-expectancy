## Required data

Function `life_exp()` takes data with 3 variables:
- xi: Age at start of interval 
- Pi: Population in age interval 
- Di: Number of deaths in interval
```
library(readxl)
library(dplyr)
    
# Load in the data
input <- read_excel("../data/example_data.xlsx", sheet = 2)
    
print(head(input, 5))
```
    ## # A tibble: 5 × 3
    ##      xi     Pi    Di
    ##   <dbl>  <dbl> <dbl>
    ## 1     0  46886   307
    ## 2     1 197911    39
    ## 3     5 249134    25
    ## 4    10 237067    24
    ## 5    15 238610    48

## Calculate life expectancy

```
source("../life-expectancy.R")

# Calculate basic life expectancy
output <- life_exp(input)

# print output
print(
  head(output %>% 
         select(c(xi, Life_Expectancy,LE_LowerCI, LE_LowerCI)), 5)
         )
```
    ##   xi Life_Expectancy Life_Expectancy_lower Life_Expectancy_upper
    ## 1  0        79.42223              79.26539              79.57906
    ## 2  1        78.94195              78.79526              79.08864
    ## 3  5        75.00262              74.85706              75.14819
    ## 4 10        70.03901              69.89407              70.18395
    ## 5 15        65.07321              64.92884              65.21757
    
## Calculate healthy life expectancy

`healthy_life_exp()` takes the output from `life_exp()` as an input.

```
# Calculate healthy life expectancy
HLE_output <- healthy_life_exp(output)

# print output
# print output
print(
  head(output %>% 
         select(
         c(xi, 
         HLE,
         HLE_LowerCI, 
         HLE_LowerCI)), 5)
         )
```
