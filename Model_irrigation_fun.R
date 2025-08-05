### Function to compute the balance
balance_computation <- function(Rel, ET, Rad, Temp, Rain, DOY,
                                start_flowering = 109,  DayFolAreaMax = 171, 
                                net_rain_effect = .66, RAW = 32, 
                                method_leaf_dev = 1)
{
  
  # Rel is relative humidity (in %)
  # ET is Evapotranspiration
  # Rad is solar radiation in W/m^2
  # Temp is temperature in Celsius degrees
  # Rain is rainfall in mm
  # DOY is the day of the year
  # start_flowering is the date (in day of year) of the beggining of the flowering
  # default value (109) corresponds approximately to 21.04 (in day of the year)
  
  # theDayFolAreaMax is the date (in day of year) where the maximum leaf surface is reached
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
  # Q and Q2 are defined in sheet Dynamique_Sfol as a second order polynomial regression
  # REFERENCE for the reference points used in the regression? 
  Q = (-0.000881834215*DFlowering ^2 + 0.150793650794*DFlowering)/6 * 100 # in percent
  Q2 = (-0.001444*DFlowering^2 + 0.17*DFlowering)/5 * 100
  Q2 = ifelse(Q2 > 100, yes = 100, no = Q2 )
  
  if(method_leaf_dev != 1) Q = Q2;
  # REFERENCE and definition of LAIMax? 
  LAIMaxPercent = case_when(
    DOY < start_flowering ~ DOY * 1.612903 - 175.806452, # linear interpolation through the
    # 2 points (109, 0) and (171, 100); 
    DOY >= start_flowering & DOY < DayFolAreaMax ~ Q,
    DOY >= DayFolAreaMax & DOY < 252 ~ 100,
    DOY >= 252 ~ DOY * -0.7843 + 297.65,
    .default = NULL
  )
  LAIMax <- LAIMaxPercent/100
  # Explanation about the 5 columns ranging from 0.5 to 2.5?
  LA = outer(X= LAIMax, Y = 5 *seq(from = 0.5, to =2.5, by= .5)) |> data.frame()
  names(LA) = paste("LA_", 1:5 * 0.5, sep = "")
  # Conversion of units: REFERENCE?
  Rs = Rad/(1000000/86400) # changing units of solar radiation
  # RN according to Calanca (PLEASE, FIND REFERENCE) Transformation of global radiation into useful 
  # radiation (apparently valid on the Swiss Plateau)  Rn = Rs *0.617-1.004 
  Rn = Rs *0.617-1.004 
  # Why 0.303? REFERENCE
  A = .303 * LA * Rn ## Rn * LA per tree
  names(A) = paste("A_", 1:5 * 0.5, sep = "")
  # IS THAT THE PRISTLEY-TALYOR FORMULA? IF YES, CITE ORIGINAL REFERENCE AND PEREIRA ET AL. (2007)
  # daily sap flow of a tree [l/(TREE * DAY)], denoted by T in the paper
  Daily_sap_flow = alph*(s/(s+gamm)*(1/lam)) * A
  names(Daily_sap_flow) = paste("Tc_", 1:5 * 0.5, sep = "")
  # REFERENCE OR DEFINITION. WHY FACTOR 5?
  Irrigation = Daily_sap_flow/5
  names(Irrigation) <- paste("Irrig_", 1:5 * 0.5, sep = "")
  # REFERENCE? Why the factor 5?
  T_Eto = Daily_sap_flow/(5 * ET)
  T_Eto[ET == 0,] <- 0 # treat the values where ET is 0 as 0 (to avoid division by 0)
  
  # REFERENCE/EXPLANATION  FOR THIS 3RD ORDER POLYNOMIAL REGRESSION
  DOY_05_fun <- function(x) 0.000000011*x^3  - 0.000008737*x^2 + 0.000824346*x + 0.379581098 
  DOY_1_fun  <- function(x) 0.000000032*x^3  - 0.000015482*x^2 + 0.000862181*x + 0.396966905
  DOY_15_fun <- function(x) 0.000000033*x^3  - 0.00001409*x^2  - 0.000000916*x + 0.443715597
  DOY_2_fun  <- function(x) 0.000000023*x^3  - 0.000005712*x^2 - 0.002115453*x + 0.541917785
  DOY_25_fun <- function(x) -0.000000023*x^3 + 0.000021998*x^2 - 0.0070441*x   + 0.745096926
  # Define and REFERENCE
  Evap <- lapply(list(DOY_05_fun,DOY_1_fun, DOY_15_fun,DOY_2_fun, DOY_25_fun), 
                 FUN = function(z)z(DOY) * ET)
  Evap <- do.call(cbind, args = Evap) |> data.frame()
  names(Evap) <- paste("Evap_", 1:5 * 0.5, sep = "")
  # Corresponds to columns T in the sheet but using T alone is not possible
  # (it has another meaning in R)
  Tmat = LAIMax * Irrigation
  Tmat[LAIMax < 0,] <- 0
  ETc_ETo <- (Tmat + Evap)/ET
  ETc_ETo[ET == 0,] <- 0
  # first, we create the condition to be verified:
  # to be usefull, rainfall must be at least of 5mm over the past 2 days.
  # Then, the useful rainfall by day is the rainfall provided that 
  # this condition (>5mm in the past 2 days) is met.
  RainfallUseful<- c(Rain[1],
                     Rain[2:length(Rain)] + 
                       Rain[1:(length(Rain) - 1)] # lagged rainfall
  )
  # Usefull rainfall
  RainfallUseful = ifelse(RainfallUseful > 5, yes = Rain, no = 0)
  # We initialize the matrix Balance
  Balance = (RainfallUseful * net_rain_effect) - (Tmat + Evap)
  # We initialize the first value of the Balance
  # REFERENCE/EXPLANATION
  Balance[1,] <- RainfallUseful[1] - ET[1] * (Tmat + Evap)[1,]
  # we define a custom function to truncate values in a given interval
  truncation <- function(x, a = 0 , b = RAW)
  {
    ifelse(x > b, yes = b, no = ifelse(x<a, yes = 0, no = x))
  }
  # we iteratively update the values by adding the preceeding values and then
  # truncate it to the interval [0, RAW = 32]
  for(i in 2:nrow(Balance))
  {
    Balance[i,] = truncation(Balance[i,] + Balance[i-1,])
  }
  names(Balance) <- paste("Balance_res_", 1:5 * 0.5, sep = "")
  Irrigation = Tmat + Evap
  Irrigation[Balance > 0] = 0
  names(Irrigation) <- paste("Irrigation_", 1:5 * 0.5, sep = "")
  RainfallUseful * net_rain_effect - (Tmat + Evap)
  # a simple moving average function of lag = n
  ma <- function(vec, n) sapply(5:length(vec), function(z)
    mean(vec[(z-n):(z-1)]))
  SmoothedIrrigation <- apply(Irrigation, 2, 
                              function(z) c(rep(NA, 4), ma(z, n = 4)))
  SmoothedIrrigation[Balance >3] <- 0
  
  return(list(s = s, LAIMaxPercent = LAIMaxPercent, Rn = Rn, 
              Daily_sap_flow = Daily_sap_flow, Evap = Evap, Tmat = Tmat,
              ETc_ETo = ETc_ETo, RainfallUseful = RainfallUseful,
              Balance = Balance, Irrigation = Irrigation,
              SmoothedIrrigation = SmoothedIrrigation))
}
