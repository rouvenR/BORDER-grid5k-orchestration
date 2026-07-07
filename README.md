# Prerequesites
- [SSH connection to G5K](https://www.grid5000.fr/w/Getting_Started#Connecting_for_the_first_time)
- [SSH connection to Github](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

# Setup Code
This section contains instructions for initial setup and how to apply code updates.

## Download related projects
```bash
./download_related_projects.sh
```

> For JoramMQ deployment, the according JoramMQ zip has to be added to ./jorammq-deployment/jorammq-mqtt-trial-1.22.0-SNAPSHOT.zip (search and replace in project for other versions)


## Note on G5K Username
Please search for "randerer" across the whole code basis and replace it with your personal G5K user name. This is with the exception of `wget "http://public.grenoble.grid5000.fr/~randerer/environment_image_border_v2.tar.zst"`.

## Initialize G5K
Run the following command once. This uploads all relevant code to G5K and created required folders and permissions.

```bash
./setup_g5k.sh
```

## Sync from local
When working on this project, the easiest way to apply changes is to work on the projects locally, then use the following script to upload them to the G5K network file system. 

```bash
./g5k_utils/upload_relevant_code_to_g5k.sh
```

## G5K Custom Environment
A G5K custom environment exists that contains all the required installations (e.g. Docker) for experiment efficiency and reproducability.

### Option 1 (default): Reuse Custom Environment
The root folder of your home directory on G5K must contain the `border-custom-environment.yaml` and `environment_image_border_v2.tar.zst`. The former is part of this repository and automatically uploaded. The latter has to be copied from the public repository using the following command:

> NOTE: The URL should contain the original username r\_anderer (without the \_), not your personal one. 

```bash
./connect_to_g5k_frontend.sh
# On your G5K home directory
wget "http://public.grenoble.grid5000.fr/~randerer/environment_image_border_v2.tar.zst"
```

### Option 2: Rebuild / Update Custom Environment
Follow the [G5K environment creation guide](https://www.grid5000.fr/w/Environment_creation). The existing environment was built using the script shown below on the deployment node. Adjust it to your updates to make the process reproducable.

```bash
# On G5K /home/randerer
border_setup_kadeploy.sh
```

# The Projects
This section gives a brief overview of all sub-projects (this one and the ones added by `./download_related_projects.sh`).

## This Project
This project contains the skeleton, that contains all the orchestration that is required to upload, launch and use the other projects with G5K.

## ./BORDER
[Github](https://github.com/rouvenR/BORDER/tree/g5k-launch)

This project contains the extensions of the BORDER framework, which is used as foundation for benchmarking the broker under test and create the MQTT and Hardware traces.

## ./jorammq-deployment
[Github](https://github.com/rouvenR/jorammq-deployment/tree/final-state-thesis)

This project contains the files required to build an image of the JoramMQ container and save the image locally.

## ./mzbench-docker-deployment
[Github](https://github.com/rouvenR/mzbench-docker-deployment/tree/final-state-thesis)

This project contains the files required to build an image of the mzbench container and save the image locally. This image is used as publisher container in the extended BORDER framework.

## ./vmq_mzbench
[Github](https://github.com/rouvenR/vmq_mzbench/tree/final-state-thesis)

This project contains the extensions of the vmq_mzbench library. The original library adds an MQTT worker to MZBench. The extension contains adjustments to the BORDER message format (e.g. to include sender timestamp in the message payload) and the new scenarios (e.g. for parallel QoS levels and the designed industry scenarios).

## ./border-data-pipeline
[Github](https://github.com/rouvenR/border-data-pipeline/tree/final-state-thesis)

This project contains the scripts used to analyse and process the traces created by the extended BORDER framework as well as to train the prediction models.


# Running Application
This section describes different flows of running the application. All of the flows use a default experiment configuration. To customize the experiments, refer to "Execution Flow -> ./BORDER/launch_experiments.sh" in the next section.

## Fully Automated Flow
In this flow, experiments are scheduled at night and a dedicated node per experiment set is scheduled at 04:30 in the morning to run the data analysis pipeline. Results can be retrieved from "home/randerer/processed_results" folder on G5K.

```bash
./connect_to_g5k_frontend.sh
./launch_experiments.sh --night --analyze-data
```

To download the results the next day, you can run the following command:

```bash
scp -r  randerer@access.grid5000.fr:grenoble/processed_results/ .
```

## Automated Experiments with manual data analysis
This flow executes the configured experiments directly. After waiting for the results, data analysis is executed on G5K frontend.

```bash
./connect_to_g5k_frontend.sh
./launch_experiments.sh

# Wait for experiments to finish (check with "oarstat -u" until there is no active nodes)

./data_pipeline.sh --timestamp <TIMESTAMP> # Find timestamp in logs or under ./results/single_broker_results/
```

To download the results, you can use the following script:

```bash
./g5k_utils/get_result_artefacts.sh
```

## Automated Experiments with local data analysis
In this flow, experiments are started directly, but instead of the data analysis running on G5K, the results are first downloaded to the local machine. While this is slightly more inefficient and takes up space on your local machine, inspection of results and visualisations may be easier.

```bash
./connect_to_g5k_frontend.sh
./launch_experiments.sh
exit

# Wait for experiments to finish

./g5k_utils/get_result_data_from_zip.sh
./data_pipeline.sh --timestamp <TIMESTAMP> # Find timestamp in logs or under s ./border-data-pipeline/inputs/result_data
```

## Fully manual flow
In this flow, a node is launched manually as well as the experiment and launch of clients after connecting to the node. This is helpful for debugging when making changes to any of the components.

```bash
oarsub -I -t deploy
kadeploy3 -a border-custom-environment.yaml -o /tmp/manual_launch_n.txt
ssh MACHINE_ID

# Set --run-tests to "true" for automated tests 
sudo ./border_setup_launch.sh --run-tag syntax_test --clients-qos0 1 --clients-qos1 250 --clients-qos2 1 --delay-qos0 12 --delay-qos1 14 --delay-qos2 12 --messages-qos0 0 --messages-qos1 75000 --messages-qos2 0 --size-qos0 100 --size-qos1 100 --size-qos2 100 --cpu 2 --ram-limit 1g --broker-type JORAMMQ --run-tests false

# Wait for framework to launch

sudo ./start_clients.sh --run-tag 20260515234745_3__C01_D012_M00_S0100_C1250_D14_M175000_S1100_C21_D212_M20_S2100_CPU2_RAM1g --clients-qos0 1 --clients-qos1 250 --clients-qos2 1 --delay-qos0 12 --delay-qos1 14 --delay-qos2 12 --messages-qos0 0 --messages-qos1 75000 --messages-qos2 0 --size-qos0 100 --size-qos1 100 --size-qos2 100 --brokers 1 --name /home/randerer/results/single_broker_results

# Wait for experiments to finish

./data_pipeline.sh --timestamp <TIMESTAMP> # Find timestamp in logs or under s ./border-data-pipeline/inputs/result_data

```

## Next steps
All of the flows explained above will create the following artefacts. Depending on the flow executed, they are either on your G5K home directory or on your local machine. Refer to "Data Formats" for more information on the raw data and metrics.
+ raw MQTT and hardware traces (./border-data-pipeline/inputs/result_data)
+ metrics files (./border-data-pipeline/inputs/training_data)
+ experiment visualisations (./border-data-pipeline/outputs/plots/raw)
+ regression plots (./border-data-pipeline/outputs/plots/regressions)
+ regression json files (./border-data-pipeline/outputs/plots/regressions)

The metrics files and the regression json files can be used to train the machine learning models and additive model respectively. Please follow the according sections under "Execution Flow" below to train the model. This step is not included in the automation pipeline because it is usually desired to run multiple experiment sets before creating a prediction model (e.g. combining multiple regression json files for different variables for the additive model or combining multiple metrics files into one for the ML models).

# Execution Flow
This section describes the execution flow and all of its individual components. Note that for normal execution, you don't need to invoke these manually. They are automatically run when using the commands described above under "Running Application".

The automated flow has two layers:

1. The experiment orchestration on Grid5000, which reserves nodes, deploys the environment, launches BORDER, and collects raw results.
2. The analysis layer, which converts raw logs and packet traces into metrics and optionally trains prediction models.

### 1. `./BORDER/launch_experiments.sh`

This is the entry point for batch execution.

- Defines the experiment matrix in `CONFIGS`. Each row contains the per-QoS client count, delay, message count, message size, CPU, RAM limit, scenario, and connect rate.
- Builds one `run_tag` per configuration. That timestamp-based tag is the primary identifier used throughout the whole pipeline.
- Submits one `oarsub` job per configuration and runs `kadeploy3` before starting the actual BORDER launch.
- Calls `./launch_border_via_ssh.sh` inside the reserved job with all resolved parameters.
- Supports `--night` to add `-t night` to the experiment reservation.
- Supports `--analyze-data` to schedule `./automated_data_pipeline.sh` for the same `BASE_START_TIME` on the next day at `04:30:00`.
- Uses `VARIABLE_COLUMN` to decide which independent variable should be used when the automated analysis step trains regressions. If not set, it defaults to `message_size_qos1`.

Typical use:

```bash
# Experiments & automated analysis at night
./BORDER/launch_experiments.sh --night --analyze-data

# Immediate execution of experiments without automated analysis
./BORDER/launch_experiments.sh
```

### 2. `./BORDER/launch_border_via_ssh.sh`

This script bridges the Grid5000 reservation with the target node.

- Validates the required experiment arguments.
- Reads the deployed machine name from `/tmp/<RUN_TAG>.txt`, which is produced by `kadeploy3`.
- Opens an SSH session to keep the allocated node alive.
- Starts `sudo ./border_setup_launch.sh ...` on the deployed host with the complete experiment configuration.

Its role is transport and delegation: it does not create the topology itself, it forwards the resolved configuration to the machine that will run the benchmark.

### 3. `./BORDER/border_setup_launch.sh`

This script prepares the remote execution environment and coordinates the experiment lifetime.

- Parses the complete experiment configuration, including `--broker-type`, `--cpu`, `--ram-limit`, `--scenario`, and `--run-tests`.
- Adjusts Docker defaults so broker containers can use a sufficiently high `nofile` limit.
- Waits for the cluster launch window and then schedules `sudo ./start_clients.sh ...` in the background.
- Starts the actual broker topology by invoking `sudo ../venv/bin/python3 flexible_router.py --brokers 1 ...`.
- Acts as the runtime coordinator on the remote node: environment setup first, topology start second, client load generation third.

This is the step where the abstract experiment configuration becomes a concrete runnable benchmark on the deployed machine.

### 4. `./BORDER/flexible_router.py`

This Python program builds the Containernet topology and starts the broker containers.

- Creates the Linux routers, switches, Docker containers, and per-broker networks used by BORDER.
- Supports multiple broker types such as `JORAMMQ`, `RABBITMQ`, `EMQX`, `VERNEMQ`, `HIVEMQ`, and `MOSQUITTO`.
- Applies CPU and RAM limits to broker containers.
- Configures per-link delays and networking between broker, publisher, and subscriber nodes.
- Loads local broker images where required, for example from the JoramMQ image archive.

In practice, this is the stage that instantiates the benchmark environment the clients will later interact with.

### 5. `./BORDER/start_clients.sh`

This script generates the experiment traffic and records the raw measurement artefacts.

- Validates the per-QoS client, message, delay, and size parameters.
- Starts `docker stats` logging and `tcpdump` capture files before traffic generation begins.
- Launches the subscriber workload inside the subscriber containers.
- Calculates total message counts and derives scenario-specific subscriber concurrency.
- Handles scenario-specific subscription layouts, including shared subscriptions and request/response style traffic.
- Writes logs and packet captures into the configured results directory, typically `/home/randerer/results/single_broker_results`.

The output of this step is the raw data later consumed by the analysis pipeline: container stats, subscriber logs, experiment logs, and `.pcap` traces.

### 6. `./data_pipeline.sh`

This is the post-processing entry point once result are available. Can be run on G5K node, frontend or locally after running `./g5k_utils/get_result_data_from_zip.sh`

- Accepts `--timestamp` to select one run family.
- Optionally accepts `--variable-column` to decide whether regression training should be included during this pass.
- Runs `python3 check_logs_for_errors.py` first and stores any detected issues in `logs/<TIMESTAMP>_errors.txt`.
- Moves and normalizes raw result folders with `move_single_broker_results.py`.
- Merges subscriber output files with `combine_split_subscriber_files.py`.
- Creates visual inspection plots with `visualize_individual_experiment.py`.
- Computes the derived metrics CSV with `compute_throughput_metrics.py`.
- If `--variable-column` is set, trains several single-target regressions with `train_throughput_regression.py` for CPU, RAM, throughput, and normalized factor targets.

This is the point where raw benchmark artefacts become structured training data.

### 7. `./border-data-pipeline/train_svm_regression.py`

This is a separate model-training step that operates on an already prepared metrics CSV.

- Reads `inputs/training_data/<TIMESTAMP>_metrics.csv`.
- Trains SVM regressors for throughput, CPU, and RAM targets.
- Supports cross-validation only, or holdout validation via `--validate-against`.
- Can optionally tune hyperparameters with `--random-search-iterations`.
- Can include or exclude capacity-limited runs with `--include-capacity-limited`.

Use this when you want a second modelling pass beyond the automatic per-target regressions triggered by `data_pipeline.sh`.

### 8. `./border-data-pipeline/train_random_forest.py`

This is the random-forest counterpart to the SVM training script.

- Uses the same metrics input convention as the SVM script.
- Trains random-forest regressors for throughput, CPU, and RAM targets.
- Supports optional holdout validation with `--validate-against`.
- Supports optional randomized hyperparameter search with `--random-search-iterations`.
- Stores trained models and evaluation output in the random-forest regression output directory.

Use this when you want a tree-based baseline or a model family that captures non-linear interactions differently from the SVM pipeline.

### 9. `./border-data-pipeline/predict_additive_model.py`

This script combines multiple regression component JSON files and evaluates their additive prediction against a validation metrics CSV.

- Loads all component JSONs that match `--model-dir`
- Requires `--validate-against` to compare predictions with ground truth metrics.
- Supports `--base-load` and `--include-capacity-limited` for evaluation behavior.

Important preparation step:

- The regression JSON outputs that should be combined must be collected in one dedicated folder (for example, one folder for CPU target components and one for RAM target components).
- Move or copy the selected JSON files from the regression output directories into that folder before running the additive model.
- Point `--model-dir` to that folder using a glob, for example `./border-data-pipeline/outputs/regressions/joram/ram/*.json`.

As of now, the resource translation factors have to be added manually to these dictionaries in `./border-data-pipeline/predict_additive_model.py`. They have to be retrieved by running the same configuration of experiments on different CPU and RAM availabilities.
```python
CPU_TRANSLATION = {
    "2": 1.0,
    "4": 0.93,
    "8": 0.7,
    "16": 0.58,
}

RAM_TRANSLATION = {
    "0.5": 1.5,
    "1": 1.0,
    "2": 0.64,
    "4": 0.48,
    "8": 0.22,
}
```

Typical use:

```bash
python3 ./border-data-pipeline/predict_additive_model.py \
	--model-dir './border-data-pipeline/outputs/regressions/joram/ram/*.json' \
	--validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_scenario_1_adjusted_throughput.csv \
	--base-load 16.65 \
	--include-capacity-limited
```

### Summary of Inputs and Outputs

1. `launch_experiments.sh` consumes experiment configurations and produces Grid5000 jobs plus `run_tag` identifiers.
2. `launch_border_via_ssh.sh` consumes the reservation output and starts the remote orchestration step.
3. `border_setup_launch.sh` consumes the experiment parameters and produces a running BORDER topology plus a scheduled client workload.
4. `flexible_router.py` consumes broker/resource settings and produces the live Containernet broker environment.
5. `start_clients.sh` consumes the topology and produces raw logs, stats, and packet captures.
6. `data_pipeline.sh` consumes the raw artefacts and produces metrics, plots, and optional single-target regressions.
7. `train_svm_regression.py` consumes the metrics CSV and produces SVM models and evaluation results.
8. `train_random_forest.py` consumes the metrics CSV and produces random-forest models and evaluation results.
9. `predict_additive_model.py` consumes a prepared folder of selected regression JSON components plus a validation metrics CSV, and produces additive-model evaluation metrics (MAE, RMSE, MaxError).

For step 9 specifically, collect the JSON outputs you want to combine into a dedicated input folder (or use a dedicated output subfolder), then pass that folder as a glob via `--model-dir`.


# Data Formats

## MQTT Connection Traces
> ./border-data-pipeline/inputs/result_data/experiments/conn_*

| broker | client | conn | connack |
| --- | --- | ---: | ---: |
| 10.0.0.100 | b'subThread-1-efexpz' | 1779919122188 | 1779919122345 |

## MQTT E2E Traces 
> ./border-data-pipeline/inputs/result_data/experiments/e2e_*

| receiver_brk | receiver_id | src_brk | client_num | sent | msg_id | received | qos |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 10.0.0.100 | b'subThread-1-rdokdj' | 0 | 1 | 1780927657309 | 0 | 1780927657342 | 1 |

## Hardware Traces
> ./border-data-pipeline/inputs/result_data/*_stats.txt

| timestamp | container_id | name | cpu_pct | mem_usage_limit | mem_pct | net_io |
| --- | --- | --- | ---: | --- | ---: | --- |
| "2026-05-27-22:09:41" | b632688b8c54e3e5fb6ed7f772d67e0125c60a4d55e6c42ac931daeaab8e6f34 | mn.pub0 | 0.00% | 1.746MiB / 187.5GiB | 0.00% | 936B / 126B |

## Metrics
> ./border-data-pipeline/inputs/training_data

| run_tag | number_of_clients_qos0 | delay_qos0 | number_of_messages_qos0 | message_size_qos0 | number_of_clients_qos1 | delay_qos1 | number_of_messages_qos1 | message_size_qos1 | number_of_clients_qos2 | delay_qos2 | number_of_messages_qos2 | message_size_qos2 | cpu | ram | active_window_start | active_window_end | active_window_seconds | throughput_window_bins | sent_throughput_mean | sent_throughput_median | received_throughput_mean | received_throughput_completion_percentage | received_throughput_median | message_loss | malformed_e2e_rows_skipped | cpu_mean_consumption | ram_mean_consumption | cpu_reached_maximum_capacity | ram_reached_maximum_capacity | incoming_throughput_qos0 | incoming_throughput_qos1 | incoming_throughput_qos2 | cpu_factor_compared_to_min | ram_factor_compared_to_min | throughput_reached_maximum_capacity | message_loss_threshold_exceeded |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- | --- | ---: | ---: | ---: | ---: | ---: | --- | --- |
| 20260615001353_0__C050_D02500_M0120_S01000_C1100_D1114_M12625_S1500_C250_D2200_M21500_S2500_CPU16_RAM8g | 50 | 2500 | 120 | 1000 | 100 | 114 | 2625 | 500 | 50 | 200 | 1500 | 500 | 16 | 8g | 1781475830000 | 1781476132000 | 303.0 | 303 | 5676.534653465346 | 5730.0 | 5676.534653465346 | 0.9900932535113975 | 5733.0 | -2490.0 | 0 | 28.814225045787545 | 4.765787545787545 | false | false | 100.0 | 4383.333333333334 | 1250.0 | 31.41557365388005 | 1.0 | False | False |


# Grid5000 Important Commands
```bash
ssh randerer@access.grid5000.fr
ssh grenoble

oarstat -u # <- only own jobs
oarsub -C 2651943 # <- connect to existing node

oarwalltime 2651943 +2:00 # <- extend time

oarsub -l host=1/core=2,walltime=0:03:00 -I
oarstat
oardel 12345 # <- delete job

oarsub -l nodes=2 -I # <- connects to the first node, load has to be distributed manually (cross connection possible with oarsh)
```

# Debugging

## Connect to node started by automation
When nodes are launched using the automated pipeline, their ID is stored in a temporary file. If you want to connect to one for debugging reasons, check under "/tmp/\<TIMESTAMP\>_\<INDEX\>__\<RUNTAG\>.txt". For example:

```bash
cat /tmp/20260629154136_0__C01_D020_M00_S0100_C1100_D1500_M1600_S1100_C21_D220_M20_S2100_CPU2_RAM1g.txt
```

## Read mqtt messages
```bash
sudo apt install mosquitto-clients -y
sudo mosquitto_sub -v -t "test" > mylog.txt
```

## Mininet Cleanup
```bash
sudo-g5k env "PATH=$PATH" mn -c
```

## Remove all Docker containers
```bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```