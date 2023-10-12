FROM rocker/geospatial:4.1.2

RUN apt-get update && apt-get -y install git

USER rstudio

RUN git clone https://github.com/melofton/vera4casts.git /home/rstudio/vera4casts

RUN Rscript /home/rstudio/vera4casts/install.R

USER root
