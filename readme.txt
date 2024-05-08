cd vehicle
docker build -t vehicle .
docker tag vehicle bezve01/vehicle
docker push bezve01/vehicle
cd ..

cd challan_as
docker build -t challan_as .
docker tag challan_as bezve01/challan_as
docker push bezve01/challan_as
cd ..

cd challan_ws
docker build -t challan_ws .
docker tag challan_ws bezve01/challan_ws
docker push bezve01/challan_ws
cd ..

cd challan_ws_public
docker build -t challan_ws_public .
docker tag challan_ws_public bezve01/challan_ws_public
docker push bezve01/challan_ws_public
cd ..

docker build -t challan .
docker tag challan bezve01/challan
docker push bezve01/challan

docker network create my-network

docker run -d  -p 5432:5432  --network my-network --name postgresql -e POSTGRESQL_PASSWORD=mypwd bitnami/postgresql:latest

docker run -d -p 9092:9092 --network my-network --name kafka --hostname kafka -e KAFKA_CFG_NODE_ID=0 -e KAFKA_CFG_PROCESS_ROLES=controller,broker -e KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 -e KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT -e KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093 -e KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER bitnami/kafka:latest

docker run -d  -p 8000:8000 --network my-network --name dynamodb amazon/dynamodb-local
	
docker run -d -p 8001:8001 -p 8002:8002 -p 8003:8003 -p 8004:8004 -e DYNAMODB_SERVICE_HOST=dynamodb -e DYNAMODB_SERVICE_PORT=8000 -e KAFKA_SERVICE_HOST=kafka -e KAFKA_SERVICE_PORT=9092 -e POSTGRES_SERVICE_HOST=postgresql -e POSTGRES_SERVICE_PORT=5432 -e VEHICLE_SERVICE_HOST=challan -e VEHICLE_SERVICE_PORT=8001 --network my-network --name challan challan

docker run -d -p 8001:8001 -e POSTGRES_SERVICE_HOST=postgresql -e POSTGRES_SERVICE_PORT=5432 --network my-network --name vehicle vehicle

docker run -d -p 8002:8002 -e DYNAMODB_SERVICE_HOST=dynamodb -e DYNAMODB_SERVICE_PORT=8000 -e KAFKA_SERVICE_HOST=kafka-server -e KAFKA_SERVICE_PORT=9092 -e VEHICLE_SERVICE_HOST=vehicle -e VEHICLE_SERVICE_PORT=8001 --network my-network --name challan_as challan_as

docker run -d -p 8003:8003 -e KAFKA_SERVICE_HOST=kafka-server -e KAFKA_SERVICE_PORT=9092 --network my-network --name challan_ws challan_ws

docker run -d -p 8004:8004 -e DYNAMODB_SERVICE_HOST=dynamodb -e DYNAMODB_SERVICE_PORT=8000 --network my-network --name challan_ws_public challan_ws_public

kubectl apply -f postgres/deployment.yaml
kubectl apply -f zookeeper/deployment.yaml
kubectl apply -f kafka/deployment.yaml
kubectl apply -f dynamodb/deployment.yaml
kubectl apply -f vehicle/deployment.yaml
kubectl apply -f challan_as/deployment.yaml
kubectl apply -f challan_ws/deployment.yaml
kubectl apply -f challan_ws_public/deployment.yaml

kubectl delete service postgres
kubectl delete service zookeeper
kubectl delete service kafka
kubectl delete service dynamodb
kubectl delete service vehicle
kubectl delete service challan-as
kubectl delete service challan-ws
kubectl delete service challan-ws-public

kubectl delete deployment postgres-deployment
kubectl delete deployment zookeeper-deployment
kubectl delete deployment kafka-deployment
kubectl delete deployment dynamodb-deployment
kubectl delete deployment vehicle-deployment
kubectl delete deployment challan-as-deployment
kubectl delete deployment challan-ws-deployment
kubectl delete deployment challan-ws-public-deployment

kubectl port-forward  <pod>  8000:8000
