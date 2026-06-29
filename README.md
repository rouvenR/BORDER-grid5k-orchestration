
# Setup Code


## Download related projects
```bash
./download_related_projects.sh
```

> For JoramMQ deployment, the according JoramMQ zip has to be added to ./jorammq-deployment/jorammq-mqtt-trial-1.22.0-SNAPSHOT.zip (search and replace in project for other versions)


## Note on G5K Username
Please search for "randerer" across the whole code basis and replace it with your personal G5K user name

## Initialize G5K
Run the following command once to up

```bash
./setup_g5k.sh
```

## Sync from local
When working on this project, the easiest way to apply changes is to work on the projects locally, then use the following script to upload them to the G5K network file system. 

```bash
./g5k_utils/upload_relevant_code_to_g5k.sh
```


# The Projects
This section gives a brief overview of all sub-projects (this one and the ones added by `./download_related_projects.sh`).

## This Project
This project contains the skeleton, that contains all the orchestration that is required to upload, launch and use the other projects with G5K.

## ./BORDER
This project contains the extensions of the BORDER framework, which is used as foundation for benchmarking the broker under test and create the MQTT and Hardware traces.

## ./jorammq-deployment
This project contains the files required to build an image of the JoramMQ container and save the image locally.

## ./mzbench-docker-deployment
This project contains the files required to build an image of the mzbench container and save the image locally. This image is used as publisher container in the extended BORDER framework.

## ./vmq_mzbench
This project contains the extensions of the vmq_mzbench library. The original library adds an MQTT worker to MZBench. The extension contains adjustments to the BORDER message format (e.g. to include sender timestamp in the message payload) and the new scenarios (e.g. for parallel QoS levels and the designed industry scenarios).

## ./border-data-pipeline
This project contains the scripts used to analyse and process the traces created by the extended BORDER framework as well as to train the prediction models.


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

# Running individual Applications

## JoramMQ Setup

### Copy (once)
```bash
scp ./jorammq-mqtt-trial-1.21.0-SNAPSHOT.zip randerer@access.grid5000.fr:grenoble/jorammq/
```

### Start
```bash
ssh randerer@access.grid5000.fr
ssh grenoble
oarsub -I
cp -r ./jorammq/jorammq-mqtt-1.21.0-SNAPSHOT ./tmp/
./tmp/jorammq-mqtt-1.21.0-SNAPSHOT/bin/jorammq-server
```

## BORDER

### Using Kadeploy

```bash
oarsub -I -t deploy
kadeploy3 -a border-custom-environment.yaml -o /tmp/manual_launch_n.txt
ssh MACHINE_ID

# Set --run-tests to "true" for automated tests 
sudo ./border_setup_launch.sh --run-tag syntax_test --clients-qos0 1 --clients-qos1 250 --clients-qos2 1 --delay-qos0 12 --delay-qos1 14 --delay-qos2 12 --messages-qos0 0 --messages-qos1 75000 --messages-qos2 0 --size-qos0 100 --size-qos1 100 --size-qos2 100 --cpu 2 --ram-limit 1g --broker-type JORAMMQ --run-tests false

sudo ./start_clients.sh --run-tag 20260515234745_3__C01_D012_M00_S0100_C1250_D14_M175000_S1100_C21_D212_M20_S2100_CPU2_RAM1g --clients-qos0 1 --clients-qos1 250 --clients-qos2 1 --delay-qos0 12 --delay-qos1 14 --delay-qos2 12 --messages-qos0 0 --messages-qos1 75000 --messages-qos2 0 --size-qos0 100 --size-qos1 100 --size-qos2 100 --brokers 1 --name /home/randerer/results/single_broker_results

```


