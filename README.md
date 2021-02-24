Data last updated Feb 10

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

### latest data, updated Feb 24, now reflects numbers through Feb 8.

Feb 22
* A late January report showed a spike in projected deaths for its final week. 
* The subsequent report downgraded that spike. 
* There is no data from February in this latest dataset, from Feb. 17.

Jan 10
* now displays as stacked line graphs (instead of stacked bars)
* and allows user to toggle between CI upperbound and Average as alternative measures for a baseline of excess

This includes some Heroku files as well, for deployment.
* Write-up at http://www.johncmulligan.net/blog/2020/11/26/excess-mortality-and-covid-19/
* App currently live at http://covid-nchs-dash-r2.herokuapp.com/

![dash1](https://raw.githubusercontent.com/JohnMulligan/covid_dashR/master/Screen%20Shot%202021-01-10%20at%209.36.38%20PM.png)
