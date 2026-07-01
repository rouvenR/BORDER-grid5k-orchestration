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

if [ -z "$TIMESTAMP" ]; then
    echo "Missing required argument: --timestamp"
    exit 2
fi

BASE_LOAD_CPU=0
BASE_LOAD_RAM=0

mkdir -p logs
ERROR_LOG_FILE="logs/${TIMESTAMP}_errors.txt"

CHECK_LOG_OUTPUT=$(python3 check_logs_for_errors.py --timestamp "$TIMESTAMP" --log true 2>&1)
CHECK_LOG_EXIT_CODE=$?

if [ "$CHECK_LOG_EXIT_CODE" -eq 1 ]; then
    printf "%s\n" "$CHECK_LOG_OUTPUT" > "$ERROR_LOG_FILE"
    echo "Errors found for timestamp $TIMESTAMP. See $ERROR_LOG_FILE for details."
elif [ "$CHECK_LOG_EXIT_CODE" -ne 0 ]; then
    printf "%s\n" "$CHECK_LOG_OUTPUT" >&2
    exit "$CHECK_LOG_EXIT_CODE"
fi

python3 ./border-data-pipeline/move_single_broker_results.py
python3 ./border-data-pipeline/combine_split_subscriber_files.py --timestamp "$TIMESTAMP"
python3 ./border-data-pipeline/visualize_individual_experiment.py --timestamp "$TIMESTAMP"
python3 ./border-data-pipeline/compute_throughput_metrics.py --timestamp "$TIMESTAMP" --broker-name jorammq

if [ -z "$VARIABLE_COLUMN" ]; then
    echo "Skipping regression training since --variable-column is not set"
else
    python3 ./border-data-pipeline/train_throughput_regression.py --timestamp "$TIMESTAMP" --variable-column "$VARIABLE_COLUMN" --target cpu_mean_consumption --base-load "$BASE_LOAD_CPU"
    python3 ./border-data-pipeline/train_throughput_regression.py --timestamp "$TIMESTAMP" --variable-column "$VARIABLE_COLUMN" --target ram_mean_consumption --base-load "$BASE_LOAD_RAM"
    python3 ./border-data-pipeline/train_throughput_regression.py --timestamp "$TIMESTAMP" --variable-column "$VARIABLE_COLUMN" --target received_throughput_mean --base-load "$BASE_LOAD_CPU"
    python3 ./border-data-pipeline/train_throughput_regression.py --timestamp "$TIMESTAMP" --variable-column "$VARIABLE_COLUMN" --target cpu_factor_compared_to_min --base-load "$BASE_LOAD_CPU"
    python3 ./border-data-pipeline/train_throughput_regression.py --timestamp "$TIMESTAMP" --variable-column "$VARIABLE_COLUMN" --target ram_factor_compared_to_min --base-load "$BASE_LOAD_RAM"
fi
