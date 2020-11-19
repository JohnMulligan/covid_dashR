This is a plotly-dash app written in R to recreate some of the functionality of the NCHS excess deaths dashboard

It reads the dataset regularly published at: https://data.cdc.gov/NCHS/Weekly-counts-of-death-by-jurisdiction-and-cause-o/u6jv-9ijr/

You will need an R environment with:
* readr
* dplyr
* tidyr
* plyr
* surveillance

Run with:

Rscript farrington_bystate_dash.R

This includes some Heroku files as well, as I prepare for deployment.

![dash1](https://raw.githubusercontent.com/JohnMulligan/covid_dashR/master/Screen%20Shot%202020-11-18%20at%209.21.30%20PM.png)
