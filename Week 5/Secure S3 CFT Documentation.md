# Secure S3 Bucket – CloudFormation Documentation 

This document explains **each and every component** of the CloudFormation template used to create a **secure Amazon S3 bucket** with **access logging**, **encryption**, and **security best practices**.

---

## What Is CloudFormation?

AWS CloudFormation is a service that lets you **define your infrastructure as code**.

Instead of clicking in the AWS Console:
- You **write a YAML/JSON file**
- AWS reads it
- AWS creates resources **exactly as defined**

Think of it as a **blueprint** for AWS infrastructure.

---

## What Does This Template Create?

This CloudFormation template creates:

1.  A **secure S3 bucket** (main bucket)
2.  A **log bucket** to store access logs
3.  **Encryption at rest**
4.  **HTTPS-only access**
5.  **Public access fully blocked**
6.  **Versioning enabled**
7.  **Deletion protection**

---

## Template Header

```yaml
AWSTemplateFormatVersion: "2010-09-09"
Description: Secure S3 bucket with encryption, versioning, HTTPS enforcement, and access logging
```

###  AWSTemplateFormatVersion
- Fixed AWS version for CloudFormation templates
- Always use: `2010-09-09`

###  Description
- Human-readable explanation
- Helps others understand **what this template does**

---

## Parameters Section

Parameters allow you to **pass values at deployment time**.

```yaml
Parameters:
  BucketName:
    Type: String
    Description: Globally unique name for the main S3 bucket

  LogBucketName:
    Type: String
    Description: Globally unique name for the S3 access log bucket
```

###  Why Parameters Are Important
- S3 bucket names must be **globally unique**
- Hardcoding names can cause failures
- Parameters make templates **reusable**

###  BucketName
- Name of your **main S3 bucket**
- Example: `my-secure-app-bucket-123`

### LogBucketName
- Name of the bucket that stores **access logs**
- Example: `my-secure-app-logs-123`

---

## Resources Section

This is the **heart of the template**.

Everything under `Resources` is **created by AWS**.

---

## Log Bucket (Access Logs)

```yaml
LogBucket:
  Type: AWS::S3::Bucket
  DeletionPolicy: Retain
```

###  What Is This?
- A separate S3 bucket
- Stores **who accessed your main bucket**

###  Why Separate Bucket?
- Security best practice
- Prevents tampering with logs
- Required for audits

---

###  Encryption (Log Bucket)

```yaml
BucketEncryption:
  ServerSideEncryptionConfiguration:
    - ServerSideEncryptionByDefault:
        SSEAlgorithm: AES256
```

- Encrypts logs **automatically**
- Uses AWS‑managed encryption keys
- No manual setup required

---

###  Block Public Access (Log Bucket)

```yaml
PublicAccessBlockConfiguration:
  BlockPublicAcls: true
  IgnorePublicAcls: true
  BlockPublicPolicy: true
  RestrictPublicBuckets: true
```

- Ensures logs are **never public**
- Protects sensitive access data

---

### Ownership Controls

```yaml
OwnershipControls:
  Rules:
    - ObjectOwnership: BucketOwnerEnforced
```

- Disables ACLs completely
- Bucket owner owns **all objects**
- AWS recommended best practice

---

## Main Secure Bucket

```yaml
SecureBucket:
  Type: AWS::S3::Bucket
  DeletionPolicy: Retain
```

###  DeletionPolicy: Retain
- Prevents data loss
- Bucket **will NOT be deleted** if stack is removed

---

###  Versioning

```yaml
VersioningConfiguration:
  Status: Enabled
```

- Keeps multiple versions of objects
- Protects against:
  - Accidental deletes
  - Overwrites
  - Ransomware

---

###  Encryption at Rest

Same as log bucket:

```yaml
SSEAlgorithm: AES256
```

- Automatically encrypts all files

---

###  Public Access Block

Ensures:
- No public reads
- No public writes
- No accidental exposure

---

###  Access Logging

```yaml
LoggingConfiguration:
  DestinationBucketName: !Ref LogBucket
  LogFilePrefix: access-logs/
```

- Logs **every request** to the bucket
- Stored securely in log bucket

---

##  Enforce HTTPS (Bucket Policy)

```yaml
Type: AWS::S3::BucketPolicy
```

###  What Is a Bucket Policy?
- JSON policy attached to bucket
- Controls **who can do what**

---

###  Deny HTTP Access

```yaml
Condition:
  Bool:
    aws:SecureTransport: false
```

- Blocks **unencrypted HTTP requests**
- Allows **only HTTPS (TLS)**

This protects data **in transit**.

---

##  Outputs Section

```yaml
Outputs:
  SecureBucketName:
    Value: !Ref SecureBucket

  LogBucketName:
    Value: !Ref LogBucket
```

###  Why Outputs Matter
- Shows useful information after deployment
- Can be used by:
  - Other CloudFormation stacks
  - CI/CD pipelines

---



