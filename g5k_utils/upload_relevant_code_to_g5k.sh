#!/usr/bin/env bash

set -euo pipefail

pids=()

scp ../BORDER/launch_experiments.sh randerer@access.grid5000.fr:grenoble/launch_experiments.sh &
pids+=("$!")
scp ../BORDER/flexible_router.py randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/flexible_router.py &
pids+=("$!")
scp ../BORDER/start_clients.sh randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/start_clients.sh &
pids+=("$!")
scp ../BORDER/clients/alpine_container/build.sh randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/clients/alpine_container/build.sh &
pids+=("$!")
scp ../BORDER/border_setup.sh randerer@access.grid5000.fr:grenoble/border_setup.sh &
pids+=("$!")
scp ../BORDER/border_setup_launch.sh randerer@access.grid5000.fr:grenoble/border_setup_launch.sh &
pids+=("$!")
scp ../BORDER/launch_border_via_ssh.sh randerer@access.grid5000.fr:grenoble/launch_border_via_ssh.sh &
pids+=("$!")
scp ../BORDER/clients/alpine_container/sub_thread.py randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/clients/alpine_container/sub_thread.py &
pids+=("$!")
scp ../jorammq-deployment/Dockerfile randerer@access.grid5000.fr:grenoble/jorammq-deployment/Dockerfile &
pids+=("$!")
scp ../jorammq-deployment/build.sh randerer@access.grid5000.fr:grenoble/jorammq-deployment/build.sh &
pids+=("$!")
scp ../jorammq-deployment/start.sh randerer@access.grid5000.fr:grenoble/jorammq-deployment/start.sh &
pids+=("$!")
scp ../jorammq-deployment/entrypoint.sh randerer@access.grid5000.fr:grenoble/jorammq-deployment/entrypoint.sh &
pids+=("$!")
scp ../mzbench-docker-deployment/Dockerfile randerer@access.grid5000.fr:grenoble/mzbench-docker-deployment/Dockerfile &
pids+=("$!")
scp ../mzbench-docker-deployment/server.config randerer@access.grid5000.fr:grenoble/mzbench-docker-deployment/server.config &
pids+=("$!")
scp ../mzbench-docker-deployment/build.sh randerer@access.grid5000.fr:grenoble/mzbench-docker-deployment/build.sh &
pids+=("$!")
scp ../mzbench-docker-deployment/run.sh randerer@access.grid5000.fr:grenoble/mzbench-docker-deployment/run.sh &
pids+=("$!")
scp ./automated_data_pipeline.sh randerer@access.grid5000.fr:grenoble/automated_data_pipeline.sh &
pids+=("$!")
scp -r  ../border-data-pipeline/*.py randerer@access.grid5000.fr:grenoble/border-data-pipeline/
scp data_pipeline.sh randerer@access.grid5000.fr:grenoble/data_pipeline.sh

# scp ../jorammq-deployment/jorammq-mqtt-trial-1.22.0-SNAPSHOT.zip randerer@access.grid5000.fr:grenoble/jorammq-deployment/jorammq-mqtt-trial-1.22.0-SNAPSHOT.zip


status=0
for pid in "${pids[@]}"; do
	if ! wait "$pid"; then
		status=1
	fi
done

exit "$status"