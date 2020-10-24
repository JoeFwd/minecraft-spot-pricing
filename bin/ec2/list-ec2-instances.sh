aws ec2 describe-instances --region eu-west-3 --profile minecraft > instances.json && cat instances.json
#use jq to filter the result
