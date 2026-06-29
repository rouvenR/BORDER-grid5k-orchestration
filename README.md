
# Setup Code


## Download related projects
```bash
./download_related_projects.sh
```

> For JoramMQ deployment, the according JoramMQ zip has to be added to ./jorammq-deployment/jorammq-mqtt-trial-1.22.0-SNAPSHOT.zip


## Note on G5K Username
Please search for "randerer" across the whole code basis and replace it with your personal G5K user name

# Running Applications

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

# Grid5000

## SSH Access
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


## BORDER Setup

### Copy (once)
```bash
ssh randerer@access.grid5000.fr
ssh grenoble
mkdir border
git clone https://github.com/mininet/mininet
```

### Using Kadeploy
```bash
oarsub -I -t deploy
kadeploy3 -a border-custom-environment.yaml -o /tmp/manual_launch_n.txt
ssh MACHINE_ID

sudo ./border_setup_launch.sh --run-tag syntax_test --clients-qos0 1 --clients-qos1 250 --clients-qos2 1 --delay-qos0 12 --delay-qos1 14 --delay-qos2 12 --messages-qos0 0 --messages-qos1 75000 --messages-qos2 0 --size-qos0 100 --size-qos1 100 --size-qos2 100 --cpu 2 --ram-limit 1g --broker-type JORAMMQ --run-tests true

sudo ./start_clients.sh --run-tag 20260515234745_3__C01_D012_M00_S0100_C1250_D14_M175000_S1100_C21_D212_M20_S2100_CPU2_RAM1g --clients-qos0 1 --clients-qos1 250 --clients-qos2 1 --delay-qos0 12 --delay-qos1 14 --delay-qos2 12 --messages-qos0 0 --messages-qos1 75000 --messages-qos2 0 --size-qos0 100 --size-qos1 100 --size-qos2 100 --brokers 1 --name /home/randerer/results/single_broker_results

#    ( sleep $WAIT_TIME_CLUSTER_LAUNCH_SECONDS; sudo ./start_clients.sh --run-tag "$RUN_TAG" --clients-qos0 "$CLIENTS_QOS0" --clients-qos1 "$CLIENTS_QOS1" --clients-qos2 "$CLIENTS_QOS2" --delay-qos0 "$DELAY_QOS0" --delay-qos1 "$DELAY_QOS1" --delay-qos2 "$DELAY_QOS2" --messages-qos0 "$MESSAGES_QOS0" --messages-qos1 "$MESSAGES_QOS1" --messages-qos2 "$MESSAGES_QOS2" --size-qos0 "$SIZE_QOS0" --size-qos1 "$SIZE_QOS1" --size-qos2 "$SIZE_QOS2" --name /home/randerer/results/single_broker_results --brokers 1 ) &


sudo ./start_clients.sh --run-tag find_high_load_7__C10_D25_M6000_Q1_S1000_CPU2_RAM1g --clients 10 --delay 25 --messages 6000 --qos 1 --size 1000 --brokers 1 --name /home/randerer/results/single_broker_results

sudo ./border_setup_launch.sh --run-tag find_high_load_5__C15_D25_M15000_Q0_S5000_CPU2_RAM1g --clients 15 --delay 25 --messages 15000 --qos 0 --size 5000 --cpu 2 --ram-limit 1g --broker-type RABBITMQ --run-tests true

sudo ./border_setup_launch.sh --run-tag manualjoramdebug_3__C10_D20_M15000_Q0_S50000_CPU8_RAM4g --clients 1 --delay 10 --messages 15000 --qos 0 --size 1000 --cpu 8 --ram-limit 4g --broker-type JORAMMQ --run-tests true

sudo ./border_setup_launch.sh --run-tag manualjoramdebug_5__C10_D20_M15000_Q0_S50000_CPU8_RAM4g --clients 10 --delay 20 --messages 15000 --qos 0 --size 5000 --cpu 8 --ram-limit 4g --broker-type JORAMMQ --run-tests true

sudo ./border_setup_launch.sh --run-tag manualjoramdebug_5__C10_D20_M15000_Q0_S50000_CPU8_RAM4g --clients 10 --delay 20 --messages 30000 --qos 0 --size 20000 --cpu 8 --ram-limit 4g --broker-type JORAMMQ --run-tests true

```

