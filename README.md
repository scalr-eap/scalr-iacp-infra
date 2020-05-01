# scalr-iacp-infra
Infrastructure needed for the IaCP deployment. Full installation instructions located here: https://iacp.docs.scalr.com/en/latest/installation/installation.html

Deploy the required infra for Scalr IaCP

* ALB
* Scalr Server x N (default 1)
* RDS Mysql 5.7 cluster

Set values for these variables in `terrform.tfvars`

1. `region` - AWS Region to use.
1. `key_name` - Key in AWS.
1. `vpc` - VPC to be used.
1. `subnet` - Subnet to be used.
1. `instance_type` - Must be 4GB ram. t3.medium recommended.
1. `name_prefix` - 1-3 character prefix to be added to all instance names.
1. Leave `ssh_private_key` set to "FROM_FILE"
1. Copy the private half of your SSH key to `./ssh/id_rsa`
1. Set your access keys for AWS using environment variables `export AWS_ACCESS_KEY_ID=<access_key> AWS_SECRET_ACCESS_KEY=<secret_key>`
1. Run `terraform init;terraform apply` and watch the magic happen.

Note: This represents the baseline configuration. It is up to you to add things like backup policies, autoscaling, etc to the configuration.
