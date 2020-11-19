library(plotly)
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)

library('surveillance')
library(readr)
library(tidyr)
library(dplyr)

app<-Dash$new()
fig<-plot_ly()

w<-1
nfreq<-52
max_steps_back<-52
steps_back<-30

counts <- read_csv("Weekly_counts_of_death_by_jurisdiction_and_cause_of_death.csv")
week_ending_dates<-unique(counts$`Week Ending Date`[order(counts$Year,counts$Week)])

steps_back_slider_opts<-list()
idx<-0
wed<-week_ending_dates[(length(week_ending_dates)-max_steps_back):length(week_ending_dates)]
for(i in wed){
	d<-as.Date(i,origin='1970-01-01')
	steps_back_slider_opts[[length(steps_back_slider_opts)+1]]<-list(label=d,value=idx)
	idx<-idx+1
}


stepsback_sliderlabels<-list()
min_start_idx<-length(week_ending_dates)-max_steps_back
max_end_idx<-length(week_ending_dates)


for(i in min_start_idx:max_end_idx){
	stepsback_sliderlabels[[i]]<-week_ending_dates[i]
}



causes<-unique(counts$`Cause Group`)
cause_dropdown_opts<-list()
for(i in causes){
	cause_dropdown_opts[[length(cause_dropdown_opts)+1]]<-list(label=i,value=i)
}

jurisdictions<-unique(counts$`Jurisdiction`)
jurisdiction_dropdown_opts<-list()
for(i in jurisdictions){
	jurisdiction_dropdown_opts[[length(jurisdiction_dropdown_opts)+1]]<-list(label=i,value=i)
}

weighted_opts<-unique(counts$`Type`)
weighted_radio_opts<-list()
for(i in weighted_opts){
	weighted_radio_opts[[length(weighted_radio_opts)+1]]<-list(label=i,value=i)
}

ci_sliderlabels<-list()
for(i in 80:100){ci_sliderlabels[[i]]<-as.character(i-1)}

yearsback_sliderlabels<-list()
for(i in 1:4){yearsback_sliderlabels[[i]]<-as.character(i-1)}



app$layout(
	htmlDiv(list(

	htmlDiv(list(
			dccGraph(id='fizz',figure=fig)
		)),
	htmlDiv(
		list(
			htmlLabel('Listed Cause of Death'),
			dccDropdown(
				id = 'cause_dropdown',
				options = cause_dropdown_opts,
				value = 'Diabetes'
			),
			htmlLabel('State'),
			dccDropdown(
				id = 'jurisdiction_dropdown',
				options = jurisdiction_dropdown_opts,
				value = "Texas"
			),
			htmlLabel('Weighted or Raw Counts'),
                        dccRadioItems(
                                id = 'weighted_radio',
                                options = weighted_radio_opts,
                                value = "Unweighted"
                        )
		),style=list('columnCount'=3,'width'='100%','marginTop'=15,'marginBottom'=15)
	),
	htmlDiv(
		list(
			htmlLabel('Confidence Interval on Trend'),
			dccSlider(
				id = 'ci_slider',
				min = 80,
				max = 99,
				marks = ci_sliderlabels,
				value = 95,
				included = FALSE
			),
                        htmlLabel('Base Trendline on # Years of Previous Data'),
                        dccSlider(
                                id = 'yearsback_slider',
                                min = 1,
                                max = 3,
                                marks = yearsback_sliderlabels,
                                value = 3,
				included= FALSE
                        )

                ),style=list('columnCount'=2,'width'='90%','marginTop'=15,'marginBottom'=15)
        ),
	htmlDiv(
                list(
                        htmlLabel('Date Range'),
			dccRangeSlider(
                                id = 'weeks_slider',
                                min = min_start_idx,
                                max = max_end_idx,
                                value = list(min_start_idx,max_end_idx)
                        )
		),style=list('width'='100%','marginTop'=15)
	)
	))
)

