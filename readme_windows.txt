REM Run and test each micro service REM

REM Create a docker network
docker network create my-network

REM Create postgresql container in that network
docker run -d  -p 5432:5432  --network my-network --name postgresql -e POSTGRESQL_PASSWORD=mypwd bitnami/postgresql:latest

REM Create kafka container in that network
docker run -d -p 9092:9092 --network my-network --name kafka --hostname kafka -e KAFKA_CFG_NODE_ID=0 -e KAFKA_CFG_PROCESS_ROLES=controller,broker -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093 -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER bitnami/kafka:latest

REM add entry "127.0.0.1 kafka" to C:/Windows/System32/drivers/etc/hosts file

REM Create a kafka topic Challan
docker run -it --rm --network my-network bitnami/kafka:latest kafka-topics.sh --create --bootstrap-server kafka:9092 --topic Challan --partitions 1 --replication-factor 1

REM Create dynamodb container in that network
docker run -d  -p 8000:8000 --network my-network --name dynamodb amazon/dynamodb-local

REM Open a new command prompt and Run Vehicle Web Server
set FLASK_KEY=SECRET_KEY
set FLASK_KEY_VALUE=the random string
set POSTGRES_SERVICE_HOST=localhost
set POSTGRES_SERVICE_PORT=5432
set POSTGRES_USER=postgres
set POSTGRES_PASSWORD=mypwd
cd vehicle
python app.py

REM Open a new command prompt and Run Challan Application Server
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

REM Open a new command prompt and Run Challan Web Server
set FLASK_KEY=SECRET_KEY
set FLASK_KEY_VALUE=the random string
set KAFKA_SERVICE_HOST=localhost
set KAFKA_SERVICE_PORT=9092
cd challan_ws
python app.py

REM Open a new command prompt and Run Challan Public Web Server
set FLASK_KEY=SECRET_KEY
set FLASK_KEY_VALUE=the random string
set DYNAMODB_SERVICE_HOST=localhost
set DYNAMODB_SERVICE_PORT=8000
cd challan_ws_public
python app.py

REM Test the application

REM Stop Challan Public Web server

REM Stop Challan Web Server

REM Stop Challan Application Server

REM Stop Vehicle Web Server

REM Stop dynamodb container
docker rm -f dynamodb

REM Stop kafka container
docker rm -f kafka

REM Stop postgresql container
docker rm -f postgresql

REM Stop docker network
docker network rm my-network

REM  Build docker images REM

REM Build challan docker image
docker build -t challan .
docker tag challan bezve01/challan
docker push bezve01/challan

REM Build vehicle docker image 
cd vehicle
docker build -t vehicle .
docker tag vehicle bezve01/vehicle
docker push bezve01/vehicle
cd ..

REM Build challan_as docker image
cd challan_as
docker build -t challan_as .
docker tag challan_as bezve01/challan_as
docker push bezve01/challan_as
cd ..

REM Build challan_ws docker image
cd challan_ws
docker build -t challan_ws .
docker tag challan_ws bezve01/challan_ws
docker push bezve01/challan_ws
cd ..

REM Build challan_ws_public docker image
cd challan_ws_public
docker build -t challan_ws_public .
docker tag challan_ws_public bezve01/challan_ws_public
docker push bezve01/challan_ws_public
cd ..



REM Deploy all services on a single docker container REM

REM Create a docker network
docker network create my-network

REM Create postgresql container in that network 
docker run -d  -p 5432:5432  --network my-network --name postgresql -e POSTGRESQL_PASSWORD=mypwd bitnami/postgresql:latest

REM Create kafka container in that network
docker run -d -p 9092:9092 --network my-network --name kafka --hostname kafka -e KAFKA_CFG_NODE_ID=0 -e KAFKA_CFG_PROCESS_ROLES=controller,broker -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093 -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER bitnami/kafka:latest

REM add entry "127.0.0.1 kafka" to C:/Windows/System32/drivers/etc/hosts file

REM Create a kafka topic Challan
docker run -it --rm --network my-network bitnami/kafka:latest kafka-topics.sh --create --bootstrap-server kafka:9092 --topic Challan --partitions 1 --replication-factor 1

