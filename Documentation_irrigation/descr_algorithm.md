# Description of the algorithm

This R function calculates the **water balance** of a plant based on meteorological variables, agronomic parameters, and empirical models.
The **balance** corresponds to the difference between water inputs (rainfall, irrigation) and estimated needs (evapotranspiration, sap flow).

------------------------------------------------------------------------

## Input Parameters

``` r
balance_computation(Rel, ET, Rad, Temp, Rain, DOY,
                    start_flowering = 109, DayFolAreaMax = 171, 
                    net_rain_effect = 0.66, RAW = 32, 
                    method_leaf_dev = 1)
```

For more details about the input parameters, see the [previous section](section:input_parameters)

| Parameter         | Description                                      |
|-------------------|--------------------------------------------------|
| `Rel`             | Relative humidity (%).                           |
| `ET`              | Evapotranspiration (mm/day).                     |
| `Rad`             | Global radiation (W/m²).                         |
| `Temp`            | Temperature (°C).                                |
| `Rain`            | Daily rainfall (mm).                             |
| `DOY`             | Day of the year.                                 |
| `start_flowering` | Day of year when flowering starts (default 109). |
| `DayFolAreaMax`   | DOY when leaf area peaks (default 171).          |
| `net_rain_effect` | Reduction factor of rainfall due to nets.        |
| `RAW`             | Readily Available Water (mm).                    |
| `method_leaf_dev` | Method to compute leaf development (1 or 2).     |

------------------------------------------------------------------------

## Computation Steps

In what follows, the variables \texttt{Rel}, \texttt{ET}, \texttt{Rad}, \texttt{Temp} and \texttt{Rain} are all **daily measurements**. It means that, when they are used in the following, they are implicitely depending on the day of the year. When it is useful, we use the index $t$ to denote the current day, $t-1$ to denote the previous one and $t_0$ to denote the first day when the measurements start. 

We will use the Priestley–Taylor formula, that reads as follows:

$$
T_c = \alpha \cdot \left( \frac{s}{s + \gamma} \cdot \frac{1}{\lambda} \right) \cdot A,
$$

where:

- $\alpha = 1.26$: Priestley–Taylor parameter  
- $\gamma = 0.066 \, \text{kPa}/^\circ \text{C}$: Psychrometric coefficient  
- $\lambda = 2.45 \, \text{MJ}/\text{kg}$: Latent heat of vaporization
- $s = s(\texttt{Temp})$ is the slope of the saturation vapor pressure curve in terms of the average daily temperature \texttt{Temp}.
- $A [\text{MJ}\cdot \text{tree}^{-1} \cdot \text{day}^{-1}]$ is the total amount of net  (all-wave) radiation absorbed by the leaf canopy;

The first is to compute the slope of the saturation vapor pressure. The steps 2 to 5 will be dedicated to the determination of $A$. 

### 1. Slope of the saturation vapor pressure curve

We use the formula provided in the [FAO report](https://www.fao.org/4/x0490e/x0490e07.htm#atmospheric%20parameters), equation (13) to compute the slope of the saturation vapor pressure curve at average daily air temperature:

$$
s = \dfrac{4098 \times 0.6108 \times \exp\left(\frac{17.27 \ \texttt{Temp}}{\texttt{Temp} + 237.3}\right)}{(\texttt{Temp} + 237.3)^2},
$$

where $T$ is the daily average temperature in $°C$. 

------------------------------------------------------------------------

### 2. Leaf area

To compute the leaf area, we first determine a leaf area index (LAI), and then, according to the age and the plant density, we attribute it to one of the five categories (0.5, 1, ..., 2.5), from which we deduce the leaf area by tree
 Indeed, based on an estimate of LAI, leaf area per tree (LA) is obtained as LA = LAI * 5 if we refer to a standard planting density of 2000 tree-ha where each tree occupies 5m2 of soil (thus corresponding in the following to the parameter $k = 1$).
Let $D = \texttt{DOY} - \texttt{start}_\texttt{flowering} + 1$. Then, we define 

$$
Q = \left(-0.00088183 \cdot D^2 + 0.15079 \cdot D\right)/6 \cdot 100.
$$

Finaly, we define 

$$
\text{LAI}^{\%}_\text{max} =
\begin{cases}
\texttt{DOY} \cdot 1.612903 - 175.806452, & \text{if } \texttt{DOY} < \texttt{start}_\texttt{flowering}, \\
Q, & \text{if } \texttt{start_flowering} \leq \texttt{DOY} < \texttt{DayFolAreaMay}, \\
100, & \text{if } \texttt{DayFolAreaMay} \leq \texttt{DOY} < 252, \\
\texttt{DOY} \cdot -0.7843 + 297.65, & \text{if } \texttt{DOY} \geq 252.
\end{cases}
$$


Interpolation logic:

- Linear before $\texttt{start}_\texttt{flowering}$
- Polynomial between $\texttt{start}_\texttt{flowering}$ and \texttt{DayFolAreaMax}
- Constant at 100% between \texttt{DayFolAreaMax} and \texttt{DOY} = 252
- Then linearly decreasing

We then transform it back to a proportion (and not a percentage)

$$
\text{LAI}_\text{max} = \frac{\text{LAI}^{\%}_\text{max}}{100}.
$$

Finally, the **Leaf Area (LA)** is computed for different densities of orchard. Although it is difficult to measure leaf area, this parameter is required for calculating water requirements. Note that small inaccuracies have little impact on the result. For practical reasons, we thus propose to assign the crop to a LAI category ranging from 0.5 (young orchard) to >2.5 (adult orchard), as shown in the following table. 


<!-- generated from https://www.tablesgenerator.com/html_tables -->

<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;}
.tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
  overflow:hidden;padding:10px 5px;word-break:normal;}
.tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
  font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
.tg .tg-yla0{font-weight:bold;text-align:left;vertical-align:middle}
.tg .tg-j6zm{font-weight:bold;text-align:left;vertical-align:bottom}
.tg .tg-7zrl{text-align:left;vertical-align:bottom}
</style>
<table class="tg"><thead>
  <tr>
    <th class="tg-yla0" rowspan="2">   <br><span style="color:black">Planting density</span>  <br>(tree/ha) </th>
    <th class="tg-j6zm" colspan="5">&nbsp;&nbsp;&nbsp;<br><span style="color:black">LAI category according to tree age</span>&nbsp;&nbsp;&nbsp;</th>
  </tr>
  <tr>
    <th class="tg-j6zm">&nbsp;&nbsp;&nbsp;<br><span style="color:black">0.5</span>&nbsp;&nbsp;&nbsp;</th>
    <th class="tg-j6zm">&nbsp;&nbsp;&nbsp;<br><span style="color:black">1</span>&nbsp;&nbsp;&nbsp;</th>
    <th class="tg-j6zm">&nbsp;&nbsp;&nbsp;<br><span style="color:black">1.5</span>&nbsp;&nbsp;&nbsp;</th>
    <th class="tg-j6zm">&nbsp;&nbsp;&nbsp;<br><span style="color:black">2</span>&nbsp;&nbsp;&nbsp;</th>
    <th class="tg-j6zm">&nbsp;&nbsp;&nbsp;<br><span style="color:black">2.5</span>&nbsp;&nbsp;&nbsp;</th>
  </tr></thead>
<tbody>
  <tr>
    <td class="tg-7zrl">   <br><span style="color:black">Low (&lt; 1500)</span>   </td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">1-3</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">3-5</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">6-7</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">8-9</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">&gt;9</span>&nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">Medium (2000 -&nbsp;&nbsp;&nbsp;3000)</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">1-2</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">3-4</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">4-5</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">5-6</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">&gt;7</span>&nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">High (&gt;3000)</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">1-2</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">3</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">4</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">5</span>&nbsp;&nbsp;&nbsp;</td>
    <td class="tg-7zrl">&nbsp;&nbsp;&nbsp;<br><span style="color:black">&gt;5</span>&nbsp;&nbsp;&nbsp;</td>
  </tr>
</tbody></table>

In case of low vigour due to soil fertility, vigour induced by dwarfing rootstock or week varieties, it is recommended to move down one category. Low vigour orchards and low density plantings may stop their leaf area development at a value of 2.

Then the leaf area is computed as

$$
\text{LA}_k =  5 \cdot k \cdot \text{LAI}_\text{max}, \quad k = 0.5,1, \ldots, 2.5,
$$

where $k$ is the index corresponding to the LAI category. 

### 3. Net radiation