app$callback(
	output = list(id='fizz',property='figure'),
	params = list(
		input(id='cause_dropdown',property='value'),
		input(id='jurisdiction_dropdown',property='value'),
		input(id='weighted_radio',property='value'),
		input(id='ci_slider',property='value'),
		input(id='yearsback_slider',property='value'),
		input(id='weeks_slider',property='value')
	),
	function(cause,jurisdiction,weighted,ci_raw,b,wb) {
		start_idx<-wb[[1]]
		end_idx<-wb[[2]]
		cistring<-paste(c(as.character(ci_raw),"% CI Upper Bound of ",as.character(b),"-Year Trend"),collapse="")
		alpha<-1.00-ci_raw/100
		
		counts_filtered<-filter(counts,Type==weighted)
		counts_filtered<-filter(counts_filtered,`Jurisdiction` == jurisdiction)
		counts_filtered<-filter(counts_filtered,`Cause Group` == cause)
		#remove extraneous columns
		counts_filtered<-counts_filtered[,!colnames(counts_filtered) %in% c('Week Ending Date','Type','Jurisdiction','State Abbreviation','Cause Subgroup','Time Period','Suppress','Note','Average Number of Deaths in Time Period','Difference from 2015-2019 to 2020','Percent Difference from 2015-2019 to 2020')]
		counts_wider = pivot_wider(counts_filtered,names_from=`Cause Group`,values_from='Number of Deaths',values_fn=(`Cause Group`=sum))
		counts_wider[is.na(counts_wider)]<-0
		end<-dim(counts_wider)[1]
		freq<-max(counts_wider[,'Week'])
		#but "observed" must be a numeric matrix
		numeric_data<-data.matrix(counts_wider)[order(counts_wider[,'Year'],counts_wider[,'Week']),]
		numeric_data<-numeric_data[,!colnames(numeric_data) %in% c('Week','Year')]
		#strip out now-extraneous columns
		#numeric_data<-numeric_data[,'Number of Deaths']
		start<-c(min(counts_wider[,'Year']),min(counts_wider[,'Week']))
		sts <- new("sts",epoch=1:end,freq=52,start=start,observed=numeric_data)
		title_str<-paste(c(cause,"mortality in",jurisdiction),collapse=" ")
		#Sparse data creates a couple problems:
		##1) not all jurisdictions have the most recent weeks -- indeed, they may not have data going way back. I address for this by comparing the indices against the data frame size after the jurisdiction and cause filters have been applied. When mismatches like this occur, I add a note to the graph's title.
		##2) the other problem is harder to catch -- insufficient data for the farrington algorithm to work. I use an error handler for that, and throw back an empty graph
		if(end<end_idx){
			gap<-end_idx - start_idx
			end_idx<-end
			if(start_idx>end_idx){
				start_idx<-max(1,end_idx-gap)
			}
			title_str<-paste(c(title_str,"**data is sparse here**"),collapse=" ")
		}
		cntrlFar <- list(range=start_idx:end_idx,start=start,w=w,b=b,alpha=alpha)
		fig <- plot_ly()
		result = tryCatch({
			surveil_sts_far <- farrington(sts,control=cntrlFar)
			far_df<-tidy.sts(surveil_sts_far)
			alarms<-far_df$alarm
			alarms_text<-list()
 			for(a in alarms){
				print(a)
 				if(a==1){alarm_text<-"X"}
				else{alarm_text<-""}
				print(alarm_text)
				alarms_text[[length(alarms_text)+1]]<-alarm_text
			}
			fig <- fig %>% layout(
 				title=title_str,
				xaxis=list('title'='Week Ending Date'),
				yaxis=list('title'='Deaths'),
				paper_bgcolor = '#c3d1e8'
			)
			fig <- fig %>% add_trace(
				x=far_df$date,
				y=far_df$observed,
				text=alarms_text,
				textposition="outside",
				type='bar',
				name=paste(c(weighted,"Deaths Count"),collapse=" ")
			)
			fig <- fig %>% add_trace(
				x=far_df$date,
				y=far_df$upperbound,
 				type='scatter',
				name=cistring
			)
		}, error = function(e) {
			print("ERROR ERROR ERROR")
 			list(
				layout=list(
					title="DATA TOO SPARSE TO RENDER GRAPH WITH THESE SPECIFIC PARAMETERS",
					xaxis=list('title'='Week Ending Date'),
					yaxis=list('title'='Deaths'),
					paper_bgcolor = '#c3d1e8'
				),
				data = list()
			)
		})
	}
)

app$run_server(host='0.0.0.0',port=Sys.getenv('PORT',8050))



