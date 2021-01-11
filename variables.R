
import::here(plotly)
import::here(dash)
import::here(dashCoreComponents)
import::here(dashHtmlComponents)

import::here('surveillance')
import::here(readr,read_csv)
import::here(tidyr)
import::here(dplyr)



w<-1
nfreq<-52
#can't go back more than a year without breaking my fragile averaging function at the bottom
##please, fix it! (or, better, put: lowerbound and mean in sts surveillance farrington)
max_steps_back<-51
steps_back<-40
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

causes<-unique(counts$`Cause Subgroup`)

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

cause<-'Diabetes'
jurisdiction<-'Texas'
weighted<-'Unweighted'
ci_slider<-95
ci_raw<-ci_slider
yearsback_slider<-3
b<-yearsback_slider
weeks_slider<-list(min_start_idx,max_end_idx)
wb<-weeks_slider
start_idx<-wb[[1]]
end_idx<-wb[[2]]
cistring<-paste(c(as.character(ci_raw),"% CI Upper Bound of ",as.character(b),"-Year Trend"),collapse="")
alpha<-1.00-ci_raw/100