Let $R_s$ be the solar radition and $R_n$ the net radiation. We first convert the unit from W $\cdot$ m$^{-2}$ to MJ m$^{-2}$ day$^{-1}$ (see Table 3, [report of FAO](https://www.fao.org/4/x0490e/x0490e07.htm#atmospheric%20parameters) for a reference).

$$
R_s = \texttt{Rad}\cdot 0.0864
$$

Then, $R_n$ can be approximated in Switzerland using the following equation (see {cite:p}`Calanca`)

$$
R_n = 0.617 \cdot R_s - 1.004
$$

---

### 4. Energy absorbed by the canopy

We use the formula provided by {cite:t}`Pereira2007b` to deduce the total amount of net (all-wave) radiation absorbed by the leaf canopy, depending on the category $k$.

$$
A_k = 0.303 \cdot \text{LA}_k \cdot R_n
$$

---

### 5. Sap flow by tree (actual transpiration)

We can now use the Priestley-Taylor formula to estimate daily sap flow of a tree.

$$
\text{ET}_{\text{PT}}(k) = \alpha \cdot \left( \frac{s}{s + \gamma} \cdot \frac{1}{\lambda} \right) \cdot A_k
$$

with:

 $\alpha$, $\gamma$, and $\lambda$ given above. 

Note that this is the sap flow per tree and not per m$^{-2}$. If one wants to give $\text{ET}_{\text{PT}}$ in m$^{2}$, it has to be divided by a factor 5 (for a standard orchard of 2000 trees/ha and thus 5m$^2$/tree).

<!--
We then compute the [reference crop evapotranspiration](https://www.fao.org/4/x0490e/x0490e06.htm#TopOfPage)
as

$$
\text{ET}_o = \frac{\text{ET}_{\text{PT}}}{5  \texttt{ET}}
$$

with the convention that $\text{ET}_o = 0 $ if $\texttt{ET} = 0$ (to avoid division by 0).
-->

### 6. Soil evaporation

Now, starting from the measured value $\texttt{ET}$, we estimate the evaporation from the ground. 
It can be estimated as a part of ET$_o$ that evolves during the growing season in function of the development of the canopy cover i.e. its growing shading effect until LAI max is reached. It is lower for young trees compared with adult trees. We have estimated third-order polynomial curves for each of the LAI category. The polynomials are provided in the code and you can find below a Figure with the curves together with the corresponding points they approximate.

```{image} ../curves_f_DOY.png
:align: center
```

The evaporation is then estimated as

$$
\text{Evap}_k = f_k(\texttt{DOY}) \cdot \texttt{ET}, \text{ for }k = 0.5, 1, \ldots,2.5 ,
$$
where we have dropped (for clarity) the dependence on the Julian day \texttt{DOY}.

On the other hand, we define WHAT???, as 

$$
T_k^\text{mat} =
\begin{cases}
\frac{1}{5} \text{ET}_{\text{PT}} \cdot \text{LAI}_\text{max},& \text{if } \texttt{ET} > 0 \\
0 & \text{else.}
\end{cases}
$$

<!-- We can now define the variable $K$ as:

$$
K = \begin{cases}
\frac{T_\text{mat}_k + \text{Evap}_k(DOY)}{ET}& \text{if }ET > 0\\
0 & \text{else.}
\end{cases}
$$
-->
### 7. Useful rainfall

The useful rainfall is the amount of precipitation that is actually added and stored in the soil. During drier periods, less than 5mm of daily rainfall would not be considered effective, as this amount of precipitation would likely evaporate from the surface before soaking into the ground.

$$
R = 
\begin{cases}
\texttt{Rain} & \text{if } \texttt{Rain}^t + \texttt{Rain}^{t-1} > 5 \\
0 & \text{otherwise}
\end{cases}
$$


### 8. Raw water balance

The water balance is the amount of water present in the soil that is available to the plant. The plant will be stressed and irrigation will only be necessary when this reserve is depleted.
Let us define $B_k$ as

$$
B_k = (R \cdot \texttt{net_rain_effect}) - (T_k^\text{mat} + \texttt{Evap}_k)
$$

Then, we have

$$
\texttt{Balance} = 
\begin{cases}
0 & \text{if } B_k^{t-1} + B_k^t <0\\
B_k^{t-1} + B_k^t & \text{if } 0 < B_k^{t-1} + B_k^t <\texttt{RAW}\\
\texttt{RAW}\text{if } B_k^{t-1} + B_k^t >\texttt{RAW}.
\end{cases}
$$

with $B_k^{t_0} = R^{t_0} - \texttt{ET}^{t_0} ({T_k^\text{mat}}^{t_0} +  \texttt{Evap}^{t_0}_k)$. In words, this means that \texttt{Balance} is truncated to the interval $[0,\texttt{RAW}]$.

### 9. Irrigation


Finally, the irrigation needed is computed as 

$$
\texttt{Irrigation} = 
\begin{cases}
0 & \text{if } \texttt{Balance} > 0 \\
T_k^\text{mat} + \text{Evap}_k & \text{otherwise}
\end{cases}
$$

We also provide a smoothed version of the needeed irrigation using the mean of the needed irrigation in the past 4 days:

$$
\texttt{SmoothedIrrigation} = 
\begin{cases}
\frac{1}{4}\sum_{i= 1}^4 \texttt{Irrigation}_{t-i} & \text{if } \texttt{Balance} > 3 \\
0  & \text{otherwise}
\end{cases}
$$

<!--
  Balance = (RainfallUseful * \texttt{net_rain_effect}) - (Tmat + Evap)
  # We initialize the first value of the Balance
  # REFERENCE/EXPLANATION
  Balance[1,] <- RainfallUseful[1] - ET[1] * (Tmat + Evap)[1,]
-->


