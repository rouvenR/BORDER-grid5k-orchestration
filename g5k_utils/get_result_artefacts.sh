#!/usr/bin/env bash

mkdir -p border-data-pipeline/inputs/training_data
scp -r  randerer@access.grid5000.fr:grenoble/border-data-pipeline/inputs/training_data/ ./border-data-pipeline/inputs/training_data/
scp -r  randerer@access.grid5000.fr:grenoble/border-data-pipeline/outputs/ ./border-data-pipeline/outputs/