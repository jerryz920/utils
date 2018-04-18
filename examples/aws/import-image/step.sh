#!/bin/bash

aws s3 mb s3://customized-ami-bucket
aws iam create-role --role-name vmimport --assume-role-policy-document file://trust-policy.json
aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://role-policy.json
# can use raw/vmdk/ova/vdi
# aws s3 cp boot2docker.vmdk s3://customized-ami-bucket/vms/boot2docker.vmdk
# aws ec2 import-image --description "Boot2Docker" --license-type <value> --disk-containers file://containers.json

