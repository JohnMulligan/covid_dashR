# Dockerized Covid Dash in R

Live app (takes time to spin up) is deployed here: https://covid-excess-nchs.herokuapp.com/

This repo contains 3 builds of a Plotly app in R for quantifying covid-related excess mortality.

It also contains a Dockerfile for building the environment for local and remote deployment.

Data is current for November 30, 2022.

This app has been featured on:

* KHOU: https://twitter.com/KHOU/status/1446477984169439235
* Fox 26 News: https://www.fox26houston.com/video/980037

Note for Aug 24: I have updated the explanatory text to make it a little more approachable.

## Data and Apps

The app parses a large csv (~50MB) from the CDC: https://data.cdc.gov/NCHS/Weekly-counts-of-death-by-jurisdiction-and-cause-o/u6jv-9ijr/
or https://data.cdc.gov/api/views/u6jv-9ijr/rows.csv?accessType=DOWNLOAD

Based on user selections of: official cause(s) of death and state(s) those deaths were reported in, it finds the average number of deaths for each week in 2015-2019, and then compares this to the number of deaths recorded in 2020-2022.

It also allows users to select two measures of 2021-22 recorded deaths provided by the CDC dataset: actual reported deaths, and projected deaths, which attempts to factor in reporting lag time.

### Further reading:

An excellent study on reporting lag times that to my mind nicely reflects a link between reporting gaps and gaps in our public health system was published in 2020: https://github.com/weinbergerlab/excess_pi_covid

And another far-reaching study interrogates the question of what our baseline is for "excess" mortality, by showing that, compared to similarly-situated countries, the United States has been experiencing much more death since well before the COVID pandemic: https://penntoday.upenn.edu/news/United-States-COVID-19-was-not-sole-cause-excess-deaths-2020 

And for documentation on a more rigorous method of calculating projected deaths than simply taking the average, see some experiments I ran with R's "Surveillance" package: https://github.com/JohnMulligan/covid-dash-r-surveillance

### More detailed notes on the data:

Again, the CDC has very good documentation on their site. It is worth visiting their larger dashboard on excess mortality. This application is most similar to their "Total number above average by jurisdiction/cause" dashboard.

https://www.cdc.gov/nchs/nvss/vsrr/covid19/excess_deaths.htm

## Local Deployment

This is based on the remote Heroku deployment for consistency and predictability

USE 2 TERMINAL WINDOWS:

### *BUILD* with:
`docker build .`

### *RUN* by specifying the host and port to bind the service to.
1. `docker run -p 0.0.0.0:8050:8050`
1. access in your browser at 0.0.0.0:8050
1. Now run docker ps
1. You will see a container with a random name running your image

### to *STOP*:
1. open a second terminal window
1. type `docker ps` and see your running container ID's
1. stop with `docker stop CONTAINER_ID`

### *REBUILD* with:
1. Changing some of your code
1. Running the build command again: `docker build .`
1. Rebuilds are fast, but the duplicate containers quickly take up a lot of space:

### *CLEAN UP* every once in a while with:
1. `docker images` to see your stopped image ID's
1. `docker image rm -f IMAGE_ID`

Note: deleting *all* of your images for this app will make your next rebuild slow.

## Remote Deployment

Once your local build is working well, you can easily deploy this to Heroku. Much of this is essentially copied from https://dashr.plotly.com/deployment

It depends on you having Heroku CLI installed and an account set up: https://devcenter.heroku.com/articles/git

	git init
	heroku create --stack container my-dash-app # change my-dash-app to a unique name
	git add . # add all files to git
	git commit -m 'Initial app boilerplate'
	git push heroku master # deploy code to Heroku
	heroku ps:scale web=1  # run the app with one Heroku 'dyno'

You should be able to access your app at https://my-dash-app.herokuapp.com (changing my-dash-app to the name of your app).

To update and redeploy:

	git status # view the changes
	git add .  # add all the changes
	git commit -m 'a description of the changes'
	git push heroku master


![dash1](https://raw.githubusercontent.com/JohnMulligan/covid_dashR/master/Screen%20Shot%202021-01-10%20at%209.36.38%20PM.png)

