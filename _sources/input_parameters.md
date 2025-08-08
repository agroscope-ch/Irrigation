(section:input_parameters)=
# Input parameters and units

The model is based on the following input parameters. 

- **`Rel` is the mean relative humidity per day(in %)**
[Relative humidity](https://www.meteoswiss.admin.ch/weather/weather-and-climate-from-a-to-z/humidity.html)
indicates the amount of water vapour contained in the air, expressed as
a percentage. Relative humidity varies with air temperature: the warmer
the air, the more water vapour it can contain.
- **`ET` is the daily Evapotranspiration in mm**
Reference evapotranspiration (in mm), denoted as `ET` is the estimation
of the [evapotranspiration](https://www.fao.org/4/x0490e/x0490e04.htm#evapotranspiration%20(et))
from the reference surface which is a hypothetical grass reference crop
with specific characteristics. ET is commonly computed from weather data using empirical or
semi-empirical equations and is expressed in mm/day. Crop
evapotranspiration denoted as $\text{ET}_C$ refers to the evaporating demand
from crops that are grown in large fields under optimal soil water and
environmental conditions.
- **`Rad` is solar radiation in W m$^{-2}$** 
[Solar radiation](https://www.fao.org/4/x0490e/x0490e07.htm#solar%20radiation)
refers to energy produced by the sun, some of which reaches the Earth.
The standard unit to express energy received on a unit surface per unit
time $[MJ \cdot m^{-2}  \cdot\text{day}^{-1}]$ (where $MJ$ stands for Mega Joule). In meteorological bulletins other units might be used, such as $W \cdot m^{-2}.$ Conversion factors can be used, e.g. $1\ W  \cdot m^{-2} = 0.0864 MJ \cdot m^{-2} \cdot \text{day}^{-1}$
- **`Temp` is the mean daily temperature in °C** [Temperature](https://www.meteosuisse.admin.ch/meteo/meteo-et-climat-de-a-a-z/temperatures.html#:~:text=M%C3%A9t%C3%A9oSuisse%20utilise%20le%20degr%C3%A9%20Celsius,intemp%C3%A9ries%20et%20au%20rayonnement%20solaire.)
is measured in Celsius degrees [°C].
- **`Rain` is the sum of the daily rainfall in mm** Rainfall is the amount of
[precipitation](https://www.meteoswiss.admin.ch/weather/weather-and-climate-from-a-to-z/precipitation.html)
in a specified place and time. Precipitation of 1 mm is equal to one
litre of water per square metre.
- **`DOY`** `DOY` is the abbreviation of day of the year also called `julian day'. It
is the sequential day number starting with day 1 on Jan 1$^\text{st}$.
- **`start_flowering = 109` is the full bloom day in Julian day**
According to the [BBCH-scale for pomefruit](https://www.openagrar.de/servlets/MCRFileNodeServlet/openagrar_derivate_00010428/BBCH-Skala_en.pdf), full bloom or full flowering corresponds to a phenological stage
characterized by at least 50% of flowers open and first petals falling
([BBCH 65](https://api.agrometeo.ch/storage/uploads/stade_pheno_pommier-fr_poster-fond.pdf)). Full bloom is often used as a reference stage due to its ease of identification. It can be considered as the starting point of the growing season for fruit trees. The default value is set to 109 Julian days (approx. April 21).  
- **`DayFolAreaMax = 171` is the date on which the maximum leaf area is reached in Julian days** It
takes place approximately [60 days](http://www.hort.cornell.edu/lakso/fcp/PaperScans/1996scan100.pdf)
after BBCH 65. The default value is set to 171 Julian days (approx. June 20).
- **`RAW = 32` is the [Readily Available Water](https://www.agric.wa.gov.au/citrus/calculating-readily-available-water) in mm.** It represents the part of the total water capacity of the soil that can be easily extracted by the plant. It varies depending on the type of soil, its depth, its structure and its organic matter content. In our conditions, we can estimate it at 30-40 mm. Once exhausted, the first signs of water stress can be observed. In drip irrigation management, regular inputs ensure constant humidity in the area wetted by the drippers. Through the use of soil moisture probes, it is possible to maintain constant humidity within the RAW limits by periodically adjusting the daily irrigation doses. More precisely, Readily Available Water (RAW) is the amount of water a soil can store between tension values of -8 kPa (field capacity) and -60 kPa (RAW depletion). Although the water reserve is not depleted at this latter value, it is considered that the remaining reserve no longer provides sufficient water supply for optimal yield and fruit quality. The most common soils found in Switzerland are sandy loam, sandy clay loam, and loam, with a fairly similar water retention capacity. Less commonly, loamy sand is found, with very little clay and a lower water retention capacity. Depending on the soil's water retention capacity and root zone depth, RAW varies between 21 and 33 mm for loamy sand and 25 to 44 mm for medium soils. When a drought follows heavy rainfall, irrigation must be resumed before the decrease in soil moisture affects the soil's water conductivity, i.e., its ability to reform a large bulb. By default, a value of 32 mm is used in the model, but this value can be modified by the user according to the following suggestion:

<!-- generated from https://www.tablesgenerator.com/html_tables -->

<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;}
.tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
  overflow:hidden;padding:10px 5px;word-break:normal;}
.tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
  font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
.tg .tg-cly1{text-align:left;vertical-align:middle}
.tg .tg-lboi{border-color:inherit;text-align:left;vertical-align:middle}
.tg .tg-9wq8{border-color:inherit;text-align:center;vertical-align:middle}
.tg .tg-qve4{background-color:#009E73;text-align:left;vertical-align:middle}
.tg .tg-eb3p{background-color:#56B4E9;border-color:inherit;text-align:center;vertical-align:middle}
.tg .tg-kvxc{border-color:#000000;text-align:left;vertical-align:bottom}
.tg .tg-nrix{text-align:center;vertical-align:middle}
</style>
<table class="tg"><thead>
  <tr>
    <th class="tg-kvxc" colspan="2">   </th>
    <th class="tg-9wq8">Shallow soil</th>
    <th class="tg-9wq8">Deep soil</th>
  </tr></thead>
<tbody>
  <tr>
    <td class="tg-eb3p" rowspan="2">Very light soil</td>
    <td class="tg-lboi">No restriction</td>
    <td class="tg-9wq8">21</td>
    <td class="tg-9wq8">31</td>
  </tr>
  <tr>
    <td class="tg-lboi">Restriction</td>
    <td class="tg-9wq8">22</td>
    <td class="tg-9wq8">33</td>
  </tr>
  <tr>
    <td class="tg-qve4" rowspan="2">Medium soil</td>
    <td class="tg-cly1">No restriction</td>
    <td class="tg-nrix">25</td>
    <td class="tg-nrix">38</td>
  </tr>
  <tr>
    <td class="tg-cly1">Restriction</td>
    <td class="tg-nrix">29</td>
    <td class="tg-nrix">41</td>
  </tr>
</tbody>
</table>

- **`net_rain_effect = 2/3` is the fraction of rainfall that is useful for the crop.** [Effective rainfall](https://www.carbonsync.com.au/faq/effective-rainfall-in-farming#:~:text=Effective%20rainfall%2C%20also%20known%20as,supporting%20their%20growth%20and%20development), also known as _useful rainfall_, refers to the proportion of total rainfall that is actually available for crop use. Light rain events ($<$ 5 mm) as are too weak to reach the root zone and are hence not considered (see the variable `RainfallUseful` in the code). In the calculation of the water balance, the contribution of a heavy rain generally represents only a fraction of the total. This fraction depends on many factors such as quantity and intensity of the rainfall, soil characteristics, soil profile and maintenance etc. Although this proportion undoubtedly differs from one crop to another, our observations, based on several series of soil moisture measurements, over several years and in different orchards, show that a value of 2/3 is suitable for a majority of situations. The default value is set to 2/3,  but this value can be modified.


The meteorological data that are required are **daily summary statistics**, e.g. averages the relative humidity and temperature and sum for the evapotranspiration, the solar radiation and the rainfall. Pay attention to the units used by the model in the description. See the prototypical input file [HERE](missing_link).
