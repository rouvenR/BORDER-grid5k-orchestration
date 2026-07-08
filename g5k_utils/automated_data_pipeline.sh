#!/usr/bin/env bash


usage() {
    echo "Usage: $0 --timestamp <TIME_STAMP> --variable-column <VARIABLE_COLUMN>"
    exit 2
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --timestamp)
            if [ -z "$2" ] || [ "${2#-}" != "$2" ]; then
                echo "Missing value for --timestamp"
                usage
            fi
            TIMESTAMP="$2"
            shift 2
            ;;
        --variable-column)
            if [ -z "$2" ] || [ "${2#-}" != "$2" ]; then
                echo "Missing value for --variable-column"
                usage
            fi
            VARIABLE_COLUMN="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            usage
            ;;
    esac
done

zip -r results_${TIMESTAMP}.zip results/
cd /border-project/

mkdir -p border-data-pipeline
cp /home/randerer/border-data-pipeline/* border-data-pipeline
cp /home/randerer/data_pipeline.sh data_pipeline.sh
cp /home/randerer/check_logs_for_errors.py check_logs_for_errors.py
cp /home/randerer/results_${TIMESTAMP}.zip results.zip
unzip results.zip
cd border-data-pipeline
mkdir -p inputs
mkdir -p outputs
cd inputs
mkdir -p result_data
cd result_data
cp -r /border-project/results/single_broker_results/* ./
cd experiments
cp -r /border-project/results/single_broker_results/experiments/* ./

cd /border-project

python3 -m venv .
source bin/activate
pip install matplotlib

./data_pipeline.sh --timestamp "$TIMESTAMP" --variable-column "$VARIABLE_COLUMN"

cd border-data-pipeline/
zip -r "${TIMESTAMP}_${VARIABLE_COLUMN}_output.zip" outputs/
cp "${TIMESTAMP}_${VARIABLE_COLUMN}_output.zip" /home/randerer/processed_results/