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
- **`Rad` is solar radiation in ??** 
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
- **`start_flowering` is the full bloom day in Julian day**
According to the [BBCH-scale for pomefruit](https://www.openagrar.de/servlets/MCRFileNodeServlet/openagrar_derivate_00010428/BBCH-Skala_en.pdf), full bloom or full flowering corresponds to a phenological stage
characterized by at least 50% of flowers open and first petals falling
([BBCH 65](https://api.agrometeo.ch/storage/uploads/stade_pheno_pommier-fr_poster-fond.pdf)). Full bloom is often used as a reference stage due to its ease of identification. It can be considered as the starting point of the
growing season for fruit trees. **The default value is set to 109 Julian days** (approx. April 21).  
- **`DayFolAreaMax` is the date on which the maximum leaf area is reached in Julian days** It
takes place approximately [60 days](http://www.hort.cornell.edu/lakso/fcp/PaperScans/1996scan100.pdf)
after BBCH 65. **The default value is set to 171 Julian days** (approx. June 20).
- **net_rain_effect is the fraction of rainfall that is useful for the crop.** [Effective rainfall](https://www.carbonsync.com.au/faq/effective-rainfall-in-farming#:~:text=Effective%20rainfall%2C%20also%20known%20as,supporting%20their%20growth%20and%20development). also known as _useful rainfall_. It refers to the proportion of total rainfall that is actually available for crop use. Light rain events ($<$ 5 mm) as are too weak to reach the root zone and are hence not considered (see the variable `RainfallUseful` in the code). In the calculation of the water balance, the contribution of a heavy rain generally represents only a fraction of the total. This fraction depends on many factors such as quantity and intensity of the rainfall, soil characteristics, soil profile and maintenance etc. Although this proportion undoubtedly differs from one crop to another, our observations, based on several series of soil moisture measurements, over several years and in different orchards, show that a value of 2/3 is suitable for a majority of situations. **The default value is set to 2/3**,  but this value can be modified.
- **`RAW` is the [Readily Available Water](https://www.agric.wa.gov.au/citrus/calculating-readily-available-water) in mm.** It represents the part of the total water capacity of the soil that can be easily extracted by the plant. It varies depending on the type of soil, its depth, its structure and its organic matter content. In our conditions, we can estimate it at 30-40 mm. Once exhausted, the first signs of water stress can be observed. In drip irrigation management, regular inputs ensure constant humidity in the area wetted by the drippers. Through the use of soil moisture probes, it is possible to maintain constant humidity within the RAW limits by periodically adjusting the daily irrigation doses. **The default value is set to 32 mm** but it can be modified. 

The meteorological data that are required are **daily summary statistics**, e.g. averages the relative humidity and temperature and sum for the evapotranspiration, the solar radiation and the rainfall. Pay attention to the units used by the model in the description. See the prototypical input file [HERE](missing_link).
