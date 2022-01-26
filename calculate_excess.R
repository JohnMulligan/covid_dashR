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

firstweek<-format(observed$`Week Ending Date`[1],format="%B %d %Y")
lastweek<-format(observed$`Week Ending Date`[nrow(observed)],format="%B %d %Y")

comparison <- filter(cause_and_jurisdiction,`Year`<2020)
comparison <- arrange(comparison,`Year`,`Week`)
comparison <- select(comparison,-`Cause Subgroup`)
comparison <- comparison %>% group_by(`Week Ending Date`,`Week`) %>% summarize('Number of Deaths'=sum(`Number of Deaths`))
comparison <- comparison %>% group_by(`Week`) %>% summarize('Number of Deaths'=mean(`Number of Deaths`))

#add the 53rd week by averaging the first and last weeks of years 2015-2019
#this is for 2020, following the CDC's stated method (but i'm getting higher excess counts)
if (53 %in% counts$Week) { 
  fiftythirdstate<-round(mean(filter(comparison,`Week` %in% c(1,52))$`Number of Deaths`))
}

comparison <- comparison  %>% select(`Number of Deaths`,`Week`)
comparison <- comparison %>% group_by(Week) %>% summarize('Number of Deaths'=round(mean(`Number of Deaths`)))
comparison <- arrange(comparison,`Week`)


#matching up the data frame sizes for easy subtraction later
if (53 %in% counts$Week) { 
	comparison<-rbind(comparison,c(`Week`=53,`Number of Deaths`=fiftythirdstate))
}

rowdiff=nrow(observed)-nrow(comparison)
padded_comparison<-rbind(comparison,head(comparison,rowdiff))
comparison_matrix<-data.matrix(padded_comparison$`Number of Deaths`)
observed_matrix<-data.matrix(observed$`Number of Deaths`)

cum_observed<-round(sum(observed_matrix))
cum_comparison<-round(sum(comparison_matrix))

jurisdiction_str<-paste(c(jurisdiction),collapse=", ")
cause_str<-paste(c(cause),collapse=", ")

fig <- plot_ly()
weds<-observed$`Week Ending Date`
y_axis_title<-paste(c(weighted, " Deaths"),collapse="")

failure<-1
result = tryCatch({
		excess<-observed_matrix-comparison_matrix
		excess[excess<0]<-0
		failure<-0
		#print(observed_matrix)
		#print(comparison_matrix)
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
	
	cum_total=cum_comparison+cum_excess

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
			y=comparison_matrix,
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
			y=comparison_matrix,
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
		paste(c("When you count up the number of people who died between ", firstweek, " and ", lastweek, " whose deaths were attributed to ", tolower(cause_str), " in ", jurisdiction_str, " you would expect to see ", cum_comparison , " total deaths in the months since the pandemic began. This average number of deaths is shown in blue."),collapse="")),
		
		htmlP(
		paste(c("Instead, we see ", cum_total, " total deaths. This means we have not explained why ", cum_excess, " more people died than than would have been expected in 'normal' times, whose deaths were attributed to these causes, in these places. This 'excess' number of deaths is shown in orange."),collapse=""))
		)
}