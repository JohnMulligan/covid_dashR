library(plotly)
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(readr)
library(tidyr)
library(dplyr)

app<-Dash$new()
fig<-plot_ly()

w<-1
nfreq<-52
max_steps_back<-51
steps_back<-40

counts <- read_delim(delim=",",file="Weekly_counts_of_death_by_jurisdiction_and_cause_of_death.csv")
week_ending_dates<-unique(counts$`Week Ending Date`[order(counts$Year,counts$Week)])

steps_back_slider_opts<-list()
idx<-0
wed<-week_ending_dates[(length(week_ending_dates)-max_steps_back):length(week_ending_dates)]
for(i in wed){
	d<-as.Date(i,origin='1970-01-01')
	steps_back_slider_opts[[length(steps_back_slider_opts)+1]]<-list(label=d,value=idx)
	idx<-idx+1
}


min_start_idx<-length(week_ending_dates)-max_steps_back
max_end_idx<-length(week_ending_dates)
wb<-list(min_start_idx,max_end_idx)


causes<-unique(counts$`Cause Subgroup`)
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
for(i in 50:100){ci_sliderlabels[[i]]<-as.character(i-1)}

yearsback_sliderlabels<-list()
for(i in 1:4){yearsback_sliderlabels[[i]]<-as.character(i-1)}

app$layout(
	htmlDiv(list(
		htmlDiv(list(
			htmlH1('Excess Mortality and COVID-19'),
			htmlP('Developed in partnership between the CRC and Medical Futures Lab at Rice.'),
			htmlBr(),
			htmlA('Data updated January 26, 2022.', href="https://data.cdc.gov/NCHS/Weekly-Counts-of-Death-by-Jurisdiction-and-Select-/u6jv-9ijr"),
			htmlBr(),
			htmlA('This app was featured on KHOU\'s pandemic coverage.',href="https://twitter.com/KHOU/status/1446477984169439235"),
			htmlBr(),
			htmlA("Read more about this app on the Medical Futures blog.", href="https://mfl.rice.edu/covid-19-excess-mortality-data-visualization")
		)),
		htmlDiv(list(htmlHr())),

		htmlDiv(list(
			dccGraph(id='fizz',figure=fig)
		)),
		htmlDiv(list(
			htmlDiv(
				list(
					htmlLabel('Listed Cause of Death'),
					dccDropdown(
						multi=TRUE,
						id = 'cause_dropdown',
						options = cause_dropdown_opts,
						value = 'Diabetes'
					),
					htmlP(''),
					htmlLabel('State'),
					dccDropdown(
						multi=TRUE,
						id = 'jurisdiction_dropdown',
						options = jurisdiction_dropdown_opts,
						value = "Texas"
					),
					htmlP(''),
					htmlLabel('Weighted or Raw Counts'),
					dccRadioItems(
							id = 'weighted_radio',
							options = weighted_radio_opts,
							value = weighted_radio_opts[[1]]$value
							),
					htmlP(''),
					htmlLabel('Graph Type'),
					dccDropdown(
						id = 'graph_type',
						options = list(
								list('label'='Stacked Lines','value'='stackedlines'),
								list('label'='Stacked Bars','value'='stackedbars')									),
						value = 'stackedbars'
						)
				),style=list('width'='48%','display'='inline-block','margin'=1)
			),
			htmlDiv(id="para",style=list('width'='48%','display'='inline-block','float'='right','margin'=1)
			)
		))
	))
)

        
app$callback(
	output = list(
		output('fizz','figure'),
		output('para','children')
	),
	params = list(
		input(id='cause_dropdown',property='value'),
		input(id='jurisdiction_dropdown',property='value'),
		input(id='weighted_radio',property='value'),
		input(id='graph_type',property='value')
	),
	
	update_output <- function(cause,jurisdiction,weighted,graph_type) {

		if (length(cause)>0 && length(jurisdiction)>0){
		
			print(cause)
			print(jurisdiction)	
			cause<-cause
			jurisdiction<-jurisdiction
			weighted<-weighted
			source("calculate_excess.R",local=TRUE)
			return(list(fig,para))
		} else {
		
			return(dashNoUpdate())
		
		}

	}
)

app$run_server(host='0.0.0.0',port=Sys.getenv('PORT',8050))



