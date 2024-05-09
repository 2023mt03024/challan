### Run and test each micro service ###

# Create a docker network
docker network create my-network

# Create postgresql container in that network
docker run -d  -p 5432:5432  --network my-network --name postgresql -e POSTGRESQL_PASSWORD=mypwd bitnami/postgresql:latest

# Create kafka container in that network
docker run -d -p 9092:9092 --network my-network --name kafka --hostname kafka -e KAFKA_CFG_NODE_ID=0 -e KAFKA_CFG_PROCESS_ROLES=controller,broker -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093 -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER bitnami/kafka:latest

# add entry "127.0.0.1 kafka" to /etc/hosts file

# Create a kafka topic Challan
docker run -it --rm --network my-network bitnami/kafka:latest kafka-topics.sh --create --bootstrap-server kafka:9092 --topic Challan --partitions 1 --replication-factor 1

# Create dynamodb container in that network
docker run -d  -p 8000:8000 --network my-network --name dynamodb amazon/dynamodb-local

# Open a new command prompt and Run Vehicle Web Server
set FLASK_KEY=SECRET_KEY
set FLASK_KEY_VALUE=the random string
set POSTGRES_SERVICE_HOST=localhost
set POSTGRES_SERVICE_PORT=5432
set POSTGRES_USER=postgres
set POSTGRES_PASSWORD=mypwd
cd vehicle
python app.py

# Open a new command prompt and Run Challan Application Server
set FLASK_KEY=SECRET_KEY
set FLASK_KEY_VALUE=the random string
set DYNAMODB_SERVICE_HOST=localhost
set DYNAMODB_SERVICE_PORT=8000
set KAFKA_SERVICE_HOST=localhost
set KAFKA_SERVICE_PORT=9092
set VEHICLE_SERVICE_HOST=localhost
set VEHICLE_SERVICE_PORT=8001
cd challan_as
python app.py

# Open a new command prompt and Run Challan Web Server
set FLASK_KEY=SECRET_KEY
set FLASK_KEY_VALUE=the random string
set KAFKA_SERVICE_HOST=localhost
set KAFKA_SERVICE_PORT=9092
cd challan_ws
python app.py

# Open a new command prompt and Run Challan Public Web Server
set FLASK_KEY=SECRET_KEY
set FLASK_KEY_VALUE=the random string
set DYNAMODB_SERVICE_HOST=localhost
set DYNAMODB_SERVICE_PORT=8000
cd challan_ws_public
python app.py

# Test the application

# Stop Challan Public Web server

# Stop Challan Web Server

# Stop Challan Application Server

# Stop Vehicle Web Server

# Stop dynamodb container
docker rm -f dynamodb

# Stop kafka container
docker rm -f kafka

# Stop postgresql container
docker rm -f postgresql

# Stop docker network
docker network rm my-network

###  Build docker images ###

# Build challan docker image
docker build -t challan .
docker tag challan bezve01/challan
docker push bezve01/challan

# Build vehicle docker image
cd vehicle
docker build -t vehicle .
docker tag vehicle bezve01/vehicle
docker push bezve01/vehicle
cd ..

# Build challan_as docker image
cd challan_as
docker build -t challan_as .
docker tag challan_as bezve01/challan_as
docker push bezve01/challan_as
cd ..

# Build challan_ws docker image
cd challan_ws
docker build -t challan_ws .
docker tag challan_ws bezve01/challan_ws
docker push bezve01/challan_ws
cd ..

# Build challan_ws_public docker image
cd challan_ws_public
docker build -t challan_ws_public .
docker tag challan_ws_public bezve01/challan_ws_public
docker push bezve01/challan_ws_public
cd ..



### Deploy all services on a single docker container ###

# Create a docker network
docker network create my-network

# Create postgresql container in that network
docker run -d  -p 5432:5432  --network my-network --name postgresql -e POSTGRESQL_PASSWORD=mypwd bitnami/postgresql:latest

# Create kafka container in that network
docker run -d -p 9092:9092 --network my-network --name kafka --hostname kafka -e KAFKA_CFG_NODE_ID=0 -e KAFKA_CFG_PROCESS_ROLES=controller,broker -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093 -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER bitnami/kafka:latest

# add entry "127.0.0.1 kafka" to /etc/hosts file

# Create a kafka topic Challan
docker run -it --rm --network my-network bitnami/kafka:latest kafka-topics.sh --create --bootstrap-server kafka:9092 --topic Challan --partitions 1 --replication-factor 1

# Create dynamodb container in that network
docker run -d  -p 8000:8000 --network my-network --name dynamodb amazon/dynamodb-local

# Create challan container in that network
docker run -d -p 8001:8001 -p 8002:8002 -p 8003:8003 -p 8004:8004 -e DYNAMODB_SERVICE_HOST=dynamodb -e DYNAMODB_SERVICE_PORT=8000 -e KAFKA_SERVICE_HOST=kafka -e KAFKA_SERVICE_PORT=9092 -e POSTGRES_SERVICE_HOST=postgresql -e POSTGRES_SERVICE_PORT=5432 -e VEHICLE_SERVICE_HOST=challan -e VEHICLE_SERVICE_PORT=8001 --network my-network --name challan challan

