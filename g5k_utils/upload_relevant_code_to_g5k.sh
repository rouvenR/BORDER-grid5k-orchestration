#!/usr/bin/env bash

set -euo pipefail

pids=()

PROJECT_ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

scp "$PROJECT_ROOT_DIR/BORDER/launch_experiments.sh" randerer@access.grid5000.fr:grenoble/launch_experiments.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/BORDER/flexible_router.py" randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/flexible_router.py &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/BORDER/start_clients.sh" randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/start_clients.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/BORDER/clients/alpine_container/build.sh" randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/clients/alpine_container/build.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/BORDER/border_setup_launch.sh" randerer@access.grid5000.fr:grenoble/border_setup_launch.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/BORDER/launch_border_via_ssh.sh" randerer@access.grid5000.fr:grenoble/launch_border_via_ssh.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/BORDER/clients/alpine_container/sub_thread.py" randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/clients/alpine_container/sub_thread.py &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/jorammq-deployment/Dockerfile" randerer@access.grid5000.fr:grenoble/jorammq-deployment/Dockerfile &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/jorammq-deployment/build.sh" randerer@access.grid5000.fr:grenoble/jorammq-deployment/build.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/jorammq-deployment/start.sh" randerer@access.grid5000.fr:grenoble/jorammq-deployment/start.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/jorammq-deployment/entrypoint.sh" randerer@access.grid5000.fr:grenoble/jorammq-deployment/entrypoint.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/mzbench-docker-deployment/Dockerfile" randerer@access.grid5000.fr:grenoble/mzbench-docker-deployment/Dockerfile &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/mzbench-docker-deployment/server.config" randerer@access.grid5000.fr:grenoble/mzbench-docker-deployment/server.config &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/mzbench-docker-deployment/build.sh" randerer@access.grid5000.fr:grenoble/mzbench-docker-deployment/build.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/mzbench-docker-deployment/run.sh" randerer@access.grid5000.fr:grenoble/mzbench-docker-deployment/run.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/g5k_utils/automated_data_pipeline.sh" randerer@access.grid5000.fr:grenoble/automated_data_pipeline.sh &
pids+=("$!")
scp -r "$PROJECT_ROOT_DIR/border-data-pipeline/"*.py randerer@access.grid5000.fr:grenoble/border-data-pipeline/ &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/check_logs_for_errors.py" randerer@access.grid5000.fr:grenoble/check_logs_for_errors.py &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/data_pipeline.sh" randerer@access.grid5000.fr:grenoble/data_pipeline.sh &
pids+=("$!")
scp "$PROJECT_ROOT_DIR/border-custom-environment.yaml" randerer@access.grid5000.fr:grenoble/border-custom-environment.yaml &
pids+=("$!")



# scp "$PROJECT_ROOT_DIR/jorammq-deployment/jorammq-mqtt-trial-1.22.0-SNAPSHOT.zip" randerer@access.grid5000.fr:grenoble/jorammq-deployment/jorammq-mqtt-trial-1.22.0-SNAPSHOT.zip


status=0
for pid in "${pids[@]}"; do
	if ! wait "$pid"; then
		status=1
	fi
done

exit "$status"