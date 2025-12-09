## Task Overview
## Install and Configure AWS CLI and list created S3 Bucket(s); and harden the credentials

### 1. Install AWS CLI
For this task, I will be installing AWS CLI on Ubuntu.

`sudo apt update`

`sudo apt install awscli -y`

After successful installation of AWS CLI on our Ubuntu Server, we can check its version with 

`aws --version`

In my case, the installed version is

`aws-cli/1.22.34 Python/3.10.12 Linux/6.6.87.2-microsoft-standard-WSL2 botocore/1.23.34`

We can also check with `aws` 
![alt text](images/aws-check.png)

---
### 2. Create IAM User for CLI 
Now we will go to AWS Console and select `IAM` 

![alt text](images/iam.png)

I already have two users present in my `IAM Users`. From which i will be selecting `Pujan`.

![alt text](images/iam_users.png)

I have also listed some `objects` inside the bucket.

![alt text](images/objects.png)


This is where we create the `access key` & `secret key`

![alt text](images/create_access_keys.png)

---
### 3. Configure AWS CLI

#### In the CLI, we will enter `aws configure`

Here, I have entered my `access` & `secret keys`. I have also selected the `region` as `ap-southeast-2` and the output format as `json`.

`AWS Access Key ID [****************BOAG]:` ...............................................

`AWS Secret Access Key [****************HFj0]:` ............................................

`Default region name [eu-west-1]:`  `ap-southeast-2`

`Default output format [None]:` `json`


![alt text](images/aws-configure.png)

We have successfully connected to our `AWS S3 Account`.

For this purpose, I have already created an `S3 bucket` named `tekbay-bootcamp-bucket` with some contents so that we can check from the `CLI`.
![alt text](images/tek-bucket.png)

We can also create `S3 bucket` from the `CLI` with
```
aws s3api create-bucket \
    --bucket <your-bucket-name> \
    --region <your-region>
```

---
### 4. List S3 Buckets

To list the buckets in our `AWS Account` from the `CLI`:

`aws s3 ls` This lists all the `S3 Buckets` present in the account.

To list objects inside a bucket:

`aws s3 ls s3://your-bucket-name`

In our case:

 `aws s3 ls s3://tekbay-bootcamp-bucket` 

We can see it in the snippet.
![alt text](images/aws-s3-ls.png)

---

### 5. HARDENING AWS CREDENTIALS

**A. Never hardcode AWS keys in code. Don't put this directly in your code.**

XXX `AWS.config.update({ accessKeyId: "...", secretAccessKey: "..." });`  XXX

---


**B. Use IAM Users only for CLI/local testing**

For EC2, Lambda, ECS → use IAM Roles, not access keys.

---

**C. Restrict IAM User Permissions**

Follow least-privilege:

- If only accessing S3:
`AmazonS3FullAccess` or **fine-grained S3 policy.**

---


**D. Rotate Access Keys**

Rotate every 60–90 days:

1. `IAM` → `User` → `Security credentials`

2. Create `new key` → `update CLI` → `delete old key`

---


**E. Enable MFA (very important)**

- `IAM` → `Users` → `Security Credentials` → `Assign MFA`
This protects console login.

---

**F. Encrypt credential files**
```
chmod 600 ~/.aws/credentials
chmod 600 ~/.aws/config
```

---

**G. Use AWS Vault (recommended)**

For secure storage of keys:

`sudo apt install aws-vault`

```
aws-vault add default
aws-vault exec default -- aws s3 ls

```
---