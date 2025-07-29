# https://github.com/Bioconductor/bioconductor_docker
FROM bioconductor/bioconductor_docker:latest

ARG MAASLIN3_VERSION="1.0"
ARG MAASLIN3_PATCH="1"
ARG MAASLIN3_DOCKER_VERSION=${MAASLIN3_VERSION}.${MAASLIN3_PATCH}

LABEL name="biobakery/maaslin3_docker" \
      version=${MAASLIN3_DOCKER_VERSION} \
      url="https://github.com/biobakery/Maaslin3" \
      vendor="The Huttenhower Lab (Biobakery)" \
      maintainer="your_email@example.com" \
      description="Docker image for MaAsLin 3, the Microbiome Multivariable Associations with Linear Models." \
      license="Copyright (c) 2024 Harvard School of Public Health. All rights reserved."

# Set a consistent working directory inside the container
# This WORKDIR will be the default for interactive sessions or if ENTRYPOINT doesn't change it.
WORKDIR /app

RUN apt-get update -y && \
    apt-get install -y \
    make \
    cmake \
    libicu-dev \
    zlib1g-dev \
    pandoc \
    git-lfs \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

RUN R -e "if (!require('BiocManager', quietly = TRUE)) install.packages('BiocManager', repos = 'https://cloud.r-project.org')"

RUN R -e "BiocManager::install('biobakery/maaslin3', ask = FALSE, update = TRUE)" && \
    R -e "BiocManager::install(c('dplyr', 'plyr', 'pbapply', 'lmerTest', 'parallel', 'lme4', 'optparse', 'logging', 'multcomp', 'ggplot2', 'RColorBrewer', 'patchwork', 'scales', 'rlang', 'tibble', 'ggnewscale', 'survival', 'methods', 'BiocGenerics', 'SummarizedExperiment', 'TreeSummarizedExperiment', 'knitr', 'testthat', 'rmarkdown', 'markdown', 'kableExtra'), ask = FALSE, update = TRUE)"

COPY . /app/maaslin3_source

# NO SYMLINK HERE
# Instead, we will directly call Rscript with the full path to the main script.

# Set the entrypoint to directly run Rscript with the full path to maaslin3.R
# This typically makes R's 'source()' function resolve paths relative to the script's directory.
ENTRYPOINT ["Rscript", "/app/maaslin3_source/R/maaslin3.R"]

# Provide a default command to display the help message if no arguments are given.
# These arguments will be appended to the ENTRYPOINT command.
CMD ["--help"]
