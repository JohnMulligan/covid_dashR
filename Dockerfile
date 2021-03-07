FROM plotly/heroku-docker-r:3.6.2_heroku18 as base

# install dependencies with init.R
COPY init.r /app/init.r
RUN /usr/bin/R --no-init-file --no-save --quiet --slave -f /app/init.r

from base as build

COPY . /app/

EXPOSE 8050

CMD cd /app && /usr/bin/R --no-save -f /app/farrington_bystate_dash.r