.PHONY:

SERVER = ec2-18-132-194-109.eu-west-2.compute.amazonaws.com
DIR := ${CURDIR}

forward_ec2_port:
	cd $(HOME)/.ssh && \
	ssh -i "airbyte.pem" -L 8000:localhost:8000 -N -f $(SERVER);

copy_docker_compose_to_ec2:
	scp -i $(HOME)/.ssh/airbyte.pem ${DIR}/docker-compose.yaml ec2-user@ec2-18-132-194-109.eu-west-2.compute.amazonaws.com:~/docker-compose.yaml

copy_env_file:
	scp -i $(HOME)/.ssh/airbyte.pem ${DIR}/.env ec2-user@ec2-18-132-194-109.eu-west-2.compute.amazonaws.com:~/.env

move_docker_compose_file_to_root_folder:
	ssh ec2-user@$(SERVER) 'sudo cp ~/docker-compose.yaml /docker-compose.yaml';

move_env_file_to_root_folder:
	ssh ec2-user@$(SERVER) 'sudo cp ~/.env /.env';

run_docker_compose_up:
	ssh ec2-user@$(SERVER) "cd /; docker-compose up -d;";

disaster_recovery: copy_docker_compose_to_ec2 copy_env_file move_docker_compose_file_to_root_folder \
move_env_file_to_root_folder
	
check_running_containers:
	ssh ec2-user@$(SERVER) 'docker ps';

install_octavia:
	curl -s -o- https://raw.githubusercontent.com/airbytehq/airbyte/master/octavia-cli/install.sh | bash; \
	echo "AIRBYTE_URL=http://host.docker.internal:8000" >> $(HOME)/.octavia;
