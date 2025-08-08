### Function to compute the balance
balance_computation <- function(Rel, ET, Rad, Temp, Rain, DOY,
                                start_flowering = 109,  DayFolAreaMax = 171, 
                                RAW = 32, net_rain_effect = .66, 
                                method_leaf_dev = 1)
{
  
  # Rel is relative humidity (in %)
  # ET is Evapotranspiration
  # Rad is solar radiation in W/m^2
  # Temp is temperature in Celsius degrees
  # Rain is rainfall in mm
  # DOY is the day of the year
  
  # start_flowering is the date (in day of year) of the beggining of the flowering;
  # default value (109) corresponds approximately to 21.04 (in day of the year)
  
  # DayFolAreaMax is the date (in day of year) where the maximum leaf surface is reached;
  # default value (171) corresponds approximately to 20.06 (in day of the year)
  
  # net_rain_effect is the coefficient that impacts the rainfall due to the nets
  # RAW is the Readily Available Water.
  # method_leaf_dev: at the moment, only one method is used 
  
  ## See equation (1) and paragraph below for constants
  ## alpha =1.26 is given in the end of the section 1
  alph = 1.26 #  is the Priestley–Taylor parameter/constant.
  gamm = 0.066 # [kPa/°C] is the psychrometric coefficient
  lam = 2.45#  [MJ/L] is the latent heat  of vaporization; 
  # A [MJ/ (tree * day)]  is the total amount of net  (all-wave) radiation absorbed by the leaf canopy; 
  
  # start_flowering = 
  # DayFolAreaMax = 171 # Day when the max of the leaf surface is reached, in day of the year
  
  
  # the slope of the saturation vapor pressure curve at average daily air temperature
  s = 4098*0.6108*exp( (17.27*Temp)/(Temp+237.3)) / (Temp+237.3)^2
  
  DFlowering = DOY - start_flowering + 1  # day counts starting from flowering
  Q = (-0.000881834215*DFlowering ^2 + 0.150793650794*DFlowering)/6 * 100 # in percent
  Q2 = (-0.001444*DFlowering^2 + 0.17*DFlowering)/5 * 100
  Q2 = ifelse(Q2 > 100, yes = 100, no = Q2 )
  
  if(method_leaf_dev != 1) Q = Q2;
  LAIMaxPercent = case_when(
    DOY < start_flowering ~ DOY * 1.612903 - 175.806452, # linear interpolation through the
    # 2 points (109, 0) and (171, 100); 
    DOY >= start_flowering & DOY < DayFolAreaMax ~ Q,
    DOY >= DayFolAreaMax & DOY < 252 ~ 100,
    DOY >= 252 ~ DOY * -0.7843 + 297.65,
    .default = NULL
  )
  LAIMax <- LAIMaxPercent/100
  # Computation in 5 categories corresponding to LAI categories
  LA = outer(X= LAIMax, Y = 5 *seq(from = 0.5, to =2.5, by= .5)) |> data.frame()
  names(LA) = paste("LA_", 1:5 * 0.5, sep = "")
  # Conversion of units: REFERENCE?
  Rs = Rad/(1000000/86400) # changing units of solar radiation
  # Rn given in Calanca et al. 
  # Transformation of global radiation into useful radiation
  # (valid on the Swiss Plateau)  Rn = Rs *0.617-1.004 
  Rn = Rs *0.617-1.004 
  # See Pereira et al. (2007b)
  A = .303 * LA * Rn ## Rn * LA per tree
  names(A) = paste("A_", 1:5 * 0.5, sep = "")
  # daily sap flow of a tree [l/(TREE * DAY)], using Priestley–Taylor formula
  # Daily sap flow is denoted by Tc in the documentation
  Daily_sap_flow = alph*(s/(s+gamm)*(1/lam)) * A
  names(Daily_sap_flow) = paste("Tc_", 1:5 * 0.5, sep = "")
  Daily_sap_flow_unit = Daily_sap_flow/5
  names(Daily_sap_flow_unit) <- paste("Daily_sap_flow_unit_", 1:5 * 0.5, sep = "")
  
  # # T_Eto is not used in the rest of the algorithm
  # T_Eto = Daily_sap_flow/(5 * ET) 
  # T_Eto[ET == 0,] <- 0 # treat the values where ET is 0 as 0 (to avoid division by 0)
  
  # third order polynomial function
  DOY_05_fun <- function(x)  0.000000010*x^3 - 0.000008397*x^2 + 0.000772552*x + 0.381393786 
  DOY_1_fun  <- function(x)  0.000000030*x^3 - 0.000014633*x^2 + 0.000732618*x + 0.401501383
  DOY_15_fun <- function(x)  0.000000033*x^3 - 0.000014090*x^2 - 0.000000916*x + 0.443715597
  DOY_2_fun  <- function(x)  0.000000017*x^3 - 0.000003173*x^2 - 0.002420317*x + 0.551676009
  DOY_25_fun <- function(x) -0.000000030*x^3 + 0.000025772*x^2 - 0.007554528*x + 0.763455458 

  Evap <- lapply(list(DOY_05_fun,DOY_1_fun, DOY_15_fun,DOY_2_fun, DOY_25_fun), 
                 FUN = function(z)z(DOY) * ET)
  Evap <- do.call(cbind, args = Evap) |> data.frame()
  names(Evap) <- paste("Evap_", 1:5 * 0.5, sep = "")
  Tmat = LAIMax * Daily_sap_flow_unit
  Tmat[LAIMax < 0,] <- 0
  ETc_ETo <- (Tmat + Evap)/ET
  ETc_ETo[ET == 0,] <- 0
  # first, we create the condition to be verified:
  # to be usefull, rainfall must be at least of 5mm over the past 2 days.
  # Then, the useful rainfall by day is the rainfall provided that 
  # this condition (>5mm in the past 2 days) is met.
  RainfallThreshold<- c(Rain[1],
                     Rain[2:length(Rain)] + 
                       Rain[1:(length(Rain) - 1)] # sum of the daily and one day before rainfall
  )
  # Usefull rainfall
  RainfallUseful = ifelse(RainfallThreshold > 5, yes = Rain, no = 0)
  # We initialize the matrix Balance
  Balance = (RainfallUseful * net_rain_effect) - (Tmat + Evap)
  # We initialize the first value of the Balance
  Balance[1,] <- RainfallUseful[1] - ET[1] * (Tmat + Evap)[1,]
  # we define a custom function to truncate values in a given interval
  truncation <- function(x, a = 0 , b = RAW)
  {
    ifelse(x > b, yes = b, no = ifelse(x<a, yes = 0, no = x))
  }
  # we iteratively update the values by adding the preceeding values and then
  # truncate it to the interval [0, RAW]
  for(i in 2:nrow(Balance))
  {
    Balance[i,] = truncation(Balance[i,] + Balance[i-1,])
  }
  names(Balance) <- paste("Balance_res_", 1:5 * 0.5, sep = "")
  # The irrigation is then given by
  Irrigation = Tmat + Evap
  Irrigation[Balance > 0] = 0
  names(Irrigation) <- paste("Irrigation_", 1:5 * 0.5, sep = "")
  # a simple mean of the past n values
  ma <- function(vec, n) sapply(5:length(vec), function(z)
    mean(vec[(z-n):(z-1)]))
  SmoothedIrrigation <- apply(Irrigation, 2, 
                              function(z) c(rep(NA, 4), ma(z, n = 4)))
  # we truncate it to the interval
  SmoothedIrrigation[Balance >3] <- 0
  
  return(list(s = s, LAIMaxPercent = LAIMaxPercent, Rn = Rn, 
              Daily_sap_flow = Daily_sap_flow, Evap = Evap, Tmat = Tmat,
              # ETc_ETo = ETc_ETo, # not computed anymore
              RainfallUseful = RainfallUseful,
              Balance = Balance, Irrigation = Irrigation,
              SmoothedIrrigation = SmoothedIrrigation))
}
