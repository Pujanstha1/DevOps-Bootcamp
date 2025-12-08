# AWS 3-Tier Architecture Documentation

![alt text](<3 Tier Architecture.png>)

### Overview

This architecture represents a highly available, secure, and fault-tolerant 3-tier application stack on AWS, consisting of:

- Web Tier – Public-facing entry point

- Application Tier – Internal processing layer

- Database Tier – Managed relational database (Amazon Aurora)

All resources are deployed inside an Amazon VPC spanning two Availability Zones (AZ1 & AZ2) for redundancy and resilience.

---
## 1. Networking Layer (VPC Architecture)
### Amazon VPC

A dedicated, isolated virtual cloud network that contains the entire application stack.
The VPC includes:

- **Two Availability Zones**

- **Public Subnets** for internet-facing components

- **Private Subnets** for internal compute and database layers

- **Internet Gateway (IGW)** for controlled internet access

This segregation ensures network security, isolation, and controlled communication between tiers.

---

### Public Subnets

These subnets contain resources that need public access, including:

- **Elastic Load Balancer (ELB/ALB)**

The route tables for these subnets forward external traffic to the Internet Gateway, enabling public availability for the Load Balancer only.

---

### Private Subnets

These subnets host:

- Web server EC2 instances (internal facing)

- Application server EC2 instances

- Aurora Primary & Read Replica databases

Private subnets do not have direct internet access, increasing security and complying with best-practice architectures.

---

## 2. Web Tier
### Elastic Load Balancer (ELB/ALB)

The load balancer is deployed in the public subnets and:

- Receives all inbound user traffic

- Distributes traffic across EC2 instances in multiple AZs

- Performs active health checks

- Terminates HTTPS (if configured)

- Routes traffic only to healthy instances

This provides high availability, security, and intelligent traffic distribution.

---
### EC2 Web Servers

Deployed inside **private subnets**, these servers:

- Handle static content or lightweight frontend logic

- Forward backend requests to the Application Tier

- Are protected from direct internet exposure

Security groups ensure that only the Load Balancer can access the Web Tier.

---

## 3. Application Tier
### EC2 Application Servers

Located in private subnets across AZ1 and AZ2, the Application Tier:

- Runs business logic and backend services

- Communicates with the Web Tier over private internal routes

- Connects securely to the Database Tier

Separation of this tier provides:

- Maintainability

- Scalability

- Security

- Resilience across AZs

---

## 4. Database Tier
### Amazon Aurora Cluster

The Database Tier uses Amazon Aurora with:

**Primary DB Instance** – handles write operations

**Read Replica** – offloads read traffic and increases throughput

Both are hosted in private subnets and configured across multiple AZs.

#### **Benefits:**

- Automated failover

- Continuous backups

- High performance storage engine

- Multi-AZ resilience

- Read scaling through replicas

---
## 5. How This Architecture Meets AWS Well-Architected Framework Pillars
### 1. Reliability

- Multi-AZ deployment across all tiers

- Aurora high availability with automatic failover

- ELB health checks remove unhealthy instances from rotation

- Redundant EC2 instances in both AZs

### 2. Fault Tolerance

- Distributed resources across two Availability Zones

- ELB reroutes traffic if an instance or AZ becomes unavailable

- Aurora replication ensures database fault tolerance

- No single point of failure

---
### 3. High Availability

- Load-balanced Web Tier

- Horizontally scalable EC2 instances

- Multi-AZ Aurora databases

- Independent scaling for each tier

---

### 4. Security

- Public subnets used only for the Load Balancer

- All compute and database resources placed in private subnets

- Security Groups enforce least privilege

- VPC isolation prevents unauthorized access

- Encrypted data in transit and at rest (if enabled)

### 5. Operational Excellence

- Clear separation of components improves troubleshooting

- Supports CI/CD workflows

- Monitoring via CloudWatch, VPC Flow Logs, and ALB logs

- Infrastructure as Code (IaC) friendly

### 6. Performance Efficiency

- Independent scaling per tier

- Aurora Read Replica improves read performance

- ELB ensures balanced request distribution

- EC2 instance types can be optimized per workload

---

### 7. Cost Optimization

- Auto Scaling prevents paying for unused capacity

- Aurora read replicas reduce dependence on large primary instance

- Only necessary components are placed in public subnets

- Efficient resource isolation reduces security overhead

---
## Summary

This 3-tier AWS architecture ensures:

- High availability, through multi-AZ redundancy

- Fault tolerance, via load balancing and database replication

- Security, with isolated public and private subnets

- Performance, through scalable layers and Aurora read replicas

- Reliability, through health checks and managed failover

- Cost efficiency, with independent scaling for each tier

It fully aligns with the AWS Well-Architected Framework and represents a production-ready, resilient cloud infrastructure design.