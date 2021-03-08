library(plotly)
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(readr)
library(tidyr)
library(dplyr)

app<-Dash$new()



years<-unique(counts$Year)


fig <- plot_ly()

for(year in years){
print(year)

counts_filtered<-filter(counts,`Type`==weighted,`Jurisdiction`==jurisdiction,`Cause Subgroup`==cause,`Year`==year)
df<-counts_filtered %>% select(`Number of Deaths`,`Week`)

print(df)

fig <- fig %>% add_trace(
	x=df$Week,
	y=df$`Number of Deaths`,
	name=year,
	type='scatter',
	mode='lines'
)

}

fig <- fig %>% layout(
	title=paste(c(jurisdiction,cause,"Mortality"),collapse=" "),
	xaxis=list('title'='Week'),
	yaxis=list('title'="title"),
	paper_bgcolor = '#c3d1e8'

)

