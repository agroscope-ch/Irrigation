# Function `balance`

## Description

The `balance` function calculates various components of water and energy balance for a tree canopy using meteorological inputs and physiological parameters. Outputs include estimates of sap flow, evapotranspiration, rainfall utility, irrigation requirements, and water balance over time.


## Mathematical Notation and Parameters

### Input Variables

1. **Rel**: Relative humidity (\%)  
2. **EPT**: Evapotranspiration rate  
3. **Rad**: Solar radiation (in  $\text{W}/\text{m}^2$  )  
4. **Temp**: Air temperature (in $^{\circ}C$)  
5. **Rain**: Daily rainfall (in mm)  
6. **DOY**: Day of year  
7. **$\text{start}_{\text{flowering}}$**: Day of year when flowering starts (default $109$)  
8. **DayFolAreaMax**: Day when maximum leaf area is reached (default $171$)  
9. **net\_rain\_effect**: Coefficient for rainfall reduction due to nets (default $0.66$)  
10. **RFU**: Maximum root zone water storage capacity (default $32$)  
11. **method\_leaf\_dev**: Method for leaf area development calculation (default $1$)



### Constants

- $\alpha = 1.26$: Priestley–Taylor parameter  
- $\gamma = 0.066 \, \text{kPa}/^\circ \text{C}$: Psychrometric coefficient  
- $\lambda = 2.45 \, \text{MJ}/\text{kg}$: Latent heat of vaporization  


### Equations

#### 1. **Slope of the Saturation Vapor Pressure Curve**  
The slope $s$ of the vapor pressure curve at temperature $T$ is computed as:  

$$
s = \frac{4098 \cdot \exp(0.6108) \cdot \frac{17.27 \cdot T}{T + 237.3}}{(T + 237.3)^2}
$$



#### 2. **Development of $\text{LAI}_\text{max}$**  
The maximum leaf area index (LAI) is computed as follows:  

$$
\text{LAI}_\text{max}^\% = 
\begin{cases} 
\text{DOY} \cdot 1.612903 - 175.806452 & \text{if } \text{DOY} < \text{start}_{\text{flowering}} \\
Q & \text{if } \text{start}_{\text{flowering}} \leq \text{DOY} < \text{DayFolAreaMax} \\
100 & \text{if } \text{DayFolAreaMax} \leq \text{DOY} < 252 \\
\text{DOY} \cdot -0.7843 + 297.65 & \text{if } \text{DOY} \geq 252
\end{cases}
$$

where $Q$is a second-order polynomial function:  

$$
Q = \frac{-0.000881834215 \cdot D_\text{flowering}^2 + 0.150793650794 \cdot D_\text{flowering}}{6} \cdot 100
$$

with $D_\text{flowering} = \text{DOY} - \text{start}_{\text{flowering}} + 1$.



#### 3. **Daily Sap Flow**  
The daily sap flow ($T_c$) is estimated using the Priestley–Taylor equation:  

$$
T_c = \alpha \cdot \frac{s}{s + \gamma} \cdot \frac{1}{\lambda} \cdot A
$$

where $A$ is the total net radiation absorbed by the canopy:  

$$
A = 0.303 \cdot \text{LAI}_\text{max} \cdot R_n
$$

and $R_n$ is the net radiation computed as:  


$$
R_n = R_s \cdot 0.617 - 1.004, \quad R_s = \frac{\text{Rad} \cdot 86400}{10^6}.
$$



#### 4. **Useful Rainfall**  
Rainfall is considered useful only if it exceeds 5 mm over the past two days. So for a day $t$, $\text{RainfallUseful}_t$ is defined in terms of the rainfalls of the past days $\text{Rain}_t$ and $\text{Rain}_{t-1}$:

$$
\text{RainfallUseful}_t = 
\begin{cases}
\text{Rain}_t & \text{if } \text{Rain}_t + \text{Rain}_{t-1} > 5 \, \text{mm} \\
0 & \text{otherwise}
\end{cases}
$$



#### 5. **Water Balance**  
The water balance at day $t$is computed iteratively:  

$$
\text{Balance}_t = \text{truncation}(\text{Balance}_{t-1} + \text{RainfallUseful}_t \cdot \text{net}_{texttt{rain_effect}} - (\text{Tmat} + \text{Evap})_t),
$$

where the truncation function ensures:  

$$
\text{truncation}(x, a, b) = 
\begin{cases}
b & \text{if } x > b \\
a & \text{if } x < a \\
x & \text{otherwise}
\end{cases}
$$

with $a = 0 $and $b = \text{RFU}$.



#### 6. **Irrigation Requirement**  
Irrigation is required when the water balance is negative:  

$$
\text{Irrigation}_t = 
\begin{cases}
0 & \text{if } \text{Balance}_t > 0 \\
\text{Tmat} + \text{Evap} & \text{otherwise}.
\end{cases}
$$



## Output
The function returns a list containing:

1. `s`: Slope of the vapor pressure curve  
2. `LAIMaxPercent`: Maximum leaf area percentage  
3. `Rn`: Net radiation  
4. `Daily_sap_flow`: Daily sap flow estimates  
5. `Evap`: Evaporation values based on polynomial regression  
6. `Tmat`: Transpiration matrix  
7. `ETc_ETo`: Ratio of crop evapotranspiration to reference evapotranspiration  
8. `RainfallUseful`: Useful rainfall values  
9. `Balance`: Daily water balance  
10. `Irrigation`: Daily irrigation requirements  
11. `SmoothedIrrigation`: Smoothed irrigation estimates using a 4-day moving average  



## Example Usage
```R
# Example inputs
Rel <- 60
EPT <- rep(5, 10)
Rad <- rep(200, 10)
Temp <- rep(25, 10)
Rain <- c(0, 10, 0, 5, 0, 0, 20, 0, 0, 5)
DOY <- 100:109

# Run the function
results <- balance(Rel, EPT, Rad, Temp, Rain, DOY)
```



## Notes
- Ensure input vectors are of the same length.  
- Polynomial regression coefficients for evaporation functions ($\text{DOY}_\text{fun}$) should be referenced or validated.


