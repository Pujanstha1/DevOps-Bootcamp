## AWS CLI

aws configure
AWS Access Key ID

AWS Secret Access Key

Region (example: us-east-1)

Output format (optional): json

aws cloudformation create-stack \
  --stack-name MyEC2Stack \
  --template-body file:///mnt/c/Users/pujan/OneDrive/Desktop/DevOps-Bootcamp/Week\ 4/Cloudformation/ec2.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=cfm


## To confirm keypair names configured
aws ec2 describe-key-pairs --query "KeyPairs[*].KeyName"

## What to check next if it still fails
### 1. Key pair exists in the SAME region

`aws ec2 describe-key-pairs --key-names cfm`

### 2. Region consistency
`aws configure get region`


### 3. Template syntax
`aws cloudformation validate-template \
  --template-body file:///mnt/c/Users/pujan/OneDrive/Desktop/DevOps-Bootcamp/Week\ 4/Cloudformation/ec2.yaml`




sudo apt install -y nginx
sudo systemctl status nginx

sudo chmod 644 index.html

The default location for the index file in ubuntu is /var/www/html/index.html and not /usr/share/nginx/html/index.html
mv index.html /usr/share/nginx/html/index.html

sudo mv /usr/share/nginx/html/index.html /var/www/html/index.html

sudo systemctl reload nginx


### Basic SCP Syntax (Local ➜ Ubuntu)
`scp -i cfm.pem local_file ubuntu@<PUBLIC_IP>:/home/ubuntu/`

**Example**
`scp -i cfm.pem index.html ubuntu@54.123.45.67:/home/ubuntu/`

# AWS CloudFormation – AWS CLI Commands Guide

This document provides commonly used **AWS CLI commands** to create, validate, update, monitor, and delete **AWS CloudFormation stacks**.

---

## 1. Create a CloudFormation Stack (Basic)

```bash
aws cloudformation create-stack \
  --stack-name MyStack \
  --template-body file:///path/to/template.yaml
```

---

## 2. Create Stack with Parameters (Most Common)

```bash
aws cloudformation create-stack \
  --stack-name MyEC2Stack \
  --template-body file:///mnt/c/Users/pujan/OneDrive/Desktop/DevOps-Bootcamp/Week\ 4/Cloudformation/ec2.yaml \
  --parameters ParameterKey=KeyPair,ParameterValue=cfm
```

> ⚠️ **Note:** Parameter names are **case-sensitive** and must exactly match the template.

---

## 3. Create Stack with IAM Resources

If your template creates IAM roles, policies, or instance profiles:

```bash
aws cloudformation create-stack \
  --stack-name MyStack \
  --template-body file:///path/to/template.yaml \
  --capabilities CAPABILITY_NAMED_IAM
```

(Use `CAPABILITY_IAM` if names are auto-generated.)

---

## 4. Create Stack Using Parameters File

### params.json
```json
[
  {
    "ParameterKey": "KeyPair",
    "ParameterValue": "cfm"
  }
]
```

### Command
```bash
aws cloudformation create-stack \
  --stack-name MyEC2Stack \
  --template-body file:///path/to/ec2.yaml \
  --parameters file://params.json
```

---

## 5. Validate a CloudFormation Template (Best Practice)

```bash
aws cloudformation validate-template \
  --template-body file:///path/to/template.yaml
```

---

## 6. Monitor Stack Status

### Describe stack
```bash
aws cloudformation describe-stacks \
  --stack-name MyEC2Stack
```

### View stack events (very useful for debugging)
```bash
aws cloudformation describe-stack-events \
  --stack-name MyEC2Stack
```

---

## 7. Update an Existing Stack

```bash
aws cloudformation update-stack \
  --stack-name MyEC2Stack \
  --template-body file:///path/to/ec2.yaml \
  --parameters ParameterKey=KeyPair,ParameterValue=cfm
```

---

## 8. Delete a Stack

```bash
aws cloudformation delete-stack \
  --stack-name MyEC2Stack
```

---

## 9. Recommended Workflow

```bash
aws cloudformation validate-template --template-body file://template.yaml
aws cloudformation create-stack --stack-name test --template-body file://template.yaml
aws cloudformation describe-stack-events --stack-name test
```

---

## 10. Common Mistakes to Avoid

- Forgetting the `file://` prefix
- Passing `.pem` file instead of **Key Pair name**
- Using wrong parameter name (case-sensitive)
- Region mismatch between resources
- Missing IAM capability flag

---

## Notes

- Ubuntu Nginx web root: `/var/www/html`
- Amazon Linux Nginx web root: `/usr/share/nginx/html`

---

**End of document**

