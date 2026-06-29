#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
RESULT_DATA_DIR="${PROJECT_ROOT_DIR}/border-data-pipeline/inputs/result_data"
LOGS_DATA_DIR="${PROJECT_ROOT_DIR}/logs"
RESULTS_ZIP="${RESULT_DATA_DIR}/results.zip"
LOGS_ZIP="${LOGS_DATA_DIR}/logs.zip"
RESULTS_ROOT="${RESULT_DATA_DIR}/results/single_broker_results"
EXPERIMENTS_SRC="${RESULTS_ROOT}/experiments"
EXPERIMENTS_DST="${RESULT_DATA_DIR}/experiments"
EXTRACTED_LOGS_DIR="${LOGS_DATA_DIR}/logs"

mkdir -p "${RESULT_DATA_DIR}"
mkdir -p "${EXPERIMENTS_DST}"
mkdir -p "${LOGS_DATA_DIR}"

echo "Downloading results.zip ..."
ssh -J randerer@access.grid5000.fr randerer@grenoble 'zip -r results.zip results/'
scp "randerer@access.grid5000.fr:grenoble/results.zip" "${RESULTS_ZIP}"
ssh -J randerer@access.grid5000.fr randerer@grenoble 'find results/single_broker_results -maxdepth 1 -type f -delete; find results/single_broker_results/experiments -maxdepth 1 -type f -delete'
ssh -J randerer@access.grid5000.fr randerer@grenoble 'rm results.zip'

echo "Downloading logs.zip ..."
ssh -J randerer@access.grid5000.fr randerer@grenoble 'zip -r logs.zip logs/'
scp "randerer@access.grid5000.fr:grenoble/logs.zip" "${LOGS_ZIP}"
ssh -J randerer@access.grid5000.fr randerer@grenoble 'find logs -maxdepth 1 -type f -delete'
ssh -J randerer@access.grid5000.fr randerer@grenoble 'rm logs.zip'


echo "Unzipping logs.zip ..."
unzip -o "${LOGS_ZIP}" -d "${LOGS_DATA_DIR}"

# Extract OAR job IDs from downloaded *_oarsub_id.log files and fetch scheduler logs.
for oarsub_log in "${EXTRACTED_LOGS_DIR}"/*_oarsub_id.log; do
    [ -f "$oarsub_log" ] || continue

    basename="${oarsub_log##${EXTRACTED_LOGS_DIR}/}"
    run_tag="${basename%_oarsub_id.log}"

    job_id=$(sed -n 's/^OAR_JOB_ID=\([0-9][0-9]*\)$/\1/p' "$oarsub_log" | head -n 1)
    [ -n "$job_id" ] || continue

    scp "randerer@access.grid5000.fr:grenoble/OAR.${job_id}.stdout" "${LOGS_DATA_DIR}/${run_tag}_OAR.${job_id}.stdout" || true
    scp "randerer@access.grid5000.fr:grenoble/OAR.${job_id}.stderr" "${LOGS_DATA_DIR}/${run_tag}_OAR.${job_id}.stderr" || true
done

echo "Moving files from logs/logs to logs ..."
if [[ -d "${EXTRACTED_LOGS_DIR}" ]]; then
  while IFS= read -r -d '' src_file; do
    mv -n "${src_file}" "${LOGS_DATA_DIR}/"
  done < <(find "${EXTRACTED_LOGS_DIR}" -maxdepth 1 -type f -print0)
fi

echo "Deleting logs/logs and logs.zip ..."
rm -rf "${EXTRACTED_LOGS_DIR}"
rm -f "${LOGS_ZIP}"


echo "Unzipping results.zip ..."
unzip -o "${RESULTS_ZIP}" -d "${RESULT_DATA_DIR}"

echo "Moving top-level single_broker_results files (skip existing) ..."
if [[ -d "${RESULTS_ROOT}" ]]; then
  while IFS= read -r -d '' src_file; do
    mv -n "${src_file}" "${RESULT_DATA_DIR}/"
  done < <(find "${RESULTS_ROOT}" -maxdepth 1 -type f -print0)
fi

echo "Moving experiments files (skip existing) ..."
if [[ -d "${EXPERIMENTS_SRC}" ]]; then
  while IFS= read -r -d '' src_file; do
    mv -n "${src_file}" "${EXPERIMENTS_DST}/"
  done < <(find "${EXPERIMENTS_SRC}" -maxdepth 1 -type f -print0)
fi

echo "Deleting results.zip ..."
rm -f "${RESULTS_ZIP}"

echo "Done."
