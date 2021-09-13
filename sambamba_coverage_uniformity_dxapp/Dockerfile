# Base image
FROM r-base:4.1.0

## create directories (Mirror directory structure, /src already exists)
RUN mkdir -p /resources /output

## copy files
COPY /install_packages.R /src/install_packages.R
COPY /sambamba_exon_coverage.R /src/sambamba_exon_coverage.R 

## install R-packages
RUN Rscript /src/install_packages.R

