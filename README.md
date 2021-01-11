This is a plotly-dash app written in R to recreate some of the functionality of the NCHS excess deaths dashboard

It reads the dataset regularly published at: https://data.cdc.gov/NCHS/Weekly-counts-of-death-by-jurisdiction-and-cause-o/u6jv-9ijr/

You will need an R environment with:
* readr
* dplyr
* tidyr
* plyr
* surveillance
* dash
* plotly

Run it locally with:

Rscript farrington_bystate_dash.R

Jan 10
* now displays as stacked line graphs (instead of stacked bars)
* and allows user to toggle between CI upperbound and Average as alternative measures for a baseline of excess

This includes some Heroku files as well, for deployment.
* Data last updated Jan 6
* Write-up at http://www.johncmulligan.net/blog/2020/11/26/excess-mortality-and-covid-19/
* App currently live at http://covid-nchs-dash-r2.herokuapp.com/

![dash1](https://raw.githubusercontent.com/JohnMulligan/covid_dashR/master/Screen%20Shot%202020-11-25%20at%208.30.25%20PM.png)

