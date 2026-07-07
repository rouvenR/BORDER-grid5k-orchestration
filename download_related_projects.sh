#!/usr/bin/env bash

git clone git@github.com:rouvenR/BORDER.git && cd BORDER && git checkout g5k-launch && cd ..
git clone git@github.com:rouvenR/jorammq-deployment.git && cd jorammq-deployment && git checkout final-state-thesis && cd ..
# JoramMQ zip has to be added to ./jorammq-deployment/jorammq-mqtt-trial-1.22.0-SNAPSHOT.zip

git clone git@github.com:rouvenR/mzbench-docker-deployment.git && cd mzbench-docker-deployment && git checkout final-state-thesis && cd ..
git clone git@github.com:rouvenR/vmq_mzbench.git && cd vmq_mzbench && git checkout final-state-thesis && cd ..

git clone git@github.com:rouvenR/border-data-pipeline.git && cd border-data-pipeline && git checkout final-state-thesis && cd ..