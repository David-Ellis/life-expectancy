# Calculating Life Expectancy 
library(readxl)

# Load in the data
data <- read_excel("data/example_data.xlsx", sheet = 2)

#central mortality rate (m_x)
# m_x = total calendar year deaths/mid-year population

data["mx"] = data["Di"]/data["Pi"]
# Convert any places where rate>1 into 1
data["mx"][data["mx"] > 1] = 1

# Most people who die, on average, do so in middle of the interval
data["ai"] <- 0.5
# Babies who die, on average, do at ~10% of the interval
data["ai"][data["xi"]==0] <- 0.1

# interval width 
ni <- diff(data["xi"][[1]])
n_end <- 1/tail(data["ai"], n=1)/tail(data["mx"], n=1)
data["ni"] <- c(ni, unlist(n_end))

# qi = niMi/(1 + ni(1 – ai)Mi)
data["qx"] = data["ni"] * data["mx"]/(1 + data["ni"]*(1 - data["ai"])*data["mx"])

# Step 1: The life table starts with 100,000 simultaneous births (l0).

l0 = 100000

# Step 2: The life table population is then calculated by multiplying 
# 100,000 (l0) by the mortality rate between age 0 and 1 years (q0) to 
# give the number of deaths at age 0 years (d0).

dx = c()
lx = c(l0)
Lx = c()

for (i in 1:nrow(data)){
  qx_i <- data["qx"][[1]][i]
  nx_i <- data["ni"][[1]][i]
  ax_i <- data["ai"][[1]][i]
  lx_i <- tail(lx, n=1)
  
  lxp1 = lx_i * (1-qx_i)
  
  dx_i <- lx_i - lxp1
  
  
  dx <- c(dx, dx_i)
  lx <- c(lx, lxp1)
  
  # Li = ni(l_{i +1}+ aidi)
  Lx_i <- nx_i * (lxp1 + ax_i*dx_i)
  Lx <- c(Lx, Lx_i)
}

lx <- head(lx, length(lx)-1)
data["lx"] <- lx

Tx <- c()
for (i in 1:length(Lx)){
  Tx_i <- sum(tail(Lx, n = length(Lx)+1-i))
  Tx <- c(Tx, Tx_i)
}

data["Tx"] = Tx

# Calculate final life expectancy for each age
data["Ex"] = data["Tx"]/data["lx"]
