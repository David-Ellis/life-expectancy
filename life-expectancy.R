# Calculating Life Expectancy 
library(dplyr)

mortality_rate <- function(data) {
  # central mortality rate (m_x)
  # m_x = total calendar year deaths/mid-year population
  data["mort_rate"] = data["Di"]/data["Pi"]
  # Convert any places where rate>1 into 1
  data["mort_rate"][data["mort_rate"] > 1] = 1
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
  n_end <- 1/tail(data["surv_frac"], n=1)/tail(data["mort_rate"], n=1)
  
  # combine and make new column 
  data["int_width"] <- c(ni, unlist(n_end))
  
  return(data)
}

death_prop <- function(data) {
  # qi = niMi/(1 + ni(1 – ai)Mi)
  numerator <- data["int_width"] * data["mort_rate"]
  denominator <- (1 + data["int_width"]*(1 - data["surv_frac"])*data["mort_rate"])
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
  mort_rate_last <- data["mort_rate"][[1]][nrow(data)]
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
  
  data["lived_beyond"] = Tx
  return(data)
}

final_life_expectancy <- function(data){
  # Calculate final life expectancy for each age
  data["Life_Expectancy"] = data["lived_beyond"]/data["alive"]
  return(data)
}

sample_variance <- function(data) {
  data <- data %>%
    transform(next_life_exp = c(`Life_Expectancy`[-1], NA)) %>%
    mutate(
      sample_var = case_when(
        Di == 0 ~ 0,
        xi == max(data$xi) ~ `mort_rate`*(1-`mort_rate`)/Pi,
        TRUE ~ death_prob**2*(1-death_prob)/Di),
      weighted_var = case_when(
        xi == max(data$xi) ~ alive^2 / mort_rate^4 * sample_var,
        TRUE ~ alive^2*((1-surv_frac)*int_width + next_life_exp)^2*sample_var),
      lived_beyond_var = rev(cumsum(rev(weighted_var))),
      obs_live_exp_var = lived_beyond_var/alive**2,
      Life_Expectancy_upper = Life_Expectancy + 1.96*sqrt(obs_live_exp_var),
      Life_Expectancy_lower = Life_Expectancy - 1.96*sqrt(obs_live_exp_var),
      ) %>%
    select(-c(next_life_exp))
  
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
  
  data <- sample_variance(data)
  return(data)
}

good_health_perc <- function(data) {
  first_xi <- which(!is.na(data$Spop_w))[1]
  last_xi <- tail(which(!is.na(data$Spop_w)), 1)

  data <- data %>%
    mutate(
      good_health_perc = case_when(
        !is.na(Spop_w) ~ Spop_gh_w/Spop_w,
        xi < data$xi[first_xi] ~ data$Spop_gh_w[first_xi]/data$Spop_w[first_xi]*AF,
        xi > data$xi[last_xi] ~ data$Spop_gh_w[last_xi]/data$Spop_w[last_xi]*AF,
        TRUE ~ NA
      )
    )
  
  return(data)
}

good_health_years <- function(data) {
  data <- data %>%
    mutate(good_heath_in_int = lived_in_int * good_health_perc)
  return(data)
}

final_HLE <- function(data) {
  # Tx_HLE
  data <- data %>%
    mutate(
      healthy_years_beyond = rev(cumsum(rev(good_heath_in_int))),
      HLE = healthy_years_beyond / alive
      )
  return(data)
}

health_life_exp <- function(LE_data, HLE_data) {
  
  data <- LE_data %>%
    left_join(HLE_data)
  
  data <- good_health_perc(data)
  data <- good_health_years(data)
  data <- final_HLE(data)
  
  return(data)
}

# # Load in the data
# LE_input <- read_excel("data/example_data.xlsx", sheet = 2)
# HLE_input <- read_excel("data/example_data.xlsx", sheet = 3)
# 
# # Calculate basic life expectancy
# LE <- life_exp(LE_input)
# output <- health_life_exp(LE, HLE_input)


