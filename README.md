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
    ##   xi Life_Expectancy LE_LowerCI LE_UpperCI
    ## 1  0        79.16675   79.13992   79.19358
    ## 2  1        78.50159   78.47626   78.52691
    ## 3  5        74.55509   74.53000   74.58018
    ## 4 10        69.58574   69.56078   69.61070
    ## 5 15        64.62036   64.59555   64.64516
    ## 6 20        59.71711   59.69266   59.74156
    
## Calculate healthy life expectancy

`healthy_life_exp()` takes the output from `life_exp()` as an input.

```
# Calculate healthy life expectancy
HLE_output <- healthy_life_exp(output)

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
    ##   xi      HLE HLE_LowerCI HLE_UpperCI
    ## 1  0 63.10993    63.09939    63.12048
    ## 2  1 62.43428    62.42384    62.44472
    ## 3  5 58.71228    58.70241    58.72215
    ## 4 10 54.03314    54.02484    54.04145
    ## 5 15 49.33953    49.33264    49.34643
    ## 6 20 44.71891    44.71283    44.72500
