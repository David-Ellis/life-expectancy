# Calculating Life Expectancy 

mortality_rate <- function(data) {
  # central mortality rate (m_x)
  # m_x = total calendar year deaths/mid-year population
  data["mort rate"] = data["Di"]/data["Pi"]
  # Convert any places where rate>1 into 1
  data["mort rate"][data["mort rate"] > 1] = 1
  return(data)
}

int_surv_frac <- function(data) {
  # Fraction of the interval survived by those who died.
  
  # Most people who die, on average, do so in middle of the interval
  data["surv_frac"] <- 0.5
  # Babies who die, on average, do at ~10% of the interval
  data["surv_frac"][data["xi"]==0] <- 0.1
  return(data)
}

int_width <- function(data){
  # interval width 
  ni <- diff(data["xi"][[1]])
  
  # final "open ended" group is dependent on mortality rate
  n_end <- 1/tail(data["surv_frac"], n=1)/tail(data["mort rate"], n=1)
  
  # combine and make new column 
  data["int_width"] <- c(ni, unlist(n_end))
  
  return(data)
}

death_prop <- function(data) {
  # qi = niMi/(1 + ni(1 – ai)Mi)
  numerator <- data["int_width"] * data["mort rate"]
  denominator <- (1 + data["int_width"]*(1 - data["surv_frac"])*data["mort rate"])
  data["death_prob"] = numerator/denominator
  return(data)
}

alive_at_start <- function(data, l0 = 100000){
  # Calculate number alive at start of interval
  alive <- c(l0)
  l_i <- l0
  for (i in 1:(nrow(data)-1)){
    
    # l_{i-1}
    l_im1 <- l_i
    l_i <- l_im1 * (1-data["death_prob"][[1]][i])
    alive <- c(alive, l_i)
  }
  
  data["alive"] <- alive
  return(data)
}

died_in_int <- function(data) {
  # Calculate number who died in each interval
  
  # Everything except last row
  died_except_last <- diff(-data["alive"][[1]])
  # last row
  died_n <- tail(data["alive"], n=1)
  # store data
  data["died"] <- c(died_except_last, unlist(died_n))
  return(data)
}


lived_in_int <- function(data) {
  # Number of people who lived in each interval
  
  # Li = n_i(l_{i+1}+ a_i*d_i)
  # Each survivor to the end of the age interval contributes n_i 
  # years and each casualty contributes an average of a_i*n_i years.
  alive_plus_one <- c(unlist(tail(data["alive"], nrow(data)-1)),0)
  a_times_d <- data["died"]*data["surv_frac"]
  data["lived_in_int"] <- data["int_width"]*(alive_plus_one + a_times_d) 
  
  # update last row
  alive_last <- data["alive"][[1]][nrow(data)]
  mort_rate_last <- data["mort rate"][[1]][nrow(data)]
  data["lived_in_int"][[1]][nrow(data)] <- alive_last/mort_rate_last
  
  return(data)
}

years_beyond_int <- function(data) {
  Tx <- c()
  Lx <- data["lived_in_int"]
  for (i in 1:nrow(data)){
    Tx_i <- sum(tail(Lx, n = nrow(data)+1-i))
    Tx <- c(Tx, Tx_i)
  }
  
  data["lived beyond"] = Tx
  return(data)
}

final_life_expectancy <- function(data){
  # Calculate final life expectancy for each age
  data["Life Expectancy"] = data["lived beyond"]/data["alive"]
  return(data)
}

life_exp <- function(data, l0 = 100000) {
  # calculate mortality rate
  data <- mortality_rate(data)
  # "calculate" average interval survival fraction 
  data <- int_surv_frac(data)
  # calculate interval width
  data <- int_width(data)
  # calculate interval death probability
  data <- death_prop(data)
  # Calculate number alive at start of interval
  data <- alive_at_start(data, l0=l0)
  # Calculate number who died
  data <- died_in_int(data)
  # Calculate number of people who lived in each interval
  data <- lived_in_int(data)
  # Person-Years Lived Beyond Start of Interval
  data <- years_beyond_int(data)
  # calculate life expectancy for each interval
  data <- final_life_expectancy(data)
  
  return(data)
}

library(readxl)
# Load in the data
input <- read_excel("data/example_data.xlsx", sheet = 2)
# Calculate basic life expectancy
output <- life_exp(input)


