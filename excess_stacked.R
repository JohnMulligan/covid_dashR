library(plotly)
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(readr)
library(tidyr)
library(dplyr)

#jurisdiction<-"Texas"
#cause<-"Diabetes"
#weighted<-"Unweighted"
fig <- plot_ly()

cause_and_jurisdiction <-filter(counts,`Type`==weighted,`Jurisdiction` %in% jurisdiction,`Cause Subgroup` %in% cause)

observed <- filter(cause_and_jurisdiction,`Year`>=2020)
observed <- observed %>% select(`Number of Deaths`,`Week`,`Week Ending Date`,`Year`)
observed <- observed %>% group_by(`Week`,`Year`,`Week Ending Date`) %>% summarize('Number of Deaths'=sum(`Number of Deaths`))
observed <- arrange(observed,`Year`,`Week`)

lastweek<-format(observed$`Week Ending Date`[nrow(observed)],format="%B %d %Y")

comparison <- filter(cause_and_jurisdiction,`Year`<2020)
comparison <- arrange(comparison,`Year`,`Week`)
comparison <- select(comparison,-`Cause Subgroup`)
comparison <- comparison %>% group_by(`Week`,`Week Ending Date`) %>% summarize('Number of Deaths'=sum(`Number of Deaths`))
firstweek<-format(comparison$`Week Ending Date`[nrow(comparison)],format="%B %d %Y")
comparison <- comparison  %>% select(`Number of Deaths`,`Week`)
comparison <- comparison %>% group_by(Week) %>% summarize('Number of Deaths'=mean(`Number of Deaths`))
comparison <- arrange(comparison,`Week`)

rowdiff=nrow(observed)-nrow(comparison)
padded<-rbind(comparison,head(comparison,rowdiff))
padded_count<-data.matrix(padded$`Number of Deaths`)
death_count<-data.matrix(observed$`Number of Deaths`)

cum_observed<-round(sum(death_count))
cum_padded<-round(sum(padded))

jurisdiction_str<-paste(c(jurisdiction),collapse=", ")
cause_str<-paste(c(cause),collapse=", ")

fig <- plot_ly()
weds<-observed$`Week Ending Date`
y_axis_title<-paste(c(weighted, " Deaths"),collapse="")

failure<-1
result = tryCatch({
		excess<-death_count-padded_count
		excess[excess<0]<-0
		failure<-0
	}, error = function(e) {
		print("ERROR ERROR ERROR")
		
})


if (failure==1){

fig<-list(
	layout=list(
		title="DATA TOO SPARSE TO RENDER GRAPH WITH THESE SPECIFIC PARAMETERS",
		xaxis=list('title'='Week Ending Date'),
		yaxis=list('title'='Deaths'),
		paper_bgcolor = '#c3d1e8'
	),
	data = list()
	)
	
para<-paste(c("The CDC's published mortality data is too sparse to estimate 2020-21 excess deaths attributed to ", tolower(cause_str), " in ", jurisdiction_str,". There are only ", nrow(observed), " weeks with data since January 2020 (showing a total of ", cum_observed, " deaths) and ", nrow(comparison)," weeks with data since 2015."),collapse="")

} else {

	cum_excess=round(sum(excess))

	cum_excess=round(sum(excess))

	title_str<-paste(c(cause_str,"-coded"," mortality in ",jurisdiction_str,": ",cum_excess," cumulative excess deaths."),collapse="")

	if (graph_type=="stackedlines"){

		fig <- fig %>% layout(
			title=title_str,
			xaxis=list('title'='Week Ending Date'),
			yaxis=list('title'=y_axis_title),
			paper_bgcolor = '#c3d1e8',
			type='scatter',
			stackgroup='one'
		)
		fig <- fig %>% add_trace(
			stackgroup='one',
			x=weds,
			y=padded_count,
			mode='none',
			name=paste(c("Average mortality, 2015-2019"),collapse="")
		)
		fig <- fig %>% add_trace(
			stackgroup='one',
			x=weds,
			y=excess,
			mode='none',
			name=paste(c(weighted," \"Excess\" mortality"),collapse="")
		)
	
	} else if (graph_type=="stackedbars") {

		fig <- fig %>% layout(
					title=title_str,
					xaxis=list('title'='Week Ending Date'),
					yaxis=list('title'=y_axis_title),
					paper_bgcolor = '#c3d1e8',
					type='bar',
					barmode='stack'
				)
		fig <- fig %>% add_trace(
			x=weds,
			y=padded_count,
			type='bar',
			name=paste(c("Average mortality, 2015-2019"),collapse="")
		)
		fig <- fig %>% add_trace(
			x=weds,
			y=excess,
			type='bar',
			name=paste(c(weighted," \"Excess\" mortality"),collapse="")
		)

	}



para<- list(htmlP(
		paste(c("This graph shows two measures of death attributed to ",
		tolower(cause_str),
		" in ",
		jurisdiction_str,
		" between ",
		firstweek,
		" and ",
		lastweek,
		"."),collapse="")),
		
		htmlP(
		paste(c("In orange, it shows the week-by-week number of deaths in excess of that week's average for 2015-2019. In blue, it shows that average."),collapse="")),
				
		htmlP(paste(c("This suggests that ",
		cum_excess,
		" people who died in ",
		jurisdiction_str,
		" since the outbreak of COVID, whose deaths were attributed to ",
		tolower(cause_str),
		", died as a result of the pandemic."),collapse="")
		))
		
		
		




}