#### API
```bash
curl https://api.grid5000.fr/stable/sites/grenoble/jobs -X POST -H 'Content-Type: application/json' -d '{"resources": "nodes=2", "types": ["deploy"], "command": "sleep 3600"}'

curl -s https://api.grid5000.fr/stable/sites/grenoble/jobs/1965460 | jq '.assigned_nodes,.state' # adjust job id
export SSH_PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`

curl -i https://api.grid5000.fr/stable/sites/grenoble/deployments -H'Content-Type: application/json' -d '{"nodes": ["dahu-12.grenoble.grid5000.fr", "dahu-17.grenoble.grid5000.fr"], "environment": "debian-nfs-border", "key": "$SSH_PUBLIC_KEY"}' # adjust dahu ids

```

### Start
```bash
ssh randerer@access.grid5000.fr
ssh grenoble
oarsub -I

# Docker
g5k-setup-docker -t

# Containernet
cd ..
cd ..

cp -r ./home/randerer/border/containernet ./tmp/
cd ./tmp
sudo-g5k apt-get install ansible
# if previous installation: sudo rm -rf openflow/
cd ./containernet
# git clone https://github.com/ANTLab-polimi/BORDER.git
sudo-g5k ansible-playbook -i "localhost," -c local -e "ansible_python_interpreter=/usr/bin/python3 force_install=true" ./ansible/install.yml
# sudo-g5k ansible-playbook -i "localhost," -c local ./tmp/containernet/ansible/install.yml
# NOTE: uncomment according line in `upload_relevant_code_to_g5k.sh` if you plan to run the build process on G5K

python3 -m venv venv
source venv/bin/activate

# If you want to install containernet in "edit" mode
# python3 -m pip install --upgrade pip
# pip install -e . --no-binary :all:
# If you want to install containernet in "normal" mode
pip install .

# Containernet example
sudo-g5k ./venv/bin/python3 examples/containernet_example.py

# BORDER example
cd BORDER
sudo-g5k ../venv/bin/python3 flexible_router.py --type RABBITMQ

# BORDER benchmarking in second terminal
./start_clients.sh --clients 5 --delay 2 --messages 50 --qos 2

# Mininet (irrelevant due to containernet installation)
# cp -r ./border/mininet ./tmp/mn
# sudo-g5k ./tmp/mininet/util/install.sh
```

### Sync from local
```bash
scp ./BORDER/flexible_router.py randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/flexible_router.py
scp ./BORDER/start_clients.sh randerer@access.grid5000.fr:grenoble/border/containernet/BORDER/start_clients.sh
scp ./BORDER/border_setup.sh randerer@access.grid5000.fr:grenoble/border_setup.sh
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

### Edit
```bash
sudo-g5k vim home/randerer/border/containernet/BORDER/start_clients.sh
sudo-g5k vim home/randerer/border/containernet/BORDER/flexible_router.py
```


# Benchmarks

## Perf
> NOTE (local change): To do this, simply modify the "jorammq-mqtt-1.21.0-SNAPSHOT/conf/jorammq.xml" file. Set "com.scalagent.jorammq.mqtt.serverMaxPendingConnections" value to 1000

> NOTE (local change): To do this, simply modify the "jorammq-mqtt-1.21.0-SNAPSHOT/conf/jorammq.xml" file. Increase "com.scalagent.jorammq.mqtt.serverConnectionTimeout" value


```
./internal_benchmarking/jorammq-mqtt-perf-1.21.0-SNAPSHOT/bin/multismartphone
```

