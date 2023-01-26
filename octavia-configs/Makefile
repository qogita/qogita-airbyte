.PHONY: forward_ec2_port install_octavia

EC2_INSTANCE = ec2-18-132-194-109.eu-west-2.compute.amazonaws.com

install_octavia:
	curl -s -o- https://raw.githubusercontent.com/airbytehq/airbyte/master/octavia-cli/install.sh | bash; \
	echo "AIRBYTE_URL=http://host.docker.internal:8000" >> $(HOME)/.octavia;