REM Create dynamodb container in that network
docker run -d  -p 8000:8000 --network my-network --name dynamodb amazon/dynamodb-local

REM Create challan container in that network	
docker run -d -p 8001:8001 -p 8002:8002 -p 8003:8003 -p 8004:8004 -e DYNAMODB_SERVICE_HOST=dynamodb -e DYNAMODB_SERVICE_PORT=8000 -e KAFKA_SERVICE_HOST=kafka -e KAFKA_SERVICE_PORT=9092 -e POSTGRES_SERVICE_HOST=postgresql -e POSTGRES_SERVICE_PORT=5432 -e VEHICLE_SERVICE_HOST=challan -e VEHICLE_SERVICE_PORT=8001 --network my-network --name challan challan

REM Test the application

REM Stop challan container
docker rm -f challan

REM Stop dynamodb container
docker rm -f dynamodb

REM Stop kafka container
docker rm -f kafka

REM Stop postgresql container
docker rm -f postgresql

REM Stop docker network
docker network rm my-network


REM Deploy each service on separate docker container REM

REM Create a docker network
docker network create my-network

REM Create postgresql container in that network 
docker run -d  -p 5432:5432  --network my-network --name postgresql -e POSTGRESQL_PASSWORD=mypwd bitnami/postgresql:latest

REM Create kafka container in that network
docker run -d -p 9092:9092 --network my-network --name kafka --hostname kafka -e KAFKA_CFG_NODE_ID=0 -e KAFKA_CFG_PROCESS_ROLES=controller,broker -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093 -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER bitnami/kafka:latest

REM add entry "127.0.0.1 kafka" to C:/Windows/System32/drivers/etc/hosts file

REM Create a kafka topic Challan
docker run -it --rm --network my-network bitnami/kafka:latest kafka-topics.sh --create --bootstrap-server kafka:9092 --topic Challan --partitions 1 --replication-factor 1

REM Create dynamodb container in that network
docker run -d  -p 8000:8000 --network my-network --name dynamodb amazon/dynamodb-local

REM Create vehicle container in that network
docker run -d -p 8001:8001 -e POSTGRES_SERVICE_HOST=postgresql -e POSTGRES_SERVICE_PORT=5432 --network my-network --name vehicle vehicle

REM Create challan_as container in that network
docker run -d -p 8002:8002 -e DYNAMODB_SERVICE_HOST=dynamodb -e DYNAMODB_SERVICE_PORT=8000 -e KAFKA_SERVICE_HOST=kafka -e KAFKA_SERVICE_PORT=9092 -e VEHICLE_SERVICE_HOST=vehicle -e VEHICLE_SERVICE_PORT=8001 --network my-network --name challan_as challan_as

REM Create challan_ws container in that network
docker run -d -p 8003:8003 -e KAFKA_SERVICE_HOST=kafka -e KAFKA_SERVICE_PORT=9092 --network my-network --name challan_ws challan_ws

REM Create challan_ws_public container in that network
docker run -d -p 8004:8004 -e DYNAMODB_SERVICE_HOST=dynamodb -e DYNAMODB_SERVICE_PORT=8000 --network my-network --name challan_ws_public challan_ws_public

REM Test the application

REM Stop challan_ws_public container
docker rm -f challan_ws_public

REM Stop challan_ws container
docker rm -f challan_ws

REM Stop challan_as container
docker rm -f challan_as

REM Stop vehicle container
docker rm -f vehicle

REM Stop dynamodb container
docker rm -f dynamodb

REM Stop kafka container
docker rm -f kafka

REM Stop postgresql container
docker rm -f postgresql

REM Stop docker network
docker network rm my-network


REM Run a minikube cluster on your local machine REM
REM and explore various options in this.         REM

REM Start minikube cluster
minikube start

REM Display the version of the kubectl installed
kubectl version

REM Display the status of the minikube cluster
minikube status

REM Display list of minikube services
minikube service list


REM Deployment of your application on minikube cluster REM