### Automation
```bash
# ssh randerer@access.grid5000.fr
# ssh grenoble
ssh -J randerer@access.grid5000.fr randerer@grenoble

oarsub -l walltime=1:00:00 "sudo-g5k ./border_setup.sh --start-time TEST_TIME_STAMP5 & sleep infinity"

# Manual
# sudo-g5k ./border_setup.sh --run-tag manual_launch_250_clients --clients 20 --delay 1 --messages 150 --qos 0 --size 100 --cpu 2 --ram-limit 1g & sleep infinity
# sudo ./border_setup_launch.sh --run-tag manual_launch_250_clients --clients 20 --delay 1 --messages 150 --qos 0 --size 100 --cpu 2 --ram-limit 1g
# sudo-g5k ./start_clients.sh --run-tag manual_launch --clients 1 --delay 1 --messages 10 --qos 0 --size 100 --brokers 1 & sleep infinity

oarsub -I # "-l host=1/core=4" does not work because all cores need to be reserved for docker installation

cd ..
cd ..
sudo-g5k home/randerer/border_setup.sh
```

# Execution Flow

## Automated

1. launch_experiments.sh
    - includes configuration, either manual (e.g. step-sized) or using `./border-data-pipeline/categorial_latin_hypercube_sampling.py`
2. launch_border_via_ssh.sh
3. border_setup_launch.sh
4. flexible_router.py
5. start_clients.sh
6. data_pipeline.sh
    1. combine_split_subscriber_files.py
    2. visualize.py
    3. compute_throughput_metrics.py
    4. train_throughput_regression.py
7. train_svm_regression.py
8. train_random_forest.py

## Manual
TODO


# Results
The following scripts downloads all logs and results from the G5K network file system and unpacks them locally for further analysis.
```bash
./g5k_utils/get_result_data_from_zip.sh
```


# Benchmarks

## Perf
> NOTE (local change): To do this, simply modify the "jorammq-mqtt-1.21.0-SNAPSHOT/conf/jorammq.xml" file. Set "com.scalagent.jorammq.mqtt.serverMaxPendingConnections" value to 1000

> NOTE (local change): To do this, simply modify the "jorammq-mqtt-1.21.0-SNAPSHOT/conf/jorammq.xml" file. Increase "com.scalagent.jorammq.mqtt.serverConnectionTimeout" value


```
./internal_benchmarking/jorammq-mqtt-perf-1.21.0-SNAPSHOT/bin/multismartphone
```

# ML Pipeline
```bash
# 20260606162745 20260607220913
./data_pipeline.sh --timestamp 20260609161555 --variable-column connection_rts
./data_pipeline.sh --timestamp 20260611210250 --variable-column message_size_qos0
./data_pipeline.sh --timestamp 20260611210417 --variable-column message_size_qos2
./data_pipeline.sh --timestamp 20260615001353



#BASE_LOAD_CPU=12
#BASE_LOAD_RAM=6
BASE_LOAD_CPU=5.28
BASE_LOAD_RAM=16.65
python3 ./border-data-pipeline/predict_additive_model.py --model-dir './border-data-pipeline/outputs/regressions/joram/ram/*.json' --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_scenario_1_adjusted_throughput.csv --base-load $BASE_LOAD_RAM --include-capacity-limited

BASE_LOAD_CPU=1
python3 ./border-data-pipeline/predict_additive_model.py --model-dir './border-data-pipeline/outputs/regressions/joram/cpu/*.json' --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_joram_msg_size_adjusted.csv --base-load $BASE_LOAD_CPU

BASE_LOAD_RAM=20
python3 ./border-data-pipeline/predict_additive_model.py --model-dir './border-data-pipeline/outputs/regressions/joram/ram/*.json' --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_joram_msg_size_adjusted.csv --base-load $BASE_LOAD_RAM 

BASE_LOAD_CPU=1
python3 ./border-data-pipeline/predict_additive_model.py --model-dir './border-data-pipeline/outputs/regressions/joram/cpu/*.json' --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_joram_msg_size_adjusted.csv --base-load $BASE_LOAD_CPU --include-capacity-limited

BASE_LOAD_RAM=20
python3 ./border-data-pipeline/predict_additive_model.py --model-dir './border-data-pipeline/outputs/regressions/joram/ram/*.json' --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_joram_msg_size_adjusted.csv --base-load $BASE_LOAD_RAM --include-capacity-limited

BASE_LOAD_CPU=2
python3 ./border-data-pipeline/predict_additive_model.py --model-dir './border-data-pipeline/outputs/regressions/joram/ram/*.json' --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_scenario_2.csv --base-load $BASE_LOAD_RAM --include-capacity-limited

validation_data_metrics_scenario_1_adjusted_throughput
validation_data_metrics_scenario_2_adjusted_message_size

python3 ./border-data-pipeline/train_svm_regression.py --timestamp combined_data_3 --include-capacity-limited --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_scenario_2_adjusted_message_size.csv --random-search-iterations 30

python3 ./border-data-pipeline/train_svm_regression.py --timestamp combined_data_2 --validate-against ./border-data-pipeline/inputs/training_data/combined_data_all_randomized_metrics.csv --include-capacity-limited

python3 ./border-data-pipeline/train_random_forest.py --timestamp combined_data_3 --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_scenario_1_adjusted_throughput.csv --include-capacity-limited

python3 ./border-data-pipeline/train_svm_regression.py --timestamp combined_data_2 --include-capacity-limited --random-search-iterations 30

python3 ./border-data-pipeline/train_svm_regression.py --timestamp combined_data_2 --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_joram_msg_size_adjusted.csv

python3 ./border-data-pipeline/train_svm_regression.py --timestamp combined_data_2 --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_scenario_1.csv --include-capacity-limited

python3 ./border-data-pipeline/train_svm_regression.py --timestamp combined_data_2 --validate-against ./border-data-pipeline/inputs/training_data/combined_data_all_randomized_metrics.csv --include-capacity-limited



python3 ./border-data-pipeline/train_svm_regression.py --timestamp combined_data_2 --validate-against ./border-data-pipeline/inputs/training_data/validation_data_metrics_scenario_1_adjusted_throughput.csv --include-capacity-limited
```

