FROM ghcr.io/rocker-org/geospatial:4.3.2

LABEL Description="RaukR environment"
LABEL org.opencontainers.image.authors="roy.francis@nbis.se"

ARG NCPUS=${NCPUS:--1}
ARG quarto_version="1.4.549"

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libhdf5-dev \
        libglpk-dev \
        libxt6 \
        patch \
        vim \
        curl

## Install conda
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /home/rstudio/miniconda.sh \
	&& /bin/bash /home/rstudio/miniconda.sh -b -p /opt/miniconda \
	&& rm -rf /home/rstudio/miniconda.sh \
	&& /opt/miniconda/bin/conda init --system bash \
	&& chgrp -R rstudio /opt/miniconda \
	&& sudo chmod 770 -R /opt/miniconda

## Install R dependencies
COPY renv.lock /renv/renv.lock
RUN install2.r --error renv \
    && R -e "renv::consent(provided=TRUE)" \
    && R -e "renv::restore(lockfile='/renv/renv.lock')" \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## Install phantomjs for screenshotting shinyapps
RUN Rscript -e 'webshot::install_phantomjs()'

## Install conda environments
RUN Rscript -e 'reticulate::conda_create("keras", packages=c("keras", "tensorflow"), channel="conda-forge", python_version="3.9", conda = "/opt/miniconda/bin/conda")' \
    && Rscript -e 'reticulate::conda_create("raukr-reticulate", python_version = "3.9", packages = c("pandas=2.2.0","sqlalchemy=2.0.0"), conda = "/opt/miniconda/bin/conda")'

## Install quarto
RUN /rocker_scripts/install_quarto.sh ${quarto_version} \
    && quarto install tinytex \
    && quarto install chromium

RUN apt-get -y autoclean \
	&& apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* \
	## Strip binary installed libraries from RSPM \
	## https://github.com/rocker-org/rocker-versioned2/issues/340 \
	&& strip /usr/local/lib/R/site-library/*/libs/*.so \
	## Fix https://github.com/tschaffter/rstudio/issues/11 \
	&& ln -s /usr/local/lib/R/lib/libR.so /lib/x86_64-linux-gnu/libR.so \
	&& mkdir -p /home/rstudio/raukr \
	&& export LC_ALL=en_US.UTF-8 \
  && export LANG=en_US.UTF-8 \
  && export LANGUAGE=en_US.UTF-8

WORKDIR /home/rstudio/raukr

## docker build --platform=linux/amd64 -t ghcr.io/nbisweden/workshop-raukr:1.0.0 -t ghcr.io/nbisweden/workshop-raukr:latest --file dockerfile .
## docker push ghcr.io/nbisweden/workshop-raukr:1.0.0
## docker push ghcr.io/nbisweden/workshop-raukr:latest
## render qmds
## docker run --platform=linux/amd64 --rm -u 1000:1000 -v ${PWD}:/home/rstudio/raukr ghcr.io/nbisweden/workshop-raukr:latest quarto render
## rstudio server
## docker run --platform=linux/amd64 --rm -e PASSWORD=raukr -p 8787:8787 -v ${PWD}:/home/rstudio/raukr ghcr.io/nbisweden/workshop-raukr:latest