REM Deploy postgres
kubectl apply -f postgres/deployment.yaml

REM Deploy kafka
kubectl apply -f kafka/deployment.yaml

REM Get pods
kubectl get pods

REM Create a kafka topic Challan
kubectl exec -it <kafka-pod> -- /opt/bitnami/kafka/bin/kafka-topics.sh --create --bootstrap-server kafka:9092 --topic Challan --partitions 1 --replication-factor 1

REM Deploy dynamodb
kubectl apply -f dynamodb/deployment.yaml

REM Deploy vehicle
kubectl apply -f vehicle/deployment.yaml

REM Deploy challan_as
kubectl apply -f challan_as/deployment.yaml

REM Deploy challan_ws
kubectl apply -f challan_ws/deployment.yaml

REM Deploy challan_ws_public
kubectl apply -f challan_ws_public/deployment.yaml

REM Get pods
kubectl get pods

REM Expose the traffic from local host to challan-ws pod
kubectl port-forward  <challan-ws-deployment pod>  8003:8003

REM Expose the traffic from local host to challan-ws-public pod
kubectl port-forward  <challan-ws-public-deployment>  8004:8004

REM Test the application

REM Stop port-forward to challan-ws-public

REM Stop port-forward to challan-ws

REM Delete challan_ws_public deployment and service
kubectl delete -f challan_ws_public/deployment.yaml

REM Delete challan_ws deployment and service
kubectl delete -f challan_ws/deployment.yaml

REM Delete challan_as deployment and service
kubectl delete -f challan_as/deployment.yaml

REM Delete vehicle deployment and service
kubectl delete -f vehicle/deployment.yaml

REM Delete dynamodb deployment and service
kubectl delete -f dynamodb/deployment.yaml

REM Delete kafka deployment and service
kubectl delete -f kafka/deployment.yaml

REM Delete postgres deployment and service
kubectl delete -f postgres/deployment.yaml

REM Stop minikube cluster
minikube stop

REM create EKS cluster
eksctl create cluster --region=us-east-1 --zones=us-east-1a,us-east-1b  --name my-cluster --fargate

REM Check access to the cluster
kubectl get svc

REM Deploy postgres
kubectl apply -f postgres/deployment.yaml

REM Deploy kafka
kubectl apply -f kafka/deployment.yaml

REM Get pods
kubectl get pods

REM Create a kafka topic Challan
kubectl exec -it <kafka-pod> -- /opt/bitnami/kafka/bin/kafka-topics.sh --create --bootstrap-server kafka:9092 --topic Challan --partitions 1 --replication-factor 1

REM Deploy dynamodb
kubectl apply -f dynamodb/deployment.yaml

REM Deploy vehicle
kubectl apply -f vehicle/deployment.yaml

REM Deploy challan_as
kubectl apply -f challan_as/deployment.yaml

REM Deploy challan_ws
kubectl apply -f challan_ws/deployment.yaml

REM Deploy challan_ws_public
kubectl apply -f challan_ws_public/deployment.yaml

REM Get pods
kubectl get pods

REM Expose the traffic from local host to challan-ws pod
kubectl port-forward  <challan-ws-deployment pod>  8003:8003

REM Expose the traffic from local host to challan-ws-public pod
kubectl port-forward  <challan-ws-public-deployment>  8004:8004

REM Test the application

REM Stop port-forward to challan-ws-public

REM Stop port-forward to challan-ws

REM Delete challan_ws_public deployment and service
kubectl delete -f challan_ws_public/deployment.yaml

REM Delete challan_ws deployment and service
kubectl delete -f challan_ws/deployment.yaml

REM Delete challan_as deployment and service
kubectl delete -f challan_as/deployment.yaml

REM Delete vehicle deployment and service
kubectl delete -f vehicle/deployment.yaml

REM Delete dynamodb deployment and service
kubectl delete -f dynamodb/deployment.yaml

REM Delete kafka deployment and service
kubectl delete -f kafka/deployment.yaml

REM Delete postgres deployment and service
kubectl delete -f postgres/deployment.yaml

REM Delete EKS cluster
eksctl delete cluster --name my-cluster