# Test the application

# Stop challan container
docker rm -f challan

# Stop dynamodb container
docker rm -f dynamodb

# Stop kafka container
docker rm -f kafka

# Stop postgresql container
docker rm -f postgresql

# Stop docker network
docker network rm my-network


### Deploy each service on separate docker container ###

# Create a docker network
docker network create my-network

# Create postgresql container in that network
docker run -d  -p 5432:5432  --network my-network --name postgresql -e POSTGRESQL_PASSWORD=mypwd bitnami/postgresql:latest

# Create kafka container in that network
docker run -d -p 9092:9092 --network my-network --name kafka --hostname kafka -e KAFKA_CFG_NODE_ID=0 -e KAFKA_CFG_PROCESS_ROLES=controller,broker -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093 -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER bitnami/kafka:latest

# add entry "127.0.0.1 kafka" to /etc/hosts file

# Create a kafka topic Challan
docker run -it --rm --network my-network bitnami/kafka:latest kafka-topics.sh --create --bootstrap-server kafka:9092 --topic Challan --partitions 1 --replication-factor 1

# Create dynamodb container in that network
docker run -d  -p 8000:8000 --network my-network --name dynamodb amazon/dynamodb-local

# Create vehicle container in that network
docker run -d -p 8001:8001 -e POSTGRES_SERVICE_HOST=postgresql -e POSTGRES_SERVICE_PORT=5432 --network my-network --name vehicle vehicle

# Create challan_as container in that network
docker run -d -p 8002:8002 -e DYNAMODB_SERVICE_HOST=dynamodb -e DYNAMODB_SERVICE_PORT=8000 -e KAFKA_SERVICE_HOST=kafka -e KAFKA_SERVICE_PORT=9092 -e VEHICLE_SERVICE_HOST=vehicle -e VEHICLE_SERVICE_PORT=8001 --network my-network --name challan_as challan_as

# Create challan_ws container in that network
docker run -d -p 8003:8003 -e KAFKA_SERVICE_HOST=kafka -e KAFKA_SERVICE_PORT=9092 --network my-network --name challan_ws challan_ws

# Create challan_ws_public container in that network
docker run -d -p 8004:8004 -e DYNAMODB_SERVICE_HOST=dynamodb -e DYNAMODB_SERVICE_PORT=8000 --network my-network --name challan_ws_public challan_ws_public

# Test the application

# Stop challan_ws_public container
docker rm -f challan_ws_public

# Stop challan_ws container
docker rm -f challan_ws

# Stop challan_as container
docker rm -f challan_as

# Stop vehicle container
docker rm -f vehicle

# Stop dynamodb container
docker rm -f dynamodb

# Stop kafka container
docker rm -f kafka

# Stop postgresql container
docker rm -f postgresql

# Stop docker network
docker network rm my-network


### Run a minikube cluster on your local machine ###
### and explore various options in this.         ###

# Start minikube cluster
minikube start

# Display the version of the kubectl installed
kubectl version

# Display the status of the minikube cluster
minikube status

# Display list of minikube services
minikube service list


### Deployment of your application on minikube cluster ###

# Deploy postgres
kubectl apply -f postgres/deployment.yaml

# Deploy kafka
kubectl apply -f kafka/deployment.yaml

# Get pods
kubectl get pods

# Create a kafka topic Challan
kubectl exec -it <kafka-pod> -- /opt/bitnami/kafka/bin/kafka-topics.sh --create --bootstrap-server kafka:9092 --topic Challan --partitions 1 --replication-factor 1

# Deploy dynamodb
kubectl apply -f dynamodb/deployment.yaml

# Deploy vehicle
kubectl apply -f vehicle/deployment.yaml

# Deploy challan_as
kubectl apply -f challan_as/deployment.yaml

# Deploy challan_ws
kubectl apply -f challan_ws/deployment.yaml

# Deploy challan_ws_public
kubectl apply -f challan_ws_public/deployment.yaml

# Get pods
kubectl get pods

# Expose the traffic from local host to challan-ws pod
kubectl port-forward  <challan-ws-deployment pod>  8003:8003

# Expose the traffic from local host to challan-ws-public pod
kubectl port-forward  <challan-ws-public-deployment>  8004:8004

# Test the application

# Stop port-forward to challan-ws-public

# Stop port-forward to challan-ws

# Delete challan_ws_public deployment and service
kubectl delete -f challan_ws_public/deployment.yaml

# Delete challan_ws deployment and service
kubectl delete -f challan_ws/deployment.yaml

# Delete challan_as deployment and service
kubectl delete -f challan_as/deployment.yaml

# Delete vehicle deployment and service
kubectl delete -f vehicle/deployment.yaml

# Delete dynamodb deployment and service
kubectl delete -f dynamodb/deployment.yaml

# Delete kafka deployment and service
kubectl delete -f kafka/deployment.yaml

# Delete postgres deployment and service
kubectl delete -f postgres/deployment.yaml

# Stop minikube cluster
minikube stop