```bash
python3 categorial_latin_hypercube_sampling.py --samples 20 --clients "2,5,10,20,30" --throughput "100,250,500,1000,2000" --qos "0,1,2" --size "100,500,1000,5000,10000" --cpu "2,4,8,16"

python3 ./border-data-pipeline/categorial_latin_hypercube_sampling.py --samples 50 --clients_qos0 "50,100,150" --throughput_qos0 "100,4375,8750,13125,17500" --size_qos0 "100,250,500,750,1000" --clients_qos1 "50,100,150" --throughput_qos1 "100,4375,8750,13125,17500" --size_qos1 "100,250,500,750,1000" --clients_qos2 "50,100,150" --throughput_qos2 "100,1250,2500,3750,5000" --size_qos2 "100,250,500,750,1000" --cpu "2,4,8,16"
```

# Debugging

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


# Other Tools

## JoramMQ (local)

> NOTE (local change): To do this, simply modify the "conf/jorammq.xml" file. Lines 58-59 contain the definition of the property "Transaction.LevelDBRepository.useJavaImpl," which is commented out;

```bash
export JMX_PORT=3333 # for profiling
./jorammq-mqtt-1.21.0-SNAPSHOT/bin/jorammq-server
```

### Docker
```bash
docker run --name jorammq -p 1883:1883/tcp -p 18090:18090/tcp joram_1.21.0:latest
```


## mqtttest
```bash
java -jar jorammq-mqtt-1.21.0-SNAPSHOT/lib/testmqtthivev5.jar help

java -Dthroughput=100000 -jar jorammq-mqtt-1.21.0-SNAPSHOT/lib/testmqtthivev5.jar 1
```

## Java UI
```bash
export PATH_TO_FX=/Users/z003s17d/Projects/Uni/MasterThesis/javafx-sdk-21.0.10_aarch/lib
java --module-path $PATH_TO_FX --add-modules javafx.controls,javafx.fxml -cp "jaxb-api.jar:jaxb-impl.jar:jaxb-core.jar:activation.jar:mqtt-spy-0.5.4-jar-with-dependencies.jar" pl.baczkowicz.mqttspy.Main
```

## Python Script
```
source paho.mqtt.python/paho_venv/bin/activate
python3 paho.mqtt.python/src/main.py
```