function usage() {
	echo "Usage: $0 [pem-key-name] [ec2-public-ip] [ec2-region] [world-name]"
}

if [[ $# < 4 ]]; then
	usage >&2
	exit 1
fi

pem_key_name=$1
ec2_public_ip=$2
ec2_region=$3
world_name=$4

if [[ ! "$pem_key_name" =~ \.pem$ ]]; then
	echo "Error: '$pem_key_name' is an invalid pem key name." >&2
	echo "Your pem key must have the .pem file extension." >&2
	exit 1
fi

if [[ ! "$ec2_public_ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
	echo "Error: '$ec2_public_ip' is an not a valid ip address." >&2
	exit 1
fi

if [[ ! "$ec2_region" =~ ^[a-z]+-[a-z]+-[0-9]+$ ]]; then
	echo "Error: '$ec2_region' is an not a valid value." >&2
	echo "A valid region is for instance eu-west-3" >&2
	exit 1
fi

dashified_ec2_public_ip=$(echo "$ec2_public_ip" | tr . -)
#Specific to default cloudformation ec2 ami | change @ec2-user to @ubuntu if the latter.
ec2_instance="ec2-user@ec2-$dashified_ec2_public_ip.$ec2_region.compute.amazonaws.com"

echo "$ec2_instance"

ssh -i "$pem_key_name" -tt "$ec2_instance" << EOF

[ ! -x "$(command -v zip)" ] && sudo yum install zip -y
[ ! -x "$(command -v mkdir)" ] && sudo yum install mkdir -y
[ ! -d /opt/minecraft/old-worlds ] && mkdir /opt/minecraft/old-worlds
zip -r /opt/minecraft/old-worlds/$(date +"%Y-%m-%d_%H-%M-%S").zip /opt/minecraft/world
rm -rf /opt/minecraft/world
exit

EOF

scp -r -i "$pem_key_name" "$world_name"/* "$ec2_instance":/opt/minecraft/world
