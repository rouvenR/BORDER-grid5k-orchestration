#!/usr/bin/env bash

ssh -J randerer@access.grid5000.fr randerer@grenoble "
    mkdir -p border &&
    cd border &&
    git clone https://github.com/rouvenR/containernet.git &&
    cd containernet &&
    mkdir -p BORDER
"

scp -r  ./BORDER randerer@access.grid5000.fr:grenoble/border/containernet/
scp -r ./mzbench-docker-deployment randerer@access.grid5000.fr:grenoble
scp -r ./jorammq-deployment randerer@access.grid5000.fr:grenoble
scp -r ./border-data-pipeline randerer@access.grid5000.fr:grenoble

chmod +x ./g5k_utils/upload_relevant_code_to_g5k.sh
./g5k_utils/upload_relevant_code_to_g5k.sh

ssh -J randerer@access.grid5000.fr randerer@grenoble "
    chmod +x automated_data_pipeline.sh &&
    chmod +x border_setup_launch.sh &&
    chmod +x launch_border_via_ssh.sh &&
    chmod +x data_pipeline.sh &&
    chmod +x launch_experiments.sh &&
    chmod +x ./border/containernet/BORDER/border_setup_kadeploy.sh &&
    chmod +x ./border/containernet/BORDER/start_clients.sh &&
    chmod +x rebuild_images.sh &&
    mkdir -p logs &&
    mkdir -p processed_results
"