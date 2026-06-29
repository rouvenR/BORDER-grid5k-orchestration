#!/usr/bin/env bash

ssh -J randerer@access.grid5000.fr randerer@grenoble "
    mkdir border &&
    mkdir mzbench-docker-deployment &&
    mkdir jorammq-deployment &&
    mkdir border-data-pipeline &&
    mkdir vmq_mzbench &&
    cd border &&
    git clone https://github.com/containernet/containernet.git &&
    cd containernet &&
    mkdir BORDER
"

scp -r  ./BORDER randerer@access.grid5000.fr:grenoble/border/containernet/
scp -r ./mzbench-docker-deployment randerer@access.grid5000.fr:grenoble
scp -r ./jorammq-deployment randerer@access.grid5000.fr:grenoble
scp -r ./border-data-pipeline randerer@access.grid5000.fr:grenoble

./g5k_utils/upload_relevant_code_to_g5k.sh