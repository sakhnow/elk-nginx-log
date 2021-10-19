#!make
include .env
export $(shell sed 's/=.*//' .env)

POD_KIBANA = ${POD_NAME}-kibana
POD_NGINX = ${POD_NAME}-nginx

podman_pod_create:
	podman pod exists ${POD_NAME} \
	|| podman pod create \
	--name ${POD_NAME} \
	-p ${POD_PORT_KIBANA}:5601 \
	-p ${POD_PORT_NGINX}:80

podman_up_elastic: podman_pod_create
	podman container exists ${POD_NAME}-elastic \
	&& podman start ${POD_NAME}-elastic \
	|| podman run --rm -d \
	--pod ${POD_NAME} \
	--name=${POD_NAME}-elastic \
	--user 1000:1000 \
	--env http.host=0.0.0.0 \
	--env http.cors.enabled=true \
	--env http.cors.allow-origin=* \
	--env http.cors.allow-methods=OPTIONS,HEAD,GET,POST,PUT,DELETE \
	--env http.cors.allow-headers=X-Requested-With,X-Auth-Token,Content-Type,Content-Length,Authorization \
	--env transport.host=127.0.0.1 \
	--env cluster.name=docker-cluster \
	--env discovery.type=single-node \
	--env xpack.security.enabled=true \
	--env ELASTIC_PASSWORD=${ELASTIC_PASSWORD} \
	--env "ES_JAVA_OPTS=-Xms512m -Xmx512m" \
	-v .data/elastic:/usr/share/elasticsearch/data:Z \
	elasticsearch:${ELK_VERSION}

podman_up_kibana: podman_pod_create
	podman container exists ${POD_KIBANA} \
	&& podman start ${POD_KIBANA} \
	|| podman run --rm -d \
	--pod ${POD_NAME} \
	--name=${POD_KIBANA} \
	--env ELASTIC_PASSWORD=${ELASTIC_PASSWORD} \
	-v ./config/kibana:/usr/share/kibana/config:Z \
	docker.elastic.co/kibana/kibana:${ELK_VERSION}

podman_up_logstash: podman_pod_create
	podman container exists ${POD_NAME}-logstash \
	&& podman start ${POD_NAME}-logstash \
	|| podman run --rm -d \
	--pod ${POD_NAME} \
	--name=${POD_NAME}-logstash \
	-v ./config/logstash/logstash.yml:/usr/share/logstash/config/logstash.yml:Z \
	-v ./config/logstash/pipelines.yml:/usr/share/logstash/config/pipelines.yml:Z \
	-v ./config/logstash/pipelines:/usr/share/logstash/config/pipelines:Z \
	--env ELASTIC_PASSWORD=${ELASTIC_PASSWORD} \
	docker.elastic.co/logstash/logstash:${ELK_VERSION}

podman_up_nginx: podman_pod_create
	podman container exists ${POD_NGINX} \
	&& podman start ${POD_NGINX} \
	|| podman run --rm -d \
	--pod ${POD_NAME} \
	--name=${POD_NGINX} \
	-v ./config/nginx/nginx.conf:/etc/nginx/nginx.conf:Z \
	nginx

podman_up: podman_up_elastic podman_up_kibana podman_up_logstash podman_up_nginx