# Utils

## Docker

### Remove all docker containers
```bash
docker stop $(docker ps -a -q)
docker rm $(docker ps -a -q)
```

## ContainerNet

### Cleanup
```bash
sudo-g5k env "PATH=$PATH" mn -c
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
c
```

# Other
```bash
python3 calculate_messages.py --throughput 1000
python3 calculate_messages.py --throughput 10000
python3 calculate_messages.py --throughput 20000
python3 calculate_messages.py --throughput 30000
python3 calculate_messages.py --throughput 40000
python3 calculate_messages.py --throughput 50000
python3 calculate_messages.py --throughput 60000
python3 calculate_messages.py --throughput 70000
python3 calculate_messages.py --throughput 80000
python3 calculate_messages.py --throughput 90000
python3 calculate_messages.py --throughput 100000


python3 calculate_messages.py --throughput 100 --clients 100
python3 calculate_messages.py --throughput 5000 --clients 100
python3 calculate_messages.py --throughput 10000 --clients 100
python3 calculate_messages.py --throughput 15000 --clients 100
python3 calculate_messages.py --throughput 20000 --clients 100
python3 calculate_messages.py --throughput 25000 --clients 100
python3 calculate_messages.py --throughput 30000 --clients 100
python3 calculate_messages.py --throughput 35000 --clients 100
python3 calculate_messages.py --throughput 40000 --clients 100
python3 calculate_messages.py --throughput 45000 --clients 100
python3 calculate_messages.py --throughput 50000 --clients 100
python3 calculate_messages.py --throughput 55000 --clients 100
python3 calculate_messages.py --throughput 60000 --clients 100
python3 calculate_messages.py --throughput 65000 --clients 100
python3 calculate_messages.py --throughput 70000 --clients 225
python3 calculate_messages.py --throughput 85000 --clients 225
python3 calculate_messages.py --throughput 100000 --clients 225


python3 calculate_messages.py --throughput 100 --clients 100
python3 calculate_messages.py --throughput 2500 --clients 100
python3 calculate_messages.py --throughput 5000 --clients 100
python3 calculate_messages.py --throughput 7500 --clients 100
python3 calculate_messages.py --throughput 10000 --clients 100
python3 calculate_messages.py --throughput 12500 --clients 100
python3 calculate_messages.py --throughput 15000 --clients 100
python3 calculate_messages.py --throughput 17500 --clients 100
python3 calculate_messages.py --throughput 20000 --clients 100
python3 calculate_messages.py --throughput 22500 --clients 100
python3 calculate_messages.py --throughput 25000 --clients 100
python3 calculate_messages.py --throughput 27500 --clients 100
python3 calculate_messages.py --throughput 30000 --clients 100
python3 calculate_messages.py --throughput 32500 --clients 100


python3 calculate_messages.py --throughput 100 --clients 100
python3 calculate_messages.py --throughput 100 --clients 500
python3 calculate_messages.py --throughput 100 --clients 1000
python3 calculate_messages.py --throughput 100 --clients 1500
python3 calculate_messages.py --throughput 100 --clients 2000
python3 calculate_messages.py --throughput 100 --clients 2500
python3 calculate_messages.py --throughput 100 --clients 3000
python3 calculate_messages.py --throughput 100 --clients 3500
python3 calculate_messages.py --throughput 100 --clients 4000
python3 calculate_messages.py --throughput 100 --clients 4500
python3 calculate_messages.py --throughput 100 --clients 5000
```



# Logs
```bash
docker container cp mn.jorammq0:/home/jorammq/log/server-0.0.log logs/
```


# Zipped Downloads
```bash
zip -r logs.zip logs/
scp randerer@access.grid5000.fr:grenoble/logs.zip ./logs/
```

```bash
zip -r results.zip results/
scp randerer@access.grid5000.fr:grenoble/results.zip ./border-data-pipeline/inputs/result_data/
```