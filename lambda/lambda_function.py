import boto3
import os

sns = boto3.client('sns')
ec2 = boto3.client('ec2')
rds = boto3.client('rds')

SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']

def lambda_handler(event, context):
    report = []

    # EC2 Check
    instances = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            report.append(f"EC2 Running: {instance['InstanceId']}")

    # RDS Check
    dbs = rds.describe_db_instances()
    for db in dbs['DBInstances']:
        if db['DBInstanceStatus'] == 'available':
            report.append(f"RDS Available: {db['DBInstanceIdentifier']}")

    # EBS Check
    volumes = ec2.describe_volumes(Filters=[{'Name': 'status', 'Values': ['available']}])
    for vol in volumes['Volumes']:
        report.append(f"Idle EBS Volume: {vol['VolumeId']} | Size: {vol['Size']} GB")

    # Unused Security Groups
    all_sgs = ec2.describe_security_groups()['SecurityGroups']
    all_enis = ec2.describe_network_interfaces()['NetworkInterfaces']

    used_sg_ids = set()
    for eni in all_enis:
        for sg in eni['Groups']:
            used_sg_ids.add(sg['GroupId'])

    for sg in all_sgs:
        if sg['GroupId'] not in used_sg_ids:
            report.append(f"Unused Security Group: {sg['GroupId']} | Name: {sg['GroupName']}")

    message = "\n".join(report) or "✅ No idle resources found."
    sns.publish(TopicArn=SNS_TOPIC_ARN, Message=message, Subject="Daily AWS Resource Report")

    return {"statusCode": 200, "body": "Report sent"}
