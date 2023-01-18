OCTAVIA_ENV_FILE := $(HOME)/.octavia
OCTAVIA_ALIAS := docker run -i --rm -v $(PWD):/home/octavia-project --network host --env-file $(OCTAVIA_ENV_FILE) --user $(id -u):$(id -g) airbyte/octavia-cli:0.40.28
AIRBYTE_URL := --airbyte-url http://host.docker.internal:8000
OCTAVIA := $(OCTAVIA_ALIAS) $(AIRBYTE_URL)
RESOURCE_NAME?=not_defined_yet
DEFINITION_ID?=not_defined_yet

.PHONY: forward_ec2_port _import_all _apply

forward_ec2_port:
	cd $(HOME)/.ssh && \
	ssh -i "airbyte.pem" -L 8000:localhost:8000 -N -f ec2-user@ec2-35-178-251-14.eu-west-2.compute.amazonaws.com

install_octavia:
	curl -s -o- https://raw.githubusercontent.com/airbytehq/airbyte/master/octavia-cli/install.sh | bash; \
	echo "AIRBYTE_URL=http://host.docker.internal:8000" >> $(HOME)/.octavia;