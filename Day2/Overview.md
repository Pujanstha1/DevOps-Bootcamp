# Day 2 – Three Pillars of DevOps

## 1. Culture
- Collaboration, transparency, and shared responsibility.
- Encourages open communication, continuous learning, and a blameless post-mortem culture.
- Goal: Break silos and build a high-trust, high-performance environment.

## 2. Practices
- Continuous Integration & Continuous Delivery (CI/CD)
- Infrastructure as Code (IaC)
- Automated Testing
- Monitoring & Logging
- Version Control
These practices enable reliable, faster, and consistent software delivery.

## 3. Principles: Automation
- Automate repetitive tasks to reduce errors and increase speed.
- Common automation areas: builds, tests, deployments, provisioning, monitoring.
- Drives consistency, predictability, and faster feedback loops.

---

# DevOps Lifecycle – The Infinity Loop

## 1. Plan
- Define features, requirements, and project goals.
- Align business needs with technical solutions.

## 2. Code
- Write application code.
- Use version control systems (e.g., Git) for collaboration and tracking.

## 3. Build
- Compile source code.
- Package the application into artifacts (e.g., JAR, Docker image).

## 4. Test
- Run automated tests: unit, integration, functional, and security.
- Ensure code quality and prevent regressions.

## 5. Release
- Prepare artifacts for deployment.
- Ensure configurations, approvals, and versioning are ready.

## 6. Deploy
- Push the application into production or staging environments.
- Use automated deployment pipelines for consistency.

## 7. Operate
- Manage infrastructure and application runtime.
- Handle scaling, backups, and environment stability.

## 8. Monitor
- Track system performance, logs, alerts, and user experience.
- Collect feedback to improve future development cycles.

---

# Key DevOps Metrics

## DevOps Research and Assessment (DORA) Metrics
1. **Deployment Frequency**  
   - Measures how often code is deployed to production.  

2. **Lead Time for Changes**  
   - Time taken from code commit to production release.  

3. **Mean Time to Recovery (MTTR)**  
   - Average time to recover from a failure in production.  

4. **Change Failure Rate**  
   - Percentage of deployments that cause incidents or failures.

---

# Documentation – DevOps Case Study

## 1. Introduction
- Overview of the project and context.

## 2. Problem Statement
- Key challenges the team aimed to solve with DevOps practices.

## 3. The Solution
- Description of the implemented solution.  
- **Architecture Diagram**: Visual representation of system components and workflow.  
- Explanation of how each component supports DevOps practices.

## 4. Key Metrics
- Deployment Frequency, Lead Time, MTTR, Change Failure Rate, etc.

## 5. Total Cost Optimization (TCO) Analysis
- Assessment of cost savings from DevOps adoption.  

## 6. Conclusion
- Summary of benefits, lessons learned, and future improvements.

---

# Why Linux in DevOps?

- **Dominant OS** for servers and cloud infrastructure.  
- **Open-source, flexible, and powerful** for customization and optimization.  
- **DevOps tools compatibility**: Most tools are built for Linux environments.  
- **Automation & Scripting**: Essential for system management, shell scripting, and task automation.  
- **Supports modern DevOps platforms**: Docker, Kubernetes, CI/CD pipelines, and more run primarily on Linux.

---

# Essential Linux Commands

## 1. Navigation
- `ls` : List files and directories  
- `pwd` : Show current directory path  
- `cd` : Change directory  

## 2. File Operations
- `mkdir` : Create directories  
- `cp` : Copy files or directories  
- `mv` : Move or rename files/directories  

## 3. Viewing Files
- `cat` : Display file contents  
- `less` : View file contents page by page  
- `head` : Show the first lines of a file  
- `tail` : Show the last lines of a file  

## 4. Finding Files and Text
- `find` : Search for files and directories  
- `grep` : Search for text within files  
- `which` : Locate the executable path of a command  

## 5. Processes
- `ps` : Display running processes  
- `top` : Real-time process monitoring  
- `kill` : Terminate a process by PID  

## 6. Networking
- `ping` : Test network connectivity  
- `curl` : Transfer data from or to a server  
- `wget` : Download files from the internet  
- `netstat` : View network connections and statistics  
- `telnet <host> <port>` : Test port connectivity (e.g., RDB, SSH)

---

## Package Management
- **Purpose**: Install, update, remove software.  
- **Debian/Ubuntu**: `apt update`, `apt install nginx`  
- **RHEL/CentOS/Fedora**: `yum` / `dnf`  

---

## Bringing it all together
- **DevOps Culture**: Collaboration, automation, continuous improvement.  
- **DevOps Lifecycle**: Continuous loop from Plan → Monitor.  
- **Linux Foundation**: Powers DevOps infrastructure.  
- **Essential Skills**: Navigation, permissions, package management.  
- **Next Step**: Practice, build pipelines, automate!